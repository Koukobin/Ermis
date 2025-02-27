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

import java.io.InputStream;
import java.util.Properties;

import com.google.common.base.Throwables;

import github.koukobin.ermis.server.main.java.util.ConsoleFormatter;

/**
 * @author Ilias Koukovinis
 *
 */
public final class GeneralServerInfo {

	public static final String VERSION;

	static {
		String version = "Version Not Found!"; // By default, set version to not found

		try (InputStream input = GeneralServerInfo.class
				.getResourceAsStream("/META-INF/maven/io.github.koukobin.ermis/ermis.server/pom.properties")) {
			Properties properties = new Properties();
			properties.load(input);
			version = properties.getProperty("version", "Version Not Specified!");
		} catch (Exception e) {
			ConsoleFormatter.styledPrint("WARNING: SERVER VERSION NOT DETECTED:",
					ConsoleFormatter.TextStyle.YELLOW,
					ConsoleFormatter.TextStyle.UNDERLINED);
			ConsoleFormatter.styledPrint(Throwables.getStackTraceAsString(e),
					ConsoleFormatter.TextStyle.YELLOW);
		}

		VERSION = version;
	}

	private GeneralServerInfo() {}
}
