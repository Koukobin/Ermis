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
import java.nio.charset.StandardCharsets;
import java.util.Properties;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.google.common.base.Throwables;
import com.password4j.Argon2Function;
import com.password4j.BcryptFunction;
import com.password4j.HashingFunction;
import com.password4j.ScryptFunction;

import github.koukobin.ermis.common.util.FileUtils;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.complexity_checker.CredentialRequirements;

/**
 * @author Ilias Koukovinis
 *
 */
public final class DatabaseSettings {

	private static final Logger logger = LogManager.getLogger("database");
	
	private static final Properties GENERAL_PROPERTIES;
	
	static {
		try {
			GENERAL_PROPERTIES = FileUtils.readPropertiesFile(ConfigurationsPaths.Database.GENERAL_SETTINGS_PATH);
		} catch (IOException ioe) {
			throw new RuntimeException(ioe);
		}
	}

	public static final int MAX_USERS = Integer.parseInt(GENERAL_PROPERTIES.getProperty("maxUsers"));

	public static final String USER = GENERAL_PROPERTIES.getProperty("user");
	public static final String USER_PASSWORD = new String(
			GENERAL_PROPERTIES.getProperty("userPassword")
			.getBytes(StandardCharsets.ISO_8859_1 /* use this charset so password can contain latin characters */));
	
	public static final String DATABASE_ADDRESS = GENERAL_PROPERTIES.getProperty("databaseAddress");
	public static final String DATABASE_NAME = GENERAL_PROPERTIES.getProperty("databaseName");
	public static final int DATABASE_PORT = Integer.parseInt(GENERAL_PROPERTIES.getProperty("databasePort"));
	
	private DatabaseSettings() {}
	
	public static class Client {

		private Client() {}
		
		public static class General {
			
			private static final Properties CLIENT_GENERAL_PROPERTIES;

			static {
				try {
					CLIENT_GENERAL_PROPERTIES = FileUtils.readPropertiesFile(ConfigurationsPaths.Client.GENERAL_SETTINGS_PATH);
				} catch (IOException ioe) {
					logger.fatal(Throwables.getStackTraceAsString(ioe));
					throw new RuntimeException(ioe);
				}
			}
			
			private General() {}
		
			public static class SaltForHashing {
				
				public static final int SALT_LENGTH = Integer.parseInt(CLIENT_GENERAL_PROPERTIES.getProperty("saltLength"));
				
				private SaltForHashing() {}
			}
		}
		
		public static class Username {
	
			private static final Properties CLIENT_USERNAME_PROPERTIES;

			static {
				try {
					CLIENT_USERNAME_PROPERTIES = FileUtils.readPropertiesFile(ConfigurationsPaths.Client.USERNAME_SETTINGS_PATH);
				} catch (IOException ioe) {
					logger.fatal(Throwables.getStackTraceAsString(ioe));
					throw new RuntimeException(ioe);
				}
			}
	
			public static final CredentialRequirements REQUIREMENTS = new CredentialRequirements();
			
			static {
				REQUIREMENTS.setMaxLength(Integer.parseInt(CLIENT_USERNAME_PROPERTIES.getProperty("usernameMaxLength")));
				REQUIREMENTS.setInvalidCharacters(CLIENT_USERNAME_PROPERTIES.getProperty("usernameInvalidCharacters"));
			}

			private Username() {}
		}
	
		public static class Password {
	
			private static final Properties CLIENT_PASSWORD_PROPERTIES;
			
			static {
				try {
					CLIENT_PASSWORD_PROPERTIES = FileUtils.readPropertiesFile(ConfigurationsPaths.Client.Password.GENERAL_SETTINGS_PATH);
				} catch (IOException ioe) {
					logger.fatal(Throwables.getStackTraceAsString(ioe));
					throw new RuntimeException(ioe);
				}
			}
			
			
			public static final CredentialRequirements REQUIREMENTS = new CredentialRequirements();
			
			static {
				REQUIREMENTS.setMinEntropy(Float.parseFloat(CLIENT_PASSWORD_PROPERTIES.getProperty("minEntropy")));
				REQUIREMENTS.setMaxLength(Integer.parseInt(CLIENT_PASSWORD_PROPERTIES.getProperty("passwordMaxLength")));
				REQUIREMENTS.setInvalidCharacters(CLIENT_PASSWORD_PROPERTIES.getProperty("passwordInvalidCharacters"));
			}
			
			private Password() {}
			
			public static class Hashing {
			
				public static final int HASH_LENGTH = Integer.parseInt(CLIENT_PASSWORD_PROPERTIES.getProperty("passwordHashLength"));
				
				public static final HashingFunction HASHING_ALGORITHM = AvailableHashingAlgorithms
						.valueOf(CLIENT_PASSWORD_PROPERTIES.getProperty("algorithmType").toUpperCase())
						.hashingAlrgorithm;
		
				private Hashing() {}
				
				private enum AvailableHashingAlgorithms {
					ARGON2(Argon2.HASHING_ALGORITHM), SCRYPT(Scrypt.HASHING_ALGORITHM), BCRYPT(Bcrypt.HASHING_ALGORITHM);

					public final HashingFunction hashingAlrgorithm;

					AvailableHashingAlgorithms(HashingFunction hashAlrgorithm) {
						this.hashingAlrgorithm = hashAlrgorithm;
					}

					private static class Argon2 {

						private static final Properties ARGON2_PROPERTIES;
		
						static {
							try {
								ARGON2_PROPERTIES = FileUtils.readPropertiesFile(ConfigurationsPaths.Client.Password.HashingAlgorithms.ARGON2_SETTINGS_PATH);
							} catch (IOException ioe) {
								logger.fatal(Throwables.getStackTraceAsString(ioe));
								throw new RuntimeException(ioe);
							}
						}
		
						public static final int MEMORY = Integer.parseInt(ARGON2_PROPERTIES.getProperty("memory"));
						public static final int ITERATIONS = Integer.parseInt(ARGON2_PROPERTIES.getProperty("iterations"));
						public static final int PARALLELISM = Integer.parseInt(ARGON2_PROPERTIES.getProperty("parallelism"));
						public static final com.password4j.types.Argon2 TYPE = com.password4j.types.Argon2.valueOf(ARGON2_PROPERTIES.getProperty("variation"));
		
						public static final HashingFunction HASHING_ALGORITHM = Argon2Function.getInstance(MEMORY, ITERATIONS, PARALLELISM, HASH_LENGTH, TYPE);

						private Argon2() {}
					}
		
					private static class Scrypt {
						
						private static final Properties SCRYPT_PROPERTIES;
		
						static {
							try {
								SCRYPT_PROPERTIES = FileUtils.readPropertiesFile(ConfigurationsPaths.Client.Password.HashingAlgorithms.SCRYPT_SETTINGS_PATH);
							} catch (IOException ioe) {
								logger.fatal(Throwables.getStackTraceAsString(ioe));
								throw new RuntimeException(ioe);
							}
						}
		
						public static final int WORK_FACTOR = Integer.parseInt(SCRYPT_PROPERTIES.getProperty("workFactor"));
						public static final int RESOURCES = Integer.parseInt(SCRYPT_PROPERTIES.getProperty("resources"));
						public static final int PARALLELIZATION = Integer.parseInt(SCRYPT_PROPERTIES.getProperty("parallelization"));
		
						public static final HashingFunction HASHING_ALGORITHM = ScryptFunction.getInstance(WORK_FACTOR,RESOURCES, PARALLELIZATION, HASH_LENGTH);

						private Scrypt() {}
					}
		
					private static class Bcrypt {
		
						private static final Properties BCRYPT_PROPERTIES;
		
						static {
							try {
								BCRYPT_PROPERTIES = FileUtils.readPropertiesFile(ConfigurationsPaths.Client.Password.HashingAlgorithms.BCRYPT_SETTINGS_PATH);
							} catch (IOException ioe) {
								logger.fatal(Throwables.getStackTraceAsString(ioe));
								throw new RuntimeException(ioe);
							}
						}
		
						public static final com.password4j.types.Bcrypt VERSION = com.password4j.types.Bcrypt.valueOf(BCRYPT_PROPERTIES.getProperty("version"));
						public static final int COST_FACTOR = Integer.parseInt(BCRYPT_PROPERTIES.getProperty("costFactor"));
		
						public static final HashingFunction HASHING_ALGORITHM = BcryptFunction.getInstance(VERSION, COST_FACTOR);

						private Bcrypt() {}
					}
					
				}
				
			}
			
		}
		
		public static class BackupVerificationCodes {
			
			private static final Properties CLIENT_BACKUP_VERIFICATION_CODES_PROPERTIES;
			
			static {
				try {
					CLIENT_BACKUP_VERIFICATION_CODES_PROPERTIES = FileUtils.readPropertiesFile(ConfigurationsPaths.BackupVerificationCodes.GENERAL_SETTINGS_PATH);
				} catch (IOException ioe) {
					logger.fatal(Throwables.getStackTraceAsString(ioe));
					throw new RuntimeException(ioe);
				}
			}
			
			public static final int AMOUNT_OF_CODES = Integer.parseInt(CLIENT_BACKUP_VERIFICATION_CODES_PROPERTIES.getProperty("amountOfCodes"));
			public static final int AMOUNT_OF_CHARACTERS = Integer.parseInt(CLIENT_BACKUP_VERIFICATION_CODES_PROPERTIES.getProperty("amountOfCharacters"));
		
			private BackupVerificationCodes() {}

			public static class Hashing {
			
				public static final int HASH_LENGTH = Integer.parseInt(CLIENT_BACKUP_VERIFICATION_CODES_PROPERTIES.getProperty("hashLength"));
				
				public static final HashingFunction HASHING_ALGORITHM = AvailableHashingAlgorithms
						.valueOf(CLIENT_BACKUP_VERIFICATION_CODES_PROPERTIES.getProperty("algorithmType").toUpperCase())
						.hashingAlrgorithm;
		
				private Hashing() {}
				
				private enum AvailableHashingAlgorithms {
					ARGON2(Argon2.HASHING_ALGORITHM), SCRYPT(Scrypt.HASHING_ALGORITHM), BCRYPT(Bcrypt.HASHING_ALGORITHM);

					public final HashingFunction hashingAlrgorithm;

					AvailableHashingAlgorithms(HashingFunction hashAlrgorithm) {
						this.hashingAlrgorithm = hashAlrgorithm;
					}

					private static class Argon2 {
						
						private static final Properties ARGON2_PROPERTIES;
		
						static {
							try {
								ARGON2_PROPERTIES = FileUtils.readPropertiesFile(ConfigurationsPaths.BackupVerificationCodes.HashingAlgorithms.ARGON2_SETTINGS_PATH);
							} catch (IOException ioe) {
								logger.fatal(Throwables.getStackTraceAsString(ioe));
								throw new RuntimeException(ioe);
							}
						}
		
						public static final int MEMORY = Integer.parseInt(ARGON2_PROPERTIES.getProperty("memory"));
						public static final int ITERATIONS = Integer.parseInt(ARGON2_PROPERTIES.getProperty("iterations"));
						public static final int PARALLELISM = Integer.parseInt(ARGON2_PROPERTIES.getProperty("parallelism"));
						public static final com.password4j.types.Argon2 TYPE = com.password4j.types.Argon2.valueOf(ARGON2_PROPERTIES.getProperty("variation"));
		
						public static final HashingFunction HASHING_ALGORITHM = Argon2Function.getInstance(MEMORY, ITERATIONS, PARALLELISM, HASH_LENGTH, TYPE);

						private Argon2() {}
					}
		
					private static class Scrypt {
						
						private static final Properties SCRYPT_PROPERTIES;
		
						static {
							try {
								SCRYPT_PROPERTIES = FileUtils.readPropertiesFile(ConfigurationsPaths.BackupVerificationCodes.HashingAlgorithms.SCRYPT_SETTINGS_PATH);
							} catch (IOException ioe) {
								logger.fatal(Throwables.getStackTraceAsString(ioe));
								throw new RuntimeException(ioe);
							}
						}
		
						public static final int WORK_FACTOR = Integer.parseInt(SCRYPT_PROPERTIES.getProperty("workFactor"));
						public static final int RESOURCES = Integer.parseInt(SCRYPT_PROPERTIES.getProperty("resources"));
						public static final int PARALLELIZATION = Integer.parseInt(SCRYPT_PROPERTIES.getProperty("parallelization"));
		
						public static final HashingFunction HASHING_ALGORITHM = ScryptFunction.getInstance(WORK_FACTOR,RESOURCES, PARALLELIZATION, HASH_LENGTH);

						private Scrypt() {}
					}
		
					private static class Bcrypt {
		
						private static final Properties BCRYPT_PROPERTIES;
		
						static {
							try {
								BCRYPT_PROPERTIES = FileUtils.readPropertiesFile(ConfigurationsPaths.BackupVerificationCodes.HashingAlgorithms.BCRYPT_SETTINGS_PATH);
							} catch (IOException ioe) {
								logger.fatal(Throwables.getStackTraceAsString(ioe));
								throw new RuntimeException(ioe);
							}
						}
		
						public static final com.password4j.types.Bcrypt VERSION = com.password4j.types.Bcrypt.valueOf(BCRYPT_PROPERTIES.getProperty("version"));
						public static final int COST_FACTOR = Integer.parseInt(BCRYPT_PROPERTIES.getProperty("costFactor"));
		
						public static final HashingFunction HASHING_ALGORITHM = BcryptFunction.getInstance(VERSION, COST_FACTOR);

						private Bcrypt() {}
					}
					
				}
				
			}
			
		}
		
	}
	
	public static class ConnectionPool {

		private static final Properties POOLING_SETTINGS;
		
		static {
			try {
				POOLING_SETTINGS = FileUtils.readPropertiesFile(ConfigurationsPaths.Database.POOLING_SETTINGS_PATH);
			} catch (IOException ioe) {
				logger.fatal(Throwables.getStackTraceAsString(ioe));
				throw new RuntimeException(ioe);
			}
		}
		
		public static class GeneralPurposePool {
			
			public static final int MIN_IDLE = Integer.parseInt(POOLING_SETTINGS.getProperty("generalPurposePoolMinIdle"));
			public static final int MAX_POOL_SIZE = Integer.parseInt(POOLING_SETTINGS.getProperty("generalPurposePoolMaxPoolSize"));
			
			private GeneralPurposePool() {}
		}
		
		public static class WriteChatMessagesPool {
			
			public static final int MIN_IDLE = Integer.parseInt(POOLING_SETTINGS.getProperty("writeChatMessagesPoolMinIdle"));
			public static final int MAX_POOL_SIZE = Integer.parseInt(POOLING_SETTINGS.getProperty("writeChatMessagesPoolMaxPoolSize"));

			private WriteChatMessagesPool() {}
		}

		private ConnectionPool() {}
	}
	
	public static class Driver {

		private static final Properties DRIVER_SETTINGS;
		
		static {
			try {
				DRIVER_SETTINGS = FileUtils.readPropertiesFile(ConfigurationsPaths.Database.DRIVER_SETTINGS_PATH);
			} catch (IOException ioe) {
				logger.fatal(Throwables.getStackTraceAsString(ioe));
				throw new RuntimeException(ioe);
			}
		}

		private Driver() {}
		
		public static Properties getDriverProperties() {
			return (Properties) DRIVER_SETTINGS.clone();
		}
	}
}
