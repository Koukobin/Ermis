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

import java.util.EnumMap;
import java.util.Map;
import java.util.Objects;

import github.koukobin.ermis.common.IDable;
import github.koukobin.ermis.common.entry.AddedInfo;

/**
 * @author Ilias Koukovinis
 *
 */
public final class GeneralResult {
	
	private static final Map<AddedInfo, String> emptyAddedInfo = new EnumMap<>(AddedInfo.class);
	
	private final IDable enumIndicatingResult;
	private final boolean isSuccessful;
	private final Map<AddedInfo, String> addedInfo;

	public GeneralResult(IDable enumIndicatingResult, boolean isSuccessful) {
		this.enumIndicatingResult = enumIndicatingResult;
		this.isSuccessful = isSuccessful;
		this.addedInfo = emptyAddedInfo;
	}
	
	public GeneralResult(IDable enumIndicatingResult, boolean isSuccessful, Map<AddedInfo, String> addedInfo) {
		this.enumIndicatingResult = enumIndicatingResult;
		this.isSuccessful = isSuccessful;
		this.addedInfo = addedInfo;
	}

	public IDable getIDable() {
		return enumIndicatingResult;
	}

	public boolean isSuccessful() {
		return isSuccessful;
	}

	public Map<AddedInfo, String> getAddedInfo() {
		return addedInfo;
	}

	@Override
	public int hashCode() {
		return Objects.hash(addedInfo, enumIndicatingResult);
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

		GeneralResult other = (GeneralResult) obj;
		return Objects.equals(addedInfo, other.addedInfo)
				&& Objects.equals(enumIndicatingResult, other.enumIndicatingResult);
	}

	@Override
	public String toString() {
		return "CreateAccountResult [enumIndicatingResult=" + enumIndicatingResult + ", addedInfo=" + addedInfo + "]";
	}

}
