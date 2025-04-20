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

import java.util.Collection;

import github.koukobin.ermis.common.message_types.ClientCommandType;
import github.koukobin.ermis.common.message_types.ServerInfoMessage;
import github.koukobin.ermis.common.message_types.ServerMessageType;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.ErmisDatabase;
import github.koukobin.ermis.server.main.java.server.ChatSession;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.epoll.EpollSocketChannel;

/**
 * @author Ilias Koukovinis
 *
 */
public class SendChatRequest implements ICommand {

	@Override
	public void execute(ClientInfo clientInfo, EpollSocketChannel channel, ByteBuf args) {
		int receiverID = args.readInt();
		int senderClientID = clientInfo.getClientID();

		if (receiverID == senderClientID) {
			getLogger().debug("You can't create chat session with yourself");
			return;
		}

		// TODO: optimize
		if (clientInfo.getChatSessions()
				.stream()
				.map(ChatSession::getActiveMembers)
				.flatMap(Collection::stream)
				.filter((ClientInfo ci) -> ci.getClientID() == receiverID)
				.count() != 0) {
			getLogger().debug("You can't create chat session with yourself");
			return;
		}
		
		boolean success;
		try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
			success = conn.sendChatRequest(receiverID, senderClientID);
		}

		if (!success) {
			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.SERVER_INFO.id);
			payload.writeInt(ServerInfoMessage.ERROR_OCCURED_WHILE_TRYING_TO_SEND_CHAT_REQUEST.id);
			channel.writeAndFlush(payload);
			return;
		}

		forActiveAccounts(receiverID, (ClientInfo ci) -> {
			ci.getChatRequests().add(senderClientID);
			CommandsHolder.executeCommand(ClientCommandType.FETCH_CHAT_REQUESTS, ci, Unpooled.EMPTY_BUFFER);
		});
	}

	@Override
	public ClientCommandType getCommand() {
		return ClientCommandType.SEND_CHAT_REQUEST;
	}

}
