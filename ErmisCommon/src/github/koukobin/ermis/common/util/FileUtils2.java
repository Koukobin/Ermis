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
package github.koukobin.ermis.common.util;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.Writer;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Properties;

/**
 * @author Ilias Koukovinis
 *
 */
public final class FileUtils2 {

    private FileUtils2() {}

	public static String readFile(String filePath) throws IOException {
		return readFile(new File(filePath));
	}

	public static String readFile(File file) throws IOException {
		return Files.readString(file.toPath());
	}

	public static Properties readPropertiesFile(File configFile) throws IOException {
		return readPropertiesFile(configFile.getAbsolutePath());
	}

	public static Properties readPropertiesFile(String configFilePath) throws IOException {
		Properties props = new Properties();
		try (InputStream is = Files.newInputStream(Path.of(configFilePath))) {
			props.load(is);
		}
		return props;
	}

	/**
	 * Replaces a property value in a properties file.
	 *
	 * @param key        the property key to update
	 * @param value      the new value for the property
	 * @param configFile the file to update
	 * @throws IOException if an I/O error occurs
	 */
	public static void replaceValueInPropertiesFile(String key, String value, File configFile) throws IOException {
		replaceValueInPropertiesFile(key, value, configFile.getAbsolutePath());
	}

	/**
	 * Replaces a property value in a properties file located at the given file
	 * path.
	 *
	 * @param key            the property key to update
	 * @param value          the new value for the property
	 * @param configFilePath the path to the properties file
	 * @throws IOException if an I/O error occurs
	 */
	public static void replaceValueInPropertiesFile(String key, String value, String configFilePath) throws IOException {
		Properties props = readPropertiesFile(configFilePath);
		props.setProperty(key, value);
		try (Writer writer = Files.newBufferedWriter(Path.of(configFilePath))) {
			props.store(writer, null);
		}
	}
}
