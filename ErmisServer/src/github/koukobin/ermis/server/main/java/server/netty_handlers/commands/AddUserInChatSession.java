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
import java.util.function.Consumer;

import github.koukobin.ermis.common.message_types.ClientCommandType;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.ErmisDatabase;
import github.koukobin.ermis.server.main.java.server.ActiveChatSessions;
import github.koukobin.ermis.server.main.java.server.ActiveClients;
import github.koukobin.ermis.server.main.java.server.ChatSession;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.epoll.EpollSocketChannel;

/**
 * @author Ilias Koukovinis
 *
 */
public class AddUserInChatSession implements ICommand {

	@Override
	public void execute(ClientInfo clientInfo, EpollSocketChannel channel, ByteBuf args) {
		int chatSessionID;
		ChatSession chatSession;
		{
			int chatSessionIndex = args.readInt();

			chatSession = clientInfo.getChatSessions().get(chatSessionIndex);
			chatSessionID = chatSession.getChatSessionID();
		}

		int memberID = args.readInt();

		if (chatSession.getMembers().contains(memberID)) {
			return;
		}

		if (!ActiveChatSessions.areMembersFriendOfUser(clientInfo, memberID)) {
			return;
		}

		List<Integer> memberIdsList = new ArrayList<>(chatSession.getMembers());
		memberIdsList.add(memberID);
		if (ActiveChatSessions.doesChatSessionAlreadyExist(clientInfo.getChatSessions(), memberIdsList)) {
			getLogger().debug("An identical group chat session already exists");
			return;
		}

		boolean success;
		try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
			success = conn.addUserToChatSession(chatSessionID, memberID);
		}

		if (!success) {
//			ByteBuf payload = channel.alloc().ioBuffer();
//			payload.writeInt(ServerMessageType.SERVER_INFO.id);
//			payload.writeInt(ServerInfoMessage.ERROR_OCCURED_WHILE_TRYING_TO_DELETE_CHAT_SESSION.id);
//			channel.writeAndFlush(payload);
			// TODO
		}

		chatSession.getMembers().add(memberID);

		List<ClientInfo> memberActiveConnections = ActiveClients.getClient(memberID);
		if (memberActiveConnections != null) {
			chatSession.getActiveMembers().addAll(memberActiveConnections);

			for (ClientInfo member : chatSession.getActiveMembers()) {
				member.getChatSessions().add(chatSession);
			}
		}

		// To ensure changes are reflected...
		Consumer<ClientInfo> updateSessions = (ClientInfo ci) -> {
			// Send updated indices to the client. This triggers a catalytic process
			// which leads to the retrieval of current chat sessions and their statuses.
			CommandsHolder.executeCommand(ClientCommandType.FETCH_CHAT_SESSION_INDICES, ci, Unpooled.EMPTY_BUFFER);
		};
		chatSession.getActiveMembers().forEach(updateSessions::accept);
	}

	@Override
	public ClientCommandType getCommand() {
		return ClientCommandType.ADD_USER_IN_CHAT_SESSION;
	}

}
