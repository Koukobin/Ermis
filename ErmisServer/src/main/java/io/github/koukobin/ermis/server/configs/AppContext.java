/* Copyright (C) 2026 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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
package main.java.io.github.koukobin.ermis.server.configs;

import java.io.IOException;

/**
 * @author Ilias Koukovinis
 *
 */
public final class AppContext {

	private static AppContext instance;

	public final DatabaseSettings dbSettings;

	private AppContext(ConfigurationLoader loader) throws IOException {
		this.dbSettings = new DatabaseSettings(loader);
	}

	public static void initialize(ConfigurationLoader loader) throws IOException {
		if (instance != null)
			throw new IllegalStateException("AppContext already initialized");

		instance = new AppContext(loader);
	}

	public static AppContext get() {
		if (instance == null)
			throw new IllegalStateException("AppContext not initialized");

		return instance;
	}

	public DatabaseSettings getDBSettings() { return dbSettings; }
}
