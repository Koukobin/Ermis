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

import main.java.io.github.koukobin.ermis.common.results.GeneralResult;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.ErmisDatabase;

import org.junit.jupiter.api.*;

import static org.junit.jupiter.api.Assertions.*;
import static test.java.databases.Utils.*;

/**
 * @author Ilias Koukovinis
 * 
 */
class ChangePasswordServiceTest extends BaseIntegrationTest {

	private static final String EMAIL         = "changepass.user@example.com";
	private static final String ORIGINAL_PASS = "0riginal!Pass#99";
	private static final String NEW_PASS      = "N3wStr0ng!Pass#1";
	private static final String USERNAME      = "ChangePassUser";

	private static int CLIENT_ID;

	private static ErmisDatabase.GeneralPurposeDBConnection conn;

	@BeforeAll
	static void setupDatabase() throws Exception {
		conn = ErmisDatabase.getGeneralPurposeConnection();
		assertNotNull(conn, "Database connection must not be null");

		nukeAll(conn);

		var result = conn.createAccount(USERNAME, ORIGINAL_PASS, uniqueDevice(), EMAIL);
		assertTrue(result.isSuccess(), "Fixture account must be created successfully");

		CLIENT_ID = resolveClientID(EMAIL, conn);
	}

	@BeforeEach
	void resetPassword() throws Exception {
		nukeAll(conn);

		var result = conn.createAccount(USERNAME, ORIGINAL_PASS, uniqueDevice(), EMAIL);
		assertTrue(result.isSuccess(), "Fixture account must be created successfully");
		
		CLIENT_ID = resolveClientID(EMAIL, conn);
	}

	@AfterAll
	static void cleanupDatabase() throws Exception {
		nukeAll(conn);
		if (conn != null) conn.close();
	}

	// =========================================================================

	@Test
	@DisplayName("succeeds when email, new password, and clientID are all valid")
	void validRequest_succeeds() {
		GeneralResult result = conn.changePassword(EMAIL, NEW_PASS, CLIENT_ID);
		assertTrue(result.isSuccess(), "changePassword with valid inputs must succeed");
	}

	@Test
	@DisplayName("new password is accepted for authentication after change")
	void afterChange_newPasswordAuthenticates() {
		conn.changePassword(EMAIL, NEW_PASS, CLIENT_ID);

		assertTrue(conn.checkAuthentication(EMAIL, NEW_PASS).isPresent(),
				"Authentication with new password must succeed after changePassword");
	}

	@Test
	@DisplayName("old password is rejected for authentication after change")
	void afterChange_oldPasswordRejected() {
		conn.changePassword(EMAIL, NEW_PASS, CLIENT_ID);

		assertFalse(conn.checkAuthentication(EMAIL, ORIGINAL_PASS).isPresent(),
				"Authentication with old password must fail after changePassword");
	}

	@Test
	@DisplayName("fails when clientID does not match the email")
	void mismatchedClientID_fails() {
		GeneralResult result = conn.changePassword(EMAIL, NEW_PASS, Integer.MAX_VALUE);
		assertFalse(result.isSuccess(),
				"changePassword with a mismatched clientID must fail");
	}

	@Test
	@DisplayName("fails for an unknown email")
	void unknownEmail_fails() {
		GeneralResult result = conn.changePassword("ghost@example.com", NEW_PASS, CLIENT_ID);
		assertFalse(result.isSuccess(),
				"changePassword for an unknown email must fail");
	}

	@Test
	@DisplayName("fails when new password is blank")
	void blankNewPassword_fails() {
		GeneralResult result = conn.changePassword(EMAIL, "", CLIENT_ID);
		assertFalse(result.isSuccess(),
				"changePassword with a blank new password must fail");
	}

	@Test
	@DisplayName("changing to the same password succeeds or is treated as a no-op without error")
	void changeToSamePassword_doesNotThrow() {
		assertDoesNotThrow(() -> conn.changePassword(EMAIL, ORIGINAL_PASS, CLIENT_ID));
		assertTrue(conn.checkAuthentication(EMAIL, ORIGINAL_PASS).isPresent(),
				"Authentication must still work after changing to the same password");
	}

	@Test
	@DisplayName("password can be changed multiple times in sequence")
	void sequentialChanges_eachSucceeds() {
		String passV2 = "S3cond!Pass#V2";
		String passV3 = "Th1rd!Pass#V3";

		assertTrue(conn.changePassword(EMAIL, passV2, CLIENT_ID).isSuccess(),
				"First change must succeed");
		assertTrue(conn.changePassword(EMAIL, passV3, CLIENT_ID).isSuccess(),
				"Second change must succeed");

		assertTrue(conn.checkAuthentication(EMAIL, passV3).isPresent(),
				"Authentication with the final password must succeed");
		assertFalse(conn.checkAuthentication(EMAIL, ORIGINAL_PASS).isPresent(),
				"Authentication with the original password must fail after two changes");
	}

	@Test
	@DisplayName("checkAuthenticationViaHash reflects the new password hash after change")
	void afterChange_hashUpdated() {
		// Capture hash before change
		String oldHash = conn.checkAuthentication(EMAIL, ORIGINAL_PASS).get();

		assertTrue(conn.changePassword(EMAIL, NEW_PASS, CLIENT_ID).isSuccess(),
				"Change password should not fail");

		// Old hash must no longer be valid
		assertFalse(conn.checkAuthenticationViaHash(EMAIL, oldHash),
				"Old hash must be invalid after password change");

		// New hash must be valid
		String newHash = conn.checkAuthentication(EMAIL, NEW_PASS)
				.orElseThrow(() -> new AssertionError("Post-change auth must succeed"));
		assertTrue(conn.checkAuthenticationViaHash(EMAIL, newHash), 
				"New hash must be valid after password change");
	}

}
