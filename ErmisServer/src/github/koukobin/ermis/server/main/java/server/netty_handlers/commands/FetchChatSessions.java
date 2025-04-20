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

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import github.koukobin.ermis.common.message_types.ClientCommandResultType;
import github.koukobin.ermis.common.message_types.ClientCommandType;
import github.koukobin.ermis.common.message_types.ServerMessageType;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.ErmisDatabase;
import github.koukobin.ermis.server.main.java.server.ChatSession;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import github.koukobin.ermis.server.main.java.server.netty_handlers.ClientUpdate;
import io.netty.buffer.ByteBuf;
import io.netty.channel.epoll.EpollSocketChannel;

/**
 * @author Ilias Koukovinis
 *
 */
public class FetchChatSessions implements ICommand {

	@Override
	public void execute(ClientInfo clientInfo, EpollSocketChannel channel, ByteBuf args) {
		ByteBuf payload = channel.alloc().ioBuffer();
		payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
		payload.writeInt(ClientCommandResultType.GET_CHAT_SESSIONS.id);

		Map<Integer, Integer> mapKeepingTrackHowManyTimesEachMotherfuckerHasBeenSent = new HashMap<>();

		while (args.readableBytes() > 0) {

			int chatSessionIndex = args.readInt();
			payload.writeInt(chatSessionIndex);

			ChatSession chatSession;
			try {
				chatSession = clientInfo.getChatSessions().get(chatSessionIndex);
			} catch (IndexOutOfBoundsException iobe) {
				// IndexOutOfBoundsException could be thrown here; this could happen,
				// for instance, if chat session was deleted by other user
				getLogger().debug("Chat session was not found", iobe);
				args.skipBytes(args.readInt() * (Integer.BYTES + Long.BYTES)); // Skip subsequent reads
				int membersSize = -1;
				payload.writeInt(membersSize); // Inferred by client session was deleted
				continue;
			}

			int chatSessionID = chatSession.getChatSessionID();
			ClientUpdate[] claimedMembers = new ClientUpdate[args.readInt()];
			for (int j = 0; j < claimedMembers.length; j++) {
				claimedMembers[j] = new ClientUpdate(args.readInt(), args.readLong());
			}

			ClientUpdate[] actualMembers;
			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				actualMembers = conn.getWhenChatSessionMembersProfilesWereLastUpdated(chatSessionID);
			}

			// TODO: OPTIMIZE
			List<ClientUpdate> outdatedMembersInfo = Arrays.asList(actualMembers).stream()
					.filter((ClientUpdate member) -> !Arrays.asList(claimedMembers).contains(member)
							&& clientInfo.getClientID() != member.clientID())
					.distinct()
					.toList();
			List<Integer> memberIDS = outdatedMembersInfo.stream().map(ClientUpdate::clientID).toList();

			payload.writeInt(memberIDS.size());
			if (memberIDS.isEmpty()) {
				continue;
			}

			for (Integer memberID : memberIDS) {
				mapKeepingTrackHowManyTimesEachMotherfuckerHasBeenSent.putIfAbsent(memberID, 1);
			}

			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				for (int j = 0; j < memberIDS.size(); j++) {

					int clientID = memberIDS.get(j);

					payload.writeInt(clientID);
					if (mapKeepingTrackHowManyTimesEachMotherfuckerHasBeenSent.get(clientID) == 0) {
						continue;
					}
					mapKeepingTrackHowManyTimesEachMotherfuckerHasBeenSent.put(clientID, 0);

					addMemberInfoToPayload(payload, conn, clientID);
				}

			}

		}

		clientInfo.getChatSessions().forEach((ChatSession c) -> {
			if (!c.getActiveMembers().contains(clientInfo)) {
				c.getActiveMembers().add(clientInfo);
			}
			ICommand.refreshChatSessionStatuses(c);
		});

		getLogger().debug("Payload size for member information: {}", payload.capacity());

		channel.writeAndFlush(payload);
	}

	@Override
	public ClientCommandType getCommand() {
		return ClientCommandType.FETCH_CHAT_SESSIONS;
	}

}
