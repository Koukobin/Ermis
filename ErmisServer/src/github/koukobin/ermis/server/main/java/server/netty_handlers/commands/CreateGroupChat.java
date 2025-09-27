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
import java.util.Arrays;
import java.util.List;

import com.google.common.primitives.Ints;

import github.koukobin.ermis.common.message_types.ClientCommandType;
import github.koukobin.ermis.common.message_types.ServerInfoMessage;
import github.koukobin.ermis.common.message_types.ServerMessageType;
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
public class CreateGroupChat implements ICommand {

	@Override
	public void execute(ClientInfo clientInfo, EpollSocketChannel channel, ByteBuf args) {
		int[] memberIds = new int[(args.readableBytes() / Integer.BYTES) + 1 /* Attributed to client self */];
		for (int i = 0; i < memberIds.length - 1; i++) {
			memberIds[i] = args.readInt();
		}
		memberIds[memberIds.length - 1] = clientInfo.getClientID();

		if (!ActiveChatSessions.areMembersFriendOfUser(clientInfo, memberIds)) {
			getLogger().debug("Members specified are not friends");
			return;
		}

		List<Integer> memberIdsList = Ints.asList(memberIds);
		if (ActiveChatSessions.doesChatSessionAlreadyExist(clientInfo.getChatSessions(), memberIdsList)) {
			getLogger().debug("An identical group chat session already exists");
			return;
		}

		int chatSessionID;
		try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
			chatSessionID = conn.createChat(memberIds);
		}

		if (chatSessionID != -1) {
			List<Integer> members = Arrays.stream(memberIds).boxed().toList();

			ChatSession chatSession = new ChatSession(chatSessionID);
			chatSession.setMembers(members);
			chatSession.setActiveMembers(new ArrayList<>(members.size()));
			for (Integer memberID : members) {
				List<ClientInfo> member = ActiveClients.getClient(memberID);

				if (member != null) {
					chatSession.getActiveMembers().addAll(member);
				}
			}

			ActiveChatSessions.addChatSession(chatSession);

			for (ClientInfo member : chatSession.getActiveMembers()) {
				member.getChatSessions().add(chatSession);

				// Send updated indices to the client. This triggers a catalytic process
				// which leads to the retrieval of current chat sessions and their statuses.
				CommandsHolder.executeCommand(ClientCommandType.FETCH_CHAT_SESSION_INDICES, member, Unpooled.EMPTY_BUFFER);
			}
		} else {
			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.SERVER_INFO.id);
			payload.writeInt(ServerInfoMessage.ERROR_OCCURED_WHILE_TRYING_TO_DELETE_CHAT_SESSION.id);
			channel.writeAndFlush(payload);
		}
	}

	@Override
	public ClientCommandType getCommand() {
		return ClientCommandType.CREATE_GROUP_CHAT_SESSION;
	}

}
