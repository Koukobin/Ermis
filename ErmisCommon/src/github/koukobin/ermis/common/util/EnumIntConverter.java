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

import java.util.Map;

/**
 * @author Ilias Koukovinis
 *
 */
public final class EnumIntConverter {

	private EnumIntConverter() {}

	/**
	 * Retrieves an enum constant from a map by its ID.
	 *
	 * @param <T> the type of enum
	 * @param map the map containing enum values, with the ID as the key
	 * @param id  the ID to look up
	 * @return the enum constant corresponding to the provided ID
	 * @throws IndexOutOfBoundsException if the ID does not exist in the map (I do
	 *                                   know why I initially chose
	 *                                   IndexOutOfBoundsException instead of
	 *                                   IllegalArgumentException)
	 */
	public static <V, T extends Enum<T>> T fromId(Map<V, T> map, int id) {
		T result = map.get(id);

		if (result == null) {
			// TODO refactor; instead of throwing IndexOutOfBoundsException to throw
			// IllegalArgumentException
			throw new IllegalArgumentException(
					"No enum constant with ID " + id + " exists for " + map.getClass().getTypeName());
		}

		return result;
	}
}
