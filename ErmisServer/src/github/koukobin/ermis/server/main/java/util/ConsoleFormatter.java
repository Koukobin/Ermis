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
package github.koukobin.ermis.server.main.java.util;

/**
 * @author Ilias Koukovinis
 *
 */
public final class ConsoleFormatter {

	private ConsoleFormatter() {}

	public enum TextStyle {
		UNDERLINED("\u001B[4m"), ITALICS("\u001B[3m"), RED("\u001B[31m"), YELLOW("\u001B[33m");

		private final String ansiCode;

		TextStyle(String ansiCode) {
			this.ansiCode = ansiCode;
		}
	}

	public static void styledPrint(String message, TextStyle... settings) {
		final String ANSI_RESET = "\u001B[0m"; // Reset text formatting

		StringBuilder builder = new StringBuilder();
		for (TextStyle setting : settings) {
			builder.append(setting.ansiCode);
		}
		builder.append(message).append(ANSI_RESET);

		String finalMessage = builder.toString();
		System.out.println(finalMessage);
	}
}
