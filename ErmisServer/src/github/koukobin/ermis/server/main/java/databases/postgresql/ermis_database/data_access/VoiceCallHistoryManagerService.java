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
import java.sql.Timestamp;
import java.time.Instant;

import com.google.common.base.Throwables;

import github.koukobin.ermis.common.VoiceCallHistoryStatus;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.models.PersonalizedVoiceCallHistory;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.models.VoiceCallHistory;

/**
 * @author Ilias Koukovinis
 *
 */
public interface VoiceCallHistoryManagerService extends BaseComponent {

	default void addVoiceCall(VoiceCallHistory call) {
		String sql = """
				INSERT INTO voice_call_history (ts_debuted, ts_ended, chat_session_id, initiator_client_id)
				VALUES (?, ?, ?, ?);
				""";
		try (PreparedStatement stmt = getConn().prepareStatement(sql)) {
			stmt.setTimestamp(1, Timestamp.from(Instant.ofEpochSecond(call.tsDebuted())));
			stmt.setTimestamp(2, Timestamp.from(Instant.ofEpochSecond(call.tsEnded())));
			stmt.setInt(3, call.chatSessionID());
			stmt.setInt(4, call.initiatorClientID());

			stmt.executeUpdate();
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}
	}

	default int addActiveVoiceCall(long tsDebuted, int chatSessionID, int initiatorClientID) {
		String sql = """
				INSERT INTO voice_call_history (ts_debuted, chat_session_id, initiator_client_id)
				VALUES (?, ?, ?)
				RETURNING voice_call_history_id;
				""";

		int voiceCallHistoryID = -1;
		try (PreparedStatement stmt = getConn().prepareStatement(sql)) {
			stmt.setTimestamp(1, Timestamp.from(Instant.ofEpochSecond(tsDebuted)));
			stmt.setInt(2, chatSessionID);
			stmt.setInt(3, initiatorClientID);

			var rs = stmt.executeQuery();

			if (rs.next()) {
				voiceCallHistoryID = rs.getInt(1);
			}
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return voiceCallHistoryID;
	}

	default void setEndedVoiceCall(long tsEnded, int voiceCallID) {
		String sql = """
				UPDATE voice_call_history SET ts_ended = ? WHERE voice_call_history_id = ?;
				""";
		try (PreparedStatement stmt = getConn().prepareStatement(sql)) {
			stmt.setTimestamp(1, Timestamp.from(Instant.ofEpochSecond(tsEnded)));
			stmt.setInt(2, voiceCallID);

			stmt.executeUpdate();
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}
	}
	
	default void addVoiceCallParticipant(int voiceCallHistoryID, int participatorClientID) {
		String sql = """
				INSERT INTO 
				voice_call_history_participants (voice_call_history_id, client_id) 
				VALUES (?, ?)
				ON CONFLICT DO NOTHING;
				""";
		try (PreparedStatement stmt = getConn().prepareStatement(sql)) {
			stmt.setInt(1, voiceCallHistoryID);
			stmt.setInt(2, participatorClientID);

			stmt.executeUpdate();
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}
	}

	default PersonalizedVoiceCallHistory[] getVoiceCall(int chatSessionID, int clientID) {
		String sql = """
				SELECT
				    vch.ts_debuted,
				    vch.ts_ended,
				    vch.initiator_client_id,
				    COALESCE(vchp.client_id, -1) AS client_id
				FROM voice_call_history AS vch
				LEFT JOIN voice_call_history_participants AS vchp
				    ON vchp.voice_call_history_id = vch.voice_call_history_id
				    AND vchp.client_id = ?
				WHERE vch.chat_session_id = ?;
				""";

		PersonalizedVoiceCallHistory[] history = {};
		try (PreparedStatement stmt = getConn().prepareStatement(sql,
				ResultSet.TYPE_SCROLL_SENSITIVE,
				ResultSet.CONCUR_UPDATABLE /*
											 * Pass these parameters so ResultSets can move forwards and backwards
											 */)) {
			stmt.setInt(1, clientID);
			stmt.setInt(2, chatSessionID);

			ResultSet rs = stmt.executeQuery();

			if (!rs.next()) {
				return history;
			}
			
			// <GET VOICE CALLS NUMBER>
			rs.last();
			int rowCount = rs.getRow();
			rs.first();
			// </GET VOICE CALLS NUMBER>

			history = new PersonalizedVoiceCallHistory[rowCount];

			try (rs) {
				// Do-while loop instead of regular while because rs.next was already called
				// once previously
				int i = 0;
				do {
					long tsDebuted = rs.getTimestamp("ts_debuted").toInstant().getEpochSecond();
					long tsEnded;

					{
						var tsEndedTimeStamp = rs.getTimestamp("ts_ended");

						if (tsEndedTimeStamp == null) {
							tsEnded = -1;
						} else {
							tsEnded = tsEndedTimeStamp.toInstant().getEpochSecond();
						}
					}

					int initiatorClientID = rs.getInt("initiator_client_id");
					int clientID0 = rs.getInt("client_id");

					VoiceCallHistoryStatus status;
					{
						if (initiatorClientID == clientID0) {
							status = VoiceCallHistoryStatus.CREATED;
						} else if (clientID0 == clientID) {
							status = VoiceCallHistoryStatus.ACCEPTED;
						} else {
							status = VoiceCallHistoryStatus.IGNORED;
						}
					}

					history[i] = new PersonalizedVoiceCallHistory(
						      new VoiceCallHistory(
						        tsDebuted,
						        tsEnded,
						        chatSessionID,
						        initiatorClientID
						      ),
						      status
						    );
					i++;
				} while (rs.next());
			}
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return history;
	}
}
