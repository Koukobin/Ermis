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
package main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database;
 
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.flywaydb.core.Flyway;

import com.google.common.base.Throwables;
import com.zaxxer.hikari.HikariDataSource;

import main.java.io.github.koukobin.ermis.server.configs.DatabaseSettings;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.PostgreSQLDatabase;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.data_access.AccountRepository;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.data_access.AuthService;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.data_access.BackupVerificationCodesModule;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.data_access.ChangePasswordService;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.data_access.ChatRequestsHandlerModule;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.data_access.ChatSessionsManagerModule;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.data_access.MessagesService;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.data_access.UserCredentialsRepository;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.data_access.UserDevicesManagerService;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.data_access.UserProfileModule;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.data_access.VoiceCallHistoryManagerService;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.generators.ChatSessionIDGenerator;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.generators.ClientIDGenerator;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.generators.MessageIDGenerator;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.models.DatabaseChatMessage;

/**
 * @author Ilias Koukovinis
 *
 */
public final class ErmisDatabase {

	private static final Logger logger;
	private static final HikariDataSource generalPurposeDataSource;
	private static final HikariDataSource writeChatMessagesDataSource;

	private ErmisDatabase() throws IllegalAccessException {
		throw new IllegalAccessException("Database cannot be constructed since it is statically initialized!");
	}

	public static void initialize() {
		// Helper method to initialize class
	}

	static {
		logger = LogManager.getLogger("database");
	}

	static {
		try {
			generalPurposeDataSource = new PostgreSQLDatabase.HikariDataSourceBuilder()
					.setUser(DatabaseSettings.USER)
					.setServerNames(DatabaseSettings.DATABASE_ADDRESS)
					.setDatabaseName(DatabaseSettings.DATABASE_NAME)
					.setUserPassword(DatabaseSettings.USER_PASSWORD)
					.setPortNumbers(DatabaseSettings.DATABASE_PORT)
					.addDriverProperties(DatabaseSettings.Driver.getDriverProperties())
					.setMinimumIdle(DatabaseSettings.ConnectionPool.GeneralPurposePool.MIN_IDLE)
					.setMaximumPoolSize(DatabaseSettings.ConnectionPool.GeneralPurposePool.MAX_POOL_SIZE)
					.setConnectionTimeout(0)
					.build();

			writeChatMessagesDataSource = new PostgreSQLDatabase.HikariDataSourceBuilder()
					.setUser(DatabaseSettings.USER)
					.setServerNames(DatabaseSettings.DATABASE_ADDRESS)
					.setDatabaseName(DatabaseSettings.DATABASE_NAME)
					.setUserPassword(DatabaseSettings.USER_PASSWORD)
					.setPortNumbers(DatabaseSettings.DATABASE_PORT)
					.addDriverProperties(DatabaseSettings.Driver.getDriverProperties())
					.setMinimumIdle(DatabaseSettings.ConnectionPool.WriteChatMessagesPool.MIN_IDLE)
					.setMaximumPoolSize(DatabaseSettings.ConnectionPool.WriteChatMessagesPool.MAX_POOL_SIZE)
					.setConnectionTimeout(0)
					.build();

			// Execute DB migrations
			{
				Flyway flyway = Flyway.configure()
						.dataSource(generalPurposeDataSource)
						.loggers("log4j2")
						.load();

				flyway.migrate();
			}

			try (Connection conn = generalPurposeDataSource.getConnection(); Statement stmt = conn.createStatement()) {
				ChatSessionIDGenerator.generateAvailableChatSessionIDS(conn);
				ClientIDGenerator.generateAvailableClientIDS(conn);

				ResultSet rs = stmt.executeQuery("SHOW ssl;");
				if (rs.next()) {
					String sslStatus = rs.getString(1);
					for (int i = 0; i < 5; i++) logger.info("SSL status: " + sslStatus);
				}
			}

			FilesStorage.initialize();
		} catch (Exception e) {
			logger.fatal(Throwables.getStackTraceAsString(e));
			throw new RuntimeException(e);
		}
	}

	public static GeneralPurposeDBConnection getGeneralPurposeConnection() {
		return new GeneralPurposeDBConnection();
	}

	public static WriteChatMessagesDBConnection getWriteChatMessagesConnection() {
		return new WriteChatMessagesDBConnection();
	}

	private static class DBConnection implements AutoCloseable {

		protected final Connection conn;

		private DBConnection(HikariDataSource hikariDataSource) {
			try {
				conn = hikariDataSource.getConnection();
			} catch (SQLException sqle) {
				logger.fatal(Throwables.getStackTraceAsString(sqle));
				throw new RuntimeException(sqle);
			}
		}

		/**
		 * Meant only to be used in testing
		 * 
		 * @returns underlying database connection
		 */
		public Connection underlyingConnection() {
			return conn;
		}

		@Override
		public void close() {
			try {
				conn.close();
			} catch (SQLException sqle) {
				logger.fatal(Throwables.getStackTraceAsString(sqle));
				throw new RuntimeException(sqle);
			}
		}
	}

	public static class WriteChatMessagesDBConnection extends DBConnection {

		private WriteChatMessagesDBConnection() {
			super(writeChatMessagesDataSource);
		}

		/**
		 * 
		 * @param message
		 * @return the message's id in the database (if adding the message was unsuccessful then returns -1)
		 */
		public int addMessage(DatabaseChatMessage message) {
			int messageID = -1;

			String sql = """
					    INSERT INTO chat_messages
					    (chat_session_id, message_id, client_id, text, file_name, file_content_id, is_read, content_type)
					    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
					    RETURNING message_id;
					""";

			try (PreparedStatement addMessage = conn.prepareStatement(sql)) {
				int chatSessionID = message.getChatSessionID();
				int generatedMessageID = MessageIDGenerator.incrementAndGetMessageID(chatSessionID, conn);
				String fileID = null;
				String text = null;
				String fileName = null;

				if (message.getText() != null) {
					text = new String(message.getText());
				}

				if (message.getFileName() != null) {
					fileName = new String(message.getFileName());
					fileID = FilesStorage.storeSentFile(message.getFileBytes());
				}

				addMessage.setInt(1, chatSessionID);
				addMessage.setInt(2, generatedMessageID);
				addMessage.setInt(3, message.getClientID());
				addMessage.setString(4, text);
				addMessage.setString(5, fileName);
				addMessage.setString(6, fileID);
				addMessage.setBoolean(7, message.isRead());
				addMessage.setInt(8, ContentTypeConverter.getContentTypeAsDatabaseInt(message.getContentType()));

				try (ResultSet rs = addMessage.executeQuery()) {
					rs.next();
					messageID = rs.getInt(1);
				}
			} catch (SQLException | IOException sqle) {
				logger.error(Throwables.getStackTraceAsString(sqle));
			}

			return messageID;
		}

		public void updateMessageReadStatus(int messageID) {
			String sql = """
					    UPDATE chat_messages
					    SET is_read = ?
					    WHERE message_id = ?;
					""";

			try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
				pstmt.setBoolean(1, true);
				pstmt.setInt(2, messageID);

				pstmt.executeUpdate();
			} catch (SQLException sqle) {
				logger.error(Throwables.getStackTraceAsString(sqle));
			}
		}

	}

	public static class GeneralPurposeDBConnection extends DBConnection implements AccountRepository,
			AuthService,
			BackupVerificationCodesModule,
			ChangePasswordService,
			ChatRequestsHandlerModule,
			ChatSessionsManagerModule,
			MessagesService,
			UserCredentialsRepository,
			UserDevicesManagerService,
			UserProfileModule,
			VoiceCallHistoryManagerService {

		private GeneralPurposeDBConnection() {
			super(generalPurposeDataSource);
		}

		@Override
		public Connection getConn() {
			return conn;
		}

	}
}
