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

import java.util.List;
import java.util.function.Consumer;

import github.koukobin.ermis.common.message_types.ClientCommandResultType;
import github.koukobin.ermis.common.message_types.ClientCommandType;
import github.koukobin.ermis.common.message_types.ServerMessageType;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.ErmisDatabase;
import github.koukobin.ermis.server.main.java.server.ActiveChatSessions;
import github.koukobin.ermis.server.main.java.server.ActiveClients;
import github.koukobin.ermis.server.main.java.server.ChatSession;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import io.netty.buffer.ByteBuf;
import io.netty.channel.epoll.EpollSocketChannel;

/**
 * @author Ilias Koukovinis
 *
 */
public class AddUserInChatSession implements ICommand {

	@Override
	public void execute(ClientInfo clientInfo, EpollSocketChannel channel, ByteBuf args) {
		int chatSessionID;

		{
			int chatSessionIndex = args.readInt();
			chatSessionID = clientInfo.getChatSessions().get(chatSessionIndex).getChatSessionID();
		}

		int memberID = args.readInt();

		// TODO: Add check here to ensure member is not already in session to minimize
		// pressure on database

		if (!ActiveChatSessions.areMembersFriendOfUser(clientInfo, memberID)) {
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

		ChatSession chatSession = ActiveChatSessions.getChatSession(chatSessionID);

		// Ensure chat session isn't null, albeit this is virtually improbable.
		// Edge case: client disconnects immediately once server receives command.
		if (chatSession != null) {
			chatSession.getMembers().add(memberID);

			Consumer<ClientInfo> updateSessions = (ClientInfo ci) -> {
				ByteBuf payload = channel.alloc().ioBuffer();
				payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
				payload.writeInt(ClientCommandResultType.GET_CHAT_SESSIONS.id);
				
				payload.writeInt(chatSessionID);
				try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
					addMemberInfoToPayload(payload, conn, memberID);
				}

				channel.writeAndFlush(payload);
			};
			chatSession.getActiveMembers().forEach(updateSessions::accept);

			List<ClientInfo> memberActiveConnections = ActiveClients.getClient(memberID);
			if (memberActiveConnections != null) {
				chatSession.getActiveMembers().addAll(memberActiveConnections);
			}

			ICommand.refreshChatSessionStatuses(chatSession); // Refresh, to ensure changes are reflected
		}
	}

	@Override
	public ClientCommandType getCommand() {
		return ClientCommandType.ADD_USER_IN_CHAT_SESSION;
	}

}
