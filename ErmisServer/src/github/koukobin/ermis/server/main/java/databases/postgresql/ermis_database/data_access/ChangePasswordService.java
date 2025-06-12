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
import java.sql.SQLException;
import java.util.Optional;

import com.google.common.base.Throwables;

import github.koukobin.ermis.common.entry.LoginInfo;
import github.koukobin.ermis.common.results.ChangePasswordResult;
import github.koukobin.ermis.common.results.GeneralResult;
import github.koukobin.ermis.server.main.java.configs.DatabaseSettings;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.hashing.HashUtil;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.hashing.SimpleHash;

/**
 * @author Ilias Koukovinis
 *
 */
public interface ChangePasswordService extends BaseComponent, UserProfileModule, UserCredentialsRepository {

	default GeneralResult changePassword(String enteredEmail, String newPassword, int clientID) {
		// Verify that the entered email is associated with the provided client ID
		Optional<Integer> associatedClientID = getClientID(enteredEmail);
		if (associatedClientID.isEmpty() || associatedClientID.get() != clientID) {
			return new GeneralResult(LoginInfo.Login.Result.ERROR_WHILE_LOGGING_IN);
		}

		if (!passwordComplexityChecker.estimate(newPassword)) {
			return new GeneralResult(ChangePasswordResult.SUCCESFULLY_CHANGED_PASSWORD);
		}

		String salt = getSalt(enteredEmail);
		SimpleHash passwordHash = HashUtil.createHash(newPassword, salt, DatabaseSettings.Client.Password.Hashing.HASHING_ALGORITHM);

		try (PreparedStatement changePassword = getConn()
				.prepareStatement("UPDATE users SET password_hash=? WHERE email=?")) {

			changePassword.setString(1, passwordHash.getHashString());
			changePassword.setString(2, enteredEmail);

			int resultUpdate = changePassword.executeUpdate();
			if (resultUpdate == 1) {
				return new GeneralResult(ChangePasswordResult.SUCCESFULLY_CHANGED_PASSWORD);
			}
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return new GeneralResult(ChangePasswordResult.ERROR_WHILE_CHANGING_PASSWORD);
	}

}
