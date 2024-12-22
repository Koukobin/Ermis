/* Copyright (C) 2024 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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
import java.util.Objects;

/**
 * @author Ilias Koukovinis
 *
 */
public record Account(byte[] profilePhoto, String displayName, int clientID) {

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + Arrays.hashCode(profilePhoto);
		result = prime * result + Objects.hash(clientID, displayName);
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
		
		Account other = (Account) obj;
		return clientID == other.clientID 
				&& Arrays.equals(profilePhoto, other.profilePhoto)
				&& Objects.equals(displayName, other.displayName);
	}

	@Override
	public String toString() {
		return "Account [icon=" + Arrays.toString(profilePhoto) + ", username=" + displayName + ", clientID=" + clientID + "]";
	}

}
