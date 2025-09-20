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

import java.sql.Array;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.EnumMap;
import java.util.Map;
import java.util.Optional;

import com.google.common.base.Throwables;

import github.koukobin.ermis.common.UserDeviceInfo;
import github.koukobin.ermis.common.entry.AddedInfo;
import github.koukobin.ermis.common.entry.CreateAccountInfo;
import github.koukobin.ermis.common.entry.LoginInfo;
import github.koukobin.ermis.common.results.GeneralResult;
import github.koukobin.ermis.common.util.EmptyArrays;
import github.koukobin.ermis.server.main.java.configs.DatabaseSettings;
import github.koukobin.ermis.server.main.java.configs.DatabaseSettings.Client.BackupVerificationCodes;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.generators.BackupVerificationCodesGenerator;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.generators.ClientIDGenerator;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.hashing.HashUtil;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.hashing.SimpleHash;

/**
 * @author Ilias Koukovinis
 *
 */
public interface AuthService
		extends BaseComponent, UserDevicesManagerService, BackupVerificationCodesModule, AccountRepository {

	default CreateAccountInfo.CredentialValidation.Result checkIfUserMeetsRequirementsToCreateAccount(
			String username, 
			String password,
			String emailAddress) {

		// Check if username and password meets the requirements
		if (!usernameComplexityChecker.estimate(username)) {
			return CreateAccountInfo.CredentialValidation.Result.USERNAME_REQUIREMENTS_NOT_MET;
		}

		if (!passwordComplexityChecker.estimate(password)) {
			return CreateAccountInfo.CredentialValidation.Result.PASSWORD_REQUIREMENTS_NOT_MET;
		}

		if (accountWithEmailExists(emailAddress)) {
			return CreateAccountInfo.CredentialValidation.Result.EMAIL_ALREADY_USED;
		}

		return CreateAccountInfo.CredentialValidation.Result.SUCCESFULLY_EXCHANGED_CREDENTIALS;
	}

	default GeneralResult createAccount(String username,
			String password,
			UserDeviceInfo deviceInfo, 
			String emailAddress) {

		// Retrieve and delete a unique client ID. If account creation fails,
		// the deleted client ID will be regenerated during the next generation.
		int clientID = ClientIDGenerator.retrieveAndDelete(getConn());

		if (clientID == -1) {
			return new GeneralResult(CreateAccountInfo.CreateAccount.Result.DATABASE_MAX_SIZE_REACHED);
		}

		final String salt;
		final String passwordHash;
		String[] rawBackupVerificationCodes;
		String[] hashedBackupVerificationCodes;

		{
			SimpleHash passwordSimpleHash = HashUtil.createHash(password,
					DatabaseSettings.Client.General.SaltForHashing.SALT_LENGTH,
					DatabaseSettings.Client.Password.Hashing.HASHING_ALGORITHM);

			passwordHash = passwordSimpleHash.getHashString();
			salt = passwordSimpleHash.getSalt();

			rawBackupVerificationCodes = BackupVerificationCodesGenerator.generateRawBackupVerificationCodes();
			hashedBackupVerificationCodes = BackupVerificationCodesGenerator.hashBackupCodes(rawBackupVerificationCodes, salt);
		}

		String createUserQuery = """
				INSERT INTO users
				(email, password_hash, client_id, backup_verification_codes, salt)
				VALUES(?, ?, ?, ?, ?);
				""";
		try (PreparedStatement createUser = getConn().prepareStatement(createUserQuery)) {
			createUser.setString(1, emailAddress);
			createUser.setString(2, passwordHash);
			createUser.setInt(3, clientID);

			Array backupVerificationCodesArray = getConn().createArrayOf("TEXT", hashedBackupVerificationCodes);
			createUser.setArray(4, backupVerificationCodesArray);
			backupVerificationCodesArray.free();

			createUser.setString(5, salt);

			int resultUpdate = createUser.executeUpdate();

			if (resultUpdate == 0) {
				return new GeneralResult(CreateAccountInfo.CreateAccount.Result.ERROR_WHILE_CREATING_ACCOUNT);
			}
		} catch (SQLException sqle) {
			logger.trace(Throwables.getStackTraceAsString(sqle));
		}

		String createProfileQuery = """
				INSERT INTO user_profiles (display_name, client_id, about) VALUES(?, ?, ?);
				""";
		try (PreparedStatement createProfile = getConn().prepareStatement(createProfileQuery)) {
			createProfile.setString(1, username);
			createProfile.setInt(2, clientID);
			createProfile.setString(3, "");

			int resultUpdate = createProfile.executeUpdate();

			if (resultUpdate == 1) {
				insertUserDevice(clientID, deviceInfo);

				Map<AddedInfo, String> addedInfo = new EnumMap<>(AddedInfo.class);
				addedInfo.put(AddedInfo.PASSWORD_HASH, passwordHash);
				addedInfo.put(AddedInfo.BACKUP_VERIFICATION_CODES, String.join("\n", rawBackupVerificationCodes));
				addedInfo.put(AddedInfo.DEVICE_UUID, deviceInfo.deviceUUID().toString());

				return new GeneralResult(CreateAccountInfo.CreateAccount.Result.SUCCESFULLY_CREATED_ACCOUNT, addedInfo);
			}
		} catch (SQLException sqle) {
			logger.trace(Throwables.getStackTraceAsString(sqle));
		}

		return new GeneralResult(CreateAccountInfo.CreateAccount.Result.ERROR_WHILE_CREATING_ACCOUNT);
	}

	/**
	 * Authenticates client and deletes account
	 */
	default GeneralResult deleteAccount(String enteredEmail, String enteredPassword, int clientID) {
		// Verify that the entered email is associated with the provided client ID
		Optional<Integer> associatedClientID = getClientID(enteredEmail);
		if (associatedClientID.isEmpty() || associatedClientID.get() != clientID) {
			return new GeneralResult(LoginInfo.Login.Result.ERROR_WHILE_LOGGING_IN);
		}

		// Perform authentication to ensure email and password match
		Optional<String> passwordHash = checkAuthentication(enteredEmail, enteredPassword);
		if (passwordHash.isEmpty()) {
			return new GeneralResult(LoginInfo.Login.Result.INCORRECT_PASSWORD);
		}

		try (PreparedStatement pstmt = getConn().prepareStatement("DELETE FROM users WHERE client_id=?;")) {
			pstmt.setInt(1, clientID);

			int resultUpdate = pstmt.executeUpdate();
			if (resultUpdate == 1 /* SUCCESS */) {
				return new GeneralResult(LoginInfo.Login.Result.SUCCESFULLY_LOGGED_IN);
			}
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return new GeneralResult(LoginInfo.Login.Result.ERROR_WHILE_LOGGING_IN);
	}

	default boolean checkAuthenticationViaHash(String email, String enteredPasswordHash) {
		String passwordHash = getPasswordHash(email);

		if (passwordHash != null) {
			return passwordHash.equals(enteredPasswordHash);
		}

		return false;
	}

	default Optional<String> checkAuthentication(String email, String enteredPassword) {
		String passwordHash = getPasswordHash(email);
		SimpleHash enteredPasswordHash = HashUtil.createHash(enteredPassword,
				getSalt(email),
				DatabaseSettings.Client.Password.Hashing.HASHING_ALGORITHM);

		return passwordHash.equals(enteredPasswordHash.getHashString())
				? Optional.of(passwordHash)
				: Optional.ofNullable(null);
	}

	default LoginInfo.CredentialsExchange.Result checkIfUserMeetsRequirementsToLogin(String emailAddress) {
		if (!accountWithEmailExists(emailAddress)) {
			return LoginInfo.CredentialsExchange.Result.ACCOUNT_DOESNT_EXIST;
		}

		return LoginInfo.CredentialsExchange.Result.SUCCESFULLY_EXCHANGED_CREDENTIALS;
	}

	default GeneralResult loginUsingBackupVerificationCode(String email, String backupVerificationCode, UserDeviceInfo deviceInfo) {
		boolean isCodeCorrect = false;

		String enteredHashedCode = HashUtil.createHash(
				backupVerificationCode, 
				getSalt(email),
				BackupVerificationCodes.Hashing.HASHING_ALGORITHM)
				.getHashString();

		String query = """
				SELECT 1
				FROM users
				WHERE ? = ANY(backup_verification_codes)
				AND email=?;
				""";
		try (PreparedStatement pstmt = getConn().prepareStatement(query)) {
			pstmt.setString(1, enteredHashedCode);
			pstmt.setString(2, email);

			ResultSet rs = pstmt.executeQuery();
			isCodeCorrect = rs.next();
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		if (!isCodeCorrect) {
			return new GeneralResult(LoginInfo.Login.Result.INCORRECT_BACKUP_VERIFICATION_CODE);
		}

		Insert result = insertUserDevice(email, deviceInfo);
		if (result == Insert.INTERNAL_ERROR) {
			return new GeneralResult(LoginInfo.Login.Result.ERROR_WHILE_LOGGING_IN);
		}

		// Remove backup verification code; a backup verification
		// code can only be used once.
		int codesLeftAmount = removeBackupVerificationCode(enteredHashedCode, email).orElse(0);

		Map<AddedInfo, String> addedInfo = new EnumMap<>(AddedInfo.class);
		addedInfo.put(AddedInfo.PASSWORD_HASH, getPasswordHash(email));
		addedInfo.put(AddedInfo.DEVICE_UUID, deviceInfo.deviceUUID().toString());

		if (codesLeftAmount == 0) {
			String[] codesArray = regenerateBackupVerificationCodes(email).orElse(EmptyArrays.EMPTY_STRING_ARRAY);
			String codesString = String.join("\n", codesArray);

			addedInfo.put(AddedInfo.BACKUP_VERIFICATION_CODES, codesString);
		}

		return new GeneralResult(LoginInfo.Login.Result.SUCCESFULLY_LOGGED_IN, addedInfo);
	}

	default GeneralResult loginUsingPassword(String email, String password, UserDeviceInfo deviceInfo) {
		Optional<String> passwordHashOptional = checkAuthentication(email, password);
		if (passwordHashOptional.isEmpty()) {
			return new GeneralResult(LoginInfo.Login.Result.INCORRECT_PASSWORD);
		}
		String passwordHash = passwordHashOptional.get();

		Insert result = insertUserDevice(email, deviceInfo);
		if (result != Insert.INTERNAL_ERROR) {
			Map<AddedInfo, String> info = new EnumMap<>(AddedInfo.class);
			info.put(AddedInfo.PASSWORD_HASH, passwordHash);
			info.put(AddedInfo.DEVICE_UUID, deviceInfo.deviceUUID().toString());

			return new GeneralResult(LoginInfo.Login.Result.SUCCESFULLY_LOGGED_IN, info);
		}

		return new GeneralResult(LoginInfo.Login.Result.ERROR_WHILE_LOGGING_IN);
	}
}
