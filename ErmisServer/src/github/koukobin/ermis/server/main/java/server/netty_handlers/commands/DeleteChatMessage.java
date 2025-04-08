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

import github.koukobin.ermis.common.message_types.ClientCommandResultType;
import github.koukobin.ermis.common.message_types.ClientCommandType;
import github.koukobin.ermis.common.message_types.ServerMessageType;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.ErmisDatabase;
import github.koukobin.ermis.server.main.java.server.ActiveChatSessions;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import io.netty.buffer.ByteBuf;
import io.netty.channel.epoll.EpollSocketChannel;

/**
 * @author Ilias Koukovinis
 *
 */
public class DeleteChatMessage implements ICommand {

	@Override
	public void execute(ClientInfo clientInfo, EpollSocketChannel channel, ByteBuf args) {
		int chatSessionID;

		{
			int chatSessionIndex = args.readInt();
			chatSessionID = clientInfo.getChatSessions().get(chatSessionIndex).getChatSessionID();
		}

		final int messagesAmount = args.readableBytes() / Integer.BYTES;

		if (messagesAmount == 0) {
			return;
		}

		ByteBuf payload = channel.alloc().ioBuffer();
		payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
		payload.writeInt(ClientCommandResultType.DELETE_CHAT_MESSAGE.id);
		payload.writeInt(chatSessionID);

		try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
			for (int i = 0; i < messagesAmount; i++) {
				int messagesID = args.readInt();
				boolean success = conn.deleteChatMessage(chatSessionID, messagesID);
				payload.writeInt(messagesID);
				payload.writeBoolean(success);
			}
		}

		/**
		 * 
		 * Alternative approach:
		 * 
		 * The following approach is perhaps more efficient from certain aspects but
		 * still unsure. Specifically, it is more efficient in terms of database
		 * connection usage (releasing connection sooner), but, on the other hand, it
		 * requires more memory for storing results in arrays before transmitting.
		 * 
		 * <pre>
		 * int[] messages = new int[messagesAmount];
		 * boolean[] success = new boolean[messagesAmount];
		 * 
		 * // Process deletions first, release DB connection ASAP try
		 * try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
		 * 	for (int i = 0; i < messagesAmount; i++) {
		 * 		messages[i] = args.readInt();
		 * 		success[i] = conn.deleteChatMessage(chatSessionID, messages[i]);
		 * 	}
		 * }
		 * // Connection is now freed
		 * 
		 * // Allocate buffer only after DB connection is released
		 * ByteBuf payload = channel.alloc().ioBuffer();
		 * payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
		 * payload.writeInt(ClientCommandResultType.DELETE_CHAT_MESSAGE.id);
		 * payload.writeInt(chatSessionID);
		 * 
		 * for (int i = 0; i < messagesAmount; i++) {
		 * 	payload.writeInt(messages[i]);
		 * 	payload.writeBoolean(success[i]);
		 * }
		 * </pre>
		 * 
		 */

		ActiveChatSessions.broadcastToChatSession(payload, ActiveChatSessions.getChatSession(chatSessionID));
	}

	@Override
	public ClientCommandType getCommand() {
		return ClientCommandType.DELETE_CHAT_MESSAGE;
	}

}
