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
package github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.complexity_checker;

import java.util.Objects;

/**
 * @author Ilias Koukovinis
 * 
 */
public class Requirements {

	private float minEntropy;
	private int maxLength;
	private String invalidCharacters;

	public Requirements() {}

	public Requirements(float minEntropy, int maxLength, String invalidCharacters) {
		this.minEntropy = minEntropy;
		this.maxLength = maxLength;
		this.invalidCharacters = invalidCharacters;
	}

	public void setMinEntropy(float minEntropy) {
		this.minEntropy = minEntropy;
	}

	public void setMaxLength(int maxLength) {
		this.maxLength = maxLength;
	}

	public void setInvalidCharacters(String invalidCharacters) {
		this.invalidCharacters = invalidCharacters;
	}

	public float getMinEntropy() {
		return minEntropy;
	}

	public int getMaxLength() {
		return maxLength;
	}

	public String getInvalidCharacters() {
		return invalidCharacters;
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

		Requirements other = (Requirements) obj;

		final double THRESHOLD = .0001;
		return this.maxLength == other.maxLength
				&& Math.abs(this.minEntropy - other.minEntropy) < THRESHOLD
				&& Objects.equals(this.invalidCharacters, other.invalidCharacters);
	}

	@Override
	public int hashCode() {
		return Objects.hash(invalidCharacters, maxLength, minEntropy);
	}

	public String toString() {
		return "Requirements:\nminEntropy=" + minEntropy + "\nmaxLength=" + maxLength + "\ninvalidCharacters=" + invalidCharacters;
	}
}

