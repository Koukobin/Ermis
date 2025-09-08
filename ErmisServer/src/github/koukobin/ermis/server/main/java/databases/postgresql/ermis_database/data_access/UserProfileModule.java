/* Copyright (C) 2025 Ilias Koukovinis <ilias.koukovinis@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */
package github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.data_access;

import java.io.IOException;
import java.net.InetAddress;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Optional;

import com.google.common.base.Throwables;

import github.koukobin.ermis.common.Account;
import github.koukobin.ermis.common.results.ChangeUsernameResult;
import github.koukobin.ermis.common.util.EmptyArrays;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.FilesStorage;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.models.UserIcon;

/**
 * @author Ilias Koukovinis
 *
 */
public interface UserProfileModule extends BaseComponent {

	default ChangeUsernameResult changeDisplayName(int clientID, String newDisplayName) {
		if (!usernameComplexityChecker.estimate(newDisplayName)) {
			return ChangeUsernameResult.REQUIREMENTS_NOT_MET;
		}

		String sql = "UPDATE user_profiles SET display_name=? WHERE client_id=?";
		try (PreparedStatement changeUsername = getConn().prepareStatement(sql)) {
			changeUsername.setString(1, newDisplayName);
			changeUsername.setInt(2, clientID);

			int resultUpdate = changeUsername.executeUpdate();
			if (resultUpdate == 1) {
				return ChangeUsernameResult.SUCCESFULLY_CHANGED_USERNAME;
			}
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return ChangeUsernameResult.ERROR_WHILE_CHANGING_USERNAME;
	}
	
	default Optional<String> getUsername(int clientID) {
		try (PreparedStatement pstmt = getConn()
				.prepareStatement("SELECT display_name FROM user_profiles WHERE client_id=?;")) {

			pstmt.setInt(1, clientID);
			ResultSet rs = pstmt.executeQuery();

			if (rs.next()) {
				return Optional.of(rs.getString(1));
			}
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return Optional.empty();
	}

	default Optional<Integer> getClientID(String email) {
		try (PreparedStatement pstmt = getConn().prepareStatement("SELECT client_id FROM users WHERE email=?;")) {

			pstmt.setString(1, email);
			ResultSet rs = pstmt.executeQuery();

			if (rs.next()) {
				return Optional.of(rs.getInt(1));
			}
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return Optional.empty();
	}

	default Optional<UserIcon> selectUserIcon(int clientID) {

		String sql = "SELECT profile_photo_id FROM user_profiles WHERE client_id = ?;";
		try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {
			pstmt.setInt(1, clientID);

			try (ResultSet rs = pstmt.executeQuery()) {
				if (rs.next()) {
					String iconID = rs.getString(1);
					if (iconID == null) {
						return Optional.of(UserIcon.empty());
					}

					byte[] icon = FilesStorage.loadProfilePhoto(iconID);
					return icon == null ? Optional.of(UserIcon.empty()) : Optional.of(new UserIcon(icon));
				}
			}
		} catch (SQLException sqle) {
			logger.error("Error while trying to retrieve profile photo id from database", sqle); // Shouldn't happen
		} catch (IOException ioe) {
			logger.error("An error occured while trying to retrieve profile photo file", ioe);
			return Optional.empty();
		}

		return Optional.empty();
	}

	default boolean setProfilePhoto(int clientID, byte[] icon) {
		boolean success = false;

		String profilePhotoID;
		try {
			profilePhotoID = FilesStorage.storeProfilePhoto(icon);
		} catch (IOException ioe) {
			logger.error("An error occured while trying to create profile photo file", ioe);
			return success;
		}

		String sql = "UPDATE user_profiles SET profile_photo_id = ? WHERE client_id = ?;";
		try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {
			pstmt.setString(1, profilePhotoID);
			pstmt.setInt(2, clientID);

			success = pstmt.executeUpdate() == 1;
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return success;
	}

	default Optional<Long> getWhenUserLastUpdatedProfile(int clientID) {

		String sql = "SELECT last_updated_at FROM user_profiles WHERE client_id = ?";
		try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {
			pstmt.setInt(1, clientID);

			try (ResultSet rs = pstmt.executeQuery()) {
				if (rs.next()) {
					long lastUpdatedEpochSecond = rs.getTimestamp(1).toInstant().getEpochSecond();
					return Optional.of(lastUpdatedEpochSecond);
				}
			}
		} catch (SQLException sqle) {
			// Shouldn't happen
			logger.error("Error while fetching last profile update of user %d".formatted(clientID), sqle);
		}

		return Optional.empty();
	}

	default Account[] getAccountsAssociatedWithDevice(InetAddress address) {
		Account[] accounts = EmptyArrays.EMPTY_ACCOUNT_ARRAY;

		String query = """
				SELECT up.display_name,
				u.email,
				ui.client_id,
				FROM user_profiles up
				JOIN user_ips ui ON up.client_id = ui.client_id
				JOIN users u ON up.client_id = u.client_id
				WHERE ui.ip_address = ?;
				""";

		try (PreparedStatement pstmt = getConn().prepareStatement(
				query,
				ResultSet.TYPE_SCROLL_SENSITIVE,
				ResultSet.CONCUR_UPDATABLE)) {
			pstmt.setString(1, address.getHostName());
			ResultSet rs = pstmt.executeQuery();
			
			// Move to the last row to get the row count
			rs.last();
			int rowCount = rs.getRow(); // Get total rows
			rs.beforeFirst();

			accounts = new Account[rowCount];

			int i = 0;
			while (rs.next()) {
				String displayName = rs.getString(1);
				String email = rs.getString(2);
				int clientID = rs.getInt(3);
				byte[] profilePhoto = EmptyArrays.EMPTY_BYTE_ARRAY;

				accounts[i] = new Account(profilePhoto, email, displayName, clientID);
				i++;
			}
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return accounts;
	}
}
