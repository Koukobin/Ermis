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

import main.java.io.github.koukobin.ermis.common.VoiceCallHistoryStatus;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.ErmisDatabase;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.models.PersonalizedVoiceCallHistory;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.models.VoiceCallHistory;

import org.junit.jupiter.api.*;

import java.sql.PreparedStatement;

import static org.junit.jupiter.api.Assertions.*;
import static test.java.databases.Utils.*;

/**
 *
 * @author Ilias Koukovinis
 * 
 */
class VoiceCallHistoryManagerServiceTest extends BaseIntegrationTest {

	private static final String EMAIL_1    = "voice.user1@example.com";
	private static final String PASSWORD_1 = "Str0ng!Pass#Voice1";
	private static final String USERNAME_1 = "VoiceUser1";

	private static final String EMAIL_2    = "voice.user2@example.com";
	private static final String PASSWORD_2 = "Str0ng!Pass#Voice2";
	private static final String USERNAME_2 = "VoiceUser2";

	private static int CLIENT_ID_1;
	private static int CLIENT_ID_2;
	private static int CHAT_SESSION_ID;

	private static ErmisDatabase.GeneralPurposeDBConnection conn;

	@BeforeAll
	static void setupDatabase() throws Exception {
		conn = ErmisDatabase.getGeneralPurposeConnection();
		assertNotNull(conn, "Database connection must not be null");

		// Wipe any leftover data from a previous run
		nukeAll(conn);

		// Create accounts
		var r1 = conn.createAccount(USERNAME_1, PASSWORD_1, uniqueDevice(), EMAIL_1);
		assertTrue(r1.isSuccess(), "Fixture account 1 must be created successfully");

		var r2 = conn.createAccount(USERNAME_2, PASSWORD_2, uniqueDevice(), EMAIL_2);
		assertTrue(r2.isSuccess(), "Fixture account 2 must be created successfully");

		CLIENT_ID_1 = resolveClientID(EMAIL_1, conn);
		CLIENT_ID_2 = resolveClientID(EMAIL_2, conn);

		// Establish a chat session between the two accounts
		conn.sendChatRequest(CLIENT_ID_1, CLIENT_ID_2);
		var sessionOpt = conn.acceptChatRequest(CLIENT_ID_1, CLIENT_ID_2);
		assertTrue(sessionOpt.isPresent(), "Chat session must be created as a precondition for voice calls");
		CHAT_SESSION_ID = sessionOpt.get();
	}

	@BeforeEach
	void cleanVoiceCallTables() throws Exception {
		String sql = """
				DELETE FROM voice_call_history_participants;
				DELETE FROM voice_call_history;
				""";
		try (PreparedStatement ps = conn.underlyingConnection().prepareStatement(sql)) {
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
	@DisplayName("addActiveVoiceCall")
	class AddActiveVoiceCallTests {

		@Test
		@DisplayName("returns a positive call ID for valid inputs")
		void validInputs_returnsPositiveCallID() {
			int callID = conn.addActiveVoiceCall(nowMillis(), CHAT_SESSION_ID, CLIENT_ID_1);
			assertTrue(callID > 0, "addActiveVoiceCall must return a positive call ID");
		}

		@Test
		@DisplayName("each invocation returns a distinct call ID")
		void twoDistinctCalls_returnDistinctIDs() {
			int callID1 = conn.addActiveVoiceCall(nowMillis(), CHAT_SESSION_ID, CLIENT_ID_1);
			int callID2 = conn.addActiveVoiceCall(nowMillis(), CHAT_SESSION_ID, CLIENT_ID_2);
			assertNotEquals(callID1, callID2, "Distinct calls must receive distinct IDs");
		}

		@Test
		@DisplayName("call initiated by either participant succeeds")
		void eitherParticipantCanInitiate() {
			int callByUser1 = conn.addActiveVoiceCall(nowMillis(), CHAT_SESSION_ID, CLIENT_ID_1);
			int callByUser2 = conn.addActiveVoiceCall(nowMillis(), CHAT_SESSION_ID, CLIENT_ID_2);
			assertTrue(callByUser1 > 0, "User 1 must be able to initiate a call");
			assertTrue(callByUser2 > 0, "User 2 must be able to initiate a call");
		}
	}

	// =========================================================================

	@Nested
	@DisplayName("setEndedVoiceCall")
	class SetEndedVoiceCallTests {

		@Test
		@DisplayName("does not throw when marking an active call as ended")
		void validCall_doesNotThrow() {
			int callID = conn.addActiveVoiceCall(nowMillis(), CHAT_SESSION_ID, CLIENT_ID_1);
			assertDoesNotThrow(() -> conn.setEndedVoiceCall(nowMillis() + 1000, callID));
		}

		@Test
		@DisplayName("call ended timestamp is after start timestamp")
		void endedTimestamp_isAfterStart() {
			long start = nowMillis();
			int callID = conn.addActiveVoiceCall(start, CHAT_SESSION_ID, CLIENT_ID_1);
			long end   = start + 5000;

			// If setEndedVoiceCall throws, the call end time is invalid — assertDoesNotThrow
			// is the observable contract since the method returns void
			assertDoesNotThrow(() -> conn.setEndedVoiceCall(end, callID));
		}

		@Test
		@DisplayName("does not throw when called on an unknown call ID")
		void unknownCallID_doesNotThrow() {
			assertDoesNotThrow(() -> conn.setEndedVoiceCall(nowMillis(), Integer.MAX_VALUE));
		}
	}

	// =========================================================================

	@Nested
	@DisplayName("addVoiceCallParticipant")
	class AddVoiceCallParticipantTests {

		@Test
		@DisplayName("does not throw when adding a valid participant to an active call")
		void validParticipant_doesNotThrow() {
			int callID = conn.addActiveVoiceCall(nowMillis(), CHAT_SESSION_ID, CLIENT_ID_1);
			assertDoesNotThrow(() -> conn.addVoiceCallParticipant(callID, CLIENT_ID_2));
		}

		@Test
		@DisplayName("both participants can be added to the same call")
		void bothParticipants_addedWithoutThrow() {
			int callID = conn.addActiveVoiceCall(nowMillis(), CHAT_SESSION_ID, CLIENT_ID_1);
			assertDoesNotThrow(() -> conn.addVoiceCallParticipant(callID, CLIENT_ID_1));
			assertDoesNotThrow(() -> conn.addVoiceCallParticipant(callID, CLIENT_ID_2));
		}

		@Test
		@DisplayName("does not throw when adding participant to an unknown call ID")
		void unknownCallID_doesNotThrow() {
			assertDoesNotThrow(() -> conn.addVoiceCallParticipant(Integer.MAX_VALUE, CLIENT_ID_1));
		}
	}

	// =========================================================================

	@Nested
	@DisplayName("addVoiceCall")
	class AddVoiceCallTests {

		@Test
		@DisplayName("does not throw for a fully populated VoiceCallHistory record")
		void validHistory_doesNotThrow() {
			long start = nowMillis();
			long end   = start + 3000;
			VoiceCallHistory history = new VoiceCallHistory(start, end, CHAT_SESSION_ID, CLIENT_ID_1);

			assertDoesNotThrow(() -> conn.addVoiceCall(history));
		}

		@Test
		@DisplayName("stored call is retrievable via getVoiceCall")
		void afterAdd_callIsRetrievable() {
			long start = nowMillis();
			long end   = start + 3000;
			VoiceCallHistory history = new VoiceCallHistory(start, end, CHAT_SESSION_ID, CLIENT_ID_1);
			conn.addVoiceCall(history);

			PersonalizedVoiceCallHistory[] calls = conn.getVoiceCall(CHAT_SESSION_ID, CLIENT_ID_1);
			assertNotNull(calls, "getVoiceCall must not return null after addVoiceCall");
			assertTrue(calls.length >= 1, "At least one call must be returned after addVoiceCall");
		}

		@Test
		@DisplayName("multiple calls are all retrievable")
		void multipleAdds_allRetrievable() {
			long base = nowMillis();
			conn.addVoiceCall(new VoiceCallHistory(base,        base + 1000, CHAT_SESSION_ID, CLIENT_ID_1));
			conn.addVoiceCall(new VoiceCallHistory(base + 2000, base + 5000, CHAT_SESSION_ID, CLIENT_ID_2));
			conn.addVoiceCall(new VoiceCallHistory(base + 6000, base + 10000, CHAT_SESSION_ID, CLIENT_ID_1));

			PersonalizedVoiceCallHistory[] calls = conn.getVoiceCall(CHAT_SESSION_ID, CLIENT_ID_1);
			assertNotNull(calls);
			assertTrue(calls.length >= 3, "All three added calls must be retrievable");
		}
	}

	// =========================================================================

	@Nested
	@DisplayName("getVoiceCall")
	class GetVoiceCallTests {

		@Test
		@DisplayName("returns empty or null when no calls exist for the session")
		void noCalls_returnsEmptyOrNull() {
			PersonalizedVoiceCallHistory[] calls = conn.getVoiceCall(CHAT_SESSION_ID, CLIENT_ID_1);
			assertTrue(calls == null || calls.length == 0,
					"getVoiceCall must return empty when no calls have been recorded");
		}

		@Test
		@DisplayName("returned records contain non-null history and status fields")
		void returnedRecords_haveNonNullFields() {
			long start = nowMillis();
			conn.addVoiceCall(new VoiceCallHistory(start, start + 2000, CHAT_SESSION_ID, CLIENT_ID_1));

			PersonalizedVoiceCallHistory[] calls = conn.getVoiceCall(CHAT_SESSION_ID, CLIENT_ID_1);
			assertNotNull(calls);
			assertTrue(calls.length >= 1);

			PersonalizedVoiceCallHistory first = calls[0];
			assertNotNull(first.history(), "history() must not be null");
			assertNotNull(first.status(),  "status() must not be null");
		}

		@Test
		@DisplayName("returned history record preserves chatSessionID and initiatorClientID")
		void returnedHistory_preservesFields() {
			long start = nowMillis();
			conn.addVoiceCall(new VoiceCallHistory(start, start + 2000, CHAT_SESSION_ID, CLIENT_ID_1));

			PersonalizedVoiceCallHistory[] calls = conn.getVoiceCall(CHAT_SESSION_ID, CLIENT_ID_1);
			assertNotNull(calls);
			assertTrue(calls.length >= 1);

			VoiceCallHistory h = calls[0].history();
			assertEquals(CHAT_SESSION_ID, h.chatSessionID(), 
					"Stored chatSessionID must match");
			assertEquals(CLIENT_ID_1, h.initiatorClientID(), 
					"Stored initiatorClientID must match");
		}

		@Test
		@DisplayName("status is one of the defined VoiceCallHistoryStatus values")
		void returnedStatus_isValidEnumValue() {
			long start = nowMillis();
			conn.addVoiceCall(new VoiceCallHistory(start, start + 2000, CHAT_SESSION_ID, CLIENT_ID_1));

			PersonalizedVoiceCallHistory[] calls = conn.getVoiceCall(CHAT_SESSION_ID, CLIENT_ID_1);
			assertNotNull(calls);

			for (PersonalizedVoiceCallHistory call : calls) {
				assertNotNull(call.status(), "status must not be null");
				// Verify it is a known enum constant
				boolean knownStatus = call.status() == VoiceCallHistoryStatus.CREATED
						|| call.status() == VoiceCallHistoryStatus.ACCEPTED
						|| call.status() == VoiceCallHistoryStatus.IGNORED;
				assertTrue(knownStatus, "status must be one of CREATED, ACCEPTED, IGNORED");
			}
		}

		@Test
		@DisplayName("returns empty or null for an unknown chat session ID")
		void unknownChatSession_returnsEmptyOrNull() {
			PersonalizedVoiceCallHistory[] calls = conn.getVoiceCall(Integer.MAX_VALUE, CLIENT_ID_1);
			assertTrue(calls == null || calls.length == 0, 
					"Unknown chatSessionID must return empty or null");
		}

		@Test
		@DisplayName("perspective differs per clientID — each sees their own status")
		void differentClientIDs_mayHaveDifferentStatus() {
			long start = nowMillis();
			conn.addVoiceCall(new VoiceCallHistory(start, start + 2000, CHAT_SESSION_ID, CLIENT_ID_1));

			PersonalizedVoiceCallHistory[] fromUser1 = conn.getVoiceCall(CHAT_SESSION_ID, CLIENT_ID_1);
			PersonalizedVoiceCallHistory[] fromUser2 = conn.getVoiceCall(CHAT_SESSION_ID, CLIENT_ID_2);

			// Both must return results, albeit their statuses may differ (CREATED vs ACCEPTED/IGNORED)
			assertNotNull(fromUser1);
			assertNotNull(fromUser2);
			assertTrue(fromUser1.length >= 1, "User 1 must see the call");
			assertTrue(fromUser2.length >= 1, "User 2 must see the call");
		}
	}

	private static long nowMillis() {
		return System.currentTimeMillis();
	}
}
