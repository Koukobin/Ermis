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
package github.koukobin.ermis.server.main.java.server.util;

import java.io.IOException;
import java.util.Map;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.google.common.base.Throwables;

import github.koukobin.ermis.common.util.FileUtils;
import github.koukobin.ermis.server.main.java.configs.ConfigurationsPaths;
import github.koukobin.ermis.server.main.java.configs.ServerSettings;

public class EmailCreator {

	private static final Logger logger = LogManager.getLogger("server");

	private static String createEmail(String emailBody, Map<String, String> replacements) {
		StringBuilder sb = new StringBuilder(emailBody);

		for (Map.Entry<String, String> entry : replacements.entrySet()) {
			String placeholder = entry.getKey();
			String replacementValue = entry.getValue();

			int startIndex = sb.indexOf(placeholder);

			if (startIndex == -1) {
				logger.error("Attempted to formulate email body but placeholder {} was not found", placeholder);
				continue;
			}

			while (startIndex != -1) {
				sb.replace(startIndex, startIndex + placeholder.length(), replacementValue);
				startIndex = sb.indexOf(replacementValue, startIndex + replacementValue.length());
			}
		}

		return sb.toString();
	}

	public static class Verification {

		private Verification() {}

		public interface VerificationEmailTemplate {

			static VerificationEmailTemplate of(String userEmail, String verificationCode) {
				return new VerificationEmailTemplate() {

					Map<String, String> replacements = Map.of(
							"USER_EMAIL", userEmail,
							"USER_ACCOUNT", userEmail,
							"VERIFICATION_CODE", verificationCode,
							"SERVER_ADDRESS", ServerSettings.SERVER_ADDRESS,
							"SERVER_PORT", Integer.toString(ServerSettings.SERVER_PORT)
							);

					public String createEmail(String verificationEmailBody) {
						return EmailCreator.createEmail(verificationEmailBody, replacements);
					}

				};
			}

			String createEmail(String verificationEmailBody);
		}

		public static class Login {

			public static final String VERIFICATION_EMAIL_BODY;

			static {
				try {
					VERIFICATION_EMAIL_BODY = FileUtils.readFile(ConfigurationsPaths.EmailCreator.Verification.LOGIN_VERIFICATION_EMAIL_BODY_FILE_PATH);
				} catch (IOException ioe) {
					logger.fatal(Throwables.getStackTraceAsString(ioe));
					throw new RuntimeException(ioe);
				}
			}

			private Login() {}

			public static String createEmail(VerificationEmailTemplate template) {
				return template.createEmail(VERIFICATION_EMAIL_BODY);
			}
		}

		public static class DeleteAccount {

			public static final String VERIFICATION_EMAIL_BODY;

			static {
				try {
					VERIFICATION_EMAIL_BODY = FileUtils.readFile(ConfigurationsPaths.EmailCreator.Verification.DELETE_ACCOUNT_VERIFICATION_EMAIL_BODY_FILE_PATH);
				} catch (IOException ioe) {
					logger.fatal(Throwables.getStackTraceAsString(ioe));
					throw new RuntimeException(ioe);
				}
			}

			private DeleteAccount() {}

			public static String createEmail(VerificationEmailTemplate template) {
				return template.createEmail(VERIFICATION_EMAIL_BODY);
			}
		}

		public static class CreateAccount {

			public static final String VERIFICATION_EMAIL_BODY;

			static {
				try {
					VERIFICATION_EMAIL_BODY = FileUtils.readFile(ConfigurationsPaths.EmailCreator.Verification.CREATE_ACCOUNT_VERIFICATION_EMAIL_BODY_FILE_PATH);
				} catch (IOException ioe) {
					logger.fatal(Throwables.getStackTraceAsString(ioe));
					throw new RuntimeException(ioe);
				}
			}

			private CreateAccount() {}

			public static String createEmail(VerificationEmailTemplate template) {
				return template.createEmail(VERIFICATION_EMAIL_BODY);
			}
		}

		public static class ChangePassword {

			public static final String VERIFICATION_EMAIL_BODY;

			static {
				try {
					VERIFICATION_EMAIL_BODY = FileUtils.readFile(ConfigurationsPaths.EmailCreator.Verification.CHANGE_PASSWORD_VERIFICATION_EMAIL_BODY_FILE_PATH);
				} catch (IOException ioe) {
					logger.fatal(Throwables.getStackTraceAsString(ioe));
					throw new RuntimeException(ioe);
				}
			}

			private ChangePassword() {}

			public static String createEmail(VerificationEmailTemplate template) {
				return template.createEmail(VERIFICATION_EMAIL_BODY);
			}
		}

	}
	
	public static class BackupVerification {
		
		public static final String VERIFICATION_EMAIL_BODY;

		public interface EmailTemplate {

			static EmailTemplate of(String userEmail, String backupCodes) {
				return new EmailTemplate() {

					Map<String, String> replacements = Map.of(
							"USER_EMAIL", userEmail,
							"USER_ACCOUNT", userEmail,
							"BACKUP_VERIFICATION_CODES", backupCodes,
							"SERVER_ADDRESS", ServerSettings.SERVER_ADDRESS,
							"SERVER_PORT", Integer.toString(ServerSettings.SERVER_PORT)
							);

					public String createEmail(String emailBody) {
						return EmailCreator.createEmail(emailBody, replacements);
					}

				};
			}

			String createEmail(String emailBody);
		}
		
		static {
			try {
				VERIFICATION_EMAIL_BODY = FileUtils.readFile(ConfigurationsPaths.EmailCreator.BACKUP_VERIFICATION_CODES_EMAIL_BODY_FILE_PATH);
			} catch (IOException ioe) {
				logger.fatal(Throwables.getStackTraceAsString(ioe));
				throw new RuntimeException(ioe);
			}
		}

		private BackupVerification() {}

		public static String createEmail(EmailTemplate template) {
			return template.createEmail(VERIFICATION_EMAIL_BODY);
		}
	}

	private EmailCreator() {}
}
