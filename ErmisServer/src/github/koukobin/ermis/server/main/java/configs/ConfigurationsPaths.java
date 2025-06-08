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
package github.koukobin.ermis.server.main.java.configs;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Properties;

import github.koukobin.ermis.server.main.java.util.PropertiesUtil;

/**
 * @author Ilias Koukovinis
 *
 */
public final class ConfigurationsPaths {

	private static final Properties properties = new Properties();

    private ConfigurationsPaths() {}

	static {
		try (InputStream input = ConfigurationsPaths.class.getResourceAsStream("/github/koukobin/ermis/server/main/resources/config.properties")) {
			properties.load(input);
			PropertiesUtil.resolvePlaceholders(properties);
		} catch (IOException e) {
			throw new RuntimeException("Failed to load configuration path properties.", e);
		}
	}

	private static void createDirectory(String path) {
		try {
			Path directory = Paths.get(path);
			if (Files.exists(directory)) {
				return;
			}
			Files.createDirectories(directory); // Create directory and all nonexistent parent directories if needed
		} catch (IOException ioe) {
			throw new RuntimeException("Failed to create directory: " + path + " - " + ioe.getMessage(), ioe);
		}
	}

	private static String getProperty(String key) {
		String propertyValue = properties.getProperty(key);

		if (propertyValue == null) {
			throw new RuntimeException("Configuration key \"" + key + "\" not recognized");
		}

		return propertyValue;
	}

	public static final String ROOT_FOLDER = getProperty("root.folder");
	public static final String CONFIGURATIONS_ROOT_FOLDER_PATH = getProperty("configurations.root.folder");

	public static class Server {

		public static final String SETTINGS = getProperty("server.settings");
		public static final String GENERAL_SETTINGS = getProperty("server.general.settings");
		public static final String SSL_SETTINGS = getProperty("server.ssl.settings");

		private Server() {}
	}

	public static class Donations {

		public static final String DONATIONS_SETTINGS_PATH = getProperty("donations.settings.path");
		public static final String HTML_FILE_PATH = getProperty("donations.html.file.path");

		private Donations() {}
	}

	public static class Emailer {
		public static final String EMAILER_SETTINGS_PATH = getProperty("emailer.settings.path");
		public static final String GENERAL_SETTINGS_PATH = getProperty("emailer.general.settings.path");

		private Emailer() {}
	}

	public static class EmailCreator {
		public static class Verification {
            public static final String LOGIN_VERIFICATION_EMAIL_BODY_FILE_PATH = getProperty("email.templates.verification.login.body.path");
            public static final String CREATE_ACCOUNT_VERIFICATION_EMAIL_BODY_FILE_PATH = getProperty("email.templates.verification.create_account.body.path");
			public static final String DELETE_ACCOUNT_VERIFICATION_EMAIL_BODY_FILE_PATH = getProperty("email.templates.verification.delete_account.body.path");
			public static final String CHANGE_PASSWORD_VERIFICATION_EMAIL_BODY_FILE_PATH = getProperty("email.templates.verification.change_password.body.path");

            private Verification() {}
		}

        private EmailCreator() {}
	}

	public static class UserFilesStorage {
        public static final String ROOT_FOLDER = getProperty("user.files.storage.root.folder");
        public static final String PROFILE_PHOTOS_DIRECTORY = getProperty("user.files.storage.profile.photos.directory");
        public static final String SENT_FILES_DIRECTORY = getProperty("user.files.storage.sent.files.directory");

		static {
			createDirectory(PROFILE_PHOTOS_DIRECTORY);
			createDirectory(SENT_FILES_DIRECTORY);
		}

		private UserFilesStorage() {}
	}

	public static class Database {
		public static final String DATABASE_SETUP_FILE = "/github/koukobin/ermis/server/main/resources/ermis_database/sql/database_setup.sql";
		public static final String DATABASE_SETTINGS_PATH = getProperty("database.settings.path");
		public static final String GENERAL_SETTINGS_PATH = getProperty("database.general.settings.path");
		public static final String DRIVER_SETTINGS_PATH = getProperty("database.driver.settings.path");
		public static final String POOLING_SETTINGS_PATH = getProperty("database.pooling.settings.path");

		private Database() {}
	}

	public static class Client {
		public static final String CLIENT_SETTINGS_PATH = getProperty("database.client.settings.path");
		public static final String GENERAL_SETTINGS_PATH = getProperty("database.client.general.settings.path");
		public static final String USERNAME_SETTINGS_PATH = getProperty("database.client.username.settings.path");

		public static class Password {
			public static final String PASSWORD_SETTINGS_PATH = getProperty("database.client.password.settings.path");
			public static final String GENERAL_SETTINGS_PATH = getProperty("database.client.password.general.settings.path");

    		public static class HashingAlgorithms {
    			public static final String HASHING_ALGORITHMS_SETTINGS_PATH = getProperty("database.client.password.hashing.algorithms.path");
    			public static final String ARGON2_SETTINGS_PATH = getProperty("database.client.password.hashing.argon2.path");
    			public static final String BCRYPT_SETTINGS_PATH = getProperty("database.client.password.hashing.bcrypt.path");
    			public static final String SCRYPT_SETTINGS_PATH = getProperty("database.client.password.hashing.scrypt.path");

				private HashingAlgorithms() {}
			}

			private Password() {}
		}

		private Client() {}
	}

	public static class BackupVerificationCodes {
    	public static final String BACKUP_VERIFICATION_CODES_SETTINGS_PATH = getProperty("database.client.backup.verification.codes.settings.path");
    	public static final String GENERAL_SETTINGS_PATH = getProperty("database.client.backup.verification.codes.general.settings.path");

		public static class HashingAlgorithms {
    		public static final String HASHING_ALGORITHMS_SETTINGS_PATH = getProperty("database.client.backup.verification.codes.hashing.algorithms.path");
    		public static final String ARGON2_SETTINGS_PATH = getProperty("database.client.backup.verification.codes.hashing.argon2.path");
    		public static final String BCRYPT_SETTINGS_PATH = getProperty("database.client.backup.verification.codes.hashing.bcrypt.path");
    		public static final String SCRYPT_SETTINGS_PATH = getProperty("database.client.backup.verification.codes.hashing.scrypt.path");

    		private HashingAlgorithms() {}
		}

    	private BackupVerificationCodes() {}
	}

	public static class Logger {
		public static final String LOGGER_SETTINGS = getProperty("logger.settings");
		public static final String LOG4J_SETTINGS = getProperty("logger.log4j.settings");

		private Logger() {}
	}

}
