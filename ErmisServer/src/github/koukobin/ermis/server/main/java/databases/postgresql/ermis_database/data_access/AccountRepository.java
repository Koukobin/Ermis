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
package github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.data_access;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.google.common.base.Throwables;

/**
 * @author Ilias Koukovinis
 *
 */
public interface AccountRepository extends BaseComponent {

	default boolean accountWithEmailExists(String email) {
		boolean accountExists = false;

		try (PreparedStatement getEmailAddress = getConn().prepareStatement("SELECT 1 FROM users WHERE email=?;")) {
			getEmailAddress.setString(1, email);
			ResultSet rs = getEmailAddress.executeQuery();

			accountExists = rs.next();
		} catch (SQLException sqle) {
			logger.error(Throwables.getStackTraceAsString(sqle));
		}

		return accountExists;
	}
}
