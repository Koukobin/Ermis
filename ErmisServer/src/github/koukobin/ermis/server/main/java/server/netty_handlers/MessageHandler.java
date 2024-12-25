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
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.CountDownLatch;

import github.koukobin.ermis.common.message_types.ClientContentType;
import github.koukobin.ermis.common.message_types.ServerMessageType;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.ErmisDatabase;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.DatabaseChatMessage;
import github.koukobin.ermis.server.main.java.server.ActiveChatSessions;
import github.koukobin.ermis.server.main.java.server.ActiveClients;
import github.koukobin.ermis.server.main.java.server.ChatSession;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import io.netty.buffer.ByteBuf;
import io.netty.channel.Channel;
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

			clientID = conn.getClientID(email);
			clientInfo.setClientID(clientID);

			String username = clientInfo.getUsername();

			if (username == null) {
				username = conn.getUsername(clientID);
				clientInfo.setUsername(username);
			}

			Integer[] chatSessionsIDS = conn.getChatSessionsUserBelongsTo(clientID);

			List<ChatSession> chatSessions = new ArrayList<>(chatSessionsIDS.length);
			clientInfo.setChatSessions(chatSessions);
			for (int i = 0; i < chatSessionsIDS.length; i++) {

				int chatSessionID = chatSessionsIDS[i];

				ChatSession chatSession = ActiveChatSessions.getChatSession(chatSessionID);

				if (chatSession == null) {

					List<Integer> membersList;

					{
						Integer[] members = conn.getMembersOfChatSession(chatSessionID);
						membersList = new ArrayList<>(members.length);
						Collections.addAll(membersList, members);
					}

					// The client will become active in the chat session once he calls
					// GET_CHAT_SESSIONS command. The reason that this happens is because if he
					// hadn't gotten the chat session with FETCH_CHAT_SESSIONS command then if
					// there was a message sent in the chat session, the server would send that to
					// the client but the client would not know how to proccess it and in what chat
					// session the message belongs to
					List<Channel> activeMembersList = new ArrayList<>(membersList.size());
					chatSession = new ChatSession(chatSessionID, activeMembersList, membersList);
					ActiveChatSessions.addChatSession(chatSessionID, chatSession);
				}

				chatSessions.add(chatSession);
			}

			Integer[] chatRequests = conn.getChatRequests(clientID);
			List<Integer> chatRequestsList = new ArrayList<>(chatRequests.length);
			Collections.addAll(chatRequestsList, chatRequests);

			clientInfo.setChatRequests(chatRequestsList);
		}

		ActiveClients.addClient(clientInfo);
		
		latch.countDown(); // Signal that handlerAdded is complete
	}

	@Override
	public void handlerRemoved(ChannelHandlerContext ctx) throws IOException {
		ActiveClients.removeClient(clientInfo);
		
		List<ChatSession> userChatSessions = clientInfo.getChatSessions();
		for (int i = 0; i < userChatSessions.size(); i++) {
			
			ChatSession chatSession = userChatSessions.get(i);
			chatSession.getActiveChannels().remove(clientInfo.getChannel());

			if (chatSession.getActiveChannels().isEmpty()) {
				ActiveChatSessions.removeChatSession(chatSession.getChatSessionID());
			} else {
				CommandHandler.refreshChatSession(chatSession);
			}
			
		}
		
	}

	@Override
	public void channelRead0(ChannelHandlerContext ctx, ByteBuf msg) throws IOException {

		ChatSession chatSession;
		
		ClientContentType contentType = ClientContentType.fromId(msg.readInt());
		
		try {
			int indexOfChatSession = msg.readInt();
			chatSession = clientInfo.getChatSessions().get(indexOfChatSession);
		} catch (IndexOutOfBoundsException ioobe) {
			ByteBuf payload = ctx.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.SERVER_MESSAGE_INFO.id);
			payload.writeBytes("Chat session selected doesn't exist. (May have been deleted by the other user)".getBytes());
			ctx.channel().writeAndFlush(payload);
			return;
		}

		int chatSessionID = chatSession.getChatSessionID();
		byte[] usernameBytes = clientInfo.getUsername().getBytes();

		byte[] textBytes = null;

		byte[] fileNameBytes = null;
		byte[] fileBytes = null;
				
		ByteBuf payload = ctx.alloc().ioBuffer();
		payload.writeInt(ServerMessageType.CLIENT_CONTENT.id);
		payload.writeInt(contentType.id);

		payload.writeLong(System.currentTimeMillis());
		
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
		
		int messageIDInDatabase = 0;
		try (ErmisDatabase.WriteChatMessagesDBConnection conn = ErmisDatabase.getWriteChatMessagesConnection()) {

			DatabaseChatMessage chatMessage = new DatabaseChatMessage(
					clientInfo.getClientID(),
					chatSessionID,
					textBytes,
					fileNameBytes,
					fileBytes,
					contentType);

			messageIDInDatabase = conn.addMessage(chatMessage);
		}

		payload.writeInt(usernameBytes.length);
		payload.writeBytes(usernameBytes);
		
		payload.writeInt(clientInfo.getClientID());
		
		payload.writeInt(messageIDInDatabase);
		payload.writeInt(chatSessionID);

		broadcastMessageToChatSession(payload, messageIDInDatabase, chatSession);
	
	}
	
	private void broadcastMessageToChatSession(ByteBuf payload, int messageID, ChatSession chatSession) {
		ActiveClients.broadcastMessageToChatSession(payload, messageID, chatSession, clientInfo);
	}

}

