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

package github.koukobin.ermis.server.main.java.databases.mysql;

import java.sql.SQLException;

import com.mysql.cj.jdbc.MysqlDataSource;

import github.koukobin.ermis.server.main.java.databases.Database;

/**
 * @author Ilias Koukovinis
 *
 *         Unused
 */
public interface MySQLDatabase {

	class HikariDataSourceBuilder extends Database.HikariDataSourceBuilder<MysqlDataSource, MySQLDatabase.HikariDataSourceBuilder> {

		public HikariDataSourceBuilder() {
			dataSource = new MysqlDataSource();
		}

		public HikariDataSourceBuilder setServerName(String serverName) {
			dataSource.setServerName(serverName);
			return this;
		}

		public HikariDataSourceBuilder setDatabaseName(String databaseName) {
			dataSource.setDatabaseName(databaseName);
			return this;
		}

		public HikariDataSourceBuilder setPortNumber(int port) {
			dataSource.setPortNumber(port);
			return this;
		}

		public HikariDataSourceBuilder setTrustCertificateKeyStoreUrl(String certificateUrl) throws SQLException {
			dataSource.setTrustCertificateKeyStoreUrl(certificateUrl);
			return this;
		}

		public HikariDataSourceBuilder setTrustCertificateKeyStorePassword(String password) throws SQLException {
			dataSource.setTrustCertificateKeyStorePassword(password);
			return this;
		}

		@Override
		protected HikariDataSourceBuilder getThis() {
			return this;
		}

		@Override
		protected String getJdbcUrl() {
			return dataSource.getUrl();
		}
	}
}
