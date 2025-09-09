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

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.UUID;

import github.koukobin.ermis.common.message_types.ClientCommandType;
import github.koukobin.ermis.common.message_types.ServerInfoMessage;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.ErmisDatabase;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import github.koukobin.ermis.server.main.java.server.util.MessageByteBufCreator;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.epoll.EpollSocketChannel;

/**
 * @author Ilias Koukovinis
 *
 */
public class LogoutOtherDevice implements ICommand {

	@Override
	public void execute(ClientInfo clientInfo, EpollSocketChannel channel, ByteBuf args) {
		byte[] deviceUUIDBytes = new byte[args.readableBytes()];
		args.readBytes(deviceUUIDBytes);

		UUID deviceUUID = UUID.fromString(new String(deviceUUIDBytes));

		try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
			conn.logout(deviceUUID, clientInfo.getClientID());
		}

//		// Search for the specific IP address and if found logout that address
//		forActiveAccounts(clientInfo.getClientID(), (ClientInfo ci) -> {
//			if (!ci.getInetAddress().equals(address)) {
//				return;
//			}
//
//			ci.getChannel().close();
//		});

		forActiveAccounts(clientInfo.getClientID(), (ClientInfo ci) -> {
			CommandsHolder.getCommand(ClientCommandType.FETCH_LINKED_DEVICES).execute(clientInfo, Unpooled.EMPTY_BUFFER);
		});
	}

	@Override
	public ClientCommandType getCommand() {
		return ClientCommandType.LOGOUT_OTHER_DEVICE;
	}

}
