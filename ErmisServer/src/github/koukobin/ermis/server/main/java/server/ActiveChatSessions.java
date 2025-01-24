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

import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import io.netty.buffer.ByteBuf;
import io.netty.channel.Channel;

/**
 * @author Ilias Koukovinis
 *
 */
public class ActiveChatSessions {

	/**
	 * Map to track active chat sessions
	 */
	private static final Map<Integer, ChatSession> chatSessionIDSToActiveChatSessions = new ConcurrentHashMap<>(100);

	private ActiveChatSessions() {}

	public static ChatSession getChatSession(int chatSessionID) {
		return chatSessionIDSToActiveChatSessions.get(chatSessionID);
	}

	public static void addChatSession(int chatSessionID, ChatSession chatSession) {
		chatSessionIDSToActiveChatSessions.put(chatSessionID, chatSession);
	}

	public static void removeChatSession(int chatSessionID) {
		chatSessionIDSToActiveChatSessions.remove(chatSessionID);
	}

	public static void addMember(int chatSessionID, ClientInfo member) {
		chatSessionIDSToActiveChatSessions.get(chatSessionID).getActiveMembers().add(member);
	}

	public static void removeMember(int chatSessionID, ClientInfo member) {
		chatSessionIDSToActiveChatSessions.get(chatSessionID).getActiveMembers().remove(member);
	}

	public static void broadcastToChatSession(ByteBuf payload, int messageID, ChatSession chatSession) {
		List<ClientInfo> members = chatSession.getActiveMembers();

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
		 * Note: We cannot directly use (membersOfChatSession.size() - 1) because it
		 * would throw an IllegalArgumentException if the size is 0.
		 */
		payload.retain(members.size());
		payload.release();

		for (int i = 0; i < members.size(); i++) {
			Channel channel = members.get(i).getChannel();
			channel.writeAndFlush(payload.duplicate());
		}
	}

}
