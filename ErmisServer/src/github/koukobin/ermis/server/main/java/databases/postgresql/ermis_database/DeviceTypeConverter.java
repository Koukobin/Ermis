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
package github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database;

import java.util.EnumMap;
import java.util.HashMap;
import java.util.Map;

import github.koukobin.ermis.common.DeviceType;

/**
 * 
 * This class essentially has the database Device types integers hardcoded to
 * ensure they never change by accident
 * 
 * @author Ilias Koukovinis
 */
public final class DeviceTypeConverter {
	
	private static final int MOBILE = 1271; // WARNING: DO NOT CHANGE
	private static final int TABLET = 1272; // WARNING: DO NOT CHANGE
	private static final int DESKTOP = 1273; // WARNING: DO NOT CHANGE
	private static final int UNSPECIFIED = 1275; // WARNING: DO NOT CHANGE
	
	private static final Map<DeviceType, Integer> deviceTypesToDatabaseInts = new EnumMap<>(DeviceType.class);
	private static final Map<Integer, DeviceType> databaseIntsToDeviceTypes = new HashMap<>();

	private DeviceTypeConverter() {}
	
	static {
		deviceTypesToDatabaseInts.put(DeviceType.MOBILE, MOBILE);
		deviceTypesToDatabaseInts.put(DeviceType.TABLET, TABLET);
		deviceTypesToDatabaseInts.put(DeviceType.DESKTOP, DESKTOP);
		deviceTypesToDatabaseInts.put(DeviceType.UNSPECIFIED, UNSPECIFIED);
		
		databaseIntsToDeviceTypes.put(MOBILE, DeviceType.MOBILE);
		databaseIntsToDeviceTypes.put(TABLET, DeviceType.TABLET);
		databaseIntsToDeviceTypes.put(DESKTOP, DeviceType.DESKTOP);
		databaseIntsToDeviceTypes.put(UNSPECIFIED, DeviceType.UNSPECIFIED);
	}

	public static int getDeviceTypeAsDatabaseInt(DeviceType contentType) {
		return deviceTypesToDatabaseInts.get(contentType);
	}
	

	public static DeviceType getDatabaseIntAsDeviceType(int contentTypeInt) {
		return databaseIntsToDeviceTypes.get(contentTypeInt);
	}
}

