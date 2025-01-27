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

package github.koukobin.ermis.common.entry;

import java.util.HashMap;
import java.util.Map;

import github.koukobin.ermis.common.util.EnumIntConverter;

/**
 * @author Ilias Koukovinis
 *
 */
public enum EntryType {
	CREATE_ACCOUNT(1), LOGIN(2);

	private static final Map<Integer, EntryType> valuesById = new HashMap<>();

	static {
		for (EntryType entryType : EntryType.values()) {
			valuesById.put(entryType.id, entryType);
		}
	}

	public final int id;

	EntryType(int id) {
		this.id = id;
	}

	public static EntryType fromId(int id) {
		return EnumIntConverter.fromId(valuesById, id);
	}

	/**
	 * A tagging interface that all credential enums must extend.
	 * 
	 * @param <V>
	 */
	public sealed interface CredentialInterface permits CreateAccountInfo.Credential, LoginInfo.Credential {
		int id();
	}
}
