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
import java.util.ArrayList;
import java.util.Collections;
import java.util.Deque;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ConcurrentLinkedDeque;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.google.common.base.Throwables;

import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.data_access.VoiceCallHistoryManagerService;

/**
 * @author Ilias Koukovinis
 *
 */
public final class ClientIDGenerator {

	private static final Logger logger = LogManager.getLogger("database");

	private static final Object lockObjectForGeneratingOrRetrievingClientIDS = new Object();

	private static final int IDS_PER_GENERATION = 5_000;

	/**
	 * It is quintessential for client ids to start <strong>after</strong> 0. This
	 * is because when accessing the database, in some instances (at the time of
	 * writing this the only such instance is:
	 * {@link VoiceCallHistoryManagerService#getVoiceCall(int, int)}), in order to
	 * retrieve client ids from a table rs.getInt() is used; the problem with this
	 * method is that <strong>if</strong> the database integer <strong>field is
	 * nullable - .getInt() returns 0.</strong> Consequently, <strong>there is a
	 * very slight chance that a user has a client id of 0 and rs.getInt() returns 0
	 * because the field is null</strong>, ultimately resulting in confusion.
	 * 
	 * <dl>
	 * </dl>
	 * 
	 * By ensuring that the lowest client id generetable is 1, this issue is
	 * eliminated.
	 * 
	 * <dl>
	 * </dl>
	 * 
	 * @Note This issue is relevant only because client id is nullable in a database
	 *       table - hence the reason this does not apply to chat session id
	 *       generation as well.
	 * 
	 */
	private static final int LOWEST_CLIENT_ID = 1;

	private static final Deque<Integer> clientIDS = new ConcurrentLinkedDeque<>();

	private ClientIDGenerator() {}

	/**
	 * 
	 * @param conn Connection to ermis database
	 */
	public static void generateAvailableClientIDS(Connection connToDatabase) {
		synchronized (lockObjectForGeneratingOrRetrievingClientIDS) {
			try (PreparedStatement pstmt = connToDatabase.prepareStatement(
					"SELECT client_id FROM users;",
					ResultSet.TYPE_SCROLL_SENSITIVE,
					ResultSet.CONCUR_UPDATABLE)) {

				ResultSet rs = pstmt.executeQuery();

				Set<Integer> usedIDs = new HashSet<>();
				while (rs.next()) {
					usedIDs.add(rs.getInt(1));
				}

				List<Integer> availableIDs = new ArrayList<>(IDS_PER_GENERATION);
				for (int id = LOWEST_CLIENT_ID; availableIDs.size() <= IDS_PER_GENERATION; id++) {
					if (!usedIDs.contains(id)) {
						availableIDs.add(id);
					}
				}

				Collections.shuffle(availableIDs);
				clientIDS.addAll(availableIDs);
			} catch (SQLException sqle) {
				logger.fatal(Throwables.getStackTraceAsString(sqle));
				throw new RuntimeException(sqle);
			}
		}
	}

	public static int retrieveAndDelete(Connection conn) {
		int id = retrieve(conn);
		if (id != -1) {
			delete(id);
		}
		return id;
	}

	public static void undo(int chatSessionID) {
		clientIDS.add(chatSessionID);
	}

	private static int retrieve(Connection conn) {
		if (clientIDS.isEmpty()) {
			generateAvailableClientIDS(conn);

			if (clientIDS.isEmpty()) {
				logger.warn("Failed to retrieve a client ID; no IDs available.");
				return -1;
			}
		}

		return clientIDS.peekLast();
	}

	private static void delete(Integer chatSessionID) {
		boolean removed = clientIDS.remove(chatSessionID);
		if (!removed) {
			logger.warn("Attempted to delete a non-existent client ID: {}", chatSessionID);
		}
	}

}
