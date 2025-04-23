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

import github.koukobin.ermis.common.message_types.ClientCommandType;
import github.koukobin.ermis.common.results.ChangeUsernameResult;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.ErmisDatabase;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.epoll.EpollSocketChannel;

/**
 * @author Ilias Koukovinis
 *
 */
public class ChangeUsername implements ICommand {

	@Override
	public void execute(ClientInfo clientInfo, EpollSocketChannel channel, ByteBuf args) {
		byte[] newUsernameBytes = new byte[args.readableBytes()];
		args.readBytes(newUsernameBytes);

		String newUsername = new String(newUsernameBytes);
		String currentUsername = clientInfo.getUsername();

//		ByteBuf payload = channel.alloc().ioBuffer();
//		payload.writeInt(ServerMessageType.SERVER_INFO.id);

		if (newUsername.equals(currentUsername)) {
//			payload.writeInt(ChangeUsernameResult.ERROR_WHILE_CHANGING_USERNAME.id);
		} else {
			ChangeUsernameResult result;
			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				result = conn.changeDisplayName(clientInfo.getClientID(), newUsername);
			}

//			payload.writeInt(result.id);

			if (result.resultHolder.isSuccessful()) {
				clientInfo.setUsername(newUsername);

				// Fetch username on behalf of the user
				CommandsHolder.getCommand(ClientCommandType.FETCH_USERNAME).execute(clientInfo, Unpooled.EMPTY_BUFFER);
			}
		}

//		channel.writeAndFlush(payload);
	}

	@Override
	public ClientCommandType getCommand() {
		return ClientCommandType.CHANGE_USERNAME;
	}

}
