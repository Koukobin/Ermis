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

import com.google.common.base.Throwables;

import github.koukobin.ermis.common.util.EmptyArrays;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.generators.ChatSessionIDGenerator;
import github.koukobin.ermis.server.main.java.server.netty_handlers.ClientUpdate;

/**
 * @author Ilias Koukovinis
 *
 */
public interface ChatSessionsManagerModule extends BaseComponent {
	
	default int createChat(int... members) {
		int chatSessionID = ChatSessionIDGenerator.retrieveAndDelete(getConn());

		if (chatSessionID == -1) {
			return chatSessionID;
		}

		String createChatSQL = "INSERT INTO chat_sessions (chat_session_id) VALUES(?) ON CONFLICT DO NOTHING;";
		try (PreparedStatement psmtp = getConn().prepareStatement(createChatSQL)) {
			psmtp.setInt(1, chatSessionID);
			int resultUpdate = psmtp.executeUpdate();

			if (resultUpdate == 1) {
				insertMembersToChatSession(chatSessionID, members);
			} else {
				ChatSessionIDGenerator.undo(chatSessionID); // In case of failure, return session id
				chatSessionID = -1;
			}
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
			ChatSessionIDGenerator.undo(chatSessionID); // In case of failure, return session id
			chatSessionID = -1;
		}

		return chatSessionID;
	}

	default boolean deleteChatSession(int chatSessionID) {
		int resultUpdate = 0;

		// chat_session_members auto-deleted by CASCADE
		String query = "DELETE FROM chat_sessions WHERE chat_session_id = ?;";
		try (PreparedStatement pstmt = getConn().prepareStatement(query)) {
			pstmt.setInt(1, chatSessionID);
			resultUpdate = pstmt.executeUpdate();
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return resultUpdate == 1;
	}

	/**
	 * This can be used by two users who have already established a chat session,
	 * add another mutual acquaintance
	 * 
	 */
	default boolean addUserToChatSession(int chatSessionID, int memberID) {

		int resultUpdate = 0;

		String query = "INSERT INTO chat_session_members (chat_session_id, member_id) VALUES (?, ?);";
		try (PreparedStatement pstmt = getConn().prepareStatement(query)) {
			pstmt.setInt(1, chatSessionID);
			pstmt.setInt(2, memberID);
			resultUpdate = pstmt.executeUpdate();
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return resultUpdate == 1;
	}

	/**
	 * 
	 * @returns the ids of the chat sessions that the user belongs to.
	 */
	default Integer[] getChatSessionsUserBelongsTo(int clientID) {
		Integer[] chatSessions = EmptyArrays.EMPTY_INTEGER_OBJECT_ARRAY;

		try (PreparedStatement getChatSessionIDS = getConn().prepareStatement(
				"SELECT chat_session_id FROM chat_session_members WHERE member_id=?;",
				ResultSet.TYPE_SCROLL_SENSITIVE,
				ResultSet.CONCUR_UPDATABLE /*
											 * Pass these parameters so ResultSets can move forwards and backwards
											 */)) {

			getChatSessionIDS.setInt(1, clientID);
			ResultSet rs = getChatSessionIDS.executeQuery();

			if (!rs.next()) {
				return chatSessions;
			}

			// Move to the last row to get the row count
			rs.last();
			int rowCount = rs.getRow(); // Get total rows
			rs.beforeFirst();

			chatSessions = new Integer[rowCount];

			int i = 0;
			while (rs.next()) {
				Integer chatSessionID = rs.getInt(1);
				chatSessions[i] = chatSessionID;
				i++;
			}
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return chatSessions;
	}

	/**
	 * 
	 * @return the client ids of the members in a chat session
	 */
	default Integer[] getMembersOfChatSession(int chatSessionID) {
		Integer[] members = EmptyArrays.EMPTY_INTEGER_OBJECT_ARRAY;

		try (PreparedStatement getMembersOfChatSessions = getConn().prepareStatement(
				"SELECT member_id FROM chat_session_members WHERE chat_session_id=?;", 
				ResultSet.TYPE_SCROLL_SENSITIVE,
				ResultSet.CONCUR_UPDATABLE /*
											 * Pass these parameters so ResultSets can move forwards and backwards
											 */)) {

			getMembersOfChatSessions.setInt(1, chatSessionID);
			ResultSet rs = getMembersOfChatSessions.executeQuery();

			// Move to the last row to get the row count
			rs.last();
			int rowCount = rs.getRow(); // Get total rows
			rs.beforeFirst();

			members = new Integer[rowCount];

			int i = 0;
			while (rs.next()) {
				Integer memberID = rs.getInt(1);
				members[i] = memberID;
				i++;
			}
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return members;
	}

	default ClientUpdate[] getWhenChatSessionMembersProfilesWereLastUpdated(int chatSessionID) {
		ClientUpdate[] members = {};

		String query = """
				SELECT up.client_id, up.last_updated_at
				FROM user_profiles up
				JOIN chat_session_members csm ON up.client_id = csm.member_id
				WHERE csm.chat_session_id = ?;
				""";
		try (PreparedStatement pstmt = getConn().prepareStatement(
				query,
				ResultSet.TYPE_SCROLL_SENSITIVE,
				ResultSet.CONCUR_UPDATABLE /*
											 * Pass these parameters so ResultSets can move forwards and backwards
											 */)) {

			pstmt.setInt(1, chatSessionID);
			ResultSet rs = pstmt.executeQuery();

			// Move to the last row to get the row count
			rs.last();
			int rowCount = rs.getRow(); // Get total rows
			rs.beforeFirst();

			members = new ClientUpdate[rowCount];

			int i = 0;
			while (rs.next()) {
				int memberID = rs.getInt(1);
				long lastUpdatedProfileAtEpochSecond = rs.getTimestamp(2).toInstant().getEpochSecond();
				members[i] = new ClientUpdate(memberID, lastUpdatedProfileAtEpochSecond);
				i++;
			}
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return members;
	}

	default void insertMembersToChatSession(int chatSessionID, int[] members) {
		String insertMembers = "INSERT INTO chat_session_members (chat_session_id, member_id) VALUES(?, ?) ON CONFLICT DO NOTHING;";
		try (PreparedStatement psmtp = getConn().prepareStatement(insertMembers)) {

			for (int i = 0; i < members.length; i++) {
				psmtp.setInt(1, chatSessionID);
				psmtp.setInt(2, members[i]);
				psmtp.addBatch();
			}

			psmtp.executeBatch();
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}
	}
}
