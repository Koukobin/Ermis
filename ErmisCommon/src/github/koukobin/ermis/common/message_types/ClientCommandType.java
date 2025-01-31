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
public enum ClientCommandType {

	// Account Management 
	CHANGE_USERNAME(CommandLevel.HEAVY, 100),
	CHANGE_PASSWORD(CommandLevel.HEAVY, 101),
	SET_ACCOUNT_ICON(CommandLevel.HEAVY, 102),
	LOGOUT_THIS_DEVICE(CommandLevel.HEAVY, 103),
	LOGOUT_OTHER_DEVICE(CommandLevel.HEAVY, 104),
	LOGOUT_ALL_DEVICES(CommandLevel.HEAVY, 105),
	DELETE_ACCOUNT(CommandLevel.HEAVY, 106),
	ADD_NEW_ACCOUNT(CommandLevel.HEAVY, 107),
	SWITCH_ACCOUNT(CommandLevel.HEAVY, 108),

	// User Information Requests
	FETCH_USERNAME(CommandLevel.LIGHT, 200),
	FETCH_CLIENT_ID(CommandLevel.LIGHT, 201),
	FETCH_LINKED_DEVICES(CommandLevel.HEAVY, 202),
	FETCH_ACCOUNT_ICON(CommandLevel.HEAVY, 203),
	FETCH_OTHER_ACCOUNTS_ASSOCIATED_WITH_IP_ADDRESS(CommandLevel.HEAVY, 204),

	// Chat Management
	FETCH_CHAT_REQUESTS(CommandLevel.LIGHT, 300),
	FETCH_CHAT_SESSIONS(CommandLevel.LIGHT, 301),
	SEND_CHAT_REQUEST(CommandLevel.HEAVY, 302),
	ACCEPT_CHAT_REQUEST(CommandLevel.HEAVY, 303),
	DECLINE_CHAT_REQUEST(CommandLevel.HEAVY, 304),
	DELETE_CHAT_SESSION(CommandLevel.HEAVY, 305),
	DELETE_CHAT_MESSAGE(CommandLevel.HEAVY, 306),
	FETCH_WRITTEN_TEXT(CommandLevel.HEAVY, 307),
	DOWNLOAD_FILE(CommandLevel.HEAVY, 308),
	DOWNLOAD_IMAGE(CommandLevel.HEAVY, 309),
	START_VOICE_CALL(CommandLevel.HEAVY, 310),
	ACCEPT_VOICE_CALL(CommandLevel.HEAVY, 311),
	
	// External Pages
	REQUEST_DONATION_PAGE_URL(CommandLevel.LIGHT, 400),
	REQUEST_SOURCE_CODE_PAGE_URL(CommandLevel.LIGHT, 401);

	
	/*
	 * This enum determines whether the command requested by the client is "Heavy" or "Light."
	 * 
	 * - "Heavy" commands, as the name suggests, require more server resources to process.
	 * - "Light" commands, on the other hand, are less resource-intensive and quicker for the server to handle.
	 * 
	 * Classifying commands in such a way may seem unnecessary at first glance, however, this allows the server 
	 * to put a delay in how many "Heavy" commands a client can submit within a given time frame which helps shield 
	 * the server from potential spam attacks.
	 */
	public enum CommandLevel {
		LIGHT, HEAVY
	}
	
	private static final HashMap<Integer, ClientCommandType> values;
	
	static {
		values = new HashMap<>(
				Arrays.stream(ClientCommandType.values())
				.collect(Collectors.toMap(type -> type.id, type -> type))
				);
	}
	
	private final CommandLevel commandLevel;
	public final int id;
	
	ClientCommandType(CommandLevel commandLevel, int id) {
		this.commandLevel = commandLevel;
		this.id = id;
	}

	public CommandLevel getCommandLevel() {
		return commandLevel;
	}
	
	public static ClientCommandType fromId(int id) {
		return EnumIntConverter.fromId(values, id);
	}
}
