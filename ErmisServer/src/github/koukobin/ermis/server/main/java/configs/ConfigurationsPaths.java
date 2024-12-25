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
import java.nio.file.FileAlreadyExistsException;
import java.nio.file.Files;
import java.nio.file.Paths;

import github.koukobin.ermis.server.main.ConfigProperty;

/**
 * @author Ilias Koukovinis
 *
 */
public final class ConfigurationsPaths {

	public static final String ROOT_FOLDER = "/srv/Ermis-Server/";
	public static final String CONFIGURATIONS_ROOT_FOLDER_PATH = ROOT_FOLDER + "configs/";
	
	public static class Server {
		
		public static final String SETTINGS = CONFIGURATIONS_ROOT_FOLDER_PATH + "Server Settings/";
		
		public static final String GENERAL_SETTINGS = SETTINGS + "General Settings.cnf";
		public static final String SSL_SETTINGS = SETTINGS + "SSLSettings.cnf";

		public static class EmailCreator {

			public static class Verification {

				public static class Login {

					public static final String VERIFICATION_EMAIL_BODY_FILE_PATH = SETTINGS + "Login Verification Message.txt";

					private Login() {}
				}

				public static class CreateAccount {

					public static final String VERIFICATION_EMAIL_BODY_FILE_PATH = SETTINGS + "CreateAccount Verification Message.txt";

					private CreateAccount() {}
				}

				private Verification() {}
			}

			private EmailCreator() {}
		}
		
		private Server() {}
	}

	public static class Donations {

		public static final String DONATIONS_SETTINGS_PATH = CONFIGURATIONS_ROOT_FOLDER_PATH + "Donation Settings/";
		public static final String HTML_FILE_PATH = DONATIONS_SETTINGS_PATH + "index.html";

		private Donations() {}
	}

	public static class Emailer {

		public static final String EMAILER_SETTINGS_PATH = CONFIGURATIONS_ROOT_FOLDER_PATH + "Emailer Settings/";
		public static final String GENERAL_SETTINGS_PATH = EMAILER_SETTINGS_PATH + "GeneralSettings.cnf";
		
		private Emailer() {}
	}
	
	public static class UserFilesStorage {
		public static final String ROOT_FOLDER = "/var/lib/ermis-server/";
		public static final String PROFILE_PHOTOS_DIRECTORY = ROOT_FOLDER + "profile_photos/";
		public static final String SENT_FILES_DIRECTORY = ROOT_FOLDER + "user_files/";

		static {
			try {
				Files.createDirectory(Paths.get(UserFilesStorage.PROFILE_PHOTOS_DIRECTORY));
			} catch (IOException ioe) {
				ioe.printStackTrace();
			}
		}
		
		private UserFilesStorage() {}
	}

	public static class Database {

		public static final InputStream DATABASE_SETUP_FILE = Database.class.getResourceAsStream(
				"/github/koukobin/ermis/server/main/resources/sql/ermis_database/database_setup.sql");

		public static final String DATABASE_SETTINGS_PATH = CONFIGURATIONS_ROOT_FOLDER_PATH + "Database Settings/";
		
		public static final String GENERAL_SETTINGS_PATH = DATABASE_SETTINGS_PATH + "GeneralSettings.cnf";
		public static final String DRIVER_SETTINGS_PATH = DATABASE_SETTINGS_PATH + "DriverSettings.cnf";
		public static final String POOLING_SETTINGS_PATH = DATABASE_SETTINGS_PATH + "PoolingSettings.cnf";
		
		public static class Client {
			
			public static final String CLIENT_SETTINGS_PATH = DATABASE_SETTINGS_PATH + "Client Settings/";
			
			public static final String GENERAL_SETTINGS_PATH = CLIENT_SETTINGS_PATH + "General Settings.cnf";
			public static final String USERNAME_SETTINGS_PATH = CLIENT_SETTINGS_PATH + "UsernameSettings.cnf";
			
			public static class Password {
				
				public static final String PASSWORD_SETTINGS_PATH = CLIENT_SETTINGS_PATH + "Password Settings/";
				
				public static final String GENERAL_SETTINGS_PATH = PASSWORD_SETTINGS_PATH + "General Settings.cnf";

				public static class HashingAlgorithms {
					
					public static final String HASHING_ALGORITHMS_SETTINGS_PATH = PASSWORD_SETTINGS_PATH + "Hashing Algorithms/";
					
					public static final String ARGON2_SETTINGS_PATH = HASHING_ALGORITHMS_SETTINGS_PATH + "Argon2.cnf";
					public static final String BCRYPT_SETTINGS_PATH = HASHING_ALGORITHMS_SETTINGS_PATH + "Bcrypt.cnf";
					public static final String SCRYPT_SETTINGS_PATH = HASHING_ALGORITHMS_SETTINGS_PATH + "Scrypt.cnf";
					
					private HashingAlgorithms() {}
				}
				
				private Password() {}
			}
			
			public static class BackupVerificationCodes {
				
				public static final String BACKUP_VERIFICATION_CODES_SETTINGS_PATH = CLIENT_SETTINGS_PATH + "Backup Verification Codes Settings/";
				
				public static final String GENERAL_SETTINGS_PATH = BACKUP_VERIFICATION_CODES_SETTINGS_PATH + "General Settings.cnf";
				
				public static class HashingAlgorithms {
					
					public static final String HASHING_ALGORITHMS_SETTINGS_PATH = BACKUP_VERIFICATION_CODES_SETTINGS_PATH + "Hashing Algorithms/";
					
					public static final String ARGON2_SETTINGS_PATH = HASHING_ALGORITHMS_SETTINGS_PATH + "Argon2.cnf";
					public static final String BCRYPT_SETTINGS_PATH = HASHING_ALGORITHMS_SETTINGS_PATH + "Bcrypt.cnf";
					public static final String SCRYPT_SETTINGS_PATH = HASHING_ALGORITHMS_SETTINGS_PATH + "Scrypt.cnf";
					
					private HashingAlgorithms() {}
				}
				
				private BackupVerificationCodes() {}
			}
			
			private Client() {}
		}
		
		private Database() {}
	}
	
	public static class Logger {
		
		public static final String LOGGER_SETTINGS = CONFIGURATIONS_ROOT_FOLDER_PATH + "Logger Settings/";
		public static final String LOG4J_SETTINGS = LOGGER_SETTINGS + "log4j2.xml";
		
		private Logger() {}
	}
	
	private ConfigurationsPaths() {}

	private static void createDirectory(String path) {
		try {
			Files.createDirectories(Paths.get(path));
		} catch (FileAlreadyExistsException fae) {
			System.out.println("Directory " + UserFilesStorage.PROFILE_PHOTOS_DIRECTORY + " already exists");
		} catch (IOException ioe) {
			System.err.println("Failed to create directory: " + path + " - " + ioe.getMessage());
			throw new RuntimeException("Failed to create directory: " + path + " - " + ioe.getMessage(), ioe);
		}
	}
}

