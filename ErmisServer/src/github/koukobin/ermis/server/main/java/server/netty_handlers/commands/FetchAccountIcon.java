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
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.UserIcon;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import io.netty.buffer.ByteBuf;
import io.netty.channel.epoll.EpollSocketChannel;

/**
 * @author Ilias Koukovinis
 *
 */
public class FetchAccountIcon implements ICommand {

	@Override
	public void execute(ClientInfo clientInfo, EpollSocketChannel channel, ByteBuf args) {
		Optional<UserIcon> optionalIcon;
		try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
			optionalIcon = conn.selectUserIcon(clientInfo.getClientID());
		}

		optionalIcon.ifPresentOrElse((UserIcon icon) -> {
			// If successfully fetched icon, write it to payload
			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
			payload.writeInt(ClientCommandResultType.FETCH_ACCOUNT_ICON.id);
			payload.writeBytes(icon.iconBytes());
			channel.writeAndFlush(payload);
		}, () -> {
			// Otherwise, send error message to inform user about insuccess
			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.SERVER_INFO.id);
			payload.writeInt(ServerInfoMessage.ERROR_OCCURED_WHILE_TRYING_TO_FETCH_PROFILE_PHOTO.id);
			channel.writeAndFlush(payload);
		});
	}

	@Override
	public ClientCommandType getCommand() {
		return ClientCommandType.FETCH_ACCOUNT_ICON;
	}

}
