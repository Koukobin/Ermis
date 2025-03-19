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
package github.koukobin.ermis.common.results;

import java.util.Arrays;
import java.util.HashMap;
import java.util.stream.Collectors;

import github.koukobin.ermis.common.util.EnumIntConverter;

/**
 * @author Ilias Koukovinis
 *
 */
public enum ChangeUsernameResult {
    SUCCESFULLY_CHANGED_USERNAME(0, true, "Succesfully changed username!"),
    PASSWORD_CANNOT_BE_IDENTICAL_TO_PREVIOUS_ONE(1, false, "Username cannot be the same as old username!"),
    ERROR_WHILE_CHANGING_USERNAME(2, false, "There was an error while trying to change username!"),
	REQUIREMENTS_NOT_MET(3, false, "Username requirements not met");

    private static final HashMap<Integer, ChangeUsernameResult> values;

    static {
		values = new HashMap<>(
				Arrays.stream(ChangeUsernameResult.values())
				.collect(Collectors.toMap(type -> type.id, type -> type))
				);
    }

    public final ResultHolder resultHolder;
    public final int id;

    ChangeUsernameResult(int id, boolean isSuccessful, String message) {
        resultHolder = new ResultHolder(isSuccessful, message);
        this.id = id;
    }

	public static ChangeUsernameResult fromId(int id) {
		return EnumIntConverter.fromId(values, id);
	}
}
