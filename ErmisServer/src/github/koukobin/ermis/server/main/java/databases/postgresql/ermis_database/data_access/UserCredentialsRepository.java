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

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.google.common.base.Throwables;

/**
 * @author Ilias Koukovinis
 *
 */
public interface UserCredentialsRepository extends BaseComponent {

	default String getEmailAddress(int clientID) {

		String emailAddress = null;

		try (PreparedStatement getEmailAddress = getConn()
				.prepareStatement("SELECT email FROM users WHERE client_id=?;")) {
			getEmailAddress.setInt(1, clientID);
			ResultSet rs = getEmailAddress.executeQuery();

			if (rs.next()) {
				emailAddress = rs.getString(1);
			}
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return emailAddress;
	}

	default String getPasswordHash(String email) {
		String passwordHash = null;

		try (PreparedStatement pstmt = getConn().prepareStatement("SELECT password_hash FROM users WHERE email=?")) {
			pstmt.setString(1, email);
			ResultSet rs = pstmt.executeQuery();
			if (rs.next()) {
				passwordHash = rs.getString(1);
			}
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return passwordHash;
	}

	default String getPasswordHash(int clientID) {

		String passwordHash = null;

		try (PreparedStatement pstmt = getConn().prepareStatement("SELECT password_hash FROM users WHERE client_id=?")) {
			pstmt.setInt(1, clientID);
			ResultSet rs = pstmt.executeQuery();

			if (rs.next()) {
				passwordHash = rs.getString(1);
			}
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return passwordHash;
	}

	default String getSalt(String email) {

		String salt = null;

		try (PreparedStatement getPasswordHash = getConn().prepareStatement("SELECT salt FROM users WHERE email=?")) {
			getPasswordHash.setString(1, email);

			ResultSet rs = getPasswordHash.executeQuery();
			if (rs.next()) {
				salt = rs.getString(1);
			}
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return salt;
	}

	default String getSalt(int clientID) {

		String salt = null;

		try (PreparedStatement getPasswordHash = getConn()
				.prepareStatement("SELECT salt FROM users WHERE client_id=?")) {

			getPasswordHash.setInt(1, clientID);

			ResultSet rs = getPasswordHash.executeQuery();
			if (rs.next()) {
				salt = rs.getString(1);
			}
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return salt;
	}
	
}
