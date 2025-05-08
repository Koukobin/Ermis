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
package github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.modules;

import java.sql.Array;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.google.common.base.Throwables;

import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.generators.BackupVerificationCodesGenerator;

/**
 * @author Ilias Koukovinis
 *
 */
public interface BackupVerificationCodesModule extends BaseComponent, UserCredentialsRepository {

	default int regenerateBackupVerificationCodes(String email) {
		int resultUpdate = 0;

		String salt = getSalt(email);

		String[] hashedBackupVerificationCodes = BackupVerificationCodesGenerator.generateHashedBackupVerificationCodes(salt);

		try (PreparedStatement replaceBackupVerificationCodes = getConn()
				.prepareStatement("UPDATE users SET backup_verification_codes=? WHERE email=?;")) {

			Array backupVerificationCodesArray = getConn().createArrayOf("TEXT", hashedBackupVerificationCodes);
			replaceBackupVerificationCodes.setArray(1, backupVerificationCodesArray);
			backupVerificationCodesArray.free();

			replaceBackupVerificationCodes.setString(2, email);

			resultUpdate = replaceBackupVerificationCodes.executeUpdate();
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return resultUpdate;
	}

	default int removeBackupVerificationCode(String backupVerificationCode, String email) {
		int resultUpdate = 0;

		String sql = "UPDATE users SET backup_verification_codes=array_remove(backup_verification_codes, ?) WHERE email=?";
		try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {
			pstmt.setString(1, backupVerificationCode);
			pstmt.setString(2, email);

			pstmt.executeUpdate();
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return resultUpdate;
	}

	default String[] getBackupVerificationCodesAsStringArray(String email) {

		String[] backupVerificationCodes = null;

		String query = "SELECT backup_verification_codes FROM users WHERE email=?";
		try (PreparedStatement pstmt = getConn().prepareStatement(query)) {
			pstmt.setString(1, email);

			ResultSet rs = pstmt.executeQuery();

			if (rs.next()) {
				backupVerificationCodes = (String[]) rs.getArray(1).getArray();
			}
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return backupVerificationCodes;
	}

	default byte[][] getBackupVerificationCodesAsByteArray(String email) {

		String[] backupVerificationCodesString = getBackupVerificationCodesAsStringArray(email);

		byte[][] backupVerificationCodes = new byte[backupVerificationCodesString.length][];
		for (int i = 0; i < backupVerificationCodesString.length; i++) {
			backupVerificationCodes[i] = backupVerificationCodesString[i].getBytes();
		}

		return backupVerificationCodes;
	}

	default int getNumberOfBackupVerificationCodesLeft(String email) {
		int numberOfBackupVerificationCodesLeft = 0;

		String sql = "SELECT array_length(backup_verification_codes, 1) FROM users WHERE email=?;";
		try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {

			pstmt.setString(1, email);

			ResultSet rs = pstmt.executeQuery();

			if (rs.next()) {
				numberOfBackupVerificationCodesLeft = rs.getInt(1);
			}
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return numberOfBackupVerificationCodesLeft;
	}
}
