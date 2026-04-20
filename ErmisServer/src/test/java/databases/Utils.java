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

import static org.junit.jupiter.api.Assertions.assertTrue;

import java.sql.PreparedStatement;
import java.util.Optional;
import java.util.UUID;

import main.java.io.github.koukobin.ermis.common.DeviceType;
import main.java.io.github.koukobin.ermis.common.UserDeviceInfo;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.ErmisDatabase;

/**
 *
 * @author Ilias Koukovinis
 * 
 */
class Utils {

	/** Soft-skips the test when a precondition value is null. */
	static void assumeNotNull(Object value, String message) {
		org.junit.jupiter.api.Assumptions.assumeTrue(value != null, message);
	}

	static UserDeviceInfo uniqueDevice() {
		return new UserDeviceInfo(UUID.randomUUID(), DeviceType.DESKTOP, "TestOS 1.0");
	}

	/**
	 * Wipes all chat and account rows.
	 */
	static void nukeAll(ErmisDatabase.GeneralPurposeDBConnection conn) throws Exception {
		String sql = """
				DELETE FROM chat_requests;
				DELETE FROM chat_sessions;
				DELETE FROM user_devices;
				DELETE FROM users;
				""";
		try (PreparedStatement ps = conn.underlyingConnection().prepareStatement(sql)) {
			ps.executeUpdate();
		}
	}

	static int resolveClientID(String email, ErmisDatabase.GeneralPurposeDBConnection conn) {
		Optional<Integer> clientID = conn.getClientID(email);
		assertTrue(clientID.isPresent(), "Could not resolve client ID for " + email);
		return clientID.get();
	}
}
