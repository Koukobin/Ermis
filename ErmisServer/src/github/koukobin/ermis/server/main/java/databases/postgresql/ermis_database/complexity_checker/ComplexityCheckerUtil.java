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
package github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.complexity_checker;

import com.google.common.base.CharMatcher;

/**
 * @author Ilias Koukovinis
 *
 */
final class ComplexityCheckerUtil {

	private ComplexityCheckerUtil() {}
	
	public static boolean estimate(Requirements requirements, String string) {
		// Check if username has exceeded minimum required entropy
		boolean hasStringExceededMaxLength = string.length() > requirements.getMaxLength();

		if (hasStringExceededMaxLength) {
			return false;
		}

		if (requirements.getInvalidCharacters() != null) {

			boolean doesStringMatchInvalidCharacters = CharMatcher.anyOf(requirements.getInvalidCharacters()).matchesAnyOf(string);

			if (doesStringMatchInvalidCharacters) {
				return false;
			}
		}

		return true;
	}
}
