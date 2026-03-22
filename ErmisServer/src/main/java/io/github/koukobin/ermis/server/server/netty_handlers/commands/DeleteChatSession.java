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

import java.util.List;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.epoll.EpollSocketChannel;
import main.java.io.github.koukobin.ermis.common.message_types.ClientCommandType;
import main.java.io.github.koukobin.ermis.common.message_types.ServerInfoMessage;
import main.java.io.github.koukobin.ermis.common.message_types.ServerMessageType;
import main.java.io.github.koukobin.ermis.server.databases.postgresql.ermis_database.ErmisDatabase;
import main.java.io.github.koukobin.ermis.server.server.ActiveChatSessions;
import main.java.io.github.koukobin.ermis.server.server.ChatSession;
import main.java.io.github.koukobin.ermis.server.server.ClientInfo;

/**
 * @author Ilias Koukovinis
 *
 */
public class DeleteChatSession implements ICommand {

	@Override
	public void execute(ClientInfo clientInfo, EpollSocketChannel channel, ByteBuf args) {
		int chatSessionID;

		{
			int chatSessionIndex = args.readInt();
			chatSessionID = clientInfo.getChatSessions().get(chatSessionIndex).getChatSessionID();
		}

		boolean success;
		try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
			success = conn.deleteChatSession(chatSessionID);
		}

		if (success) {
			ChatSession chatSession = ActiveChatSessions.getChatSession(chatSessionID);

			// Ensure chat session isn't null, albeit this is virtually improbable.
			// Edge case: client disconnects immediately once server receives command.
			if (chatSession != null) {
				List<ClientInfo> activeMembers = chatSession.getActiveMembers();
				for (int i = 0; i < activeMembers.size(); i++) {
					ClientInfo member = activeMembers.get(i);
					member.getChatSessions().remove(chatSession);

					CommandsHolder.executeCommand(ClientCommandType.FETCH_CHAT_SESSION_INDICES, member, Unpooled.EMPTY_BUFFER);
				}

				ActiveChatSessions.removeChatSession(chatSessionID);
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
		return ClientCommandType.DELETE_CHAT_SESSION;
	}

}
