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

import main.java.io.github.koukobin.ermis.common.UserDeviceInfo;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.ErmisDatabase;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.data_access.Insert;

import org.junit.jupiter.api.*;

import java.sql.PreparedStatement;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static test.java.databases.Utils.*;

/**
 * Integration tests for UserDevicesManagerService.
 * 
 * @author Ilias Koukovinis
 * 
 */
class UserDevicesManagerServiceTest extends BaseIntegrationTest {

	// -------------------------------------------------------------------------
	// Fixture accounts
	// -------------------------------------------------------------------------

	private static final String EMAIL_1    = "devices.user1@example.com";
	private static final String PASSWORD_1 = "Str0ng!Pass#Dev1";
	private static final String USERNAME_1 = "DeviceUser1";

	private static final String EMAIL_2    = "devices.user2@example.com";
	private static final String PASSWORD_2 = "Str0ng!Pass#Dev2";
	private static final String USERNAME_2 = "DeviceUser2";

	private static int CLIENT_ID_1;
	private static int CLIENT_ID_2;

    private static ErmisDatabase.GeneralPurposeDBConnection conn;

	@BeforeAll
	static void setupDatabase() throws Exception {
		conn = ErmisDatabase.getGeneralPurposeConnection();
		assertNotNull(conn, "Database connection must not be null");

		nukeAll(conn);

		var r1 = conn.createAccount(USERNAME_1, PASSWORD_1, uniqueDevice(), EMAIL_1);
		assertTrue(r1.isSuccess(), "Fixture account 1 must be created successfully");

		var r2 = conn.createAccount(USERNAME_2, PASSWORD_2, uniqueDevice(), EMAIL_2);
		assertTrue(r2.isSuccess(), "Fixture account 2 must be created successfully");

		CLIENT_ID_1 = resolveClientID(EMAIL_1, conn);
		CLIENT_ID_2 = resolveClientID(EMAIL_2, conn);
	}

	@BeforeEach
	void cleanDevices() throws Exception {
		try (PreparedStatement ps = conn.underlyingConnection().prepareStatement("DELETE FROM user_devices;")) {
			ps.executeUpdate();
		}
	}

	@AfterAll
	static void cleanupDatabase() throws Exception {
		nukeAll(conn);
		if (conn != null) conn.close();
	}

	// =========================================================================

	@Nested
	@DisplayName("insertUserDevice(String email, UserDeviceInfo)")
	class InsertUserDeviceByEmailTests {

		@Test
		@DisplayName("returns SUCCESSFUL_INSERT for a new device on a known account")
		void newDevice_returnsSuccessfulInsert() {
			Insert result = conn.insertUserDevice(EMAIL_1, uniqueDevice());
			assertEquals(Insert.SUCCESSFUL_INSERT, result,
					"Inserting a new device for a known email must return SUCCESSFUL_INSERT");
		}

		@Test
		@DisplayName("returns DUPLICATE_ENTRY when the same device UUID is inserted twice")
		void duplicateDevice_returnsDuplicateEntry() {
			UserDeviceInfo device = uniqueDevice();
			conn.insertUserDevice(EMAIL_1, device);

			Insert second = conn.insertUserDevice(EMAIL_1, device);
			assertEquals(Insert.DUPLICATE_ENTRY, second,
					"Re-inserting the same device UUID must return DUPLICATE_ENTRY");
		}

		@Test
		@DisplayName("returns INTERNAL_ERROR (or non-success) for an unknown email")
		void unknownEmail_returnsNonSuccess() {
			Insert result = conn.insertUserDevice("ghost@example.com", uniqueDevice());
			assertNotEquals(Insert.SUCCESSFUL_INSERT, result,
					"Inserting a device for an unknown email must not return SUCCESSFUL_INSERT");
		}

		@Test
		@DisplayName("multiple distinct devices can be inserted for the same account")
		void multipleDistinctDevices_allSucceed() {
			assertEquals(Insert.SUCCESSFUL_INSERT, conn.insertUserDevice(EMAIL_1, uniqueDevice()));
			assertEquals(Insert.SUCCESSFUL_INSERT, conn.insertUserDevice(EMAIL_1, uniqueDevice()));
			assertEquals(Insert.SUCCESSFUL_INSERT, conn.insertUserDevice(EMAIL_1, uniqueDevice()));
		}
	}

	// =========================================================================

	@Nested
	@DisplayName("insertUserDevice(int clientID, UserDeviceInfo)")
	class InsertUserDeviceByClientIDTests {

		@Test
		@DisplayName("returns SUCCESSFUL_INSERT for a new device on a known clientID")
		void newDevice_returnsSuccessfulInsert() {
			Insert result = conn.insertUserDevice(CLIENT_ID_1, uniqueDevice());
			assertEquals(Insert.SUCCESSFUL_INSERT, result,
					"Inserting a new device for a known clientID must return SUCCESSFUL_INSERT");
		}

		@Test
		@DisplayName("returns DUPLICATE_ENTRY when the same device UUID is inserted twice")
		void duplicateDevice_returnsDuplicateEntry() {
			UserDeviceInfo device = uniqueDevice();
			conn.insertUserDevice(CLIENT_ID_1, device);

			Insert second = conn.insertUserDevice(CLIENT_ID_1, device);
			assertEquals(Insert.DUPLICATE_ENTRY, second,
					"Re-inserting the same device UUID must return DUPLICATE_ENTRY");
		}

		@Test
		@DisplayName("returns non-success for an unknown clientID")
		void unknownClientID_returnsNonSuccess() {
			Insert result = conn.insertUserDevice(-1, uniqueDevice());
			assertNotEquals(Insert.SUCCESSFUL_INSERT, result,
					"Inserting a device for an unknown clientID must not return SUCCESSFUL_INSERT");
		}

		@Test
		@DisplayName("multiple distinct devices can be inserted for the same clientID")
		void multipleDistinctDevices_allSucceed() {
			assertEquals(Insert.SUCCESSFUL_INSERT, conn.insertUserDevice(CLIENT_ID_1, uniqueDevice()));
			assertEquals(Insert.SUCCESSFUL_INSERT, conn.insertUserDevice(CLIENT_ID_1, uniqueDevice()));
			assertEquals(Insert.SUCCESSFUL_INSERT, conn.insertUserDevice(CLIENT_ID_1, uniqueDevice()));
		}

		@Test
		@DisplayName("email and clientID overloads produce the same outcome for the same account")
		void emailAndClientIDOverloads_consistent() {
			UserDeviceInfo deviceA = uniqueDevice();
			UserDeviceInfo deviceB = uniqueDevice();

			Insert byEmail    = conn.insertUserDevice(EMAIL_1, deviceA);
			Insert byClientID = conn.insertUserDevice(CLIENT_ID_1, deviceB);

			assertEquals(Insert.SUCCESSFUL_INSERT, byEmail, "Email overload must return SUCCESSFUL_INSERT");
			assertEquals(Insert.SUCCESSFUL_INSERT, byClientID, "clientID overload must return SUCCESSFUL_INSERT");
		}
	}

	// =========================================================================

	@Nested
	@DisplayName("isDeviceLoggedIn")
	class IsDeviceLoggedInTests {

		@Test
		@DisplayName("returns true immediately after inserting a device")
		void afterInsert_returnsTrue() {
			UserDeviceInfo device = uniqueDevice();
			conn.insertUserDevice(EMAIL_1, device);

			assertTrue(conn.isDeviceLoggedIn(EMAIL_1, device.deviceUUID()),
					"Device must be reported as logged-in right after insertion");
		}

		@Test
		@DisplayName("returns false for a device that was never inserted")
		void neverInserted_returnsFalse() {
			assertFalse(conn.isDeviceLoggedIn(EMAIL_1, UUID.randomUUID()),
					"A never-registered device must not be reported as logged-in");
		}

		@Test
		@DisplayName("returns false after the device is logged out")
		void afterLogout_returnsFalse() {
			UserDeviceInfo device = uniqueDevice();
			conn.insertUserDevice(EMAIL_1, device);

			conn.logoutDevice(device.deviceUUID(), CLIENT_ID_1);

			assertFalse(conn.isDeviceLoggedIn(EMAIL_1, device.deviceUUID()),
					"Device must not be reported as logged-in after logout");
		}

		@Test
		@DisplayName("returns false for device under the wrong email")
		void wrongEmail_returnsFalse() {
			UserDeviceInfo device = uniqueDevice();
			conn.insertUserDevice(EMAIL_1, device);

			assertFalse(conn.isDeviceLoggedIn(EMAIL_2, device.deviceUUID()),
					"A device registered to user 1 must not appear logged-in under user 2's email");
		}
	}

	// =========================================================================

	@Nested
	@DisplayName("logoutDevice")
	class LogoutDeviceTests {

		@Test
		@DisplayName("returns true when an existing device is logged out")
		void existingDevice_returnsTrue() {
			UserDeviceInfo device = uniqueDevice();
			conn.insertUserDevice(CLIENT_ID_1, device);

			assertTrue(conn.logoutDevice(device.deviceUUID(), CLIENT_ID_1),
					"Logging out an existing device must return true");
		}

		@Test
		@DisplayName("device is no longer logged in after logout")
		void afterLogout_deviceGone() {
			UserDeviceInfo device = uniqueDevice();
			conn.insertUserDevice(CLIENT_ID_1, device);

			conn.logoutDevice(device.deviceUUID(), CLIENT_ID_1);

			assertFalse(conn.isDeviceLoggedIn(EMAIL_1, device.deviceUUID()));
		}

		@Test
		@DisplayName("returns false for a device that does not exist")
		void nonExistentDevice_returnsFalse() {
			assertFalse(conn.logoutDevice(UUID.randomUUID(), CLIENT_ID_1),
					"Logging out a non-existent device must return false");
		}

		@Test
		@DisplayName("returns false when clientID does not own the device")
		void wrongClientID_returnsFalse() {
			UserDeviceInfo device = uniqueDevice();
			conn.insertUserDevice(CLIENT_ID_1, device);

			assertFalse(conn.logoutDevice(device.deviceUUID(), CLIENT_ID_2),
					"Logging out a device with the wrong clientID must return false");
		}

		@Test
		@DisplayName("only the targeted device is removed; others remain logged in")
		void otherDevicesUnaffected() {
			UserDeviceInfo deviceA = uniqueDevice();
			UserDeviceInfo deviceB = uniqueDevice();
			conn.insertUserDevice(CLIENT_ID_1, deviceA);
			conn.insertUserDevice(CLIENT_ID_1, deviceB);

			conn.logoutDevice(deviceA.deviceUUID(), CLIENT_ID_1);

			assertFalse(conn.isDeviceLoggedIn(EMAIL_1, deviceA.deviceUUID()), 
					"Device A must be gone after its logout");
			assertTrue(conn.isDeviceLoggedIn(EMAIL_1, deviceB.deviceUUID()), 
					"Device B must still be logged in");
		}
	}

	// =========================================================================

	@Nested
	@DisplayName("logoutAllDevices")
	class LogoutAllDevicesTests {

		@Test
		@DisplayName("returns true when there are devices to remove")
		void withDevices_returnsTrue() {
			conn.insertUserDevice(CLIENT_ID_1, uniqueDevice());
			conn.insertUserDevice(CLIENT_ID_1, uniqueDevice());

			assertTrue(conn.logoutAllDevices(CLIENT_ID_1), 
					"logoutAllDevices must return true when devices existed");
		}

		@Test
		@DisplayName("all devices are gone after logoutAllDevices")
		void afterLogoutAll_noDevicesRemain() {
			conn.insertUserDevice(CLIENT_ID_1, uniqueDevice());
			conn.insertUserDevice(CLIENT_ID_1, uniqueDevice());

			conn.logoutAllDevices(CLIENT_ID_1);

			UserDeviceInfo[] remaining = conn.getUserDevices(CLIENT_ID_1);
			assertTrue(remaining == null || remaining.length == 0, 
					"No devices must remain after logoutAllDevices");
		}

		@Test
		@DisplayName("returns false (or true vacuously) when no devices are registered")
		void noDevices_doesNotThrow() {
			// Behaviour on empty set is implementation-defined; just assert it doesn't throw
			assertDoesNotThrow(() -> conn.logoutAllDevices(CLIENT_ID_1));
		}

		@Test
		@DisplayName("only removes devices belonging to the target clientID")
		void otherAccountsDevicesUnaffected() {
			UserDeviceInfo deviceUser2 = uniqueDevice();
			conn.insertUserDevice(CLIENT_ID_1, uniqueDevice());
			conn.insertUserDevice(CLIENT_ID_2, deviceUser2);

			conn.logoutAllDevices(CLIENT_ID_1);

			assertTrue(conn.isDeviceLoggedIn(EMAIL_2, deviceUser2.deviceUUID()),
					"Devices belonging to other accounts must not be affected");
		}
	}

	// =========================================================================

	@Nested
	@DisplayName("getUserDevices")
	class GetUserDevicesTests {

		@Test
		@DisplayName("returns empty array when no devices are registered")
		void noDevices_returnsEmptyOrNull() {
			UserDeviceInfo[] devices = conn.getUserDevices(CLIENT_ID_1);
			assertTrue(devices == null || devices.length == 0,
					"No devices registered must return empty or null array");
		}

		@Test
		@DisplayName("returns exactly the devices that were inserted")
		void insertsThreeDevices_returnsThree() {
			conn.insertUserDevice(CLIENT_ID_1, uniqueDevice());
			conn.insertUserDevice(CLIENT_ID_1, uniqueDevice());
			conn.insertUserDevice(CLIENT_ID_1, uniqueDevice());

			UserDeviceInfo[] devices = conn.getUserDevices(CLIENT_ID_1);
			assertNotNull(devices);
			assertEquals(3, devices.length, "Must return exactly 3 devices");
		}

		@Test
		@DisplayName("count decreases by one after a single logout")
		void afterOneLogout_countDecreasedByOne() {
			UserDeviceInfo deviceA = uniqueDevice();
			UserDeviceInfo deviceB = uniqueDevice();
			conn.insertUserDevice(CLIENT_ID_1, deviceA);
			conn.insertUserDevice(CLIENT_ID_1, deviceB);

			conn.logoutDevice(deviceA.deviceUUID(), CLIENT_ID_1);

			UserDeviceInfo[] devices = conn.getUserDevices(CLIENT_ID_1);
			assertNotNull(devices);
			assertEquals(1, devices.length, "One device must remain after logging out one of two");
		}

		@Test
		@DisplayName("only returns devices belonging to the requested clientID")
		void doesNotReturnOtherUsersDevices() {
			conn.insertUserDevice(CLIENT_ID_1, uniqueDevice());
			conn.insertUserDevice(CLIENT_ID_2, uniqueDevice());
			conn.insertUserDevice(CLIENT_ID_2, uniqueDevice());

			UserDeviceInfo[] user1Devices = conn.getUserDevices(CLIENT_ID_1);
			assertNotNull(user1Devices);
			assertEquals(1, user1Devices.length,
                    "getUserDevices must only return devices for the requested clientID");
		}

		@Test
		@DisplayName("returns empty after logoutAllDevices")
		void afterLogoutAll_returnsEmpty() {
			conn.insertUserDevice(CLIENT_ID_1, uniqueDevice());
			conn.insertUserDevice(CLIENT_ID_1, uniqueDevice());

			conn.logoutAllDevices(CLIENT_ID_1);

			UserDeviceInfo[] devices = conn.getUserDevices(CLIENT_ID_1);
			assertTrue(devices == null || devices.length == 0,
					"getUserDevices must return empty after logoutAllDevices");
		}
	}

}
