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

import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

import com.google.common.base.Throwables;

import github.koukobin.ermis.common.LoadedInMemoryFile;
import github.koukobin.ermis.common.message_types.ClientContentType;
import github.koukobin.ermis.common.message_types.UserMessage;
import github.koukobin.ermis.common.util.EmptyArrays;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.ContentTypeConverter;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.FilesStorage;

/**
 * @author Ilias Koukovinis
 *
 */
public interface MessagesService extends BaseComponent, UserProfileModule {

	default boolean deleteChatMessage(int chatSessionID, int messageID) {
		int resultUpdate = 0;

		try {
			try (PreparedStatement deleteMessage = getConn()
					.prepareStatement("DELETE FROM chat_messages WHERE chat_session_id=? AND message_id=?")) {

				deleteMessage.setInt(1, chatSessionID);
				deleteMessage.setInt(2, messageID);

				resultUpdate = deleteMessage.executeUpdate();
			}
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return resultUpdate == 1;
	}

	default Optional<LoadedInMemoryFile> getFile(int messageID, int chatSessionID) {
		LoadedInMemoryFile file = null;

		String query = "SELECT file_content_id, file_name FROM chat_messages WHERE message_id=? AND chat_session_id=?;";
		try (PreparedStatement pstmt = getConn().prepareStatement(query)) {
			pstmt.setInt(1, messageID);
			pstmt.setInt(2, chatSessionID);

			ResultSet rs = pstmt.executeQuery();

			if (!rs.next()) {
				return Optional.empty();
			}

			String fileContentID = rs.getString(1);
			String fileName = new String(rs.getBytes(2));

			byte[] fileContent = FilesStorage.loadUserFile(fileContentID);

			file = new LoadedInMemoryFile(fileName, fileContent);
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		} catch (IOException ioe) {
			logger.error("An error occured while trying to retrieve file associated with message", ioe);
		}

		return Optional.ofNullable(file);
	}

	/**
	 * Fetches chat messages for a given chat session. Additionally, it updates the
	 * delivery status of the messages - i.e it sets is_read = true - except
	 * messages written by the requesting client id. Supports pagination using
	 * offset and limit.
	 *
	 * @param chatSessionId      The ID of the chat session.
	 * 
	 * @param offset             The number of messages to skip (for pagination).
	 * @param limit              The maximum number of messages to retrieve.
	 * @param requestingClientId The ID of the client requesting the messages
	 *                           (messages from this client are excluded).
	 * @return A list of UserMessage objects matching the criteria.
	 */
	default UserMessage[] selectMessages(int chatSessionID, int offset, int limit, int requestingClientID) {
		UserMessage[] messages = EmptyArrays.EMPTY_USER_MESSAGES_ARRAY;

		String fetchMessagesSql = """
				SELECT message_id, client_id, text, file_name, ts_entered, content_type, is_read
					FROM chat_messages
					WHERE chat_session_id = ?
					ORDER BY message_id DESC
					LIMIT ? OFFSET ?
				""";
		try (PreparedStatement selectMessages = getConn().prepareStatement(fetchMessagesSql,
				ResultSet.TYPE_SCROLL_SENSITIVE,
				ResultSet.CONCUR_UPDATABLE /*
											 * Pass these parameters so ResultSets can move forwards and backwards
											 */)) {

			selectMessages.setInt(1, chatSessionID);
			selectMessages.setInt(2, limit);
			selectMessages.setInt(3, offset);
			ResultSet rs = selectMessages.executeQuery();

			if (!rs.next()) {
				return messages;
			}

			// <GET MESSAGES SELECTED NUMBER>
			rs.last();
			int rowCount = rs.getRow();
			rs.first();
			// </GET MESSAGES SELECTED NUMBER>

			messages = new UserMessage[rowCount];

			/*
			 * TODO [2025-05-08]: Retrieving username as well as client id is simply
			 * unnecessary and will simply degrade performance and increase strain on
			 * database. Albeit the performance hit is probably negligible, it should still
			 * be optimized - someday.
			 */
			Map<Integer, String> clientIDSToUsernames = new HashMap<>();

			// reverse messages order from newest to oldest to oldest to newest
			for (int i = rowCount - 1; i >= 0; i--, rs.next()) {
				int messageID = rs.getInt(1);
				int clientID = rs.getInt(2);

				String username = clientIDSToUsernames.get(clientID);

				if (username == null) {
					username = getUsername(clientID).orElse("null");
					clientIDSToUsernames.put(clientID, username);
				}

				byte[] textBytes = rs.getBytes(3);
				byte[] fileNameBytes = rs.getBytes(4);

				Timestamp timeWritten = rs.getTimestamp(5);

				ClientContentType contentType = ContentTypeConverter.getDatabaseIntAsContentType(rs.getInt(6));
				final boolean isRead = rs.getBoolean(7);
				messages[i] = new UserMessage(
						username,
						clientID,
						messageID,
						chatSessionID,
						textBytes,
						fileNameBytes,
						timeWritten.toInstant().getEpochSecond(),
						isRead,
						contentType);
			}
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		String updateIsReadSql = """
					UPDATE chat_messages
				    SET is_read = TRUE
				    WHERE message_id IN (
					    SELECT message_id
					    FROM chat_messages
					    WHERE chat_session_id = ?
					      AND client_id <> ?
					      AND is_read = FALSE
					    ORDER BY message_id DESC
					    LIMIT ? OFFSET ?
					);
				""";
		try (PreparedStatement updateIsRead = getConn().prepareStatement(updateIsReadSql)) {
			updateIsRead.setInt(1, chatSessionID);
			updateIsRead.setInt(2, requestingClientID);
			updateIsRead.setInt(3, limit);
			updateIsRead.setInt(4, offset);

			updateIsRead.executeUpdate();
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return messages;
	}
}
