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
public enum AddedInfo {
	PASSWORD_HASH(1),
	BACKUP_VERIFICATION_CODES(2),
	DEVICE_UUID(3);

	private static final Map<Integer, AddedInfo> valuesById = new HashMap<>();

	static {
		for (AddedInfo entryType : AddedInfo.values()) {
			valuesById.put(entryType.id, entryType);
		}
	}

	public final int id;

	AddedInfo(int id) {
		this.id = id;
	}

	public static AddedInfo fromId(int id) {
		return EnumIntConverter.fromId(valuesById, id);
	}
}
