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
package github.koukobin.ermis.server.main.java.server;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import github.koukobin.ermis.common.message_types.ServerMessageType;
import github.koukobin.ermis.server.main.java.configs.ServerSettings;
import io.netty.buffer.ByteBuf;
import io.netty.channel.Channel;

/**
 * @author Ilias Koukovinis
 *
 */
public class ActiveClients {

	/**
	 * Map to track active clients
	 */
	private static final Map<Integer, List<ClientInfo>> clientIDSToActiveClients = new ConcurrentHashMap<>(ServerSettings.SERVER_BACKLOG);
	
	private ActiveClients() {}
	
	public static List<ClientInfo> getClient(int clientID) {
		return clientIDSToActiveClients.get(clientID);
	}
	
	public static void addClient(ClientInfo clientInfo) {
		clientIDSToActiveClients.putIfAbsent(clientInfo.getClientID(), new ArrayList<>());
		clientIDSToActiveClients.get(clientInfo.getClientID()).add(clientInfo);
	}
	
	public static void removeClient(ClientInfo clientInfo) {
		clientIDSToActiveClients.get(clientInfo.getClientID()).remove(clientInfo);
	}

	public static void broadcastMessageToChatSession(ByteBuf payload, int messageID, ChatSession chatSession, ClientInfo sender) {

		List<Channel> membersOfChatSession = chatSession.getActiveChannels();

		/*
		 * Increase reference count by the amount of clients that this message is gonna
		 * be sent to.
		 * 
		 * Since the reference count is already at 1, we release once and increase by
		 * the number of the users the message will be sent to.
		 * 
		 * For instance, if there are 2 users in the chat session, we increase the
		 * payload's reference count by 2 (2 + 1 = 3) and release once (3 - 1 = 2),
		 * which ensures the adequate number of writes for the specific number of users
		 * 
		 * Note: We cannot directly use (membersOfChatSession.size() - 1) because it would
		 * throw an IllegalArgumentException if the size is 0.
		 */
		payload.retain(membersOfChatSession.size());
		payload.release();

		for (int i = 0; i < membersOfChatSession.size(); i++) {
			Channel channel = membersOfChatSession.get(i);
			
			if (channel.equals(sender.getChannel())) {
				ByteBuf messageSent = channel.alloc().ioBuffer();
				messageSent.writeInt(ServerMessageType.MESSAGE_SUCCESFULLY_SENT.id);
				messageSent.writeInt(chatSession.getChatSessionID());
				messageSent.writeInt(messageID);
				channel.writeAndFlush(messageSent);
				continue;
			}
			
			channel.writeAndFlush(payload.duplicate());
		}
	}
}
