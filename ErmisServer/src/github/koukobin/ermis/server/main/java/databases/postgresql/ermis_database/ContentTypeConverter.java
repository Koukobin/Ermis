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

import github.koukobin.ermis.common.message_types.ClientContentType;

/**
 * 
 * This class essentially has the database content type integers hardcoded so they
 * never change by accident
 * 
 * @author Ilias Koukovinis
 */
final class ContentTypeConverter {

	private static final int TEXT = 117; // WARNING: DO NOT CHANGE
	private static final int FILE = 64; // WARNING: DO NOT CHANGE
	private static final int PHOTO = 343; // WARNING: DO NOT CHANGE
	
	private static final Map<ClientContentType, Integer> contentTypesToDatabaseInts = new EnumMap<>(ClientContentType.class);
	private static final Map<Integer, ClientContentType> databaseIntsToContentTypes = new HashMap<>();

	private ContentTypeConverter() {}
	
	static {
		contentTypesToDatabaseInts.put(ClientContentType.TEXT, TEXT);
		contentTypesToDatabaseInts.put(ClientContentType.FILE, FILE);
		contentTypesToDatabaseInts.put(ClientContentType.IMAGE, PHOTO);
		
		databaseIntsToContentTypes.put(TEXT, ClientContentType.TEXT);
		databaseIntsToContentTypes.put(FILE, ClientContentType.FILE);
		databaseIntsToContentTypes.put(PHOTO, ClientContentType.IMAGE);
	}

	static int getContentTypeAsDatabaseInt(ClientContentType contentType) {
		return contentTypesToDatabaseInts.get(contentType);
	}
	

	static ClientContentType getDatabaseIntAsContentType(int contentTypeInt) {
		return databaseIntsToContentTypes.get(contentTypeInt);
	}
}

