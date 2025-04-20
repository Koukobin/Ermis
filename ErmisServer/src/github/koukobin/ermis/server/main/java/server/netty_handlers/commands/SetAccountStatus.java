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
import github.koukobin.ermis.common.message_types.ClientCommandType;
import github.koukobin.ermis.server.main.java.server.ChatSession;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.epoll.EpollSocketChannel;

/**
 * @author Ilias Koukovinis
 *
 */
public class SetAccountStatus implements ICommand {

	@Override
	public void execute(ClientInfo clientInfo, EpollSocketChannel channel, ByteBuf args) {
		ClientStatus newStatus = ClientStatus.fromId(args.readInt());
		clientInfo.setStatus(newStatus);

		List<ClientInfo> friends = clientInfo.getChatSessions()
				.stream()
				.map(ChatSession::getActiveMembers)
				.flatMap(Collection::stream)
				.distinct()
				.toList();

		for (ClientInfo member : friends) {
			CommandsHolder.executeCommand(ClientCommandType.FETCH_CHAT_SESSION_STATUSES, member, Unpooled.EMPTY_BUFFER);
		}
	}

	@Override
	public ClientCommandType getCommand() {
		return ClientCommandType.SET_ACCOUNT_STATUS;
	}

}
