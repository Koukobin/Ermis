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
import java.util.List;

import github.koukobin.ermis.common.ClientStatus;
import github.koukobin.ermis.common.message_types.ClientCommandResultType;
import github.koukobin.ermis.common.message_types.ClientCommandType;
import github.koukobin.ermis.common.message_types.ServerMessageType;
import github.koukobin.ermis.server.main.java.server.ActiveClients;
import github.koukobin.ermis.server.main.java.server.ChatSession;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import io.netty.buffer.ByteBuf;
import io.netty.channel.epoll.EpollSocketChannel;

/**
 * @author Ilias Koukovinis
 *
 */
public class FetchChatSessionStatuses implements ICommand {

	@Override
	public void execute(ClientInfo clientInfo, EpollSocketChannel channel, ByteBuf args) {
		Integer[] friendsToFetchStatuses;

		if (args.readableBytes() > 0) {
			friendsToFetchStatuses = new Integer[args.readableBytes() / Integer.BYTES];
			for (int i = 0; i < friendsToFetchStatuses.length; i++) {
				friendsToFetchStatuses[i] = args.readInt();
			} // TODO: IMPLEMENENT CHECK THAT THESE ARE ACTUALLY FRIENDS
		} else {
			friendsToFetchStatuses = clientInfo.getChatSessions().stream().map(ChatSession::getMembers)
					.flatMap(Collection::stream).distinct().toArray(Integer[]::new);
		}

		ByteBuf payload = channel.alloc().ioBuffer();
		payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
		payload.writeInt(ClientCommandResultType.GET_CHAT_SESSIONS_STATUSES.id);

		for (int i = 0; i < friendsToFetchStatuses.length; i++) {
			int clientID = friendsToFetchStatuses[i];

			if (clientID == clientInfo.getClientID()) {
				continue;
			}

			ClientStatus clientStatus;
			List<ClientInfo> member = ActiveClients.getClient(clientID);

			if (member == null) {
				clientStatus = ClientStatus.OFFLINE;
			} else {
				ClientInfo random = member.get(0);
				clientStatus = random.getStatus();
			}

			payload.writeInt(clientID);
			payload.writeInt(clientStatus.id);
		}

		channel.writeAndFlush(payload);
	}

	@Override
	public ClientCommandType getCommand() {
		return ClientCommandType.FETCH_CHAT_SESSION_STATUSES;
	}

}
