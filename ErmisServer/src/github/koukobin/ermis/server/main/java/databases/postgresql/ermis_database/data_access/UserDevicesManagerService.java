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
import java.util.UUID;

import com.google.common.base.Throwables;

import github.koukobin.ermis.common.DeviceType;
import github.koukobin.ermis.common.UserDeviceInfo;
import github.koukobin.ermis.common.util.EmptyArrays;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.DeviceTypeConverter;

/**
 * @author Ilias Koukovinis
 *
 */
public interface UserDevicesManagerService extends BaseComponent, UserProfileModule {

	default Insert insertUserDevice(String email, UserDeviceInfo deviceInfo) {
		return insertUserDevice(getClientID(email).orElseThrow(), deviceInfo);
	}

	default Insert insertUserDevice(int clientID, UserDeviceInfo deviceInfo) {
		String sql = """
				  INSERT INTO user_devices (client_id, device_uuid, device_type, os_name)
				  VALUES (?, ?, ?, ?)
				  ON CONFLICT (client_id, device_uuid) DO NOTHING;
				""";

		try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {
			pstmt.setInt(1, clientID);
			pstmt.setString(2, deviceInfo.deviceUUID().toString());
			pstmt.setInt(3, DeviceTypeConverter.getDeviceTypeAsDatabaseInt(deviceInfo.deviceType()));
			pstmt.setString(4, deviceInfo.osName());

			int affectedRows = pstmt.executeUpdate();
			return affectedRows > 0 ? Insert.SUCCESSFUL_INSERT : Insert.DUPLICATE_ENTRY;
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return Insert.INTERNAL_ERROR;
	}

	default boolean logoutDevice(UUID deviceUUID, int clientID) {
		int resultUpdate = 0;

		String sql = "DELETE FROM user_devices WHERE device_uuid=? AND client_id=?";
		try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {
			pstmt.setString(1, deviceUUID.toString());
			pstmt.setInt(2, clientID);

			resultUpdate = pstmt.executeUpdate();
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return resultUpdate == 1;
	}

	default boolean logoutAllDevices(int clientID) {
		int resultUpdate = 0;

		String sql = "DELETE FROM user_devices WHERE client_id=?";
		try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {
			pstmt.setInt(1, clientID);

			resultUpdate = pstmt.executeUpdate();
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return resultUpdate == 1;
	}

	default boolean isDeviceLoggedIn(String email, UUID deviceUUID) {
		boolean isLoggedIn = false;

		String query = """
				    SELECT 1
				    FROM users u
				    JOIN user_devices ud
				    ON u.client_id = ud.client_id
				    WHERE u.email = ? AND ud.device_uuid = ?;
				""";
		try (PreparedStatement pstmt = getConn().prepareStatement(query)) {
			pstmt.setString(1, email);
			pstmt.setString(2, deviceUUID.toString());

			ResultSet rs = pstmt.executeQuery();
			isLoggedIn = rs.next();
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return isLoggedIn;
	}

	default UserDeviceInfo[] getUserDevices(int clientID) {
		UserDeviceInfo[] userDevices = EmptyArrays.EMPTY_DEVICE_INFO_ARRAY;

		try (PreparedStatement pstmt = getConn().prepareStatement(
				"SELECT device_uuid, device_type, os_name FROM user_devices WHERE client_id=?",
				ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE)) {

			pstmt.setInt(1, clientID);
			ResultSet rs = pstmt.executeQuery();

			// Move to the last row to get the row count
			rs.last();
			int rowCount = rs.getRow(); // Get total rows
			rs.beforeFirst();

			userDevices = new UserDeviceInfo[rowCount];

			int i = 0;
			while (rs.next()) {
				UUID deviceUUID = UUID.fromString(rs.getString("device_uuid"));
				DeviceType deviceType = DeviceTypeConverter.getDatabaseIntAsDeviceType(rs.getInt("device_type"));
				String osName = rs.getString("os_name");
				userDevices[i] = new UserDeviceInfo(deviceUUID, deviceType, osName);
				i++;
			}
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return userDevices;
	}
}
