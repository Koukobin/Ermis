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

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import github.koukobin.ermis.common.message_types.ClientCommandType;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.ErmisDatabase;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.UserIcon;
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
public interface ICommand {

	void execute(ClientInfo clientInfo, EpollSocketChannel channel, ByteBuf args);

	ClientCommandType getCommand();

	default void execute(ClientInfo clientInfo, ByteBuf args) {
		EpollSocketChannel channel = clientInfo.getChannel();
		execute(clientInfo, channel, args);
	}

	/**
	 * Executes a given action for every active device associated with the specified
	 * account/clientID.
	 *
	 * @param clientID the ID of the account whose active devices are to be
	 *                 processed
	 * @param action   the operation to perform on each active device
	 */
	default void forActiveAccounts(int clientID, Consumer<ClientInfo> action) {
		List<ClientInfo> activeClients = ActiveClients.getClient(clientID);

		if (activeClients == null) {
			return;
		}

		for (ClientInfo clientInfo : activeClients) {
			action.accept(clientInfo);
		}
	}

	default void addMemberInfoToPayload(ByteBuf payload, ErmisDatabase.GeneralPurposeDBConnection conn, int clientID) {
		List<ClientInfo> member = ActiveClients.getClient(clientID);

		long lastUpdatedEpochSecond = conn.getWhenUserLastUpdatedProfile(clientID).orElse(Long.valueOf(-1));

		byte[] usernameBytes;
		UserIcon icon = conn.selectUserIcon(clientID).orElse(UserIcon.empty());
		byte[] iconBytes = icon.iconBytes();

		if (member == null) {
			usernameBytes = conn.getUsername(clientID).orElse("null").getBytes();
		} else {
			ClientInfo random = member.get(0);
			usernameBytes = random.getUsername().getBytes();
		}

		payload.writeInt(usernameBytes.length);
		payload.writeBytes(usernameBytes);
		payload.writeInt(iconBytes.length);
		payload.writeBytes(iconBytes);
		payload.writeLong(lastUpdatedEpochSecond);
	}

	/**
	 * TODO: This method can be optimized not to update the statuses of all members
	 * in a given chat session, but only of the users that actually changed their
	 * status.
	 * 
	 * @param chatSession
	 */
	@Deprecated
	static void refreshChatSessionStatuses(ChatSession chatSession) {
		List<ClientInfo> activeMembers = chatSession.getActiveMembers();
		for (int i = 0; i < activeMembers.size(); i++) {
			CommandsHolder.executeCommand(ClientCommandType.FETCH_CHAT_SESSION_STATUSES, activeMembers.get(i),
					Unpooled.EMPTY_BUFFER);
		}
	}

	default Logger getLogger() {
		return LogManager.getLogger("server");
	}
}
