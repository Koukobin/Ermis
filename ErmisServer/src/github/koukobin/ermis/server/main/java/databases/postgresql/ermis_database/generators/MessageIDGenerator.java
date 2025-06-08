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
package github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.generators;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * @author Ilias Koukovinis
 *
 */
public final class MessageIDGenerator {

	private static final Logger logger = LogManager.getLogger("database");
	private static final Map<Integer, AtomicInteger> chatSessionIDToMessageID = new ConcurrentHashMap<>();

	private MessageIDGenerator() {}

	/**
	 * Retrieves or initializes the AtomicInteger for the given chat session ID.
	 */
	private static AtomicInteger getMessageIDAtomic(int chatSessionID, Connection conn) {
		return chatSessionIDToMessageID.computeIfAbsent(chatSessionID, (Integer chatSessionIDKey) -> {
			try (PreparedStatement stmt = conn.prepareStatement(
					"SELECT message_id FROM chat_messages WHERE chat_session_id=? ORDER BY message_id DESC LIMIT 1")) {
				stmt.setInt(1, chatSessionIDKey);
				try (ResultSet rs = stmt.executeQuery()) {
					int lastMessageID = rs.next() ? rs.getInt(1) : 0;
					return new AtomicInteger(lastMessageID);
				}
			} catch (SQLException sqle) {
				logger.error("Error initializing message ID for chat session {}", chatSessionIDKey, sqle);
				throw new RuntimeException("Failed to initialize message ID", sqle);
			}
		});
	}

	/**
	 * Increment and retrieve the next message ID for the specified chat session.
	 */
	public static int incrementAndGetMessageID(int chatSessionID, Connection conn) {
		AtomicInteger messageID = getMessageIDAtomic(chatSessionID, conn);
		return messageID.incrementAndGet();
	}

	/**
	 * Retrieve the current message ID count for the specified chat session.
	 */
	public static int getMessageIDCount(int chatSessionID, Connection conn) {
		AtomicInteger messageID = getMessageIDAtomic(chatSessionID, conn);
		return messageID.get();
	}

}
