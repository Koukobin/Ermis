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
package main.java.io.github.koukobin.ermis.server.configs;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Properties;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.password4j.Argon2Function;
import com.password4j.BcryptFunction;
import com.password4j.HashingFunction;
import com.password4j.ScryptFunction;

import main.java.io.github.koukobin.ermis.common.util.FileUtils;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.complexity_checker.CredentialRequirements;

/**
 * @author Ilias Koukovinis
 *
 */
public final class DatabaseSettings {

	@SuppressWarnings("unused")
	private static final Logger logger = LogManager.getLogger("database");

	public final int maxUsers;
	public final String databaseAddress;
	public final String databaseName;
	public final int databasePort;
	public final String user;
	public final String userPassword;

	public final Client client;
	public final ConnectionPool pool;
	public final Driver driver;

	public final Client.Username username;
	public final Client.Password password;
	public final Client.BackupVerificationCodes backupCodes;

	private final ConfigurationLoader loader;

	public DatabaseSettings(ConfigurationLoader loader) throws IOException {
		this.loader = loader;

		Properties props = loader.getDatabaseGeneral();
		this.maxUsers = Integer.parseInt(props.getProperty("maxUsers"));
		this.databaseAddress = props.getProperty("databaseAddress");
		this.databaseName = props.getProperty("databaseName");
		this.databasePort = Integer.parseInt(props.getProperty("databasePort"));
		this.user = props.getProperty("user");

		if (loader.enableUnitTests) {
			userPassword = props.getProperty("db_user_password");
		} else {
			if (ServerSettings.IS_PRODUCTION_MODE) {
				userPassword = Files.readString(
						Path.of("/run/credentials/ermis-server.service/db_user_password"),
						StandardCharsets.ISO_8859_1 // Use this charset so password can contain latin characters
						).trim();
			} else {
				userPassword = FileUtils.
						readPropertiesFile(ConfigurationsPaths.DevelopmentMode.CONF_SETTINGS)
						.getProperty("db_user_password");
			}
		}

		this.client = new Client();
		this.pool = new ConnectionPool();
		this.driver = new Driver();

		this.username = client.username;
		this.password = client.password;
		this.backupCodes = client.backupCodes;
	}

	public class Client {

		public final General general = new General();
		public final Username username = new Username();
		public final Password password = new Password();
		public final BackupVerificationCodes backupCodes = new BackupVerificationCodes();

		private Client() {}

		public class General {

			private final Properties CLIENT_GENERAL_PROPERTIES;

			{
				CLIENT_GENERAL_PROPERTIES = loader.getDatabaseClientGeneral();
			}

			public final SaltForHashing saltForHashing = new SaltForHashing();

			private General() {}

			public class SaltForHashing {

				public final int SALT_LENGTH = Integer.parseInt(CLIENT_GENERAL_PROPERTIES.getProperty("saltLength"));

				private SaltForHashing() {}
			}
		}

		public class Username {

			private final Properties CLIENT_USERNAME_PROPERTIES;

			{
				CLIENT_USERNAME_PROPERTIES = loader.getDatabaseClientUsername();

			}

			public final CredentialRequirements REQUIREMENTS = new CredentialRequirements();

			{
				REQUIREMENTS.setMaxLength(Integer.parseInt(CLIENT_USERNAME_PROPERTIES.getProperty("usernameMaxLength")));
				REQUIREMENTS.setInvalidCharacters(CLIENT_USERNAME_PROPERTIES.getProperty("usernameInvalidCharacters"));
			}

			private Username() {}
		}

		public class Password {

			private final Properties CLIENT_PASSWORD_PROPERTIES;

			{
				CLIENT_PASSWORD_PROPERTIES = loader.getDatabaseClientPasswordGeneral();
			}

			public final CredentialRequirements REQUIREMENTS = new CredentialRequirements();

			{
				REQUIREMENTS.setMinEntropy(Float.parseFloat(CLIENT_PASSWORD_PROPERTIES.getProperty("minEntropy")));
				REQUIREMENTS.setMaxLength(Integer.parseInt(CLIENT_PASSWORD_PROPERTIES.getProperty("passwordMaxLength")));
				REQUIREMENTS.setInvalidCharacters(CLIENT_PASSWORD_PROPERTIES.getProperty("passwordInvalidCharacters"));
			}

			public final Hashing hashing = new Hashing();

			private Password() {}

			public class Hashing {

				public final int HASH_LENGTH = Integer.parseInt(CLIENT_PASSWORD_PROPERTIES.getProperty("passwordHashLength"));

				public final HashingFunction HASHING_ALGORITHM;

				{
					Argon2 argon2 = new Argon2();
					Scrypt scrypt = new Scrypt();
					Bcrypt bcrypt = new Bcrypt();

					AvailableHashingAlgorithms.initialize(argon2, scrypt, bcrypt);

					HASHING_ALGORITHM = AvailableHashingAlgorithms
							.valueOf(CLIENT_PASSWORD_PROPERTIES.getProperty("algorithmType").toUpperCase())
							.getHashingAlgorithm();
				}

				private Hashing() {}

				private class Argon2 {

					private final Properties ARGON2_PROPERTIES;

					{
						ARGON2_PROPERTIES = loader.getDatabaseClientPasswordHashingArgon2();
					}

					public final int MEMORY = Integer.parseInt(ARGON2_PROPERTIES.getProperty("memory"));
					public final int ITERATIONS = Integer.parseInt(ARGON2_PROPERTIES.getProperty("iterations"));
					public final int PARALLELISM = Integer.parseInt(ARGON2_PROPERTIES.getProperty("parallelism"));
					public final com.password4j.types.Argon2 TYPE = com.password4j.types.Argon2.valueOf(ARGON2_PROPERTIES.getProperty("variation"));

					public final HashingFunction HASHING_ALGORITHM = Argon2Function.getInstance(MEMORY, ITERATIONS, PARALLELISM, HASH_LENGTH, TYPE);

					private Argon2() {}
				}

				private class Scrypt {

					private final Properties SCRYPT_PROPERTIES;

					{
						SCRYPT_PROPERTIES = loader.getDatabaseClientPasswordHashingScrypt();
					}

					public final int WORK_FACTOR = Integer.parseInt(SCRYPT_PROPERTIES.getProperty("workFactor"));
					public final int RESOURCES = Integer.parseInt(SCRYPT_PROPERTIES.getProperty("resources"));
					public final int PARALLELIZATION = Integer.parseInt(SCRYPT_PROPERTIES.getProperty("parallelization"));
	
					public final HashingFunction HASHING_ALGORITHM = ScryptFunction.getInstance(WORK_FACTOR,RESOURCES, PARALLELIZATION, HASH_LENGTH);

					private Scrypt() {}
				}

				private class Bcrypt {

					private final Properties BCRYPT_PROPERTIES;

					{
						BCRYPT_PROPERTIES = loader.getDatabaseClientPasswordHashingBcrypt();
					}

					public final com.password4j.types.Bcrypt VERSION = com.password4j.types.Bcrypt.valueOf(BCRYPT_PROPERTIES.getProperty("version"));
					public final int COST_FACTOR = Integer.parseInt(BCRYPT_PROPERTIES.getProperty("costFactor"));

					public final HashingFunction HASHING_ALGORITHM = BcryptFunction.getInstance(VERSION, COST_FACTOR);

					private Bcrypt() {}
				}
				
				private enum AvailableHashingAlgorithms {
					ARGON2, SCRYPT, BCRYPT;

					private HashingFunction hashingAlgorithm;

					// Call this after constructing the three classes above
					public static void initialize(Argon2 argon2, Scrypt scrypt, Bcrypt bcrypt) {
						ARGON2.hashingAlgorithm = argon2.HASHING_ALGORITHM;
						SCRYPT.hashingAlgorithm = scrypt.HASHING_ALGORITHM;
						BCRYPT.hashingAlgorithm = bcrypt.HASHING_ALGORITHM;
					}

					public HashingFunction getHashingAlgorithm() {
						return hashingAlgorithm;
					}

				}

			}

		}

		public class BackupVerificationCodes {

			private final Properties CLIENT_BACKUP_VERIFICATION_CODES_PROPERTIES;

			{
				CLIENT_BACKUP_VERIFICATION_CODES_PROPERTIES = loader.getDatabaseClientBackupCodesGeneral();
			}

			public final int AMOUNT_OF_CODES = Integer.parseInt(CLIENT_BACKUP_VERIFICATION_CODES_PROPERTIES.getProperty("amountOfCodes"));
			public final int AMOUNT_OF_CHARACTERS = Integer.parseInt(CLIENT_BACKUP_VERIFICATION_CODES_PROPERTIES.getProperty("amountOfCharacters"));

			public final Hashing hashing = new Hashing();
			
			private BackupVerificationCodes() {}

			public class Hashing {

				public final int HASH_LENGTH = Integer.parseInt(CLIENT_BACKUP_VERIFICATION_CODES_PROPERTIES.getProperty("hashLength"));

				public final HashingFunction HASHING_ALGORITHM;

				{
					Argon2 argon2 = new Argon2();
					Scrypt scrypt = new Scrypt();
					Bcrypt bcrypt = new Bcrypt();

					AvailableHashingAlgorithms.initialize(argon2, scrypt, bcrypt);
					
					HASHING_ALGORITHM = AvailableHashingAlgorithms
							.valueOf(CLIENT_BACKUP_VERIFICATION_CODES_PROPERTIES.getProperty("algorithmType").toUpperCase())
							.getHashingAlgorithm();
				}

				private Hashing() {}

				private class Argon2 {

					private final Properties ARGON2_PROPERTIES;

					{
						ARGON2_PROPERTIES = loader.getDatabaseClientPasswordHashingArgon2();
					}

					public final int MEMORY = Integer.parseInt(ARGON2_PROPERTIES.getProperty("memory"));
					public final int ITERATIONS = Integer.parseInt(ARGON2_PROPERTIES.getProperty("iterations"));
					public final int PARALLELISM = Integer.parseInt(ARGON2_PROPERTIES.getProperty("parallelism"));
					public final com.password4j.types.Argon2 TYPE = com.password4j.types.Argon2.valueOf(ARGON2_PROPERTIES.getProperty("variation"));

					public final HashingFunction HASHING_ALGORITHM = Argon2Function.getInstance(MEMORY, ITERATIONS, PARALLELISM, HASH_LENGTH, TYPE);

					private Argon2() {}
				}

				private class Scrypt {

					private final Properties SCRYPT_PROPERTIES;

					{
						SCRYPT_PROPERTIES = loader.getDatabaseClientPasswordHashingScrypt();
					}

					public final int WORK_FACTOR = Integer.parseInt(SCRYPT_PROPERTIES.getProperty("workFactor"));
					public final int RESOURCES = Integer.parseInt(SCRYPT_PROPERTIES.getProperty("resources"));
					public final int PARALLELIZATION = Integer.parseInt(SCRYPT_PROPERTIES.getProperty("parallelization"));

					public final HashingFunction HASHING_ALGORITHM = ScryptFunction.getInstance(WORK_FACTOR,RESOURCES, PARALLELIZATION, HASH_LENGTH);

					private Scrypt() {}
				}

				private class Bcrypt {

					private final Properties BCRYPT_PROPERTIES;

					{
						BCRYPT_PROPERTIES = loader.getDatabaseClientPasswordHashingBcrypt();
					}

					public final com.password4j.types.Bcrypt VERSION = com.password4j.types.Bcrypt.valueOf(BCRYPT_PROPERTIES.getProperty("version"));
					public final int COST_FACTOR = Integer.parseInt(BCRYPT_PROPERTIES.getProperty("costFactor"));

					public final HashingFunction HASHING_ALGORITHM = BcryptFunction.getInstance(VERSION, COST_FACTOR);

					private Bcrypt() {}
				}
				
				private enum AvailableHashingAlgorithms {
					ARGON2, SCRYPT, BCRYPT;

					private HashingFunction hashingAlgorithm;

					// Call this after constructing the three classes above
					public static void initialize(Argon2 argon2, Scrypt scrypt, Bcrypt bcrypt) {
						ARGON2.hashingAlgorithm = argon2.HASHING_ALGORITHM;
						SCRYPT.hashingAlgorithm = scrypt.HASHING_ALGORITHM;
						BCRYPT.hashingAlgorithm = bcrypt.HASHING_ALGORITHM;
					}

					public HashingFunction getHashingAlgorithm() {
						return hashingAlgorithm;
					}

				}

			}

		}

	}

	public class ConnectionPool {

		private final Properties POOLING_SETTINGS;

		{
			POOLING_SETTINGS = loader.getDatabasePooling();
		}

		public GeneralPurposePool generalPurposePool = new GeneralPurposePool();
		public WriteChatMessagesPool writeChatMessagePool = new WriteChatMessagesPool();
		
		public class GeneralPurposePool {

			public final int MIN_IDLE = Integer.parseInt(POOLING_SETTINGS.getProperty("generalPurposePoolMinIdle"));
			public final int MAX_POOL_SIZE = Integer.parseInt(POOLING_SETTINGS.getProperty("generalPurposePoolMaxPoolSize"));

			private GeneralPurposePool() {}
		}

		public class WriteChatMessagesPool {

			public final int MIN_IDLE = Integer.parseInt(POOLING_SETTINGS.getProperty("writeChatMessagesPoolMinIdle"));
			public final int MAX_POOL_SIZE = Integer.parseInt(POOLING_SETTINGS.getProperty("writeChatMessagesPoolMaxPoolSize"));

			private WriteChatMessagesPool() {}
		}

		private ConnectionPool() {}
	}

	public class Driver {

		private final Properties DRIVER_SETTINGS;

		{
			DRIVER_SETTINGS = loader.getDatabaseDriver();
		}

		private Driver() {}

		public Properties getDriverProperties() {
			return (Properties) DRIVER_SETTINGS.clone();
		}
	}
}
