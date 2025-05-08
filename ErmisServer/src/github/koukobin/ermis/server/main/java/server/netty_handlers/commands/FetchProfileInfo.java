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
package github.koukobin.ermis.server.main.java.server.netty_handlers.commands;

import java.util.Optional;

import github.koukobin.ermis.common.message_types.ClientCommandResultType;
import github.koukobin.ermis.common.message_types.ClientCommandType;
import github.koukobin.ermis.common.message_types.ServerInfoMessage;
import github.koukobin.ermis.common.message_types.ServerMessageType;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.ErmisDatabase;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.models.UserIcon;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import io.netty.buffer.ByteBuf;
import io.netty.channel.epoll.EpollSocketChannel;

/**
 * @author Ilias Koukovinis
 *
 */
public class FetchProfileInfo implements ICommand {

	@Override
	public void execute(ClientInfo clientInfo, EpollSocketChannel channel, ByteBuf args) {
		long userLastUpdatedEpochSecond = args.readableBytes() > 0 ? args.readLong() : 0;
		int clientID = clientInfo.getClientID();

		Optional<Long> optionalActualLastUpdatedEpochSecond;
		try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
			optionalActualLastUpdatedEpochSecond = conn.getWhenUserLastUpdatedProfile(clientID);
		}

		long lastUpdatedEpochSecond = optionalActualLastUpdatedEpochSecond.orElseGet(() -> Long.valueOf(-1)).longValue();
		boolean isProfileInfoOutdated = lastUpdatedEpochSecond > userLastUpdatedEpochSecond;

		if (!isProfileInfoOutdated) {
			return;
		}

		byte[] usernameBytes = clientInfo.getUsername().getBytes();

		ByteBuf payload = channel.alloc().ioBuffer();
		payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
		payload.writeInt(ClientCommandResultType.FETCH_PROFILE_INFO.id);
		payload.writeInt(clientID);
		payload.writeInt(usernameBytes.length);
		payload.writeBytes(usernameBytes);
		payload.writeLong(lastUpdatedEpochSecond);

		Optional<UserIcon> optionalIcon;
		try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
			optionalIcon = conn.selectUserIcon(clientInfo.getClientID());
		}

		optionalIcon.ifPresentOrElse((UserIcon icon) -> {
			// If successfully fetched icon, write it to payload
			payload.writeBytes(icon.iconBytes());
		}, () -> {
			// Otherwise, send error message to inform user about insuccess
			ByteBuf error = channel.alloc().ioBuffer();
			error.writeInt(ServerMessageType.SERVER_INFO.id);
			error.writeInt(ServerInfoMessage.ERROR_OCCURED_WHILE_TRYING_TO_FETCH_PROFILE_PHOTO.id);
			channel.writeAndFlush(error);
		});

		getLogger().debug("Payload size for profile information: {}", payload.capacity());

		channel.writeAndFlush(payload);
//		executeCommand(clientInfo, ClientCommandType.FETCH_CLIENT_ID, Unpooled.EMPTY_BUFFER);
//		executeCommand(clientInfo, ClientCommandType.FETCH_USERNAME, Unpooled.EMPTY_BUFFER);
//		executeCommand(clientInfo, ClientCommandType.FETCH_ACCOUNT_STATUS, Unpooled.EMPTY_BUFFER);
//		executeCommand(clientInfo, ClientCommandType.FETCH_ACCOUNT_ICON, Unpooled.EMPTY_BUFFER);
	}

	@Override
	public ClientCommandType getCommand() {
		return ClientCommandType.FETCH_PROFILE_INFORMATION;
	}

}
