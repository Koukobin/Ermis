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
package github.koukobin.ermis.desktop_client.main.java.database;

import java.net.MalformedURLException;
import java.net.PortUnreachableException;
import java.net.URL;
import java.net.UnknownHostException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import github.koukobin.ermis.common.util.FileUtils;
import github.koukobin.ermis.desktop_client.main.java.database.models.DatabaseChatMessage;
import github.koukobin.ermis.desktop_client.main.java.database.models.LocalAccountInfo;
import github.koukobin.ermis.desktop_client.main.java.database.models.ServerInfo;
import github.koukobin.ermis.desktop_client.main.java.info.GeneralAppInfo;

/**
 * @author Ilias Koukovinis
 *
 */
public final class ClientDatabase {

	private static final Logger logger = LoggerFactory.getLogger(ClientDatabase.class);
	
	private static final DBConnection conn = new DBConnection();
	
	private ClientDatabase() throws IllegalAccessException {
		throw new IllegalAccessException("Database cannot be constructed since it is statically initialized!");
	}

	public static DBConnection getDBConnection() {
		return conn;
	}
	
	public static class DBConnection {

		private static final String JDBC_URL;

		static {
			JDBC_URL = "jdbc:sqlite:" + GeneralAppInfo.CLIENT_DATABASE_PATH;
		}

		private final Connection conn;

		private DBConnection() {
			try {
				conn = createConnection();

				class DatabaseSetup {
					private static boolean isInitialized = false;

					private DatabaseSetup() {}

					public static void initialize(Connection conn) {
						if (isInitialized) {
							return;
						}

						String setupSQL = FileUtils.readFile(ClientDatabase.class.getResourceAsStream(GeneralAppInfo.CLIENT_DATABASE_SETUP_FILE_PATH));

						// Since `stmt.executeUpdate()` doesn’t support running multiple queries separated by
						// semicolons (;) in SQLite, we are forced to separate each query
						// and run it individually.
						String[] individualQueries = setupSQL.split(";");
						try (Statement stmt = conn.createStatement()) {
							for (String query : individualQueries) {
								stmt.executeUpdate(query);
							}
						} catch (SQLException sqle) {
							throw new RuntimeException(sqle);
						}

						isInitialized = true;
					}
				}

				DatabaseSetup.initialize(conn);
			} catch (SQLException sqle) {
				throw new RuntimeException(sqle);
			}
		}

		private static Connection createConnection() throws SQLException {
			return DriverManager.getConnection(JDBC_URL);
		}

		public int addServerInfo(ServerInfo serverInfo) {
			int resultUpdate = 0;

			try (PreparedStatement addServerInfo = conn.prepareStatement("INSERT INTO server_info (server_url) VALUES(?);")) {
				addServerInfo.setString(1, serverInfo.getURL().toString());

				resultUpdate = addServerInfo.executeUpdate();
			} catch (SQLException sqle) {
				logger.error(sqle.getMessage(), sqle);
			}

			return resultUpdate;
		}

		public int removeServerInfo(ServerInfo serverInfo) {
			int resultUpdate = 0;

			try (PreparedStatement addServerInfo = conn.prepareStatement("DELETE FROM server_info WHERE server_url=?;")) {
				addServerInfo.setString(1, serverInfo.getURL().toString());

				resultUpdate = addServerInfo.executeUpdate();
			} catch (SQLException sqle) {
				logger.error(sqle.getMessage(), sqle);
			}

			return resultUpdate;
		}

		public int setServerInfo(ServerInfo serverInfo) {
			int resultUpdate = 0;

			try (PreparedStatement addServerInfo = conn.prepareStatement("UPDATE server_info SET server_url=?;")) {
				addServerInfo.setString(1, serverInfo.getURL().toString());

				resultUpdate = addServerInfo.executeUpdate();
			} catch (SQLException sqle) {
				logger.error(sqle.getMessage(), sqle);
			}

			return resultUpdate;
		}

		public ServerInfo[] getServerInfos() {
			List<ServerInfo> serverInfos = new ArrayList<>();
			try (PreparedStatement addServerInfo = conn.prepareStatement("SELECT * FROM server_info;")) {
				ResultSet rs = addServerInfo.executeQuery();

				while (rs.next()) {
					String serverURL = rs.getString(1);
					serverInfos.add(new ServerInfo(new URL(serverURL)));
				}
			} catch (SQLException | UnknownHostException | PortUnreachableException | MalformedURLException e) {
				logger.error(e.getMessage(), e);
			}

			return serverInfos.toArray(new ServerInfo[] {});
		}

		public int addUserAccount(ServerInfo serverInfo, LocalAccountInfo userAccount) {
			int result = 0;

			String sql = """
					INSERT OR REPLACE INTO
					server_accounts (server_url, email, password_hash, device_uuid, last_used)
					VALUES (?, ?, ?, ?, ?);
					""";
			try (PreparedStatement ps = conn.prepareStatement(sql)) {
				Timestamp timeStamp = new Timestamp(userAccount.getLastUsed().toEpochSecond(ZoneOffset.UTC));
				ps.setString(1, serverInfo.getURL().toString());
				ps.setString(2, userAccount.getEmail());
				ps.setString(3, userAccount.getPasswordHash());
				ps.setString(4, userAccount.getDeviceUUID().toString());
				ps.setTimestamp(5, timeStamp);

				result = ps.executeUpdate();
			} catch (SQLException e) {
				logger.error(e.getMessage(), e);
			}

			return result;
		}

		public Optional<LocalAccountInfo> getLastUsedAccount(ServerInfo serverInfo) {
			LocalAccountInfo account = null;

			String sql = "SELECT email, password_hash, device_uuid, last_used FROM server_accounts WHERE server_url = ? ORDER BY last_used DESC LIMIT 1;";
			try (PreparedStatement ps = conn.prepareStatement(sql)) {
				ps.setString(1, serverInfo.getURL().toString());
				ResultSet rs = ps.executeQuery();

				if (rs.next()) {
					String email = rs.getString("email");
					String passwordHash = rs.getString("password_hash");
					UUID deviceUUID = UUID.fromString(rs.getString("device_uuid"));
					Timestamp lastUsed = rs.getTimestamp("last_used");
					account = new LocalAccountInfo(email, passwordHash, deviceUUID, lastUsed.toLocalDateTime());
				}
			} catch (SQLException sqle) {
				logger.error(sqle.getMessage(), sqle);
			}

			return Optional.ofNullable(account);
		}

		public List<LocalAccountInfo> getUserAccounts(ServerInfo serverInfo) {
			List<LocalAccountInfo> accounts = new ArrayList<>();
			String sql = "SELECT email, password_hash, device_uuid, last_used FROM server_accounts WHERE server_url = ?;";

			try (PreparedStatement ps = conn.prepareStatement(sql)) {
				ps.setString(1, serverInfo.getURL().toString());
				ResultSet rs = ps.executeQuery();

				while (rs.next()) {
					String email = rs.getString("email");
					String passwordHash = rs.getString("password_hash");
					UUID deviceUUID = UUID.fromString(rs.getString("device_uuid"));
					Timestamp lastUsed = rs.getTimestamp("last_used");
					accounts.add(new LocalAccountInfo(email, passwordHash, deviceUUID, lastUsed.toLocalDateTime()));
				}
			} catch (SQLException e) {
				logger.error(e.getMessage(), e);
			}

			return accounts;
		}

		public int addChatSession(ServerInfo serverInfo, int chatSessionId) {
			int result = 0;
			String sql = "INSERT INTO chat_sessions (server_url, chat_session_id) VALUES (?, ?);";

			try (PreparedStatement ps = conn.prepareStatement(sql)) {
				ps.setString(1, serverInfo.getURL().toString());
				ps.setInt(2, chatSessionId);

				result = ps.executeUpdate();
			} catch (SQLException e) {
				logger.error(e.getMessage(), e);
			}

			return result;
		}

		public int removeChatSession(ServerInfo serverInfo, int chatSessionId) {
			int result = 0;
			String sql = "DELETE FROM chat_sessions WHERE server_url = ? AND chat_session_id = ?;";

			try (PreparedStatement ps = conn.prepareStatement(sql)) {
				ps.setString(1, serverInfo.getURL().toString());
				ps.setInt(2, chatSessionId);

				result = ps.executeUpdate();
			} catch (SQLException sqle) {
				logger.error(sqle.getMessage(), sqle);
			}

			return result;
		}

		public int addChatMessage(ServerInfo serverInfo, DatabaseChatMessage message) {
			int result = 0;
			String sql = "INSERT INTO chat_messages (server_url, chat_session_id, message_id, client_id, text, file_name, content_type, ts_entered) "
					+ "VALUES (?, ?, ?, ?, ?, ?, ?, ?);";

			try (PreparedStatement ps = conn.prepareStatement(sql)) {
				Timestamp date = new Timestamp(message.getTimeWritten());

				ps.setString(1, serverInfo.getURL().toString());
				ps.setInt(2, message.getChatSessionID());
				ps.setInt(3, message.getMessageID());
				ps.setInt(4, message.getClientID());
				ps.setString(5, message.getText());
				ps.setString(6, new String(message.getFileName()));
				ps.setInt(7, message.getContentType().id);
				ps.setTimestamp(8, date);

				result = ps.executeUpdate();
			} catch (SQLException sqle) {
				logger.error(sqle.getMessage(), sqle);
			}

			return result;
		}

		public int removeChatMessage(ServerInfo serverInfo, int chatSessionId, int messageID) {
			int result = 0;
			String sql = "DELETE FROM chat_messages WHERE server_url = ? AND chat_session_id = ? AND message_id = ?;";

			try (PreparedStatement ps = conn.prepareStatement(sql)) {
				ps.setString(1, serverInfo.getURL().toString());
				ps.setInt(2, chatSessionId);
				ps.setInt(3, messageID);
				result = ps.executeUpdate();

			} catch (SQLException e) {
				logger.error(e.getMessage(), e);
			}

			return result;
		}
	}

}
