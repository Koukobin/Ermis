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
package github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.data_access;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Optional;

import com.google.common.base.Throwables;

import github.koukobin.ermis.common.util.EmptyArrays;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.generators.ChatSessionIDGenerator;

/**
 * @author Ilias Koukovinis
 *
 */
public interface ChatRequestsHandlerModule extends BaseComponent {

	/**
	 * Accepts a chat request and creates a new chat session.
	 *
	 * @param senderClientID   ID of the client who sent the chat request.
	 * @param receiverClientID ID of the client who received the chat request.
	 * @return the newly created chat session ID. If the creation of the chat
	 *         session fails, returns -1.
	 * @apiNote This method is not thread-safe; if executed simultaneously with
	 *          identical values, multiple unique chat sessions may be created. In
	 *          order to make it thread-safe, synchronize the method or handle
	 *          concurrency externally.
	 * 
	 */
	default Optional<Integer> acceptChatRequest(int receiverClientID, int senderClientID) {
		// This method probably should be refactored in the future...
		String sql = """
				-- Check for an existing chat session
				WITH existing_chat_session AS (
				    SELECT 1
				    FROM chat_sessions s
				    JOIN chat_session_members m1 ON s.chat_session_id = m1.chat_session_id
				    JOIN chat_session_members m2 ON s.chat_session_id = m2.chat_session_id
				    WHERE m1.member_id = ? AND m2.member_id = ?
				),
				-- Check for an existing chat request
				existing_request AS (
				    SELECT 1
				    FROM chat_requests
				    WHERE sender_client_id = ? AND receiver_client_id = ?
				      AND NOT EXISTS (SELECT 1 FROM existing_chat_session)
				),
				-- Create a new chat session if the request exists
				new_session AS (
				    INSERT INTO chat_sessions (chat_session_id)
				    SELECT ?
				    WHERE EXISTS (SELECT 1 FROM existing_request)
				    RETURNING chat_session_id
				),
				-- Add members to the new chat session
				new_session_members AS (
				    INSERT INTO chat_session_members (chat_session_id, member_id)
				    SELECT chat_session_id, ?
				    FROM new_session
				    UNION ALL
				    SELECT chat_session_id, ?
				    FROM new_session
				    RETURNING chat_session_id
				)
				-- Delete the chat request upon successful creation of the chat session
				DELETE FROM chat_requests
				WHERE sender_client_id = ? AND receiver_client_id = ?
				  AND EXISTS (SELECT 1 FROM new_session_members);
				""";

		// Generate a new chat session ID
		int generatedChatSessionID = ChatSessionIDGenerator.retrieveAndDelete(getConn());

		if (generatedChatSessionID == -1) {
			return Optional.empty(); // Return if failed
		}

		Integer chatSessionID = null;
		try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {
			pstmt.setInt(1, senderClientID);
			pstmt.setInt(2, receiverClientID);
			pstmt.setInt(3, senderClientID);
			pstmt.setInt(4, receiverClientID);
			pstmt.setInt(5, generatedChatSessionID);
			pstmt.setInt(6, senderClientID); // Repeated for the INSERT clause
			pstmt.setInt(7, receiverClientID); // Repeated for the INSERT clause
			pstmt.setInt(8, senderClientID); // Repeated for the DELETE clause
			pstmt.setInt(9, receiverClientID); // Repeated for the DELETE clause

			int affectedRows = pstmt.executeUpdate();
			if (affectedRows > 0) {
				// Successfully created chat session
				chatSessionID = generatedChatSessionID;
			} else {
				// Creation failed or chat request does not exist
				ChatSessionIDGenerator.undo(generatedChatSessionID);
			}
		} catch (SQLException sqle) {
			logger.debug("Error accepting chat request", sqle);
		}

		return Optional.ofNullable(chatSessionID);
	}

	default boolean deleteChatRequest(int receiverClientID, int senderClientID) {

		int resultUpdate = 0;

		String query = "DELETE FROM chat_requests WHERE receiver_client_id=? AND sender_client_id=?";
		try (PreparedStatement pstmt = getConn().prepareStatement(query)) {
			pstmt.setInt(1, receiverClientID);
			pstmt.setInt(2, senderClientID);

			resultUpdate = pstmt.executeUpdate();
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return resultUpdate == 1;
	}

	default boolean sendChatRequest(int receiverClientID, int senderClientID) {

		int resultUpdate = 0;

		// No need to check if given client id exists since the chat_requests table
		// references client ids from users table
		try {
			String checkRequestSQL = "SELECT 1 FROM chat_requests WHERE sender_client_id = ? AND receiver_client_id = ?";
			try (PreparedStatement pstmt = getConn().prepareStatement(checkRequestSQL)) {
				pstmt.setInt(1, senderClientID);
				pstmt.setInt(2, receiverClientID);

				ResultSet rs = pstmt.executeQuery();

				if (rs.next()) {
					return false; // Chat request already exists
				}
			}

			String sql = "INSERT INTO chat_requests (receiver_client_id, sender_client_id) VALUES (?, ?)";
			try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {
				pstmt.setInt(1, receiverClientID);
				pstmt.setInt(2, senderClientID);
				resultUpdate = pstmt.executeUpdate();
			}
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return resultUpdate == 1;
	}

	default Integer[] getChatRequests(int clientID) {
		Integer[] friendRequests = EmptyArrays.EMPTY_INTEGER_OBJECT_ARRAY;

		try (PreparedStatement pstmt = getConn()
				.prepareStatement("SELECT sender_client_id FROM chat_requests WHERE receiver_client_id=?;",
						ResultSet.TYPE_SCROLL_SENSITIVE, 
						ResultSet.CONCUR_UPDATABLE)) {

			pstmt.setInt(1, clientID);
			ResultSet rs = pstmt.executeQuery();

			// Move to the last row to get the row count
			rs.last();
			int rowCount = rs.getRow(); // Get total rows
			rs.beforeFirst();

			friendRequests = new Integer[rowCount];

			int i = 0;
			while (rs.next()) {
				friendRequests[i] = rs.getInt("sender_client_id");
				i++;
			}
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return friendRequests;
	}
}
