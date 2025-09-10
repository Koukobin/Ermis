/* Copyright (C) 2025 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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
package github.koukobin.ermis.desktop_client.main.java.database.models;

import java.time.LocalDateTime;
import java.util.Objects;
import java.util.UUID;

/**
 * @author Ilias Koukovinis
 *
 */
public class LocalAccountInfo {

	private String email;
	private String passwordHash;
	private UUID deviceUUID;
	private LocalDateTime lastUsed;

	public LocalAccountInfo(String email, String passwordHash, UUID deviceUUID, LocalDateTime lastUsed) {
		this.email = email;
		this.passwordHash = passwordHash;
		this.deviceUUID = deviceUUID;
		this.lastUsed = lastUsed;
	}

	public String getEmail() {
		return email;
	}

	public String getPasswordHash() {
		return passwordHash;
	}

	public UUID getDeviceUUID() {
		return deviceUUID;
	}

	public LocalDateTime getLastUsed() {
		return lastUsed;
	}

	@Override
	public int hashCode() {
		return Objects.hash(deviceUUID, email, lastUsed, passwordHash);
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;

		if (obj == null)
			return false;

		if (getClass() != obj.getClass())
			return false;

		LocalAccountInfo other = (LocalAccountInfo) obj;
		return Objects.equals(deviceUUID, other.deviceUUID) 
				&& Objects.equals(email, other.email)
				&& Objects.equals(lastUsed, other.lastUsed) 
				&& Objects.equals(passwordHash, other.passwordHash);
	}

	@Override
	public String toString() {
		return "LocalAccountInfo [email=" + email 
				+ ", passwordHash=" + passwordHash 
				+ ", deviceUUID=" + deviceUUID
				+ ", lastUsed=" + lastUsed + "]";
	}
}
