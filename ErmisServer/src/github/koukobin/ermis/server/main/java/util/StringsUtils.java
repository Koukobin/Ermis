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
 * 
 * Utility class for working with strings and arrays. Provides methods to
 * convert arrays of primitive or object types into their string
 * representations.
 * 
 * @author Ilias Koukovinis
 *
 */
public final class StringsUtils {

	private StringsUtils() {}

	public static <T> String arrayToString(T[] array) {
		StringBuilder sb = new StringBuilder();
		for (T num : array) {
			sb.append(num);
		}
		return sb.toString();
	}

	public static String arrayToString(int[] array) {
		StringBuilder sb = new StringBuilder();
		for (int num : array) {
			sb.append(num);
		}
		return sb.toString();
	}

	public static <T> String arrayToStringWithDelimiter(T[] array, String delimiter) {
		StringBuilder sb = new StringBuilder();
		for (int i = 0; i < array.length; i++) {
			sb.append(array[i]);
			if (i < array.length - 1) {
				sb.append(delimiter);
			}
		}
		return sb.toString();
	}

	public static String arrayToStringWithDelimiter(int[] array, String delimiter) {
		StringBuilder sb = new StringBuilder();
		for (int i = 0; i < array.length; i++) {
			sb.append(array[i]);
			if (i < array.length - 1) {
				sb.append(delimiter);
			}
		}
		return sb.toString();
	}

}

