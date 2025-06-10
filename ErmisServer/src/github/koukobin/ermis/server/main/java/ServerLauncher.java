/* Copyright (C) 2021-2025 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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
package github.koukobin.ermis.server.main.java;

import java.io.IOException;
import java.io.InputStream;

import github.koukobin.ermis.server.main.java.configs.LoggerSettings;
import github.koukobin.ermis.server.main.java.server.Server;
import github.koukobin.ermis.server.main.java.util.ConsoleFormatter;

/**
 * @author Ilias Koukovinis
 */
public class ServerLauncher {

	static {
		LoggerSettings.initializeConfigurationFile();
	}
	
	public static void main(String[] args) {
		try (InputStream is = ServerLauncher.class.getResourceAsStream("/github/koukobin/ermis/server/main/resources/banner.txt")) {
            if (is != null) {
            	System.out.println(new String(is.readAllBytes())); // Print Ermis-Server banner
            } else {
            	System.out.println("Could not load Ermis-Server Banner!");
				System.out.println();
			}

			ConsoleFormatter.styledPrint("Author: Ilias Koukovinis",
					ConsoleFormatter.TextStyle.ITALICS,
					ConsoleFormatter.TextStyle.UNDERLINED);
			System.out.println();
		} catch (IOException ioe) {
			ioe.printStackTrace(); // Shouldn't happen
		} finally {
			Server.start();
		}
	}
}
