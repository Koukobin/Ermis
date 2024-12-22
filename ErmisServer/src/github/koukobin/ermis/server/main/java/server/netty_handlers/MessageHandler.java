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
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentHashMap;
import java.util.function.Consumer;

import com.google.common.primitives.Ints;

import github.koukobin.ermis.common.Account;
import github.koukobin.ermis.common.LoadedInMemoryFile;
import github.koukobin.ermis.common.UserDeviceInfo;
import github.koukobin.ermis.common.message_types.ClientCommandResultType;
import github.koukobin.ermis.common.message_types.ClientCommandType;
import github.koukobin.ermis.common.message_types.ClientMessageType;
import github.koukobin.ermis.common.message_types.ContentType;
import github.koukobin.ermis.common.message_types.Message;
import github.koukobin.ermis.common.message_types.ServerMessageType;
import github.koukobin.ermis.common.results.ResultHolder;
import github.koukobin.ermis.server.main.java.configs.ServerSettings;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.ErmisDatabase;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.DatabaseChatMessage;
import github.koukobin.ermis.server.main.java.server.ActiveChatSessions;
import github.koukobin.ermis.server.main.java.server.ChatSession;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import github.koukobin.ermis.server.main.java.server.codec.MessageHandlerDecoder;
import github.koukobin.ermis.server.main.java.server.util.MessageByteBufCreator;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.Channel;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.epoll.EpollSocketChannel;

/**
 * @author Ilias Koukovinis
 * 
 */
final class MessageHandler extends ParentHandler {
	
	private static final Map<Integer, List<ClientInfo>> clientIDSToActiveClients = new ConcurrentHashMap<>(ServerSettings.SERVER_BACKLOG);

	private CompletableFuture<?> commandsToBeExecutedQueue = 
			CompletableFuture.runAsync(() -> {}); // initialize it like this for thenRunAsync to work
	
	public MessageHandler(ClientInfo clientInfo) {
		super(clientInfo);
	}
	
	@Override
	public void handlerAdded(ChannelHandlerContext ctx) {
		
		MessageHandlerDecoder decoder = new MessageHandlerDecoder(ServerSettings.MAX_CLIENT_MESSAGE_TEXT_BYTES, ServerSettings.MAX_CLIENT_MESSAGE_FILE_BYTES);
		ctx.pipeline().replace("decoder", "decoder", decoder);
		
		try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
			
			int clientID = conn.getClientID(clientInfo.getChannel().remoteAddress().getAddress());
			
			clientInfo.setUsername(conn.getUsername(clientID));
			clientInfo.setEmail(conn.getEmailAddress(clientID));
			clientInfo.setClientID(clientID);

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

		clientIDSToActiveClients.putIfAbsent(clientInfo.getClientID(), new ArrayList<>());
		clientIDSToActiveClients.get(clientInfo.getClientID()).add(clientInfo);
	}

	@Override
	public void handlerRemoved(ChannelHandlerContext ctx) throws IOException {
		clientIDSToActiveClients.remove(clientInfo.getClientID());
		
		List<ChatSession> userChatSessions = clientInfo.getChatSessions();
		for (int i = 0; i < userChatSessions.size(); i++) {
			
			ChatSession chatSession = userChatSessions.get(i);
			chatSession.getActiveChannels().remove(clientInfo.getChannel());

			if (chatSession.getActiveChannels().isEmpty()) {
				ActiveChatSessions.removeChatSession(chatSession.getChatSessionID());
			} else {
				refreshChatSession(chatSession);
			}
			
		}
		
	}

	@Override
	public void channelRead1(ChannelHandlerContext ctx, ByteBuf msg) throws IOException {

		ClientMessageType msgType = ClientMessageType.fromId(msg.readInt());

		switch (msgType) {
		case CLIENT_CONTENT -> {

			ChatSession chatSession;
			
			ContentType contentType = ContentType.fromId(msg.readInt());
			
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
		case COMMAND -> {
			
			ClientCommandType commandType = ClientCommandType.fromId(msg.readInt());

			switch (commandType.getCommandLevel()) {
			case HEAVY -> {
				msg.retain(); // increase reference count by 1 for executeCommand
				commandsToBeExecutedQueue.thenRunAsync(() -> {
					try {
						executeCommand(commandType, msg);
					} catch (Exception e) {
						exceptionCaught(ctx, e);
					}
				});
			}
			case LIGHT -> {
				executeCommand(commandType, msg);
			}
			default -> { /* No such case */ }
			}
		}
		}
	}
	
	private void broadcastMessageToChatSession(ByteBuf payload, int messageID, ChatSession chatSession) {
		broadcastMessageToChatSession(payload, messageID, chatSession, clientInfo);
	}
	
	private static void broadcastMessageToChatSession(ByteBuf payload, int messageID, ChatSession chatSession, ClientInfo sender) {

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
	
	private static void broadcastToChatSession(ByteBuf payload, int messageID, ChatSession chatSession) {

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
			channel.writeAndFlush(payload.duplicate());
		}
	}

	private void executeCommand(ClientCommandType commandType, ByteBuf args) {
		executeCommand(clientInfo, commandType, args);
	}
	
	/**
	 * This method can be used by the client to execute various commands, such as to
	 * change his username or to get his clientID
	 * 
	 */
	private static void executeCommand(ClientInfo clientInfo, ClientCommandType commandType, ByteBuf args) {
		
		EpollSocketChannel channel = clientInfo.getChannel();
		
		switch (commandType) {
		case CHANGE_USERNAME -> {

			byte[] newUsernameBytes = new byte[args.readableBytes()];
			args.readBytes(newUsernameBytes);

			String newUsername = new String(newUsernameBytes);
			String currentUsername = clientInfo.getUsername();
			
			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.SERVER_MESSAGE_INFO.id);
			
			if (newUsername.equals(currentUsername)) {
				payload.writeBytes("Username cannot be the same as old username!".getBytes());
			} else {
				ResultHolder resultHolder;
				try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
					resultHolder = conn.changeDisplayName(clientInfo.getClientID(), newUsername);
				}

				payload.writeBytes(resultHolder.getResultMessage().getBytes());

				if (resultHolder.isSuccessful()) {
					clientInfo.setUsername(newUsername);
					
					// Fetch username on behalf of the user
					executeCommand(clientInfo, ClientCommandType.FETCH_USERNAME, Unpooled.EMPTY_BUFFER);
				}
			}

			channel.writeAndFlush(payload);
		}
		case CHANGE_PASSWORD -> {

			byte[] newPasswordBytes = new byte[args.readableBytes()];
			args.readBytes(newPasswordBytes);

			// Note that unlike the CHANGE_USERNAME command we don't check wether or not the
			// password is the same for security reasons
			String newPassword = new String(newPasswordBytes);

			ResultHolder resultHolder;
			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				resultHolder = conn.changePassword(clientInfo.getEmail(), newPassword);
			}

			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.SERVER_MESSAGE_INFO.id);
			payload.writeBytes(resultHolder.getResultMessage().getBytes());
			channel.writeAndFlush(payload);
		}
		case DOWNLOAD_FILE -> {
			
			int chatSessionIndex = args.readInt();
			int messageID = args.readInt();
			
			LoadedInMemoryFile file;
			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				file = conn.getFile(messageID, clientInfo.getChatSessions().get(chatSessionIndex).getChatSessionID());
			}

			byte[] fileBytes = file.getFileBytes();
			byte[] fileNameBytes = file.getFileName().getBytes();

			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
			payload.writeInt(ClientCommandResultType.DOWNLOAD_FILE.id);
			payload.writeInt(fileNameBytes.length);
			payload.writeBytes(fileNameBytes);
			payload.writeBytes(fileBytes);
			
			channel.writeAndFlush(payload);
		}
		case DOWNLOAD_IMAGE -> {
			
			int chatSessionIndex = args.readInt();
			int messageID = args.readInt();
			
			LoadedInMemoryFile file;
			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				file = conn.getFile(messageID, clientInfo.getChatSessions().get(chatSessionIndex).getChatSessionID());
			}

			byte[] fileBytes = file.getFileBytes();
			byte[] fileNameBytes = file.getFileName().getBytes();

			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
			payload.writeInt(ClientCommandResultType.DOWNLOAD_IMAGE.id);
			payload.writeInt(messageID);
			payload.writeInt(fileNameBytes.length);
			payload.writeBytes(fileNameBytes);
			payload.writeBytes(fileBytes);
			
			channel.writeAndFlush(payload);
		}
		case SEND_CHAT_REQUEST -> {
			
			int receiverID = args.readInt();
			int senderClientID = clientInfo.getClientID();
			
			int resultUpdate;
			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				resultUpdate = conn.sendChatRequest(receiverID, senderClientID);
			}
			
			boolean isSuccessfull = resultUpdate == 1;
			
			if (!isSuccessfull) {
				ByteBuf payload = channel.alloc().ioBuffer();
				payload.writeInt(ServerMessageType.SERVER_MESSAGE_INFO.id);
				payload.writeBytes("An error occured while trying to send chat request!".getBytes());
				channel.writeAndFlush(payload);
				return;
			}
			
			forClient(receiverID, (ClientInfo ci) -> {
				ci.getChatRequests().add(senderClientID);
			});
		}
		case ACCEPT_CHAT_REQUEST -> {
			
			int senderClientID = args.readInt();
			int receiverClientID = clientInfo.getClientID();
			
			int chatSessionID;
			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				chatSessionID = conn.acceptChatRequest(receiverClientID, senderClientID);
			}

			if (chatSessionID != -1) {

				List<Integer> membersList = Ints.asList(receiverClientID, senderClientID);
				List<Channel> activeMembersList = new ArrayList<>(membersList.size());

				ChatSession chatSession = new ChatSession(chatSessionID, activeMembersList, membersList);

				ActiveChatSessions.addChatSession(chatSessionID, chatSession);

				clientInfo.getChatRequests().remove(Integer.valueOf(senderClientID));
				clientInfo.getChatSessions().add(chatSession);

				forClient(senderClientID, (ClientInfo ci) -> ci.getChatSessions().add(chatSession));
			} else {
				ByteBuf payload = channel.alloc().ioBuffer();
				payload.writeInt(ServerMessageType.SERVER_MESSAGE_INFO.id);
				payload.writeBytes("Something went wrong while trying accept chat request!".getBytes());
				channel.writeAndFlush(payload);
			}
		}
		case DECLINE_CHAT_REQUEST -> {
			
			int senderClientID = args.readInt();
			int receiverClientID = clientInfo.getClientID();
			
			int resultUpdate;
			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				resultUpdate = conn.deleteChatRequest(receiverClientID, senderClientID);
			}
			
			boolean isSuccessfull = resultUpdate == 1;
			
			if (!isSuccessfull) {
				ByteBuf payload = channel.alloc().ioBuffer();
				payload.writeInt(ServerMessageType.SERVER_MESSAGE_INFO.id);
				payload.writeBytes("Something went wrong while trying to decline chat request!".getBytes());
				channel.writeAndFlush(payload);
			} else {
				clientInfo.getChatRequests().remove(Integer.valueOf(senderClientID));
			}
		}
		case DELETE_CHAT_SESSION -> {
			
			int chatSessionID;
			
			{
				int chatSessionIndex = args.readInt();
				chatSessionID = clientInfo.getChatSessions().get(chatSessionIndex).getChatSessionID();
			}
			
			int resultUpdate;
			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				resultUpdate = conn.deleteChatSession(chatSessionID);
			}
			
			boolean isSuccessfull = resultUpdate == 1;

			if (!isSuccessfull) {
				ByteBuf payload = channel.alloc().ioBuffer();
				payload.writeInt(ServerMessageType.SERVER_MESSAGE_INFO.id);
				payload.writeBytes("Something went wrong while trying delete chat session!".getBytes());
				channel.writeAndFlush(payload);
			} else {
				
				ChatSession chatSession = ActiveChatSessions.getChatSession(chatSessionID);
				
				if (chatSession != null) {
					
					List<Integer> activeMembers = chatSession.getActiveMembers();
					for (int i = 0; i < activeMembers.size(); i++) {
						forClient(activeMembers.get(i), (ClientInfo ci) -> ci.getChatSessions().remove(chatSession));
					}
					
					ActiveChatSessions.removeChatSession(chatSessionID);
				}
			}
		}
		case DELETE_CHAT_MESSAGE -> {

			int chatSessionID;

			{
				int chatSessionIndex = args.readInt();
				chatSessionID = clientInfo.getChatSessions().get(chatSessionIndex).getChatSessionID();
			}

			int messageID = args.readInt();

			int resultUpdate;
			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				resultUpdate = conn.deleteChatMessage(chatSessionID, messageID);
			}

			boolean isSuccesfull = resultUpdate == 1;

			if (isSuccesfull) {

				ByteBuf payload = channel.alloc().ioBuffer();
				payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
				payload.writeInt(ClientCommandResultType.DELETE_CHAT_MESSAGE.id);
				payload.writeInt(chatSessionID);
				payload.writeInt(messageID);
				
				broadcastToChatSession(payload, messageID, ActiveChatSessions.getChatSession(chatSessionID));
			}
		}
		case LOGOUT_THIS_DEVICE -> {

			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				conn.logout(channel.remoteAddress().getAddress(), clientInfo.getClientID());
			}

			channel.close();
		}
		case LOGOUT_OTHER_DEVICE -> {

			byte[] addressBytes = new byte[args.readableBytes()];
			args.readBytes(addressBytes);

			InetAddress address;
			
			try {
				address = InetAddress.getByName(new String(addressBytes));
			} catch (UnknownHostException uhe) {
				logger.debug(String.format("Address not recognized %s", new String(addressBytes)), uhe);
				MessageByteBufCreator.sendMessageInfo(channel, "Address not recognized!");
				return;
			}

			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				conn.logout(address, clientInfo.getClientID());
			}

			// Search for the specific IP address and if found logout that address
			forClient(clientInfo.getClientID(), (ClientInfo ci) -> {
				if (!ci.getInetAddress().equals(address)) {
					return;
				}
				
				ci.getChannel().close();
			});
		}
		case LOGOUT_ALL_DEVICES -> {

			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				conn.logoutAllDevices(clientInfo.getClientID());
			}

			// Close all channels associated with this client id
			forClient(clientInfo.getClientID(), (ClientInfo ci) -> {
				ci.getChannel().close();
			});
		}
		case FETCH_USERNAME -> {
			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
			payload.writeInt(ClientCommandResultType.GET_DISPLAY_NAME.id);
			payload.writeBytes(clientInfo.getUsername().getBytes());
			channel.writeAndFlush(payload);
		}
		case FETCH_CLIENT_ID -> {
			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
			payload.writeInt(ClientCommandResultType.GET_CLIENT_ID.id);
			payload.writeInt(clientInfo.getClientID());
			channel.writeAndFlush(payload);
		}
		case FETCH_USER_DEVICES -> {
			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
			payload.writeInt(ClientCommandResultType.FETCH_USER_DEVICES.id);
			
			UserDeviceInfo[] devices;
			
			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				devices = conn.getUserIPS(clientInfo.getClientID());
			}

			for (int i = 0; i < devices.length; i++) {
				payload.writeInt(devices[i].deviceType().id);
				
				String ipAddress = devices[i].ipAddress();
				payload.writeInt(ipAddress.length());
				payload.writeBytes(ipAddress.getBytes());
				
				String osName = devices[i].osName();
				payload.writeInt(osName.length());
				payload.writeBytes(osName.getBytes());
			}
			
			channel.writeAndFlush(payload);
		}
		case DELETE_ACCOUNT -> {
			
			byte[] emailAddress = new byte[args.readInt()];
			args.readBytes(emailAddress);
			
			byte[] password = new byte[args.readInt()];
			args.readBytes(password);

			int resultUpdate;
			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				resultUpdate = conn.deleteAccount(new String(emailAddress), new String(password), clientInfo.getClientID());
			}
			
			if (resultUpdate == 1) {
				channel.close();
				return;
			}
			
			MessageByteBufCreator.sendMessageInfo(channel, "An error occured while trying to delete your account");
		}
		case ADD_ACCOUNT_ICON -> {
			
			byte[] icon = new byte[args.readableBytes()];
			args.readBytes(icon);
			
			int resultUpdate ;
			
			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				resultUpdate = conn.addUserIcon(clientInfo.getClientID(), icon);
			}
			
			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
			payload.writeInt(ClientCommandResultType.SET_ACCOUNT_ICON.id);
			payload.writeBoolean(resultUpdate == 1);
			
			channel.writeAndFlush(payload);
		}
		case FETCH_ACCOUNT_ICON -> {
			
			byte[] accountIcon;
			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				accountIcon = conn.selectUserIcon(clientInfo.getClientID());
			}
			
			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
			payload.writeInt(ClientCommandResultType.FETCH_ACCOUNT_ICON.id);
			if (accountIcon != null) {
				payload.writeBytes(accountIcon);
			}
			
			channel.writeAndFlush(payload);
		}
		case FETCH_WRITTEN_TEXT -> {
			
			int chatSessionIndex = args.readInt();
			int chatSessionID = clientInfo.getChatSessions().get(chatSessionIndex).getChatSessionID();

			int numOfMessagesAlreadySelected = args.readInt();
			
			Message[] messages;
			
			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				messages = conn.selectMessages(chatSessionID, numOfMessagesAlreadySelected, ServerSettings.NUMBER_OF_MESSAGES_TO_READ_FROM_THE_DATABASE_AT_A_TIME);
			}
			
			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
			payload.writeInt(ClientCommandResultType.GET_WRITTEN_TEXT.id);
			payload.writeInt(chatSessionIndex);

			for (int i = 0; i < messages.length; i++) {

				Message message = messages[i];
				byte[] messageBytes = message.getText();
				byte[] fileNameBytes = message.getFileName();
				byte[] usernameBytes = message.getUsername().getBytes();
				long timeWritten = message.getTimeWritten();
				ContentType contentType = message.getContentType();
				
				payload.writeInt((contentType.id));
				payload.writeInt(message.getClientID());
				payload.writeInt(message.getMessageID());

				payload.writeInt(usernameBytes.length);
				payload.writeBytes(usernameBytes);

				payload.writeLong(timeWritten);
				
				switch (contentType) {
				case TEXT -> {
					payload.writeInt(messageBytes.length);
					payload.writeBytes(messageBytes);
				}
				case FILE, IMAGE -> {
					payload.writeInt(fileNameBytes.length);
					payload.writeBytes(fileNameBytes);
				}
				}
			}

			channel.writeAndFlush(payload);
		}
		case FETCH_CHAT_REQUESTS -> {
			
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
		case FETCH_CHAT_SESSIONS -> {
			
			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
			payload.writeInt(ClientCommandResultType.GET_CHAT_SESSIONS.id);
			
			List<ChatSession> chatSessions = clientInfo.getChatSessions();

			payload.writeInt(chatSessions.size());
			if (!chatSessions.isEmpty()) {
				for (int i = 0; i < chatSessions.size(); i++) {

					ChatSession chatSession = chatSessions.get(i);
					int chatSessionID = chatSession.getChatSessionID();
					List<Integer> membersClientIDS = chatSession.getActiveMembers();

					payload.writeInt(chatSessionID);

					// The one that is subtracted is attributed to the user inquring this command
					payload.writeInt(membersClientIDS.size() - 1);
					try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
						for (int j = 0; j < membersClientIDS.size(); j++) {

							int clientID = membersClientIDS.get(j);

							boolean isActive;
							List<ClientInfo> memberClientInfo = clientIDSToActiveClients.get(clientID);
							
							byte[] usernameBytes;
							byte[] iconBytes = conn.selectUserIcon(clientID);
							
							if (memberClientInfo == null) {
								usernameBytes = conn.getUsername(clientID).getBytes();
								isActive = false;
							} else {
								ClientInfo random = memberClientInfo.get(0);
								if (clientInfo.getClientID() ==  random.getClientID()) {
									continue;
								}
								
								usernameBytes = random.getUsername().getBytes();
								isActive = true;
							}

							payload.writeInt(clientID);
							payload.writeBoolean(isActive);
							payload.writeInt(usernameBytes.length);
							payload.writeBytes(usernameBytes);
							payload.writeInt(iconBytes.length);
							payload.writeBytes(iconBytes);
						}

					}

					if (!chatSession.getActiveChannels().contains(clientInfo.getChannel())) {
						chatSession.getActiveChannels().add(clientInfo.getChannel());
						refreshChatSession(chatSession);
					}

				}
			}
			
			channel.writeAndFlush(payload);
		}
		case FETCH_OTHER_ACCOUNTS_ASSOCIATED_WITH_IP_ADDRESS -> {

			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
			payload.writeInt(ClientCommandResultType.FETCH_OTHER_ACCOUNTS_ASSOCIATED_WITH_IP_ADDRESS.id);

			Account[] accounts;
			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				accounts = conn.getAccountsAssociatedWithDevice(clientInfo.getInetAddress());
			}
			
			for (int i = 0; i < accounts.length; i++) {
				payload.writeInt(accounts[i].clientID());
				
				String displayName = accounts[i].displayName();
				payload.writeInt(displayName.length());
				payload.writeBytes(displayName.getBytes());
				
				byte[] profilePhoto = accounts[i].profilePhoto();
				payload.writeInt(profilePhoto.length);
				payload.writeBytes(profilePhoto);
			}
			
			channel.writeAndFlush(payload);
		}
		case START_VOICE_CALL -> {
			
//			int chatSessionIndex = args.readInt();
//			int clientID = args.readInt();
//			InetSocketAddress address = null;
//			for (var a : clientInfo.getChatSessions().get(chatSessionIndex).getActiveChannels()) {
//				if (a.getClientID() == clientID) {
//					address = a.getChannel().localAddress();
//				}
//			}
//			
//			ByteBuf payload = clientIDSToActiveClients.get(clientID).getChannel().alloc().ioBuffer();
//			payload.writeInt(ServerMessageType.VOICE_CALL_INCOMING.id);
//			payload.writeInt(clientID);
//
//			clientIDSToActiveClients.get(clientID).getChannel().writeAndFlush(payload);
//
//			ServerUDP.addVoiceChat(address, clientInfo.getChannel().localAddress());
//			logger.debug("Voice chat added");
		}
		case REQUEST_DONATION_PAGE -> {
			
			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
			payload.writeInt(ClientCommandResultType.GET_DONATION_PAGE.id);
			payload.writeInt(ServerSettings.Donations.HTML_PAGE.length());
			payload.writeBytes(ServerSettings.Donations.HTML_PAGE.getBytes());
			payload.writeBytes(ServerSettings.Donations.HTML_FILE_NAME.getBytes());

			channel.writeAndFlush(payload);
		}
		case REQUEST_SOURCE_CODE_PAGE -> {

			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
			payload.writeInt(ClientCommandResultType.GET_SOURCE_CODE_PAGE.id);
			payload.writeBytes(ServerSettings.SOURCE_CODE_URL.getBytes());

			channel.writeAndFlush(payload);
		}
		default -> {

			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.SERVER_MESSAGE_INFO.id);
			payload.writeBytes(("Command:" + commandType.toString() + "not implemented!").getBytes());

			channel.writeAndFlush(payload);
		}
		}
		
	}
	
	private static void forClient(int clientID, Consumer<ClientInfo> DO) {
		List<ClientInfo> idont =  clientIDSToActiveClients.get(clientID);
		
		if (idont == null) {
			return;
		}
		
		for (ClientInfo clientInfo : idont) {
			DO.accept(clientInfo);;
		}
	}

	private static void refreshChatSession(ChatSession chatSession) {
		List<Integer> activeMembers = chatSession.getActiveMembers();
		for (int i = 0; i < activeMembers.size(); i++) {
			forClient(activeMembers.get(i), (ClientInfo member) -> {
				executeCommand(member, ClientCommandType.FETCH_CHAT_SESSIONS, Unpooled.EMPTY_BUFFER);
			});
		}
	}

}


