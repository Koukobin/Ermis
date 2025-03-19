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
public enum ServerInfoMessage {
    TOO_MANY_REQUESTS_MADE(0),
    COMMAND_NOT_RECOGNIZED(1),
    ERROR_OCCURED_WHILE_TRYING_TO_FETCH_PROFILE_PHOTO(2),
    INET_ADDRESS_NOT_RECOGNIZED(3),
    MESSAGE_LENGTH_EXCEEDS_LIMIT(4),
    CHAT_SESSION_DOES_NOT_EXIST(5),
    ERROR_OCCURED_WHILE_TRYING_TO_DELETE_CHAT_SESSION(6),
    ERROR_OCCURED_WHILE_TRYING_TO_DECLINE_CHAT_REQUEST(7),
	ERROR_OCCURED_WHILE_TRYING_TO_ACCEPT_CHAT_REQUEST(8),
	ERROR_OCCURED_WHILE_TRYING_TO_SEND_CHAT_REQUEST(9),
	ERROR_OCCURED_WHILE_TRYING_TO_FETCH_FILE_FROM_DATABASE(10),
	DECOMPRESSION_FAILED(11),
	MESSAGE_TYPE_NOT_RECOGNIZED(12),
	CONTENT_TYPE_NOT_KNOWN(13),
	MESSAGE_TYPE_NOT_IMPLEMENTED(14),
	CONTENT_TYPE_NOT_IMPLEMENTED(15),
	COMMAND_NOT_KNOWN(16);

	private static final HashMap<Integer, ServerMessageType> values;

	static {
		values = new HashMap<>(
				Arrays.stream(ServerMessageType.values())
				.collect(Collectors.toMap(type -> type.id, type -> type))
				);
	}
	
    public final int id;

    ServerInfoMessage(int id) {
        this.id = id;
    }

	public static ServerMessageType fromId(int id) {
		return EnumIntConverter.fromId(values, id);
	}
}

