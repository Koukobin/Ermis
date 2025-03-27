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
package github.koukobin.ermis.common;

import java.util.Arrays;
import java.util.HashMap;
import java.util.stream.Collectors;

import github.koukobin.ermis.common.util.EnumIntConverter;

/**
 * @author Ilias Koukovinis
 *
 */
public enum ClientStatus {
	ONLINE(0), OFFLINE(1), DO_NOT_DISTURB(2), INVISIBLE(3);

	private static final HashMap<Integer, ClientStatus> values;

	static {
		values = new HashMap<>(
				Arrays.stream(ClientStatus.values())
				.collect(Collectors.toUnmodifiableMap(type -> type.id, type -> type))
				);
	}

	public final int id;

	ClientStatus(int id) {
		this.id = id;
	}

	public static ClientStatus fromId(int id) {
		return EnumIntConverter.fromId(values, id);
	}
}

