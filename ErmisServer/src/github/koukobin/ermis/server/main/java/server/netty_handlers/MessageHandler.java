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
package github.koukobin.ermis.server.main.java.server.netty_handlers;

import java.io.IOException;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CountDownLatch;

import com.google.common.collect.Lists;

import github.koukobin.ermis.common.message_types.ClientContentType;
import github.koukobin.ermis.common.message_types.MessageDeliveryStatus;
import github.koukobin.ermis.common.message_types.ServerInfoMessage;
import github.koukobin.ermis.common.message_types.ServerMessageType;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.ErmisDatabase;
import github.koukobin.ermis.server.main.java.WhatTheFuckIsGoingOnException;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.DatabaseChatMessage;
import github.koukobin.ermis.server.main.java.server.ActiveChatSessions;
import github.koukobin.ermis.server.main.java.server.ActiveClients;
import github.koukobin.ermis.server.main.java.server.ChatSession;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import github.koukobin.ermis.server.main.java.server.util.MessageByteBufCreator;
import io.netty.buffer.ByteBuf;
import io.netty.channel.Channel;
import io.netty.channel.ChannelFuture;
import io.netty.channel.ChannelHandlerContext;

/**
 * @author Ilias Koukovinis
 * 
 */
final class MessageHandler extends AbstractChannelClientHandler {

	private final CountDownLatch latch = new CountDownLatch(1);

	public MessageHandler(ClientInfo clientInfo) {
		super(clientInfo);
	}

	public void awaitInitialization() {
		try {
			latch.await(); // Block until handlerAdded is complete
		} catch (InterruptedException ie) {
			getLogger().error("Thread interrupted");
			Thread.currentThread().interrupt();
		}
	}

	@Override
	public void handlerAdded(ChannelHandlerContext ctx) {
		try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {

			String email = clientInfo.getEmail();

			if (email == null) {
				throw new IllegalStateException("Email not initialized for client: " + clientInfo);
			}

			int clientID = clientInfo.getClientID();

			clientID = conn.getClientID(email).orElseThrow();
			clientInfo.setClientID(clientID);

			String username = clientInfo.getUsername();

			if (username == null) {
				username = conn.getUsername(clientID).orElseThrow(() -> {
					throw new WhatTheFuckIsGoingOnException("Username should not be null in this case");
				});
				clientInfo.setUsername(username);
//				conn.getUsername(clientID).ifPresentOrElse((String username0) -> {
//					clientInfo.setUsername(username0);
//				}, () -> {
//					throw new WhatTheFuckIsGoingOnException("Username should not be null in this case");
//				});
			}

			Integer[] chatSessionsIDS = conn.getChatSessionsUserBelongsTo(clientID);

			List<ChatSession> chatSessions = new ArrayList<>(chatSessionsIDS.length);
			clientInfo.setChatSessions(chatSessions);
			for (int i = 0; i < chatSessionsIDS.length; i++) {

				int chatSessionID = chatSessionsIDS[i];

				ChatSession chatSession = ActiveChatSessions.getChatSession(chatSessionID);

				if (chatSession == null) {

					List<Integer> chatMembers;

					{
						Integer[] members = conn.getMembersOfChatSession(chatSessionID);
						chatMembers = Lists.newArrayList(members);
					}

					// The client will become active in the chat session once he calls
					// GET_CHAT_SESSIONS command. The reason that this happens is because if he
					// hadn't gotten the chat session with FETCH_CHAT_SESSIONS command then if
					// there was a message sent in the chat session, the server would send that to
					// the client but the client would not know how to process it and in what chat
					// session the message belongs to
					List<ClientInfo> activeChatMembers = new ArrayList<>(chatMembers.size());
					chatSession = new ChatSession(chatSessionID, activeChatMembers, chatMembers);
					ActiveChatSessions.addChatSession(chatSessionID, chatSession);
				}

				chatSessions.add(chatSession);
			}

			Integer[] chatRequests = conn.getChatRequests(clientID);
			List<Integer> chatRequestsList = Lists.newArrayList(chatRequests);

			clientInfo.setChatRequests(chatRequestsList);
		}

		ActiveClients.addClient(clientInfo);

		latch.countDown(); // Signal that handlerAdded is complete
	}

	@Override
	public void handlerRemoved(ChannelHandlerContext ctx) throws IOException {
		ActiveClients.removeClient(clientInfo);

		List<ChatSession> chatSessions = clientInfo.getChatSessions();
		for (ChatSession chatSession : chatSessions) {

			chatSession.getActiveMembers().remove(clientInfo);
			if (chatSession.getActiveMembers().isEmpty()) {
				ActiveChatSessions.removeChatSession(chatSession.getChatSessionID());
				continue;
			}

			CommandHandler.refreshChatSessionStatuses(chatSession);
		}

	}

	@Override
	public void channelRead0(ChannelHandlerContext ctx, ByteBuf msg) throws IOException {
		final int tempMessageID = msg.readInt();

		ClientContentType contentType = ClientContentType.fromId(msg.readInt());

		ChatSession chatSession;
		try {
			int chatSessionIndex = msg.readInt();
			chatSession = clientInfo.getChatSessions().get(chatSessionIndex);
		} catch (IndexOutOfBoundsException ioobe) {
			getLogger().debug("Chat session index does not exist:", ioobe);
			MessageByteBufCreator.sendMessageInfo(ctx, ServerInfoMessage.CHAT_SESSION_DOES_NOT_EXIST);
			return;
		}

		int chatSessionID = chatSession.getChatSessionID();
		byte[] usernameBytes = clientInfo.getUsername().getBytes();

		byte[] textBytes = null;

		byte[] fileNameBytes = null;
		byte[] fileBytes = null;

		long epochSecond = Instant.now().getEpochSecond();

		ByteBuf payload = ctx.alloc().ioBuffer();
		payload.writeInt(ServerMessageType.CLIENT_MESSAGE.id);
		payload.writeInt(contentType.id);

		payload.writeLong(epochSecond);

		switch (contentType) {
		case TEXT -> {
			int textLength = msg.readInt();
			textBytes = new byte[textLength];
			msg.readBytes(textBytes);

			payload.writeInt(textLength);
			payload.writeBytes(textBytes);
		}
		case FILE, IMAGE -> {
			int fileNameLength = msg.readInt();
			fileNameBytes = new byte[fileNameLength];
			msg.readBytes(fileNameBytes);

			fileBytes = new byte[msg.readableBytes()];
			msg.readBytes(fileBytes);

			payload.writeInt(fileNameLength);
			payload.writeBytes(fileNameBytes);
		}
		}

		int messageID;
		final boolean isRead = false;
		try (ErmisDatabase.WriteChatMessagesDBConnection conn = ErmisDatabase.getWriteChatMessagesConnection()) {
			DatabaseChatMessage chatMessage = new DatabaseChatMessage(
					clientInfo.getClientID(),
					chatSessionID,
					textBytes,
					fileNameBytes,
					fileBytes,
					isRead,
					contentType);

			messageID = conn.addMessage(chatMessage);
		}

		payload.writeInt(usernameBytes.length);
		payload.writeBytes(usernameBytes);

		payload.writeInt(clientInfo.getClientID());

		payload.writeInt(messageID);
		payload.writeInt(chatSessionID);

		receivedMessage(ctx, tempMessageID, messageID);
		broadcastMessageToChatSession(payload, tempMessageID, messageID, chatSession);
	}

	private void broadcastMessageToChatSession(ByteBuf payload, int tempMessageID, int messageID, ChatSession chatSession) {
		ActiveChatSessions.broadcastToChatSessionExcept(payload, chatSession, clientInfo, (ChannelFuture cf) -> {
			Channel channel = cf.channel();
			if (cf.isSuccess()) {

				ByteBuf s = channel.alloc().ioBuffer();
				s.writeInt(ServerMessageType.MESSAGE_DELIVERY_STATUS.id);
				s.writeInt(MessageDeliveryStatus.DELIVERED.id);
				s.writeInt(tempMessageID);
				s.writeInt(messageID);
				clientInfo.getChannel().writeAndFlush(s);
				
				try (ErmisDatabase.WriteChatMessagesDBConnection conn = ErmisDatabase.getWriteChatMessagesConnection()) {
					conn.updateMessageReadStatus(messageID);
				}

				getLogger().debug("Client message by {} successfully transferred to {}",
						clientInfo.getInetAddress(),
						cf.channel().remoteAddress());
				return;
			}

			ByteBuf f = channel.alloc().ioBuffer();
			f.writeInt(ServerMessageType.MESSAGE_DELIVERY_STATUS.id);
			f.writeInt(MessageDeliveryStatus.FAILED.id);
			f.writeInt(tempMessageID);
			f.writeInt(messageID);
			clientInfo.getChannel().writeAndFlush(f);

			getLogger().debug("An error occured while attempting to forward client message by {} to {}",
					clientInfo.getInetAddress(),
					cf.channel().remoteAddress());
		});
	}

	private static void receivedMessage(ChannelHandlerContext channel, int tempMessageID, int messageID) {
		ByteBuf payload = channel.alloc().ioBuffer();
		payload.writeInt(ServerMessageType.MESSAGE_DELIVERY_STATUS.id);
		payload.writeInt(MessageDeliveryStatus.SERVER_RECEIVED.id);
		payload.writeInt(tempMessageID);
		payload.writeInt(messageID);
		channel.writeAndFlush(payload);
	}

}
