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

import github.koukobin.ermis.common.util.FileUtils;

/**
 * @author Ilias Koukovinis
 *
 */
public final class EmailerSettings {

	private static final Properties GENERAL_PROPERTIES;

	static {
		try {
			GENERAL_PROPERTIES = FileUtils.readPropertiesFile(ConfigurationsPaths.Emailer.GENERAL_SETTINGS_PATH);
		} catch (IOException ioe) {
			throw new RuntimeException(ioe);
		}
	}

	public static final String MAIL_SMTP_HOST = GENERAL_PROPERTIES.getProperty("mailSmtpHost");
	public static final String MAIL_SMTP_PORT = GENERAL_PROPERTIES.getProperty("mailSmtpPort");
	
	public static final String EMAIL_USERNAME = GENERAL_PROPERTIES.getProperty("emailUsername");
	public static final String EMAIL_PASSWORD = new String(
			GENERAL_PROPERTIES.getProperty("emailPassword")
			.getBytes(StandardCharsets.ISO_8859_1 /* This charset is used to ensure password can contain latin characters */));
	
	private EmailerSettings() {}
}
