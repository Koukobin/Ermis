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

import java.util.HashMap;

import github.koukobin.ermis.common.util.EnumIntConverter;

/**
 * @author Ilias Koukovinis
 *
 */
public enum VoiceCallHistoryStatus {
	CREATED(0), ACCEPTED(1), IGNORED(2);

	private static final HashMap<Integer, VoiceCallHistoryStatus> valuesByCode = new HashMap<>();

	static {
		for (VoiceCallHistoryStatus deviceType : VoiceCallHistoryStatus.values()) {
			valuesByCode.put(deviceType.id, deviceType);
		}
	}

	public final int id;

	VoiceCallHistoryStatus(int id) {
		this.id = id;
	}

	public static VoiceCallHistoryStatus fromId(int id) {
		return EnumIntConverter.fromId(valuesByCode, id);
	}

}
