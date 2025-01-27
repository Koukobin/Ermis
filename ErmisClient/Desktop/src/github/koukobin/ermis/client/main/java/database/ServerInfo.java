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
package github.koukobin.ermis.client.main.java.database;

import java.net.InetAddress;
import java.net.PortUnreachableException;
import java.net.URL;
import java.net.UnknownHostException;
import java.time.Instant;
import java.util.Objects;

/**
 * @author Ilias Koukovinis
 *
 */
public final class ServerInfo {

	private final URL serverURL;
	private final InetAddress address;
	private final Instant lastUsed;

	public ServerInfo(URL serverURL) throws PortUnreachableException, UnknownHostException {
		int port = serverURL.getPort();
		if (port == -1) {

			port = serverURL.getDefaultPort();

			if (port == -1) {
				throw new PortUnreachableException("Port not found");
			}
		}

		this.serverURL = serverURL;
		this.address = InetAddress.getByName(serverURL.getHost());
		this.lastUsed = Instant.now();
	}
	
	public InetAddress getAddress() {
		return address;
	}

	public int getPort() {
		return serverURL.getPort();
	}

	public URL getURL() {
		return serverURL;
	}

	public Instant getLastUsed() {
        return lastUsed;
    }

	@Override
	public int hashCode() {
		return Objects.hash(serverURL, lastUsed);
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

		ServerInfo other = (ServerInfo) obj;
		return Objects.equals(serverURL, other.serverURL) && Objects.equals(lastUsed, other.lastUsed);
	}

	@Override
	public String toString() {
		return serverURL.toString();
	}
}
