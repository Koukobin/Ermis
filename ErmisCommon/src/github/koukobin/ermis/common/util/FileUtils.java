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
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;
import java.util.Scanner;

/**
 * 
 * A utility class for performing common file operations such as reading files
 * and managing properties files.
 * 
 * @author Ilias Koukovinis
 *
 */
public final class FileUtils {

	private FileUtils() {}

	public static String readFile(String filePath) throws FileNotFoundException {
		return readFile(new FileInputStream(filePath));
	}

	public static String readFile(File file) throws FileNotFoundException {
		return readFile(new FileInputStream(file));
	}

	public static String readFile(InputStream is) {
		StringBuilder fileContentStringBuilder = new StringBuilder();
		try (Scanner scanner = new Scanner(is)) {
			while (scanner.hasNextLine()) {
				fileContentStringBuilder.append(scanner.nextLine() + "\n");
			}
		}

		return fileContentStringBuilder.toString();
	}

	public static Properties readPropertiesFile(File configFile) throws IOException {
		return readPropertiesFile(configFile.getAbsolutePath());
	}

	public static Properties readPropertiesFile(String configFilePath) throws IOException {
		Properties props = new Properties();
		try (FileInputStream fis = new FileInputStream(configFilePath)) {
			props.load(fis);
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
	public static void replaceValueInPropertiesFile(String key, String value, File configFilePath) throws IOException {
		replaceValueInPropertiesFile(key, value, configFilePath.getAbsolutePath());
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
		try (FileWriter writer = new FileWriter(configFilePath)) {
			props.store(writer, null);
		}
	}

}
