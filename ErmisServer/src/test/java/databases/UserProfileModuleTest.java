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

import main.java.io.github.koukobin.ermis.common.Account;
import main.java.io.github.koukobin.ermis.common.DeviceType;
import main.java.io.github.koukobin.ermis.common.UserDeviceInfo;
import main.java.io.github.koukobin.ermis.common.results.ChangeUsernameResult;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.ErmisDatabase;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.models.UserIcon;

import org.junit.jupiter.api.*;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static test.java.databases.Utils.*;

/**
 * @author Ilias Koukovinis
 * 
 */
class UserProfileModuleTest extends BaseIntegrationTest {

    private static final String EMAIL          = "profile.user@example.com";
    private static final String PASSWORD       = "Str0ng!Pass#Profile";
    private static final String ORIGINAL_NAME  = "OriginalName";
    private static final String NEW_NAME       = "UpdatedName";

	private static int CLIENT_ID;
	private static UUID deviceUUID;

	private static ErmisDatabase.GeneralPurposeDBConnection conn;

	/** Minimal 1×1 white PNG used for profile photo */
	private static byte[] minimalPng() {
		return new byte[] {
            (byte)0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A,                          // PNG signature
            0x00,0x00,0x00,0x0D,0x49,0x48,0x44,0x52,                                // IHDR length + type
            0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,                                // width=1, height=1
            0x08,0x02,0x00,0x00,0x00,(byte)0x90,0x77,0x53,(byte)0xDE,               // bit depth, color, crc
            0x00,0x00,0x00,0x0C,0x49,0x44,0x41,0x54,                                // IDAT length + type
            0x08,(byte)0xD7,0x63,(byte)0xF8,(byte)0xCF,(byte)0xC0,0x00,0x00,
            0x00,0x02,0x00,0x01,(byte)0xE2,0x21,(byte)0xBC,0x33,                    // compressed pixel + crc
            0x00,0x00,0x00,0x00,0x49,0x45,0x4E,0x44,(byte)0xAE,0x42,0x60,(byte)0x82 // IEND
		};
	}

	@BeforeAll
	static void setupDatabase() throws Exception {
		conn = ErmisDatabase.getGeneralPurposeConnection();
		assertNotNull(conn, "Database connection must not be null");

		nukeAll(conn);

		UserDeviceInfo deviceInfo = uniqueDevice();
		deviceUUID = deviceInfo.deviceUUID();

		var result = conn.createAccount(ORIGINAL_NAME, PASSWORD, deviceInfo, EMAIL);
		assertTrue(result.isSuccess(), "Fixture account must be created successfully");

		CLIENT_ID = resolveClientID(EMAIL, conn);
	}

	@BeforeEach
	void resetProfileState() {
		conn.changeDisplayName(CLIENT_ID, ORIGINAL_NAME);
	}

	@AfterAll
	static void cleanupDatabase() throws Exception {
		nukeAll(conn);
		if (conn != null) conn.close();
	}

	// =========================================================================

	@Nested
	@DisplayName("getUsername")
	class GetUsernameTests {

		@Test
		@DisplayName("returns the username set at account creation")
		void returnsOriginalUsername() {
			Optional<String> name = conn.getUsername(CLIENT_ID);
			assertTrue(name.isPresent(), "getUsername must return a present Optional for a known clientID");
			assertEquals(ORIGINAL_NAME, name.get(), "Returned username must match the one set at creation");
		}

		@Test
		@DisplayName("returns empty for an unknown clientID")
		void unknownClientID_returnsEmpty() {
			Optional<String> name = conn.getUsername(Integer.MAX_VALUE);
			assertFalse(name.isPresent(), "Unknown clientID must return empty Optional");
		}

		@Test
		@DisplayName("reflects the updated name after changeDisplayName")
		void afterDisplayNameChange_returnsNewName() {
			conn.changeDisplayName(CLIENT_ID, NEW_NAME);

			Optional<String> name = conn.getUsername(CLIENT_ID);
			assertTrue(name.isPresent());
			assertEquals(NEW_NAME, name.get(), "getUsername must return the new name after changeDisplayName");
		}
	}

	// =========================================================================

	@Nested
	@DisplayName("getClientID")
	class GetClientIDTests {

		@Test
		@DisplayName("returns the correct clientID for a registered email")
		void knownEmail_returnsClientID() {
			Optional<Integer> id = conn.getClientID(EMAIL);
			assertTrue(id.isPresent(), "getClientID must return a present Optional for a known email");
			assertEquals(CLIENT_ID, id.get(), "Returned clientID must match the one resolved at setup");
		}

		@Test
		@DisplayName("returns empty for an unregistered email")
		void unknownEmail_returnsEmpty() {
			Optional<Integer> id = conn.getClientID("ghost@example.com");
			assertFalse(id.isPresent(), "Unknown email must return empty Optional");
		}

		@Test
		@DisplayName("is consistent with resolveClientID used in test setup")
		void consistentWithAuthentication() {
			Optional<Integer> id = conn.getClientID(EMAIL);
			assertTrue(id.isPresent());
			assertEquals(CLIENT_ID, id.get(),
					"getClientID must return the same ID as the one derived from checkAuthentication");
		}
	}

	// =========================================================================

	@Nested
	@DisplayName("changeDisplayName")
	class ChangeDisplayNameTests {

		@Test
		@DisplayName("returns SUCCESFULLY_CHANGED_USERNAME for a valid new name")
		void validNewName_returnsSuccess() {
			ChangeUsernameResult result = conn.changeDisplayName(CLIENT_ID, NEW_NAME);
			assertTrue(result.resultHolder.isSuccessful(), 
					"changeDisplayName with a new valid name must succeed");
			assertEquals(ChangeUsernameResult.SUCCESFULLY_CHANGED_USERNAME, result);
		}

		@Test
		@DisplayName("new name is persisted and returned by getUsername")
		void newNameIsPersisted() {
			conn.changeDisplayName(CLIENT_ID, NEW_NAME);

			assertEquals(NEW_NAME, conn.getUsername(CLIENT_ID).orElseThrow(),
					"getUsername must return the new name after changeDisplayName");
		}

		@Test
		@DisplayName("returns REQUIREMENTS_NOT_MET for a blank name")
		void blankName_returnsRequirementsNotMet() {
			ChangeUsernameResult result = conn.changeDisplayName(CLIENT_ID, "");
			assertEquals(ChangeUsernameResult.REQUIREMENTS_NOT_MET, result,
					"Blank display name must fail requirements check");
		}

		@Test
		@DisplayName("returns non-success for an unknown clientID")
		void unknownClientID_returnsNonSuccess() {
			ChangeUsernameResult result = conn.changeDisplayName(Integer.MAX_VALUE, NEW_NAME);
			assertFalse(result.resultHolder.isSuccessful(), 
					"changeDisplayName for unknown clientID must not succeed");
		}

		@Test
		@DisplayName("name can be changed multiple times in sequence")
		void sequentialChanges_eachSucceeds() {
			String nameV2 = "NameVersion2";
			String nameV3 = "NameVersion3";

			assertTrue(conn.changeDisplayName(CLIENT_ID, nameV2).resultHolder.isSuccessful());
			assertTrue(conn.changeDisplayName(CLIENT_ID, nameV3).resultHolder.isSuccessful());

			assertEquals(nameV3, conn.getUsername(CLIENT_ID).orElseThrow(),
					"Final name must be persisted after sequential changes");
		}
	}

	// =========================================================================

	@Nested
	@DisplayName("setProfilePhoto")
	class SetProfilePhotoTests {

		@Test
		@DisplayName("returns true when setting a valid photo")
		void validPhoto_returnsTrue() {
			assertTrue(conn.setProfilePhoto(CLIENT_ID, minimalPng()),
					"setProfilePhoto with valid bytes must return true");
		}

		@Test
		@DisplayName("photo is retrievable via selectUserIcon after being set")
		void afterSet_iconIsPresent() {
			conn.setProfilePhoto(CLIENT_ID, minimalPng());

			Optional<UserIcon> icon = conn.selectUserIcon(CLIENT_ID);
			assertTrue(icon.isPresent(), "selectUserIcon must return a present Optional after setProfilePhoto");
			assertNotNull(icon.get().iconBytes(), "UserIcon bytes must not be null");
			assertNotEquals(0, icon.get().iconBytes().length, "UserIcon bytes must not be empty");
		}

		@Test
		@DisplayName("stored bytes match what was set")
		void storedBytesMatchInput() {
			byte[] photo = minimalPng();
			conn.setProfilePhoto(CLIENT_ID, photo);

			byte[] stored = conn.selectUserIcon(CLIENT_ID)
					.orElseThrow(() -> new AssertionError("Icon must be present after setProfilePhoto")).iconBytes();
			assertArrayEquals(photo, stored, "Retrieved icon bytes must exactly match what was stored");
		}

		@Test
		@DisplayName("returns false for an unknown clientID")
		void unknownClientID_returnsFalse() {
			assertFalse(conn.setProfilePhoto(Integer.MAX_VALUE, minimalPng()),
					"setProfilePhoto for unknown clientID must return false");
		}

		@Test
		@DisplayName("photo can be overwritten with a second call")
		void overwritePhoto_latestBytesStored() {
			byte[] firstPhoto  = minimalPng();
			byte[] secondPhoto = new byte[] { 0x00, 0x01, 0x02, 0x03 }; // Arbitrary replacement

			conn.setProfilePhoto(CLIENT_ID, firstPhoto);
			conn.setProfilePhoto(CLIENT_ID, secondPhoto);

			byte[] stored = conn.selectUserIcon(CLIENT_ID)
					.orElseThrow()
					.iconBytes();
			assertArrayEquals(secondPhoto, stored, 
					"After overwriting, the latest photo bytes must be stored");
		}
	}

	// =========================================================================

	@Nested
	@DisplayName("selectUserIcon")
	class SelectUserIconTests {

		@Test
		@DisplayName("returns present after a photo is set")
		void afterPhotoSet_returnsPresent() {
			conn.setProfilePhoto(CLIENT_ID, minimalPng());

			assertTrue(conn.selectUserIcon(CLIENT_ID).isPresent());
		}

		@Test
		@DisplayName("returns empty for an unknown clientID")
		void unknownClientID_returnsEmpty() {
			Optional<UserIcon> icon = conn.selectUserIcon(Integer.MAX_VALUE);
			assertFalse(icon.isPresent(), "selectUserIcon must return empty for unknown clientID");
		}
	}

	// =========================================================================

	@Nested
	@DisplayName("getWhenUserLastUpdatedProfile")
	class GetWhenUserLastUpdatedProfileTests {

		@Test
		@DisplayName("returns a present timestamp for a known clientID")
		void knownClientID_returnsTimestamp() {
			Optional<Long> ts = conn.getWhenUserLastUpdatedProfile(CLIENT_ID);
			assertTrue(ts.isPresent(), "Must return a present timestamp for a known clientID");
		}

		@Test
		@DisplayName("returned timestamp is a positive epoch value")
		void timestamp_isPositive() {
			long ts = conn.getWhenUserLastUpdatedProfile(CLIENT_ID)
					.orElseThrow(() -> new AssertionError("Timestamp must be present"));
			assertTrue(ts > 0, "Timestamp must be a positive epoch value");
		}

		@Test
		@DisplayName("timestamp advances after a profile update")
		void afterProfileUpdate_timestampAdvances() throws InterruptedException {
			long before = conn.getWhenUserLastUpdatedProfile(CLIENT_ID)
					.orElseThrow(() -> new AssertionError("Timestamp must be present before update"));

			Thread.sleep(50); // ensure clock advances
			conn.changeDisplayName(CLIENT_ID, NEW_NAME);

			long after = conn.getWhenUserLastUpdatedProfile(CLIENT_ID)
					.orElseThrow(() -> new AssertionError("Timestamp must be present after update"));

			assertTrue(after >= before, "Timestamp must not regress after a profile update");
		}

		@Test
		@DisplayName("returns empty for an unknown clientID")
		void unknownClientID_returnsEmpty() {
			Optional<Long> ts = conn.getWhenUserLastUpdatedProfile(Integer.MAX_VALUE);
			assertFalse(ts.isPresent(), "Unknown clientID must return empty Optional");
		}
	}

	// =========================================================================

	@Nested
	@DisplayName("getAccountsAssociatedWithDevice")
	class GetAccountsAssociatedWithDeviceTests {

		@Test
		@DisplayName("returns the fixture account for the device used at creation")
		void knownDevice_returnsAccount() {
			Account[] accounts = conn.getAccountsAssociatedWithDevice(deviceUUID);
			assertNotNull(accounts, "Must not return null for a known device UUID");
			assertTrue(accounts.length >= 1,
					"Must return at least one account for the device used at account creation");
		}

		@Test
		@DisplayName("returned account contains the correct clientID")
		void returnedAccount_hasCorrectClientID() {
			Account[] accounts = conn.getAccountsAssociatedWithDevice(deviceUUID);
			assertNotNull(accounts);

			boolean found = false;
			for (Account a : accounts) {
				if (a.clientID() == CLIENT_ID) {
					found = true;
					break;
				}
			}
			assertTrue(found, "Returned accounts must include the fixture account's clientID");
		}

		@Test
		@DisplayName("returns empty array for an unknown device UUID")
		void unknownDevice_returnsEmpty() {
			Account[] accounts = conn.getAccountsAssociatedWithDevice(UUID.randomUUID());
			assertTrue(accounts == null || accounts.length == 0,
					"Unknown device UUID must return empty or null array");
		}
	}

}
