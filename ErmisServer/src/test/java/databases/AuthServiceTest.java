/* Copyright (C) 2026 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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
package test.java.databases;

import main.java.io.github.koukobin.ermis.common.entry.AddedInfo;
import main.java.io.github.koukobin.ermis.common.entry.CreateAccountInfo;
import main.java.io.github.koukobin.ermis.common.entry.LoginInfo;
import main.java.io.github.koukobin.ermis.common.results.GeneralResult;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.ErmisDatabase;

import org.junit.jupiter.api.*;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static test.java.databases.Utils.*;

/**
 * @author Ilias Koukovinis
 *
 */
class AuthServiceTest extends BaseIntegrationTest {

	private static final String VALID_EMAIL    = "testuser@example.com";
    private static final String VALID_PASSWORD = "Str0ng!Pass#2024";
    private static final String VALID_USERNAME = "TestUser";

    private static final String ALT_EMAIL      = "other@example.com";
    private static final String ALT_PASSWORD   = "An0ther!Pass#9999";
    private static final String ALT_USERNAME   = "OtherUser";

	private static ErmisDatabase.GeneralPurposeDBConnection conn;

	@BeforeAll
	static void openConnection() throws Exception {
		conn = ErmisDatabase.getGeneralPurposeConnection();
		assertNotNull(conn, "Database connection must not be null – check DB config");

		nukeAll(conn);
	}

	@BeforeEach
	void wipeAuthTables() throws Exception {
		nukeAll(conn);
	}

	@AfterAll
    static void closeConnection() throws Exception {
		nukeAll(conn);
        if (conn != null) conn.close();
	}

	// =========================================================================

	@Nested
	@DisplayName("accountWithEmailExists")
	class AccountWithEmailExistsTests {

		@Test
		@DisplayName("returns false when no account exists for that email")
		void noAccount_returnsFalse() {
			assertFalse(conn.accountWithEmailExists(VALID_EMAIL));
		}

		@Test
		@DisplayName("returns true after an account is created with that email")
		void afterCreate_returnsTrue() {
			conn.createAccount(VALID_USERNAME, VALID_PASSWORD, uniqueDevice(), VALID_EMAIL);

			assertTrue(conn.accountWithEmailExists(VALID_EMAIL));
		}

		@Test
		@DisplayName("returns false for a different email even when another account exists")
		void differentEmail_returnsFalse() {
			conn.createAccount(VALID_USERNAME, VALID_PASSWORD, uniqueDevice(), VALID_EMAIL);

			assertFalse(conn.accountWithEmailExists(ALT_EMAIL));
		}

	}

	// =========================================================================

	@Nested
	@DisplayName("checkAuthentication")
	class CheckAuthenticationTests {

		@Test
		@DisplayName("returns non-empty Optional for valid credentials")
		void validCredentials_returnsPresent() {
			conn.createAccount(VALID_USERNAME, VALID_PASSWORD, uniqueDevice(), VALID_EMAIL);

			Optional<String> result = conn.checkAuthentication(VALID_EMAIL, VALID_PASSWORD);
			assertTrue(result.isPresent(), "Valid credentials must return a present Optional");
		}

		@Test
		@DisplayName("returned token/hash is non-blank")
		void validCredentials_tokenIsNotBlank() {
			conn.createAccount(VALID_USERNAME, VALID_PASSWORD, uniqueDevice(), VALID_EMAIL);

			Optional<String> result = conn.checkAuthentication(VALID_EMAIL, VALID_PASSWORD);
			assertTrue(result.isPresent());
			assertFalse(result.get().isBlank(), "Returned token must not be blank");
		}

		@Test
		@DisplayName("returns empty Optional for wrong password")
		void wrongPassword_returnsEmpty() {
			conn.createAccount(VALID_USERNAME, VALID_PASSWORD, uniqueDevice(), VALID_EMAIL);

			Optional<String> result = conn.checkAuthentication(VALID_EMAIL, "WrongPass!");
			assertFalse(result.isPresent(), "Wrong password must return empty Optional");
		}

		@Test
		@DisplayName("returns empty Optional for unknown email")
		void unknownEmail_returnsEmpty() {
			Optional<String> result = conn.checkAuthentication("nobody@example.com", VALID_PASSWORD);
			assertFalse(result.isPresent());
		}

		@Test
		@DisplayName("returns empty Optional when password is empty string")
		void emptyPassword_returnsEmpty() {
			conn.createAccount(VALID_USERNAME, VALID_PASSWORD, uniqueDevice(), VALID_EMAIL);

			Optional<String> result = conn.checkAuthentication(VALID_EMAIL, "");
			assertFalse(result.isPresent());
		}
	}

	// =========================================================================

	@Nested
	@DisplayName("checkAuthenticationViaHash")
	class CheckAuthenticationViaHashTests {

		@Test
		@DisplayName("returns true for the correct hash of an existing account")
		void correctHash_returnsTrue() {
			conn.createAccount(VALID_USERNAME, VALID_PASSWORD, uniqueDevice(), VALID_EMAIL);
			// Obtain the stored hash to use as the credential
			Optional<String> hashOpt = conn.checkAuthentication(VALID_EMAIL, VALID_PASSWORD);
			assertTrue(hashOpt.isPresent(), "Precondition: authentication must succeed");

			assertTrue(conn.checkAuthenticationViaHash(VALID_EMAIL, hashOpt.get()));
		}

		@Test
		@DisplayName("returns false for a wrong hash")
		void wrongHash_returnsFalse() {
			conn.createAccount(VALID_USERNAME, VALID_PASSWORD, uniqueDevice(), VALID_EMAIL);

			assertFalse(conn.checkAuthenticationViaHash(VALID_EMAIL, "totally-wrong-hash"));
		}

		@Test
		@DisplayName("returns false for unknown email")
		void unknownEmail_returnsFalse() {
			assertFalse(conn.checkAuthenticationViaHash("ghost@example.com", "anyhash"));
		}

		@Test
		@DisplayName("returns false for blank hash")
		void blankHash_returnsFalse() {
			conn.createAccount(VALID_USERNAME, VALID_PASSWORD, uniqueDevice(), VALID_EMAIL);

			assertFalse(conn.checkAuthenticationViaHash(VALID_EMAIL, ""));
		}
	}

	// =========================================================================

	@Nested
	@DisplayName("checkIfUserMeetsRequirementsToCreateAccount")
	class CheckIfUserMeetsRequirementsToCreateAccountTests {

		@Test
		@DisplayName("returns success result for valid, unused credentials")
		void validCredentials_returnsSuccess() {
			CreateAccountInfo.CredentialValidation.Result result =
                    conn.checkIfUserMeetsRequirementsToCreateAccount(
                    		VALID_USERNAME, VALID_PASSWORD, VALID_EMAIL);

            assertTrue(result.isSuccessful(),
                    "Valid, unused credentials should meet all creation requirements");
		}

		@Test
		@DisplayName("returns failure when email is already registered")
		void duplicateEmail_returnsDuplicateEmailError() {
			conn.createAccount(VALID_USERNAME, VALID_PASSWORD, uniqueDevice(), VALID_EMAIL);

			CreateAccountInfo.CredentialValidation.Result result =
                    conn.checkIfUserMeetsRequirementsToCreateAccount(
                    		ALT_USERNAME, ALT_PASSWORD, VALID_EMAIL);

			assertFalse(result.isSuccessful(), "Duplicate email must fail validation");
		}

		@Test
		@DisplayName("returns failure for a blank password")
		void blankPassword_returnsFailure() {
			CreateAccountInfo.CredentialValidation.Result result =
                    conn.checkIfUserMeetsRequirementsToCreateAccount(
                    		VALID_USERNAME, "", VALID_EMAIL);

			assertFalse(result.isSuccessful(), "Blank password should fail validation");
		}

		@Test
		@DisplayName("returns failure for a blank username")
		void blankUsername_returnsFailure() {
            CreateAccountInfo.CredentialValidation.Result result =
                    conn.checkIfUserMeetsRequirementsToCreateAccount(
                    		 "", VALID_PASSWORD, VALID_EMAIL);

			assertFalse(result.isSuccessful(), "Blank username should fail validation");
		}
	}

	// =========================================================================

	@Nested
	@DisplayName("createAccount")
	class CreateAccountTests {

		@Test
		@DisplayName("succeeds for valid, unique credentials")
		void validCredentials_succeeds() {
			GeneralResult result =
                    conn.createAccount(VALID_USERNAME, VALID_PASSWORD, uniqueDevice(), VALID_EMAIL);

			assertTrue(result.isSuccess(), "Account creation with valid data must succeed");
		}

		@Test
		@DisplayName("account is findable by email after creation")
		void afterCreate_accountExists() {
			conn.createAccount(VALID_USERNAME, VALID_PASSWORD, uniqueDevice(), VALID_EMAIL);

			assertTrue(conn.accountWithEmailExists(VALID_EMAIL));
		}

		@Test
		@DisplayName("fails when email is already taken")
		void duplicateEmail_fails() {
			conn.createAccount(VALID_USERNAME, VALID_PASSWORD, uniqueDevice(), VALID_EMAIL);

			GeneralResult duplicate =
                    conn.createAccount(ALT_USERNAME, ALT_PASSWORD, uniqueDevice(), VALID_EMAIL);

			assertFalse(duplicate.isSuccess(), "Creating a second account with the same email must fail");
		}

		@Test
        @DisplayName("different emails can be registered independently")
        void differentEmails_bothSucceed() {
            GeneralResult first  = conn.createAccount(VALID_USERNAME, VALID_PASSWORD, uniqueDevice(), VALID_EMAIL);
            GeneralResult second = conn.createAccount(ALT_USERNAME,   ALT_PASSWORD,   uniqueDevice(), ALT_EMAIL);

            assertTrue(first.isSuccess(),  "First account must be created successfully");
            assertTrue(second.isSuccess(), "Second account with different email must also succeed");
        }
    }

	// =========================================================================

	@Nested
	@DisplayName("deleteAccount")
	class DeleteAccountTests {

		@Test
		@DisplayName("succeeds when credentials and clientID are correct")
		void validCredentials_succeeds() {
			conn.createAccount(VALID_USERNAME, VALID_PASSWORD, uniqueDevice(), VALID_EMAIL);
			int clientID = resolveClientID(VALID_EMAIL, conn);

			GeneralResult result = conn.deleteAccount(VALID_EMAIL, VALID_PASSWORD, clientID);

			assertTrue(result.isSuccess(), "Deleting own account with correct credentials must succeed");
		}

		@Test
		@DisplayName("account no longer exists after deletion")
		void afterDelete_accountGone() {
			conn.createAccount(VALID_USERNAME, VALID_PASSWORD, uniqueDevice(), VALID_EMAIL);
			int clientID = resolveClientID(VALID_EMAIL, conn);

			conn.deleteAccount(VALID_EMAIL, VALID_PASSWORD, clientID);

			assertFalse(conn.accountWithEmailExists(VALID_EMAIL),
					"Email must not exist in the database after account deletion");
		}

		@Test
		@DisplayName("fails when password is wrong")
		void wrongPassword_fails() {
			conn.createAccount(VALID_USERNAME, VALID_PASSWORD, uniqueDevice(), VALID_EMAIL);
			int clientID = resolveClientID(VALID_EMAIL, conn);

			GeneralResult result = conn.deleteAccount(VALID_EMAIL, "WrongPass!", clientID);

			assertFalse(result.isSuccess(), "Wrong password must prevent account deletion");
		}

		@Test
		@DisplayName("fails when clientID does not match the email")
		void mismatchedClientID_fails() {
            conn.createAccount(VALID_USERNAME, VALID_PASSWORD, uniqueDevice(), VALID_EMAIL);
            conn.createAccount(ALT_USERNAME,   ALT_PASSWORD,   uniqueDevice(), ALT_EMAIL);

			int wrongClientID = resolveClientID(ALT_EMAIL, conn);

			GeneralResult result = conn.deleteAccount(VALID_EMAIL, VALID_PASSWORD, wrongClientID);

			assertFalse(result.isSuccess(), "Mismatched clientID must prevent account deletion");
		}
	}

	// =========================================================================

	@Nested
	@DisplayName("checkIfUserMeetsRequirementsToLogin")
	class CheckIfUserMeetsRequirementsToLoginTests {

		@Test
		@DisplayName("returns success for a registered email")
		void registeredEmail_returnsSuccess() {
			conn.createAccount(VALID_USERNAME, VALID_PASSWORD, uniqueDevice(), VALID_EMAIL);

			LoginInfo.CredentialsExchange.Result result =
					conn.checkIfUserMeetsRequirementsToLogin(VALID_EMAIL);

			assertTrue(result.isSuccessful(), "Registered email must pass login pre-check");
		}

		@Test
		@DisplayName("returns failure for an unknown email")
		void unknownEmail_returnsFailure() {
			LoginInfo.CredentialsExchange.Result result =
                    conn.checkIfUserMeetsRequirementsToLogin("nobody@example.com");

			assertFalse(result.isSuccessful(), "Unknown email must fail login pre-check");
		}

		@Test
		@DisplayName("returns failure for a malformed email")
		void malformedEmail_returnsFailure() {
			LoginInfo.CredentialsExchange.Result result =
                    conn.checkIfUserMeetsRequirementsToLogin("not-an-email");

			assertFalse(result.isSuccessful(), "Malformed email must fail login pre-check");
		}

		@Test
		@DisplayName("returns failure for a blank email")
		void blankEmail_returnsFailure() {
			LoginInfo.CredentialsExchange.Result result =
                    conn.checkIfUserMeetsRequirementsToLogin("");

			assertFalse(result.isSuccessful(), "Blank email must fail login pre-check");
		}
	}

	// =========================================================================

	@Nested
	@DisplayName("loginUsingPassword")
	class LoginUsingPasswordTests {

		@Test
		@DisplayName("succeeds with correct credentials")
		void correctCredentials_succeeds() {
			conn.createAccount(VALID_USERNAME, VALID_PASSWORD, uniqueDevice(), VALID_EMAIL);

			GeneralResult result =
                    conn.loginUsingPassword(VALID_EMAIL, VALID_PASSWORD, uniqueDevice());

			assertTrue(result.isSuccess(), "Login with correct credentials must succeed");
		}

		@Test
		@DisplayName("fails with wrong password")
		void wrongPassword_fails() {
			conn.createAccount(VALID_USERNAME, VALID_PASSWORD, uniqueDevice(), VALID_EMAIL);

			GeneralResult result =
                    conn.loginUsingPassword(VALID_EMAIL, "WrongPass!", uniqueDevice());

			assertFalse(result.isSuccess(), "Login with wrong password must fail");
		}

		@Test
		@DisplayName("fails for an unregistered email")
		void unregisteredEmail_fails() {
			GeneralResult result =
                    conn.loginUsingPassword("ghost@example.com", VALID_PASSWORD, uniqueDevice());

			assertFalse(result.isSuccess(), "Login for unregistered email must fail");
		}

		@Test
		@DisplayName("succeeds on repeated logins from different devices")
		void multipleDevices_eachLoginSucceeds() {
			conn.createAccount(VALID_USERNAME, VALID_PASSWORD, uniqueDevice(), VALID_EMAIL);

			GeneralResult first = conn.loginUsingPassword(VALID_EMAIL, VALID_PASSWORD, uniqueDevice());
			GeneralResult second = conn.loginUsingPassword(VALID_EMAIL, VALID_PASSWORD, uniqueDevice());

			assertTrue(first.isSuccess(), "First login must succeed");
			assertTrue(second.isSuccess(), "Second login from a different device must also succeed");
		}
	}

	// =========================================================================

	@Nested
	@DisplayName("loginUsingBackupVerificationCode")
	class LoginUsingBackupVerificationCodeTests {

		@Test
		@DisplayName("succeeds with a valid backup code")
		void validCode_succeeds() {
			GeneralResult caResult = conn.createAccount(VALID_USERNAME, VALID_PASSWORD, uniqueDevice(), VALID_EMAIL);
			String backupCodes = caResult.getAddedInfo().get(AddedInfo.BACKUP_VERIFICATION_CODES);

			assumeNotNull(backupCodes, "Precondition: account must have at least one backup code");

			String backupCode = backupCodes.split("\n")[0];

			GeneralResult result =
                    conn.loginUsingBackupVerificationCode(VALID_EMAIL, backupCode, uniqueDevice());

			assertTrue(result.isSuccess(), "Login with a valid backup code failed: " + result.getIDable());
		}

		@Test
		@DisplayName("fails when the same backup code is used twice")
		void reusedCode_fails() {
			GeneralResult caResult = conn.createAccount(VALID_USERNAME, VALID_PASSWORD, uniqueDevice(), VALID_EMAIL);
			String backupCodes = caResult.getAddedInfo().get(AddedInfo.BACKUP_VERIFICATION_CODES);

			assumeNotNull(backupCodes, "Precondition: account must have at least one backup code");

			String backupCode = backupCodes.split("\n")[0];

			conn.loginUsingBackupVerificationCode(VALID_EMAIL, backupCode, uniqueDevice());
			GeneralResult secondUse =
                    conn.loginUsingBackupVerificationCode(VALID_EMAIL, backupCode, uniqueDevice());

			assertFalse(secondUse.isSuccess(), "Backup codes must be single-use");
		}

		@Test
		@DisplayName("fails with an invalid backup code")
		void invalidCode_fails() {
			conn.createAccount(VALID_USERNAME, VALID_PASSWORD, uniqueDevice(), VALID_EMAIL);

			GeneralResult result =
                    conn.loginUsingBackupVerificationCode(VALID_EMAIL, "INVALID-CODE-0000", uniqueDevice());

			assertFalse(result.isSuccess(), "Invalid backup code must not allow login");
		}

		@Test
		@DisplayName("fails for unknown email")
		void unknownEmail_fails() {
            GeneralResult result =
                    conn.loginUsingBackupVerificationCode(
                            "nobody@example.com", "ANYCODE-1234", uniqueDevice());

			assertFalse(result.isSuccess(), "Unknown email must reject backup-code login");
		}
	}

}
