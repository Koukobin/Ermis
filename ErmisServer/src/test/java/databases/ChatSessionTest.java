/* Copyright (C) 2023 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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

import static org.junit.jupiter.api.Assertions.*;

import java.sql.PreparedStatement;
import java.util.Optional;

import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.ErmisDatabase;

/**
 * @author Ilias Koukovinis
 *
 */
public class ChatSessionTest extends BaseIntegrationTest {

	private static final String EMAIL_1    = "chat.user1@example.com";
	private static final String PASSWORD_1 = "Str0ng!Pass#User1";
	private static final String USERNAME_1 = "ChatUser1";

	private static final String EMAIL_2    = "chat.user2@example.com";
	private static final String PASSWORD_2 = "Str0ng!Pass#User2";
	private static final String USERNAME_2 = "ChatUser2";

	private static int CLIENT_ID_1;
	private static int CLIENT_ID_2;

	private static ErmisDatabase.GeneralPurposeDBConnection conn;

	@BeforeAll
	static void setupDatabase() throws Exception {
		conn = ErmisDatabase.getGeneralPurposeConnection();
		assertNotNull(conn, "Database connection must not be null");

		// Wipe any leftover data from a previous run
		Utils.nukeAll(conn);

		// Create the two accounts that all chat tests will use
		var r1 = conn.createAccount(USERNAME_1, PASSWORD_1, Utils.uniqueDevice(), EMAIL_1);
		assertTrue(r1.isSuccess(), "Fixture account 1 must be created successfully");

		var r2 = conn.createAccount(USERNAME_2, PASSWORD_2, Utils.uniqueDevice(), EMAIL_2);
		assertTrue(r2.isSuccess(), "Fixture account 2 must be created successfully");

		CLIENT_ID_1 = Utils.resolveClientID(EMAIL_1, conn);
		CLIENT_ID_2 = Utils.resolveClientID(EMAIL_2, conn);
	}

	@BeforeEach
	void cleanChatTables() throws Exception {
		// Only wipe chat data to ensure accounts persist across tests
		String cleanupSql = "DELETE FROM chat_requests; DELETE FROM chat_sessions;";
		try (PreparedStatement pstmt = conn.underlyingConnection().prepareStatement(cleanupSql)) {
			pstmt.executeUpdate();
		}
	}

	@AfterAll
	static void cleanupDatabase() throws Exception {
		Utils.nukeAll(conn);
		if (conn != null) conn.close();
	}

	// =========================================================================

	@Test
	void sendChatRequest_firstRequest_returnsTrue() {
		boolean result = conn.sendChatRequest(CLIENT_ID_1, CLIENT_ID_2);
		assertTrue(result, "First chat request from user 1 to user 2 should succeed");
	}

	@Test
	void sendChatRequest_duplicateRequest_returnsFalse() {
		assertTrue(conn.sendChatRequest(CLIENT_ID_1, CLIENT_ID_2), "Initial request should succeed");

		boolean duplicate = conn.sendChatRequest(CLIENT_ID_1, CLIENT_ID_2);
		assertFalse(duplicate, "Duplicate chat request from user 1 to user 2 should be rejected");
	}

	// =========================================================================

	@Test
	void acceptChatRequest_validPendingRequest_returnsChatSessionID() {
		conn.sendChatRequest(CLIENT_ID_1, CLIENT_ID_2);

		Optional<Integer> chatSessionID = conn.acceptChatRequest(CLIENT_ID_1, CLIENT_ID_2);
		assertTrue(chatSessionID.isPresent(), "Accepting a valid pending request should return a chat session ID");
	}

	@Test
	void acceptChatRequest_alreadyAcceptedRequest_returnsEmpty() {
		conn.sendChatRequest(CLIENT_ID_1, CLIENT_ID_2);
		conn.acceptChatRequest(CLIENT_ID_1, CLIENT_ID_2);

		Optional<Integer> chatSessionID = conn.acceptChatRequest(CLIENT_ID_1, CLIENT_ID_2);
		assertFalse(chatSessionID.isPresent(), "Accepting an already-accepted request should return empty");
	}

	@Test
	void acceptChatRequest_nonExistentRequest_returnsEmpty() {
		// No request was ever sent between these two users
		Optional<Integer> chatSessionID = conn.acceptChatRequest(CLIENT_ID_1, CLIENT_ID_2);
		assertFalse(chatSessionID.isPresent(), "Accepting a non-existent request should return empty");
	}

}
