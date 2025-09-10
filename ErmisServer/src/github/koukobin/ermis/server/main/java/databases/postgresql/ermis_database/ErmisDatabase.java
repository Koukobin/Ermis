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
package github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database;
 
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.google.common.base.Throwables;
import com.zaxxer.hikari.HikariDataSource;

import github.koukobin.ermis.common.util.FileUtils;
import github.koukobin.ermis.server.main.java.configs.ConfigurationsPaths.Database;
import github.koukobin.ermis.server.main.java.configs.DatabaseSettings;
import github.koukobin.ermis.server.main.java.databases.postgresql.PostgreSQLDatabase;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.data_access.AccountRepository;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.data_access.AuthService;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.data_access.BackupVerificationCodesModule;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.data_access.ChangePasswordService;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.data_access.ChatRequestsHandlerModule;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.data_access.ChatSessionsManagerModule;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.data_access.MessagesService;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.data_access.UserCredentialsRepository;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.data_access.UserDevicesManagerService;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.data_access.UserProfileModule;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.data_access.VoiceCallHistoryManagerService;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.generators.ChatSessionIDGenerator;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.generators.ClientIDGenerator;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.generators.MessageIDGenerator;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.models.DatabaseChatMessage;

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

			try (Connection conn = generalPurposeDataSource.getConnection(); Statement stmt = conn.createStatement()) {
				/*
				 * Since the hash and salt are encoded into base64 without padding we calculate
				 * the base64 encoded data size using the formula (size * 8 + 5) / 6
				 */
				int hashLength = (DatabaseSettings.Client.Password.Hashing.HASH_LENGTH * 8 + 5) / 6;
				int saltLength = (DatabaseSettings.Client.General.SaltForHashing.SALT_LENGTH * 8 + 5) / 6;
				int backupVerificationCodesCharactersLength = (DatabaseSettings.Client.BackupVerificationCodes.Hashing.HASH_LENGTH * 8 + 5) / 6;
				int usernameMaxLength = DatabaseSettings.Client.Username.REQUIREMENTS.getMaxLength();

				String setupSQL = FileUtils.readFile(ErmisDatabase.class.getResourceAsStream(Database.DATABASE_SETUP_FILE))
						.replace("DISPLAY_LENGTH", Integer.toString(usernameMaxLength))
						.replace("PASSWORD_HASH_LENGTH", Integer.toString(hashLength))
						.replace("BACKUP_VERIFICATION_CODES_AMOUNT", Integer.toString(DatabaseSettings.Client.BackupVerificationCodes.AMOUNT_OF_CODES))
						.replace("BACKUP_VERIFICATION_CODES_LENGTH", Integer.toString(backupVerificationCodesCharactersLength))
						.replace("SALT_LENGTH", Integer.toString(saltLength));

				stmt.execute(setupSQL);

				ChatSessionIDGenerator.generateAvailableChatSessionIDS(conn);
				ClientIDGenerator.generateAvailableClientIDS(conn);
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
