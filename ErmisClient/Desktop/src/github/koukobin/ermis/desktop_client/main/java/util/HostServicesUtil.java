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
package github.koukobin.ermis.desktop_client.main.java.util;

import javafx.application.HostServices;

/**
 * 
 * Utility class to hold a reference to JavaFX's HostServices instance, which
 * facilitates browser access. Due to the way JavaFX operates, it supplies
 * HostServices only through the primary application instance. Consequently,
 * creating this utility class is necessary.
 * 
 * @author Ilias Koukovinis
 *
 */
public final class HostServicesUtil {

	private static HostServices hostServices;

	private HostServicesUtil() {}

	public static void inititalize(HostServices services) {
		if (hostServices == null) {
			hostServices = services;
		} else {
			throw new IllegalStateException("HostServices has already been initialized");
		}
	}

	public static HostServices getHostServices() {
		if (hostServices == null) {
			throw new IllegalStateException("HostServices not initialized");
		}

		return hostServices;
	}
}

