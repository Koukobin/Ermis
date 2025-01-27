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

import java.util.Objects;

/**
 * @author Ilias Koukovinis
 *
 */
public class ResultHolder {

	private boolean isSuccessful;
	private String resultMessage;

	public ResultHolder(boolean success, String resultMessage) {
		this.isSuccessful = success;
		this.resultMessage = resultMessage;
	}

	public void setIsSuccesfull(boolean isSuccesfull) {
		this.isSuccessful = isSuccesfull;
	}
	
	public void setResultMessage(String resultMessage) {
		this.resultMessage = resultMessage;
	}
	
	public boolean isSuccessful() {
		return isSuccessful;
	}

	public String getResultMessage() {
		return resultMessage;
	}

	@Override
	public int hashCode() {
		return Objects.hash(isSuccessful, resultMessage);
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

		ResultHolder other = (ResultHolder) obj;
		return isSuccessful == other.isSuccessful && Objects.equals(resultMessage, other.resultMessage);
	}

	@Override
	public String toString() {
		return "ResultHolder [isSuccesfull=" + isSuccessful + ", resultMessage=" + resultMessage + "]";
	}
}
