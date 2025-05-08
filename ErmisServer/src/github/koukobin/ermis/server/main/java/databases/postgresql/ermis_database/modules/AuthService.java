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
import java.util.EnumMap;
import java.util.Map;
import java.util.Optional;

import com.google.common.base.Throwables;

import github.koukobin.ermis.common.UserDeviceInfo;
import github.koukobin.ermis.common.entry.AddedInfo;
import github.koukobin.ermis.common.entry.CreateAccountInfo;
import github.koukobin.ermis.common.entry.LoginInfo;
import github.koukobin.ermis.common.results.GeneralResult;
import github.koukobin.ermis.server.main.java.configs.DatabaseSettings;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.ErmisDatabase.Insert;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.generators.BackupVerificationCodesGenerator;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.generators.ClientIDGenerator;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.hashing.HashUtil;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.hashing.SimpleHash;

/**
 * @author Ilias Koukovinis
 *
 */
public interface AuthService extends BaseComponent, UserIpManagerService, BackupVerificationCodesModule, AccountRepository {

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

//	/**
//	 * First checks if user meets requirements method before createAccount method
//	 */
//	public CreateAccountResult checkAndCreateAccount1(String username,
//			String password,
//			UserDeviceInfo deviceInfo,
//			String emailAddress) {
//
//		CreateAccountResult resultHolder = new CreateAccountResult(checkIfUserMeetsRequirementsToCreateAccount(username, password, emailAddress));
//
//		if (!resultHolder.getEnumIndicatingResult().resultHolder.isSuccessful()) {
//			return resultHolder;
//		}
//
//		return createAccount(username, password, deviceInfo, emailAddress);
//	}

	default GeneralResult createAccount(String username,
			String password,
			UserDeviceInfo deviceInfo, 
			String emailAddress) {

		// Retrieve and delete a unique client ID. If account creation fails, 
		// the deleted client ID will be regenerated during the next generation.
		int clientID = ClientIDGenerator.retrieveAndDelete(getConn());

		if (clientID == -1) {
			return new GeneralResult(CreateAccountInfo.CreateAccount.Result.DATABASE_MAX_SIZE_REACHED, CreateAccountInfo.CreateAccount.Result.DATABASE_MAX_SIZE_REACHED.resultHolder.isSuccessful());
		}

		String salt;
		String passwordHashResult;
		String[] hashedBackupVerificationCodes;

		{
			SimpleHash passwordHash = HashUtil.createHash(password,
					DatabaseSettings.Client.General.SaltForHashing.SALT_LENGTH,
					DatabaseSettings.Client.Password.Hashing.HASHING_ALGORITHM);

			passwordHashResult = passwordHash.getHashString();
			salt = passwordHash.getSalt();
			
			hashedBackupVerificationCodes = BackupVerificationCodesGenerator.generateHashedBackupVerificationCodes(salt);
		}

		try (PreparedStatement createUser = getConn().prepareStatement("INSERT INTO users ("
				+ "email, password_hash, client_id, backup_verification_codes, salt) "
				+ "VALUES(?, ?, ?, ?, ?);")) {

			createUser.setString(1, emailAddress);
			createUser.setString(2, passwordHashResult);
			createUser.setInt(3, clientID);

			Array backupVerificationCodesArray = getConn().createArrayOf("TEXT", hashedBackupVerificationCodes);
			createUser.setArray(4, backupVerificationCodesArray);
			backupVerificationCodesArray.free();

			createUser.setString(5, salt);

			int resultUpdate = createUser.executeUpdate();
			
			if (resultUpdate == 0) {
				return new GeneralResult(CreateAccountInfo.CreateAccount.Result.ERROR_WHILE_CREATING_ACCOUNT, CreateAccountInfo.CreateAccount.Result.ERROR_WHILE_CREATING_ACCOUNT.resultHolder.isSuccessful());
			}
		} catch (SQLException sqle) {
			logger.trace(Throwables.getStackTraceAsString(sqle));
		}
		
		try (PreparedStatement createProfile = getConn().prepareStatement("INSERT INTO user_profiles ("
				+ "display_name, client_id, about) "
				+ "VALUES(?, ?, ?);")) {

			createProfile.setString(1, username);
			createProfile.setInt(2, clientID);
			createProfile.setString(3, "");

			int resultUpdate = createProfile.executeUpdate();

			if (resultUpdate == 1) {

				insertUserIp(clientID, deviceInfo);
				
				Map<AddedInfo, String> addedInfo = new EnumMap<>(AddedInfo.class);
				addedInfo.put(AddedInfo.PASSWORD_HASH, passwordHashResult);
				addedInfo.put(AddedInfo.BACKUP_VERIFICATION_CODES, String.join("\n", hashedBackupVerificationCodes));
				
				return new GeneralResult(CreateAccountInfo.CreateAccount.Result.SUCCESFULLY_CREATED_ACCOUNT, CreateAccountInfo.CreateAccount.Result.SUCCESFULLY_CREATED_ACCOUNT.resultHolder.isSuccessful(), addedInfo);
			}
		} catch (SQLException sqle) {
			logger.trace(Throwables.getStackTraceAsString(sqle));
		}

		return new GeneralResult(CreateAccountInfo.CreateAccount.Result.ERROR_WHILE_CREATING_ACCOUNT, CreateAccountInfo.CreateAccount.Result.ERROR_WHILE_CREATING_ACCOUNT.resultHolder.isSuccessful());
	}

	/**
	 * Authenticates client and deletes account
	 */
	default GeneralResult deleteAccount(String enteredEmail, String enteredPassword, int clientID) {
		// Verify that the entered email is associated with the provided client ID
		Optional<Integer> associatedClientID = getClientID(enteredEmail);
		if (associatedClientID.isEmpty() || associatedClientID.get() != clientID) {
			return new GeneralResult(LoginInfo.Login.Result.ERROR_WHILE_LOGGING_IN, false);
		}

		// Perform authentication to ensure email and password match
		Optional<String> passwordHash = checkAuthentication(enteredEmail, enteredPassword);

		if (passwordHash.isEmpty()) {
			return new GeneralResult(LoginInfo.Login.Result.INCORRECT_PASSWORD, false);
		}

		try (PreparedStatement pstmt = getConn().prepareStatement("DELETE FROM users WHERE client_id=?;")) {
			pstmt.setInt(1, clientID);

			int resultUpdate = pstmt.executeUpdate();

			if (resultUpdate == 1 /* SUCCESS */) {
				return new GeneralResult(LoginInfo.Login.Result.SUCCESFULLY_LOGGED_IN, false);
			}
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return new GeneralResult(LoginInfo.Login.Result.ERROR_WHILE_LOGGING_IN, false);
	}

	default boolean checkAuthenticationViaHash(String email, String enteredPasswordpasswordHash) {
		String passwordHash = getPasswordHash(email);

		if (passwordHash != null) {
			return passwordHash.equals(enteredPasswordpasswordHash);
		}

		return false;
	}

	default Optional<String> checkAuthentication(String email, String enteredPassword) {
		String passwordHash = getPasswordHash(email);
		SimpleHash enteredPasswordHash = HashUtil.createHash(enteredPassword, getSalt(email), DatabaseSettings.Client.Password.Hashing.HASHING_ALGORITHM);
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

//	public LoginResult checkRequirementsAndLogin(String email, String password, UserDeviceInfo deviceInfo) {
//		Result resultHolder = checkIfUserMeetsRequirementsToLogin(email);
//
//		if (!resultHolder.resultHolder.isSuccessful()) {
//			return new LoginResult(resultHolder);
//		}
//
//		return loginUsingPassword(email, password, deviceInfo);
//	}

	default GeneralResult loginUsingBackupVerificationCode(String email, String backupVerificationCode, UserDeviceInfo deviceInfo) {
		boolean isBackupVerificationCodeCorrect = false;

		int backupVerificationCodesAmount = 0;
		String query = "SELECT array_length(backup_verification_codes::TEXT[], 1) FROM users WHERE ? = ANY(backup_verification_codes) AND email=?;";
		try (PreparedStatement pstmt = getConn().prepareStatement(query)) {
			pstmt.setString(1, backupVerificationCode);
			pstmt.setString(2, email);

			ResultSet rs = pstmt.executeQuery();

			if (rs.next()) {
				isBackupVerificationCodeCorrect = true;
				backupVerificationCodesAmount = rs.getInt(1);
			}
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		if (!isBackupVerificationCodeCorrect) {
			return new GeneralResult(LoginInfo.Login.Result.INCORRECT_BACKUP_VERIFICATION_CODE,
					LoginInfo.Login.Result.INCORRECT_BACKUP_VERIFICATION_CODE.resultHolder.isSuccessful());
		}

		// Add address to user logged in ip addresses
		Insert resultC = insertUserIp(email, deviceInfo);

		if (resultC == Insert.SUCCESSFUL_INSERT) {
			// Remove backup verification code from user; a backup verification
			// code can only be used once
			removeBackupVerificationCode(backupVerificationCode, email);

			// Regenerate backup verification codes if they have become 0
			boolean hasRegeneratedBackupVerificationCodes = false;
			if (backupVerificationCodesAmount - 1 == 0) {
				regenerateBackupVerificationCodes(email);
				hasRegeneratedBackupVerificationCodes = true;
			}

			GeneralResult result;

			// If has regenerated backup verification codes then add the to the
			// result message
			if (hasRegeneratedBackupVerificationCodes) {
				Map<AddedInfo, String> addedInfo = new EnumMap<>(AddedInfo.class);
				addedInfo.put(AddedInfo.BACKUP_VERIFICATION_CODES, backupVerificationCode);

				result = new GeneralResult(LoginInfo.Login.Result.SUCCESFULLY_LOGGED_IN,
						LoginInfo.Login.Result.SUCCESFULLY_LOGGED_IN.resultHolder.isSuccessful(), addedInfo);
			} else {
				result = new GeneralResult(LoginInfo.Login.Result.SUCCESFULLY_LOGGED_IN,
						LoginInfo.Login.Result.SUCCESFULLY_LOGGED_IN.resultHolder.isSuccessful());
			}

			return result;
		}

		return new GeneralResult(LoginInfo.Login.Result.ERROR_WHILE_LOGGING_IN,
				LoginInfo.Login.Result.ERROR_WHILE_LOGGING_IN.resultHolder.isSuccessful());
	}

	default GeneralResult loginUsingPassword(String email, String password, UserDeviceInfo deviceInfo) {
		Optional<String> passwordHashOptional = checkAuthentication(email, password);
		if (passwordHashOptional.isEmpty()) {
			return new GeneralResult(LoginInfo.Login.Result.INCORRECT_PASSWORD, LoginInfo.Login.Result.INCORRECT_PASSWORD.resultHolder.isSuccessful());
		}
		String passwordHash = passwordHashOptional.get();

		// Add address to user logged in ip addresses
		Insert result = insertUserIp(email, deviceInfo);

		if (result != Insert.NOTHING_CHANGED) {
			Map<AddedInfo, String> info = new EnumMap<>(AddedInfo.class);
			info.put(AddedInfo.PASSWORD_HASH, passwordHash);
			return new GeneralResult(LoginInfo.Login.Result.SUCCESFULLY_LOGGED_IN, LoginInfo.Login.Result.SUCCESFULLY_LOGGED_IN.resultHolder.isSuccessful(), info);
		}

		return new GeneralResult(LoginInfo.Login.Result.ERROR_WHILE_LOGGING_IN, LoginInfo.Login.Result.ERROR_WHILE_LOGGING_IN.resultHolder.isSuccessful());
	}
}
