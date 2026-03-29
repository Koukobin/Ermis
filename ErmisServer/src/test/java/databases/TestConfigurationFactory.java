/* Copyright (C) 2026 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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
package test.java.databases;

import java.sql.SQLException;
import java.util.Properties;

import org.flywaydb.core.Flyway;
import org.testcontainers.containers.PostgreSQLContainer;

import main.java.io.github.koukobin.ermis.server.configs.ConfigurationLoader;

/**
 * @author Ilias Koukovinis
 *
 */
public class TestConfigurationFactory {

	@SuppressWarnings("resource")
	private static final PostgreSQLContainer<?> POSTGRES = 
		new PostgreSQLContainer<>("postgres:16")
			.withDatabaseName("test_db")
			.withUsername("test_user")
			.withPassword("password");

	static {
		POSTGRES.start();

		Flyway flyway = Flyway.configure()
				.dataSource(POSTGRES.getJdbcUrl(), POSTGRES.getUsername(), POSTGRES.getPassword())
				.locations("filesystem:src/main/resources/db/migration")
				.loggers("log4j2")
				.load();

		flyway.migrate();
	}

	public static ConfigurationLoader defaultLoader() throws SQLException {
		return new ConfigurationLoader.Builder()
				.withDatabaseGeneral(databaseGeneral())
				.withDatabaseDriver(databaseDriver())
				.withDatabasePooling(databasePooling())
				.withDatabaseClientGeneral(databaseClientGeneral())
				.withDatabaseClientUsername(databaseClientUsername())
				.withDatabaseClientPasswordGeneral(databaseClientPasswordGeneral())
				.withDatabaseClientPasswordHashingArgon2(argon2())
				.withDatabaseClientPasswordHashingBcrypt(bcrypt())
				.withDatabaseClientPasswordHashingScrypt(scrypt())
				.withDatabaseClientBackupCodesGeneral(withDatabaseClientBackupCodesGeneral())
				.withDatabaseClientBackupCodesHashingArgon2(argon2())
				.withUserFilesStorageRoot("./target/test")
				.withProfilePhotosDir("./target/test/profile-photos/")
				.withSentFilesDir("./target/test/sent-files/")
				.withJUnitTestsEnabled()
				.build();
	}

	public static Properties databaseGeneral() {
		Properties p = new Properties();
		p.setProperty("user", POSTGRES.getUsername());
		p.setProperty("db_user_password", POSTGRES.getPassword());
		p.setProperty("maxUsers", "10");
		p.setProperty("databaseName", POSTGRES.getDatabaseName());
		p.setProperty("databaseAddress", POSTGRES.getHost());
		p.setProperty("databasePort", POSTGRES.getMappedPort(5432).toString());
		return p;
	}

	public static Properties databaseDriver() {
		Properties p = new Properties();
		p.setProperty("useSSL", "true");
		p.setProperty("requireSSL", "true");
		p.setProperty("sslMode", "PREFERRED");
		return p;
	}

	public static Properties databasePooling() {
		Properties p = new Properties();
		p.setProperty("generalPurposePoolMinIdle", "10");
		p.setProperty("writeChatMessagesPoolMinIdle", "10");
		p.setProperty("generalPurposePoolMaxPoolSize", "50");
		p.setProperty("writeChatMessagesPoolMaxPoolSize", "50");
		return p;
	}

	public static Properties databaseClientGeneral() {
		Properties p = new Properties();
		p.setProperty("saltLength", "16");
		return p;
	}

	public static Properties databaseClientUsername() {
		Properties p = new Properties();
		p.setProperty("usernameMaxLength", "16");
		p.setProperty("usernameInvalidCharacters", "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~");
		return p;
	}

	public static Properties databaseClientPasswordGeneral() {
		Properties p = new Properties();
		p.setProperty("passwordMaxLength", "16");
		p.setProperty("passwordInvalidCharacters", "");
		p.setProperty("minEntropy", "15");
		p.setProperty("passwordHashLength", "16");
		p.setProperty("algorithmType", "Argon2");
		return p;
	}

	public static Properties withDatabaseClientBackupCodesGeneral() {
		Properties p = new Properties();
		p.setProperty("amountOfCodes", "3");
		p.setProperty("amountOfCharacters", "9");
		p.setProperty("hashLength", "9");
		p.setProperty("algorithmType", "Argon2");
		return p;
	}

	public static Properties bcrypt() {
		Properties p = new Properties();
		p.setProperty("version", "B");
		p.setProperty("costFactor", "10");
		return p;
	}

	public static Properties scrypt() {
		Properties p = new Properties();
		p.setProperty("resources", "8");
		p.setProperty("workFactor", "131072");
		p.setProperty("parallelization", "1");
		return p;
	}

	public static Properties argon2() {
		Properties p = new Properties();
		p.setProperty("memory", "65536");
		p.setProperty("iterations", "3");
		p.setProperty("parallelism", "1");
		p.setProperty("variation", "ID");
		return p;
	}

}
