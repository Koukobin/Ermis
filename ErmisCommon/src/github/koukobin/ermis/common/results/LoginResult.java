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

import github.koukobin.ermis.common.entry.AddedInfo;
import github.koukobin.ermis.common.entry.LoginInfo;

/**
 * @author Ilias Koukovinis
 *
 */
public class LoginResult {
	
	private static final Map<AddedInfo, String> emptyAddedInfo = new EnumMap<>(AddedInfo.class);
	
	private final LoginInfo.Login.Result enumIndicatingResult;
	private final Map<AddedInfo, String> addedInfo;

	public LoginResult(LoginInfo.Login.Result enumIndicatingResult) {
		this.enumIndicatingResult = enumIndicatingResult;
		this.addedInfo = emptyAddedInfo;
	}
	
	public LoginResult(LoginInfo.Login.Result enumIndicatingResult, Map<AddedInfo, String> addedInfo) {
		this.enumIndicatingResult = enumIndicatingResult;
		this.addedInfo = addedInfo;
	}

	public LoginInfo.Login.Result getEnumIndicatingResult() {
		return enumIndicatingResult;
	}

	public Map<AddedInfo, String> getAddedInfo() {
		return addedInfo;
	}

	public boolean isSuccessful() {
		return enumIndicatingResult.resultHolder.isSuccessful();
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

		LoginResult other = (LoginResult) obj;
		return Objects.equals(addedInfo, other.addedInfo)
				&& Objects.equals(enumIndicatingResult, other.enumIndicatingResult);
	}

	@Override
	public String toString() {
		return "LoginResult [enumIndicatingResult=" + enumIndicatingResult + ", addedInfo=" + addedInfo + "]";
	}

}
