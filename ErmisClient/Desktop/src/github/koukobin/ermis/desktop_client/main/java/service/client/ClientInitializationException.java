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
package github.koukobin.ermis.desktop_client.main.java.service.client;

/**
 * @author Ilias Koukovinis
 *
 */
@SuppressWarnings("serial") // Does not need serial ID
public class ClientInitializationException extends Exception {

	public ClientInitializationException() {
		super();
	}
	
    public ClientInitializationException(String message) {
        super(message);
    }
	
    public ClientInitializationException(String message, Throwable cause) {
        super(message, cause);
    }

    public ClientInitializationException(Throwable cause) {
        super(cause);
    }
}
