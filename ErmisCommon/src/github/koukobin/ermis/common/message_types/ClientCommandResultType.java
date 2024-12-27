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
package github.koukobin.ermis.common.message_types;

import java.util.Arrays;
import java.util.HashMap;
import java.util.stream.Collectors;

import github.koukobin.ermis.common.util.EnumIntConverter;

/**
 * @author Ilias Koukovinis
 *
 */
public enum ClientCommandResultType {
	
    // Account Management
    SET_ACCOUNT_ICON(100),
    
	// User Information Requests
    GET_DISPLAY_NAME(200),
    GET_CLIENT_ID(201),
    FETCH_LINKED_DEVICES(202),
    FETCH_ACCOUNT_ICON(203),
    FETCH_OTHER_ACCOUNTS_ASSOCIATED_WITH_IP_ADDRESS(204),
    
    // Chat Management
    GET_CHAT_REQUESTS(300),
    GET_CHAT_SESSIONS(301),
    GET_WRITTEN_TEXT(302),
    DELETE_CHAT_MESSAGE(303),
    
    // File Management
    DOWNLOAD_FILE(400),
    DOWNLOAD_IMAGE(401),
    
    // External Pages
    GET_DONATION_PAGE(500),
    GET_SOURCE_CODE_PAGE(501);
	
	private static final HashMap<Integer, ClientCommandResultType> values;

	static {
		values = new HashMap<>(
				Arrays.stream(ClientCommandResultType.values())
				.collect(Collectors.toMap(type -> type.id, type -> type))
				);
	}

	public final int id;

    ClientCommandResultType(int id) {
        this.id = id;
    }

	public static ClientCommandResultType fromId(int id) {
		return EnumIntConverter.fromId(values, id);
	}
}
