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

import github.koukobin.ermis.common.util.FileUtils;

/**
 * @author Ilias Koukovinis
 *
 */
public final class ServerSettings {

	private static final Logger logger = LogManager.getLogger("server");

	private static final Properties GENERAL_PROPERTIES;

	static {
		try {
			GENERAL_PROPERTIES = FileUtils.readPropertiesFile(ConfigurationsPaths.Server.GENERAL_SETTINGS);
		} catch (IOException ioe) {
			logger.fatal(Throwables.getStackTraceAsString(ioe));
			throw new RuntimeException(ioe);
		}
	}

	public static final boolean IS_PRODUCTION_READY = Boolean.parseBoolean(GENERAL_PROPERTIES.getProperty("isProductionReady"));

	public static final String SOURCE_CODE_URL = GENERAL_PROPERTIES.getProperty("sourceCodeURL");

	public static final int SERVER_BACKLOG = Integer.parseInt(GENERAL_PROPERTIES.getProperty("backlog"));
	public static final int SERVER_PORT = Integer.parseInt(GENERAL_PROPERTIES.getProperty("port"));
	public static final String SERVER_ADDRESS = GENERAL_PROPERTIES.getProperty("address");

	public static final int VOICE_CALL_SIGNALLING_SERVER_PORT = 9999;

	/**
	 * Duration before inactive clients are kicked from the server
	 */
	public static final int CONNECT_TIMEOUT_MILLIS = Integer.parseInt(GENERAL_PROPERTIES.getProperty("connectTimeoutMillis"));

	public static final int WORKER_THREADS = Integer.parseInt(GENERAL_PROPERTIES.getProperty("workerThreads"));

	public static final int NUMBER_OF_MESSAGES_TO_READ_FROM_THE_DATABASE_AT_A_TIME = 30;

	public static final int MAX_CLIENT_MESSAGE_FILE_BYTES = Integer.parseInt(GENERAL_PROPERTIES.getProperty("maxClientMessageFileBytes"));;
	public static final int MAX_CLIENT_MESSAGE_TEXT_BYTES = Integer.parseInt(GENERAL_PROPERTIES.getProperty("maxClientMessageTextBytes"));

	private ServerSettings() {}

	public static class SSL {

		private static final Properties SSL_PROPERTIES;

		static {
			try {
				SSL_PROPERTIES = FileUtils.readPropertiesFile(ConfigurationsPaths.Server.SSL_SETTINGS);
			} catch (IOException ioe) {
				logger.fatal(Throwables.getStackTraceAsString(ioe));
				throw new RuntimeException(ioe);
			}
		}

		public static final String CERTIFICATE_TYPE = SSL_PROPERTIES.getProperty("key-store-type");
		public static final String CERTIFICATE_LOCATION = SSL_PROPERTIES.getProperty("key-store");
		public static final String CERTIFICATE_PASSWORD = new String(
				SSL_PROPERTIES.getProperty("key-store-password")
				.getBytes(StandardCharsets.ISO_8859_1 /* use this charset so password can contain latin characters */));

		private static final String[] ENABLED_PROTOCOLS = SSL_PROPERTIES.getProperty("enabled-protocols").replace(" ", "").split(",");
		private static final String[] ENABLED_CIPHER_SUITES = SSL_PROPERTIES.getProperty("ciphers").replace(" ", "").split(",");

		private SSL() {}

		public static String[] getEnabledProtocols() {
			return ENABLED_PROTOCOLS.clone();
		}

		public static String[] getEnabledCipherSuites() {
			return ENABLED_CIPHER_SUITES.clone();
		}
	}

	public static class Donations {

		public static final String DONATION_HTML_PAGE_URL = String.format("https://%s/donation.html", SERVER_ADDRESS);

		private Donations() {}
	}

}