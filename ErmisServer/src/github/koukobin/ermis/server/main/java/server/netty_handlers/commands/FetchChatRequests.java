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

import github.koukobin.ermis.common.message_types.ClientCommandResultType;
import github.koukobin.ermis.common.message_types.ClientCommandType;
import github.koukobin.ermis.common.message_types.ServerMessageType;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import io.netty.buffer.ByteBuf;
import io.netty.channel.epoll.EpollSocketChannel;

/**
 * @author Ilias Koukovinis
 *
 */
public class FetchChatRequests implements ICommand {

	@Override
	public void execute(ClientInfo clientInfo, EpollSocketChannel channel, ByteBuf args) {
		List<Integer> chatRequests = clientInfo.getChatRequests();

		ByteBuf payload = channel.alloc().ioBuffer(Integer.BYTES * 3 + Integer.BYTES * chatRequests.size());
		payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
		payload.writeInt(ClientCommandResultType.GET_CHAT_REQUESTS.id);
		payload.writeInt(chatRequests.size());

		if (!chatRequests.isEmpty()) {
			for (int i = 0; i < chatRequests.size(); i++) {
				int clientID = chatRequests.get(i);
				payload.writeInt(clientID);
			}
		}

		channel.writeAndFlush(payload);
	}

	@Override
	public ClientCommandType getCommand() {
		return ClientCommandType.FETCH_CHAT_REQUESTS;
	}

}
