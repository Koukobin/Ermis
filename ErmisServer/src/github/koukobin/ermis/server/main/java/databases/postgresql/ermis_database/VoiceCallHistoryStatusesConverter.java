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
package github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database;

import java.util.EnumMap;
import java.util.HashMap;
import java.util.Map;

import github.koukobin.ermis.common.VoiceCallHistoryStatus;

/**
 * 
 * This class essentially has the database voice call history statuses integers
 * hardcoded so they never change by accident
 * 
 * @author Ilias Koukovinis
 */
public class VoiceCallHistoryStatusesConverter {

	private static final int ACCEPTED = 3_14159; // WARNING: DO NOT CHANGE
	private static final int IGNORED  = 2_71828; // WARNING: DO NOT CHANGE

	private static final Map<VoiceCallHistoryStatus, Integer> statusesToDatabaseInts;
	private static final Map<Integer, VoiceCallHistoryStatus> databaseIntsToStatuses;

	private VoiceCallHistoryStatusesConverter() {}

	static {
		statusesToDatabaseInts = new EnumMap<>(VoiceCallHistoryStatus.class);
		databaseIntsToStatuses = new HashMap<>();

		statusesToDatabaseInts.put(VoiceCallHistoryStatus.ACCEPTED, ACCEPTED);
		statusesToDatabaseInts.put(VoiceCallHistoryStatus.IGNORED, IGNORED);

		databaseIntsToStatuses.put(ACCEPTED, VoiceCallHistoryStatus.ACCEPTED);
		databaseIntsToStatuses.put(IGNORED, VoiceCallHistoryStatus.IGNORED);
	}

	public static int getStatusAsDatabaseInt(VoiceCallHistoryStatus contentType) {
		return statusesToDatabaseInts.get(contentType);
	}

	public static VoiceCallHistoryStatus getDatabaseIntAsStatus(int contentTypeInt) {
		return databaseIntsToStatuses.get(contentTypeInt);
	}
}
