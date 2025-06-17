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
package github.koukobin.ermis.server.main.java.databases;

import java.util.Properties;

import javax.sql.DataSource;

import java.util.Map.Entry;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

/**
 * @author Ilias Koukovinis
 *
 */
public interface Database {

	abstract class HikariDataSourceBuilder<E extends DataSource, T extends HikariDataSourceBuilder<E,T>> {

		private T thisObj;

		/**
		 * Will be used to get the JDBC url
		 */
		protected E dataSource;
		private HikariConfig config;

		{
			config = new HikariConfig();
			thisObj = getThis();
		}

		protected abstract T getThis();
		protected abstract String getJdbcUrl();

		public T setUser(String user) {
			config.setUsername(user);
			return thisObj;
		}

		public T setUserPassword(String userPassword) {
			config.setPassword(userPassword);
			return thisObj;
		}

		public T addDriverProperties(Properties driverProperties) {
			for (Entry<Object, Object> entry : driverProperties.entrySet()) {
				addDataSourceProperty(String.valueOf(entry.getKey()), String.valueOf(entry.getValue()));
			}
			return thisObj;
		}

		public T addDataSourceProperty(String name, String value) {

			// only add property if value is not null
			if ("null".equalsIgnoreCase(value)) {
				return thisObj;
			}

			config.addDataSourceProperty(name, value);
			return thisObj;
		}

		public T setMinimumIdle(int minIdle) {
			config.setMinimumIdle(minIdle);
			return thisObj;
		}

		public T setMaximumPoolSize(int maxIdle) {
			config.setMaximumPoolSize(maxIdle);
			return thisObj;
		}

		public T setAutoCommit(boolean autoCommit) {
			config.setAutoCommit(autoCommit);
			return thisObj;
		}

		public T setConnectionTimeout(int connectionTimeout) {
			config.setConnectionTimeout(connectionTimeout);
			return thisObj;
		}

		public T setIdleTimeout(int idleTimeout) {
			config.setIdleTimeout(idleTimeout);
			return thisObj;
		}

		public T setKeepaliveTime(int keepAliveTime) {
			config.setKeepaliveTime(keepAliveTime);
			return thisObj;
		}

		public T setMaxLifetime(int maxLifetime) {
			config.setMaxLifetime(maxLifetime);
			return thisObj;
		}

		public T setInitializationFailTimeout(int initializationFailTimeout) {
			config.setInitializationFailTimeout(initializationFailTimeout);
			return thisObj;
		}

		public T setIsolateInternalQueries(boolean isolateInternalQueries) {
			config.setIsolateInternalQueries(isolateInternalQueries);
			return thisObj;
		}

		public T setAllowPoolSuspension(boolean allowPoolSuspension) {
			config.setAllowPoolSuspension(allowPoolSuspension);
			return thisObj;
		}

		public T setReadOnly(boolean readOnly) {
			config.setReadOnly(readOnly);
			return thisObj;
		}

		public T setValidationTimeout(int validationTimeout) {
			config.setValidationTimeout(validationTimeout);
			return thisObj;
		}

		public T setLeakDetectionThreshold(int leakDetectionThreshold) {
			config.setLeakDetectionThreshold(leakDetectionThreshold);
			return thisObj;
		}

		public HikariDataSource build() {
			config.setJdbcUrl(getJdbcUrl());
			return new HikariDataSource(config);
		}
	}
}
