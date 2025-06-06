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
package github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.models;

import java.util.Arrays;

import github.koukobin.ermis.common.util.EmptyArrays;

/**
 * @author Ilias Koukovinis
 *
 */
public record UserIcon(byte[] iconBytes) {

	public static final UserIcon EMPTY_USER_ICON = new UserIcon(EmptyArrays.EMPTY_BYTE_ARRAY);

	public static UserIcon empty() {
		return EMPTY_USER_ICON;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + Arrays.hashCode(iconBytes);
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj) {
			return true;
		}

		if (obj == null) {
			return false;
		}

		if (getClass() != obj.getClass()) {
			return false;
		}

		UserIcon other = (UserIcon) obj;
		return Arrays.equals(iconBytes, other.iconBytes);
	}

	@Override
	public String toString() {
		return "UserIcon [iconBytes=" + Arrays.toString(iconBytes) + "]";
	}
	
	
}
