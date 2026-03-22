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
package main.java.io.github.koukobin.ermis.server.server.netty_handlers.commands;

import io.netty.buffer.ByteBuf;
import io.netty.channel.epoll.EpollSocketChannel;
import main.java.io.github.koukobin.ermis.common.message_types.ClientCommandResultType;
import main.java.io.github.koukobin.ermis.common.message_types.ClientCommandType;
import main.java.io.github.koukobin.ermis.common.message_types.ServerMessageType;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.ErmisDatabase;
import main.java.io.github.koukobin.ermis.server.server.ClientInfo;

/**
 * @author Ilias Koukovinis
 *
 */
public class SetAccountIcon implements ICommand {

	@Override
	public void execute(ClientInfo clientInfo, EpollSocketChannel channel, ByteBuf args) {
		byte[] icon = new byte[args.readableBytes()];
		args.readBytes(icon);

		boolean isSuccessful;

		try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
			isSuccessful = conn.setProfilePhoto(clientInfo.getClientID(), icon);
		}

		ByteBuf payload = channel.alloc().ioBuffer();
		payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
		payload.writeInt(ClientCommandResultType.SET_ACCOUNT_ICON.id);
		payload.writeBoolean(isSuccessful);

		channel.writeAndFlush(payload);
	}

	@Override
	public ClientCommandType getCommand() {
		return ClientCommandType.SET_ACCOUNT_ICON;
	}

}
