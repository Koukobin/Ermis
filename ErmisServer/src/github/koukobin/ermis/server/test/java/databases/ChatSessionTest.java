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
package github.koukobin.ermis.server.test.java.databases;

import java.sql.PreparedStatement;
import java.util.Optional;

import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.ErmisDatabase;

/**
 * @author Ilias Koukovinis
 *
 */
public class ChatSessionTest {

	private static ErmisDatabase.GeneralPurposeDBConnection conn;

	@BeforeAll
	static void setupDatabase() {
		conn = ErmisDatabase.getGeneralPurposeConnection();
	}

	@BeforeEach
	void populateTestData() throws Exception {
		String cleanupSql = "DELETE FROM chat_requests; DELETE FROM chat_sessions;";
		try (PreparedStatement pstmt = conn.underlyingConnection().prepareStatement(cleanupSql)) {
			pstmt.executeUpdate();
		}
	}

	@Test
	void testCreateChatSessionSuccess() throws Exception {
		boolean result = conn.sendChatRequest(1, 2);
		assert result;

		result = conn.sendChatRequest(1, 2);
		assert !result;
	}

	@Test
	void testCreateChatSessionFailure() throws Exception {
		conn.sendChatRequest(1, 2);

		Optional<Integer> chatSessionID = conn.acceptChatRequest(1, 2);
		assert chatSessionID.isPresent();

		chatSessionID = conn.acceptChatRequest(1, 2);
		assert chatSessionID.isPresent();
	}

	@AfterAll
	static void cleanupDatabase() {
		conn.close();
	}
}
