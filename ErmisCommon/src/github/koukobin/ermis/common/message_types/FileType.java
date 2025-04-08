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
package github.koukobin.ermis.common.message_types;

import java.util.HashMap;
import java.util.Map;

import github.koukobin.ermis.common.util.EnumIntConverter;

/**
 * @author Ilias Koukovinis
 *
 */
public enum FileType {
	FILE((byte) 0), IMAGE((byte) 1), VOICE((byte) 2);

	private static final Map<Byte, FileType> values;

	static {
		values = new HashMap<>();

		for (FileType type : FileType.values()) {
			if (values.containsKey(type.id)) {
				throw new IllegalArgumentException("Duplicate DownloadFileType ID: " + type.id);
			}
			values.put(type.id, type);
		}
	}

	public final byte id;

	FileType(byte id) {
		this.id = id;
	}

	public static FileType fromId(byte id) {
		return EnumIntConverter.fromId(values, id);
	}
}
