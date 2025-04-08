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

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.function.Consumer;

import com.google.common.collect.Lists;

import github.koukobin.ermis.common.message_types.ClientCommandResultType;
import github.koukobin.ermis.common.message_types.ClientCommandType;
import github.koukobin.ermis.common.message_types.ServerInfoMessage;
import github.koukobin.ermis.common.message_types.ServerMessageType;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.ErmisDatabase;
import github.koukobin.ermis.server.main.java.server.ActiveChatSessions;
import github.koukobin.ermis.server.main.java.server.ChatSession;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import io.netty.buffer.ByteBuf;
import io.netty.channel.epoll.EpollSocketChannel;

/**
 * @author Ilias Koukovinis
 *
 */
public class AcceptChatRequest implements ICommand {

	@Override
	public void execute(ClientInfo clientInfo, EpollSocketChannel channel, ByteBuf args) {
		int senderClientID = args.readInt();
		int receiverClientID = clientInfo.getClientID();

		Optional<Integer> optionalChatSessionID;
		synchronized (clientInfo.getChatRequests()) {
			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				optionalChatSessionID = conn.acceptChatRequest(receiverClientID, senderClientID);
			}
		}

		if (optionalChatSessionID.isEmpty()) {
			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.SERVER_INFO.id);
			payload.writeInt(ServerInfoMessage.ERROR_OCCURED_WHILE_TRYING_TO_ACCEPT_CHAT_REQUEST.id);
			channel.writeAndFlush(payload);
			return;
		}
		int chatSessionID = optionalChatSessionID.get();

		List<Integer> members = Lists.newArrayList(receiverClientID, senderClientID);
		List<ClientInfo> activeMembers = new ArrayList<>(members.size());

		ChatSession chatSession = new ChatSession(chatSessionID, activeMembers, members);
		ActiveChatSessions.addChatSession(chatSession);

		clientInfo.getChatRequests().remove(Integer.valueOf(senderClientID));

		Consumer<ClientInfo> updateSessions = (ClientInfo ci) -> {
			ci.getChatSessions().add(chatSession);

			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
			payload.writeInt(ClientCommandResultType.GET_CHAT_SESSIONS.id);

			payload.writeInt(chatSessionID);
			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				addMemberInfoToPayload(payload, conn, ci.getClientID() == senderClientID ? receiverClientID : senderClientID);
			}

			channel.writeAndFlush(payload);
		};
		forActiveAccounts(receiverClientID, updateSessions);
		forActiveAccounts(senderClientID, updateSessions);
	}

	@Override
	public ClientCommandType getCommand() {
		return ClientCommandType.ACCEPT_CHAT_REQUEST;
	}

}
