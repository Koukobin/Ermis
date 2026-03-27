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
package main.java.io.github.koukobin.ermis.server.configs;

import java.io.IOException;
import java.util.Properties;

import main.java.io.github.koukobin.ermis.common.util.FileUtils;

/**
 * Central loader for all user configuration files.
 * 
 * @author Ilias Koukovinis
 *
 */
public class ConfigurationLoader {

	private final Properties serverGeneral;
	private final Properties serverSsl;

	private final String emailTemplateLoginBody;
	private final String emailTemplateCreateAccountBody;
	private final String emailTemplateDeleteAccountBody;
	private final String emailTemplateChangePasswordBody;
	private final String emailTemplateBackupVerificationCodesBody;

	private final Properties emailerGeneral;

	private final Properties databaseGeneral;
	private final Properties databaseDriver;
	private final Properties databasePooling;

	private final Properties databaseClientGeneral;
	private final Properties databaseClientUsername;

	private final Properties databaseClientPasswordGeneral;
	private final Properties databaseClientPasswordHashingArgon2;
	private final Properties databaseClientPasswordHashingBcrypt;
	private final Properties databaseClientPasswordHashingScrypt;

	private final Properties databaseClientBackupCodesGeneral;
	private final Properties databaseClientBackupCodesHashingArgon2;
	private final Properties databaseClientBackupCodesHashingBcrypt;
	private final Properties databaseClientBackupCodesHashingScrypt;

	public boolean enableUnitTests = false;

	public ConfigurationLoader() throws IOException {
		this.serverGeneral = FileUtils.readPropertiesFile(ConfigurationsPaths.Server.GENERAL_SETTINGS);
		this.serverSsl     = FileUtils.readPropertiesFile(ConfigurationsPaths.Server.SSL_SETTINGS);

		this.emailTemplateLoginBody = ConfigurationsPaths.EmailCreator.Verification.LOGIN_VERIFICATION_EMAIL_BODY_FILE_PATH;
		this.emailTemplateCreateAccountBody = ConfigurationsPaths.EmailCreator.Verification.CREATE_ACCOUNT_VERIFICATION_EMAIL_BODY_FILE_PATH;
		this.emailTemplateDeleteAccountBody = ConfigurationsPaths.EmailCreator.Verification.DELETE_ACCOUNT_VERIFICATION_EMAIL_BODY_FILE_PATH;
		this.emailTemplateChangePasswordBody = ConfigurationsPaths.EmailCreator.Verification.CHANGE_PASSWORD_VERIFICATION_EMAIL_BODY_FILE_PATH;
		this.emailTemplateBackupVerificationCodesBody = ConfigurationsPaths.EmailCreator.BACKUP_VERIFICATION_CODES_EMAIL_BODY_FILE_PATH;

		this.emailerGeneral = FileUtils.readPropertiesFile(ConfigurationsPaths.Emailer.GENERAL_SETTINGS_PATH);

		this.databaseGeneral = FileUtils.readPropertiesFile(ConfigurationsPaths.Database.GENERAL_SETTINGS_PATH);
		this.databaseDriver  = FileUtils.readPropertiesFile(ConfigurationsPaths.Database.DRIVER_SETTINGS_PATH);
		this.databasePooling = FileUtils.readPropertiesFile(ConfigurationsPaths.Database.POOLING_SETTINGS_PATH);

		this.databaseClientGeneral  = FileUtils.readPropertiesFile(ConfigurationsPaths.Client.GENERAL_SETTINGS_PATH);
		this.databaseClientUsername = FileUtils.readPropertiesFile(ConfigurationsPaths.Client.USERNAME_SETTINGS_PATH);

        this.databaseClientPasswordGeneral        = FileUtils.readPropertiesFile(ConfigurationsPaths.Client.Password.GENERAL_SETTINGS_PATH);
        this.databaseClientPasswordHashingArgon2  = FileUtils.readPropertiesFile(ConfigurationsPaths.Client.Password.HashingAlgorithms.ARGON2_SETTINGS_PATH);
        this.databaseClientPasswordHashingBcrypt  = FileUtils.readPropertiesFile(ConfigurationsPaths.Client.Password.HashingAlgorithms.BCRYPT_SETTINGS_PATH);
        this.databaseClientPasswordHashingScrypt  = FileUtils.readPropertiesFile(ConfigurationsPaths.Client.Password.HashingAlgorithms.SCRYPT_SETTINGS_PATH);

        this.databaseClientBackupCodesGeneral       = FileUtils.readPropertiesFile(ConfigurationsPaths.BackupVerificationCodes.GENERAL_SETTINGS_PATH);
        this.databaseClientBackupCodesHashingArgon2 = FileUtils.readPropertiesFile(ConfigurationsPaths.BackupVerificationCodes.HashingAlgorithms.ARGON2_SETTINGS_PATH);
        this.databaseClientBackupCodesHashingBcrypt = FileUtils.readPropertiesFile(ConfigurationsPaths.BackupVerificationCodes.HashingAlgorithms.BCRYPT_SETTINGS_PATH);
        this.databaseClientBackupCodesHashingScrypt = FileUtils.readPropertiesFile(ConfigurationsPaths.BackupVerificationCodes.HashingAlgorithms.SCRYPT_SETTINGS_PATH);
	}

	// Constructor utilized by Builder
	private ConfigurationLoader(Builder builder) {
		this.serverGeneral = orEmpty(builder.serverGeneral);
		this.serverSsl     = orEmpty(builder.serverSsl);

		this.emailTemplateLoginBody                   = builder.emailTemplateLoginBody;
		this.emailTemplateCreateAccountBody           = builder.emailTemplateCreateAccountBody;
		this.emailTemplateDeleteAccountBody           = builder.emailTemplateDeleteAccountBody;
		this.emailTemplateChangePasswordBody          = builder.emailTemplateChangePasswordBody;
		this.emailTemplateBackupVerificationCodesBody = builder.emailTemplateBackupVerificationCodesBody;

		this.emailerGeneral = orEmpty(builder.emailerGeneral);

		this.databaseGeneral = orEmpty(builder.databaseGeneral);
		this.databaseDriver  = orEmpty(builder.databaseDriver);
		this.databasePooling = orEmpty(builder.databasePooling);

		this.databaseClientGeneral  = orEmpty(builder.databaseClientGeneral);
		this.databaseClientUsername = orEmpty(builder.databaseClientUsername);

		this.databaseClientPasswordGeneral       = orEmpty(builder.databaseClientPasswordGeneral);
		this.databaseClientPasswordHashingArgon2 = orEmpty(builder.databaseClientPasswordHashingArgon2);
		this.databaseClientPasswordHashingBcrypt = orEmpty(builder.databaseClientPasswordHashingBcrypt);
		this.databaseClientPasswordHashingScrypt = orEmpty(builder.databaseClientPasswordHashingScrypt);

		this.databaseClientBackupCodesGeneral       = orEmpty(builder.databaseClientBackupCodesGeneral);
		this.databaseClientBackupCodesHashingArgon2 = orEmpty(builder.databaseClientBackupCodesHashingArgon2);
		this.databaseClientBackupCodesHashingBcrypt = orEmpty(builder.databaseClientBackupCodesHashingBcrypt);
		this.databaseClientBackupCodesHashingScrypt = orEmpty(builder.databaseClientBackupCodesHashingScrypt);

		this.enableUnitTests = builder.enableUnitTests;
	}

	private static Properties orEmpty(Properties p) {
		return p != null ? p : new Properties();
	}

    public Properties getServerGeneral()    { return serverGeneral; }
    public Properties getServerSsl()        { return serverSsl; }

    public String getEmailTemplateLoginBody()                   { return emailTemplateLoginBody; }
    public String getEmailTemplateCreateAccountBody()           { return emailTemplateCreateAccountBody; }
    public String getEmailTemplateDeleteAccountBody()           { return emailTemplateDeleteAccountBody; }
    public String getEmailTemplateChangePasswordBody()          { return emailTemplateChangePasswordBody; }
    public String getEmailTemplateBackupVerificationCodesBody() { return emailTemplateBackupVerificationCodesBody; }

    public Properties getEmailerGeneral()   { return emailerGeneral; }

    public Properties getDatabaseGeneral()  { return databaseGeneral; }
    public Properties getDatabaseDriver()   { return databaseDriver; }
    public Properties getDatabasePooling()  { return databasePooling; }

    public Properties getDatabaseClientGeneral()   { return databaseClientGeneral; }
    public Properties getDatabaseClientUsername()  { return databaseClientUsername; }

    public Properties getDatabaseClientPasswordGeneral()        { return databaseClientPasswordGeneral; }
    public Properties getDatabaseClientPasswordHashingArgon2()  { return databaseClientPasswordHashingArgon2; }
    public Properties getDatabaseClientPasswordHashingBcrypt()  { return databaseClientPasswordHashingBcrypt; }
    public Properties getDatabaseClientPasswordHashingScrypt()  { return databaseClientPasswordHashingScrypt; }

    public Properties getDatabaseClientBackupCodesGeneral()       { return databaseClientBackupCodesGeneral; }
    public Properties getDatabaseClientBackupCodesHashingArgon2() { return databaseClientBackupCodesHashingArgon2; }
    public Properties getDatabaseClientBackupCodesHashingBcrypt() { return databaseClientBackupCodesHashingBcrypt; }
    public Properties getDatabaseClientBackupCodesHashingScrypt() { return databaseClientBackupCodesHashingScrypt; }

	// Builder useful for tests
	public static class Builder {

		private Properties serverGeneral;
		private Properties serverSsl;

		private String emailTemplateLoginBody;
		private String emailTemplateCreateAccountBody;
		private String emailTemplateDeleteAccountBody;
		private String emailTemplateChangePasswordBody;
		private String emailTemplateBackupVerificationCodesBody;

		private Properties emailerGeneral;

		private Properties databaseGeneral;
		private Properties databaseDriver;
		private Properties databasePooling;

		private Properties databaseClientGeneral;
		private Properties databaseClientUsername;

		private Properties databaseClientPasswordGeneral;
		private Properties databaseClientPasswordHashingArgon2;
		private Properties databaseClientPasswordHashingBcrypt;
		private Properties databaseClientPasswordHashingScrypt;

		private Properties databaseClientBackupCodesGeneral;
		private Properties databaseClientBackupCodesHashingArgon2;
		private Properties databaseClientBackupCodesHashingBcrypt;
		private Properties databaseClientBackupCodesHashingScrypt;

		private boolean enableUnitTests;

        public Builder withServerGeneral(Properties p)   { this.serverGeneral = p; return this; }
        public Builder withServerSsl(Properties p)       { this.serverSsl = p; return this; }

        public Builder withEmailTemplateLoginBody(String path)                   { this.emailTemplateLoginBody = path; return this; }
        public Builder withEmailTemplateCreateAccountBody(String path)           { this.emailTemplateCreateAccountBody = path; return this; }
        public Builder withEmailTemplateDeleteAccountBody(String path)           { this.emailTemplateDeleteAccountBody = path; return this; }
        public Builder withEmailTemplateChangePasswordBody(String path)          { this.emailTemplateChangePasswordBody = path; return this; }
        public Builder withEmailTemplateBackupVerificationCodesBody(String path) { this.emailTemplateBackupVerificationCodesBody = path; return this; }

        public Builder withEmailerGeneral(Properties p)  { this.emailerGeneral = p; return this; }

        public Builder withDatabaseGeneral(Properties p) { this.databaseGeneral = p; return this; }
        public Builder withDatabaseDriver(Properties p)  { this.databaseDriver = p; return this; }
        public Builder withDatabasePooling(Properties p) { this.databasePooling = p; return this; }

        public Builder withDatabaseClientGeneral(Properties p)  { this.databaseClientGeneral = p; return this; }
        public Builder withDatabaseClientUsername(Properties p) { this.databaseClientUsername = p; return this; }

        public Builder withDatabaseClientPasswordGeneral(Properties p)       { this.databaseClientPasswordGeneral = p; return this; }
        public Builder withDatabaseClientPasswordHashingArgon2(Properties p) { this.databaseClientPasswordHashingArgon2 = p; return this; }
        public Builder withDatabaseClientPasswordHashingBcrypt(Properties p) { this.databaseClientPasswordHashingBcrypt = p; return this; }
        public Builder withDatabaseClientPasswordHashingScrypt(Properties p) { this.databaseClientPasswordHashingScrypt = p; return this; }

        public Builder withDatabaseClientBackupCodesGeneral(Properties p)       { this.databaseClientBackupCodesGeneral = p; return this; }
        public Builder withDatabaseClientBackupCodesHashingArgon2(Properties p) { this.databaseClientBackupCodesHashingArgon2 = p; return this; }
        public Builder withDatabaseClientBackupCodesHashingBcrypt(Properties p) { this.databaseClientBackupCodesHashingBcrypt = p; return this; }
        public Builder withDatabaseClientBackupCodesHashingScrypt(Properties p) { this.databaseClientBackupCodesHashingScrypt = p; return this; }

		public Builder withJUnitTestsEnabled() { this.enableUnitTests  = true; return this; }

		public ConfigurationLoader build() {
			return new ConfigurationLoader(this);
		}

	}
}
