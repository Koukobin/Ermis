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

import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.function.BiConsumer;
import java.util.function.Consumer;

import javax.annotation.Nonnull;

import io.netty.buffer.ByteBuf;
import io.netty.channel.Channel;
import io.netty.channel.ChannelFuture;
import io.netty.channel.epoll.EpollSocketChannel;

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

	public static void addChatSession(ChatSession chatSession) {
		chatSessionIDSToActiveChatSessions.put(chatSession.getChatSessionID(), chatSession);
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
	
	public static boolean areMembersFriendOfUser(@Nonnull ClientInfo clientInfo, @Nonnull int... memberIds) {
		List<ClientInfo> friends = clientInfo.getChatSessions()
				.parallelStream()
				.map(ChatSession::getActiveMembers)
				.distinct()
				.filter((List<ClientInfo> ci) -> ci.contains(clientInfo))
				.flatMap(Collection::stream)
				.toList(); // Baddass use of stream API

		boolean isMemberIDFriendOrJustRandomIndividual = true;
		for (ClientInfo ci : friends) {
			for (int memberID : memberIds) {
				if (ci.getClientID() == memberID) {
					isMemberIDFriendOrJustRandomIndividual &= true;
					break;
				}
			}
		}

		return isMemberIDFriendOrJustRandomIndividual;
	}

	public static void broadcastToChatSession(ByteBuf payload, ChatSession chatSession) {
		List<ClientInfo> members = chatSession.getActiveMembers();

		assessReferenceCount(members.size(), payload);
		for (int i = 0; i < members.size(); i++) {
			EpollSocketChannel channel = members.get(i).getChannel();
			channel.writeAndFlush(payload.duplicate());
		}
	}

	public static void broadcastToChatSession(ByteBuf payload, BiConsumer<ByteBuf, Channel> execute, ChatSession chatSession) {
		List<ClientInfo> members = chatSession.getActiveMembers();

		assessReferenceCount(members.size(), payload);
		for (int i = 0; i < members.size(); i++) {
			EpollSocketChannel channel = members.get(i).getChannel();
			execute.accept(payload.duplicate(), channel);
		}
	}

	public static void broadcastToChatSessionExcept(ByteBuf payload, ChatSession chatSession, ClientInfo excludeClient, Consumer<ChannelFuture> run) {
		List<ClientInfo> members = chatSession.getActiveMembers();

		assessReferenceCount(members.size(), payload);
		for (int i = 0; i < members.size(); i++) {
			ClientInfo clientInfo = members.get(i);
			EpollSocketChannel channel = clientInfo.getChannel();
			int clientID = clientInfo.getClientID();

			if (channel.equals(excludeClient.getChannel())) {
				continue;
			}

			ChannelFuture future = channel.writeAndFlush(payload.duplicate());

			if (clientID != excludeClient.getClientID()) {
				future.addListener((ChannelFuture f) -> run.accept(f));
			}
		}
	}

	private static void assessReferenceCount(int numberOfSends, ByteBuf payload) {
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
		payload.retain(numberOfSends);
		payload.release();
	}

}
