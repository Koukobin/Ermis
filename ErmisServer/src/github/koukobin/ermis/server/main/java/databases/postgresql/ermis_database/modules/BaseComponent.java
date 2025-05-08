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
package github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.modules;

import java.sql.Connection;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import github.koukobin.ermis.server.main.java.configs.DatabaseSettings;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.complexity_checker.PasswordComplexityChecker;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.complexity_checker.UsernameComplexityChecker;

/**
 * @author Ilias Koukovinis
 *
 */
public interface BaseComponent {
	Logger logger = LogManager.getLogger("database");

	UsernameComplexityChecker usernameComplexityChecker = new UsernameComplexityChecker(DatabaseSettings.Client.Username.REQUIREMENTS);
	PasswordComplexityChecker passwordComplexityChecker = new PasswordComplexityChecker(DatabaseSettings.Client.Password.REQUIREMENTS);

	Connection getConn();
}
