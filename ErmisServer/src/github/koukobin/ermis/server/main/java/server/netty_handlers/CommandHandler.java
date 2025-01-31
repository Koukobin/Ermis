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
import java.util.List;
import java.util.Optional;
import java.util.concurrent.CompletableFuture;
import java.util.function.Consumer;

import com.google.common.collect.Lists;

import github.koukobin.ermis.common.Account;
import github.koukobin.ermis.common.LoadedInMemoryFile;
import github.koukobin.ermis.common.UserDeviceInfo;
import github.koukobin.ermis.common.message_types.ClientCommandResultType;
import github.koukobin.ermis.common.message_types.ClientCommandType;
import github.koukobin.ermis.common.message_types.ClientContentType;
import github.koukobin.ermis.common.message_types.ServerMessageType;
import github.koukobin.ermis.common.message_types.UserMessage;
import github.koukobin.ermis.common.results.ResultHolder;
import github.koukobin.ermis.common.util.EmptyArrays;
import github.koukobin.ermis.server.main.java.configs.ServerSettings;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.ErmisDatabase;
import github.koukobin.ermis.server.main.java.server.ActiveChatSessions;
import github.koukobin.ermis.server.main.java.server.ChatSession;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import github.koukobin.ermis.server.main.java.server.ServerUDP;
import github.koukobin.ermis.server.main.java.server.ServerUDP.VoiceChat;
import github.koukobin.ermis.server.main.java.server.ActiveClients;
import github.koukobin.ermis.server.main.java.server.util.MessageByteBufCreator;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.ChannelHandler;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.epoll.EpollSocketChannel;

/**
 * @author Ilias Koukovinis
 *
 */
public final class CommandHandler extends AbstractChannelClientHandler {

	private CompletableFuture<?> commandsToBeExecutedQueue;
	
	protected CommandHandler(ClientInfo clientInfo) {
		super(clientInfo);
		commandsToBeExecutedQueue = CompletableFuture.runAsync(() -> {
		}); // initialize it like this for thenRunAsync to work
	}

	@Override
	public void channelRead0(ChannelHandlerContext ctx, ByteBuf msg) throws IOException {
		ClientCommandType commandType = ClientCommandType.fromId(msg.readInt());
		getLogger().debug(commandType);

		switch (commandType.getCommandLevel()) {
		case HEAVY -> {
			msg.retain(); // increase reference count by 1 for executeCommand since autoRelease is true
			commandsToBeExecutedQueue.thenRunAsync(() -> {
				try {
					executeCommand(commandType, msg);
				} catch (Exception e) {
					super.exceptionCaught(ctx, e);
				}
			});
		}
		case LIGHT -> {
			executeCommand(commandType, msg);
		}
		default -> getLogger().debug("Command not recognized");
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
		case DOWNLOAD_FILE, DOWNLOAD_IMAGE -> {

			int chatSessionIndex = args.readInt();
			int messageID = args.readInt();

			Optional<LoadedInMemoryFile> optionalFile;
			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				optionalFile = conn.getFile(messageID, clientInfo.getChatSessions().get(chatSessionIndex).getChatSessionID());
			}

			optionalFile.ifPresentOrElse((LoadedInMemoryFile file) -> {
				byte[] fileBytes = file.getFileBytes();
				byte[] fileNameBytes = file.getFileName().getBytes();

				ByteBuf payload = channel.alloc().ioBuffer();
				payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
				switch (commandType) {
				case DOWNLOAD_IMAGE -> {
					payload.writeInt(ClientCommandResultType.DOWNLOAD_IMAGE.id);
					payload.writeInt(messageID); // Include the message ID of the image so the client can add it to the correct message
				}
				case DOWNLOAD_FILE -> {
					payload.writeInt(ClientCommandResultType.DOWNLOAD_FILE.id);
					// Unlike with downloading images, there is no need to specify message id for file
					// downloads, since the client will save the file directly to the file system
					// without needing to associate it to a specific message.
				}
				default -> {
					final String log = """
							How the fuck have we reached here. This log CANNOT happen. This log SHOULD NOT happen.
							I have placed it here purely for debugging purposes (Additionally, because I have started to go insane).
							It is virtually impossible for you to actually witness this log. In the astronomically rare instance that you do - you are fucked.
							This indicates there is a significant flaw in the server's internal structure.
							For more details: Unexpected value in switch statement - {} - where either DOWNLOAD_IMAGE or DOWNLOAD_FILE was expected.
							Anyways... I am gonna go to sleep now.
							""";
					getLogger().fatal(log, commandType);
				}
				}
				payload.writeInt(fileNameBytes.length);
				payload.writeBytes(fileNameBytes);
				payload.writeBytes(fileBytes);

				channel.writeAndFlush(payload);
			}, () -> {
				ByteBuf payload = channel.alloc().ioBuffer();
				payload.writeInt(ServerMessageType.SERVER_MESSAGE_INFO.id);
				payload.writeBytes("An error occured while trying to fetch file from database!".getBytes());
				channel.writeAndFlush(payload);
			});

		}
		case SEND_CHAT_REQUEST -> {
			
			int receiverID = args.readInt();
			int senderClientID = clientInfo.getClientID();
			
			boolean success;
			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				success = conn.sendChatRequest(receiverID, senderClientID);
			}
			
			if (!success) {
				ByteBuf payload = channel.alloc().ioBuffer();
				payload.writeInt(ServerMessageType.SERVER_MESSAGE_INFO.id);
				payload.writeBytes("An error occured while trying to send chat request!".getBytes());
				channel.writeAndFlush(payload);
				return;
			}

			forActiveAccounts(receiverID, (ClientInfo ci) -> {
				ci.getChatRequests().add(senderClientID);
			});
		}
		case ACCEPT_CHAT_REQUEST -> {

			int senderClientID = args.readInt();
			int receiverClientID = clientInfo.getClientID();

			int chatSessionID;
			synchronized (clientInfo.getChatRequests()) {
				try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
					chatSessionID = conn.acceptChatRequest(receiverClientID, senderClientID);
				}
			}

			if (chatSessionID == -1) {
				ByteBuf payload = channel.alloc().ioBuffer();
				payload.writeInt(ServerMessageType.SERVER_MESSAGE_INFO.id);
				payload.writeBytes("Something went wrong while trying accept chat request!".getBytes());
				channel.writeAndFlush(payload);
				return;
			}

			List<Integer> members = Lists.newArrayList(receiverClientID, senderClientID);
			List<ClientInfo> activeMembers = new ArrayList<>(members.size());

			ChatSession chatSession = new ChatSession(chatSessionID, activeMembers, members);
			ActiveChatSessions.addChatSession(chatSession);

			clientInfo.getChatRequests().remove(Integer.valueOf(senderClientID));
			clientInfo.getChatSessions().add(chatSession);

			Consumer<ClientInfo> updateSessions = (ClientInfo ci) -> ci.getChatSessions().add(chatSession);
			forActiveAccounts(receiverClientID, updateSessions);
			forActiveAccounts(senderClientID, updateSessions);
		}
		case DECLINE_CHAT_REQUEST -> {
			
			int senderClientID = args.readInt();
			int receiverClientID = clientInfo.getClientID();
			
			boolean success;
			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				success = conn.deleteChatRequest(receiverClientID, senderClientID);
			}

			if (success) {
				clientInfo.getChatRequests().remove(Integer.valueOf(senderClientID));
				return;
			}

			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.SERVER_MESSAGE_INFO.id);
			payload.writeBytes("Something went wrong while trying to decline chat request!".getBytes());
			channel.writeAndFlush(payload);
		}
		case DELETE_CHAT_SESSION -> {
			
			int chatSessionID;
			
			{
				int chatSessionIndex = args.readInt();
				chatSessionID = clientInfo.getChatSessions().get(chatSessionIndex).getChatSessionID();
			}

			boolean success;
			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				success = conn.deleteChatSession(chatSessionID);
			}

			if (success) {
				ChatSession chatSession = ActiveChatSessions.getChatSession(chatSessionID);

				if (chatSession != null) {

					List<ClientInfo> activeMembers = chatSession.getActiveMembers();
					for (int i = 0; i < activeMembers.size(); i++) {
						activeMembers.get(i).getChatSessions().remove(chatSession);
					}

					ActiveChatSessions.removeChatSession(chatSessionID);
				}
			} else {
				ByteBuf payload = channel.alloc().ioBuffer();
				payload.writeInt(ServerMessageType.SERVER_MESSAGE_INFO.id);
				payload.writeBytes("Something went wrong while trying delete chat session!".getBytes());
				channel.writeAndFlush(payload);
			}
		}
		case DELETE_CHAT_MESSAGE -> {
			int chatSessionID;

			{
				int chatSessionIndex = args.readInt();
				chatSessionID = clientInfo.getChatSessions().get(chatSessionIndex).getChatSessionID();
			}

			final int messagesAmount = args.readableBytes() / Integer.BYTES;

			if (messagesAmount == 0) {
				break;
			}

			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
			payload.writeInt(ClientCommandResultType.DELETE_CHAT_MESSAGE.id);
			payload.writeInt(chatSessionID);

			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				for (int i = 0; i < messagesAmount; i++) {
					int messagesID = args.readInt();
					boolean success = conn.deleteChatMessage(chatSessionID, messagesID);
					payload.writeInt(messagesID);
					payload.writeBoolean(success);
				}
			}

			/**
			 * 
			 * Alternative approach:
			 * 
			 * The following approach is perhaps more efficient from certain aspects but
			 * still unsure. Specifically, it is more efficient in terms of database
			 * connection usage (releasing connection sooner), but, on the other hand, it
			 * requires more memory for storing results in arrays before transmitting.
			 * 
			 * <pre>
			 * int[] messages = new int[messagesAmount];
			 * boolean[] success = new boolean[messagesAmount];
			 * 
			 * // Process deletions first, release DB connection ASAP try
			 * try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
			 * 	for (int i = 0; i < messagesAmount; i++) {
			 * 		messages[i] = args.readInt();
			 * 		success[i] = conn.deleteChatMessage(chatSessionID, messages[i]);
			 * 	}
			 * }
			 * // Connection is now freed
			 * 
			 * // Allocate buffer only after DB connection is released
			 * ByteBuf payload = channel.alloc().ioBuffer();
			 * payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
			 * payload.writeInt(ClientCommandResultType.DELETE_CHAT_MESSAGE.id);
			 * payload.writeInt(chatSessionID);
			 * 
			 * for (int i = 0; i < messagesAmount; i++) {
			 * 	payload.writeInt(messages[i]);
			 * 	payload.writeBoolean(success[i]);
			 * }
			 * </pre>
			 * 
			 */

			ActiveChatSessions.broadcastToChatSession(payload, ActiveChatSessions.getChatSession(chatSessionID));
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
				getLogger().debug(String.format("Address not recognized %s", new String(addressBytes)), uhe);
				MessageByteBufCreator.sendMessageInfo(channel, "Address not recognized!");
				return;
			}

			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				conn.logout(address, clientInfo.getClientID());
			}

			// Search for the specific IP address and if found logout that address
			forActiveAccounts(clientInfo.getClientID(), (ClientInfo ci) -> {
				if (!ci.getInetAddress().equals(address)) {
					return;
				}
				
				ci.getChannel().close();
			});

			forActiveAccounts(clientInfo.getClientID(), (ClientInfo ci) -> {
				executeCommand(clientInfo, ClientCommandType.FETCH_LINKED_DEVICES, Unpooled.EMPTY_BUFFER);
			});
		}
		case LOGOUT_ALL_DEVICES -> {
			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				conn.logoutAllDevices(clientInfo.getClientID());
			}

			// Close all channels associated with this client id
			forActiveAccounts(clientInfo.getClientID(), (ClientInfo ci) -> {
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
		case FETCH_LINKED_DEVICES -> {
			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
			payload.writeInt(ClientCommandResultType.FETCH_LINKED_DEVICES.id);
			
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
			
			byte[] passwordBytes = new byte[args.readInt()];
			args.readBytes(passwordBytes);
			
			String email = new String(emailAddress);
			
			if (email.equals(clientInfo.getEmail())) {
				MessageByteBufCreator.sendMessageInfo(channel, "Incorrect email");
			}
			
//			channel.pipeline().addLast(VerificationHandler.class.getName(), new VerificationHandler(clientInfo, email) {
//				
//				@Override
//				public EntryResult executeWhenVerificationSuccessful() throws IOException {
//
//					String password = new String(passwordBytes);
//
//					int resultUpdate;
//					try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
//						resultUpdate = conn.deleteAccount(email, new String(password), clientInfo.getClientID());
//					}
//					
//					if (resultUpdate == 1) {
//						channel.close();
//						return null;
//					}
//					
//					MessageByteBufCreator.sendMessageInfo(channel, "An error occured while trying to delete your account");
//					return null;
//				}
//				
//				@Override
//				public String createEmailMessage(String account, String generatedVerificationCode) {
//					return ServerSettings.EmailCreator.Verification.DeleteAccount.createEmail(email, account, generatedVerificationCode);
//				}
//			});

		}
		case SET_ACCOUNT_ICON -> {
			
			byte[] icon = new byte[args.readableBytes()];
			args.readBytes(icon);
			
			int resultUpdate;
			
			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				resultUpdate = conn.setProfilePhoto(clientInfo.getClientID(), icon);
			}
			
			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
			payload.writeInt(ClientCommandResultType.SET_ACCOUNT_ICON.id);
			payload.writeBoolean(resultUpdate == 1);
			
			channel.writeAndFlush(payload);
		}
		case ADD_NEW_ACCOUNT, SWITCH_ACCOUNT -> {
			// Check if handler is already present in the pipeline
			ChannelHandler handler = channel.pipeline().get(StartingEntryHandler.class);
			if (handler != null) {
				return; // Handler already exists, so no need to add it again
			}

			// If handler doesn't exist, add it to the pipeline
			channel.pipeline().addLast(StartingEntryHandler.class.getName(), new StartingEntryHandler());
		}
		case FETCH_ACCOUNT_ICON -> {
			
			Optional<byte[]> optionalIcon;
			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				optionalIcon = conn.selectUserIcon(clientInfo.getClientID());
			}
			
			optionalIcon.ifPresentOrElse((byte[] icon) -> {
				ByteBuf payload = channel.alloc().ioBuffer();
				payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
				payload.writeInt(ClientCommandResultType.FETCH_ACCOUNT_ICON.id);
				payload.writeBytes(icon);
				channel.writeAndFlush(payload);
			}, () -> {
				ByteBuf payload = channel.alloc().ioBuffer();
				payload.writeInt(ServerMessageType.SERVER_MESSAGE_INFO.id);
				payload.writeBytes("An error occured while trying to fetch profile photo from database!".getBytes());
				channel.writeAndFlush(payload);
			});
		}
		case FETCH_WRITTEN_TEXT -> {
			
			int chatSessionIndex = args.readInt();
			int chatSessionID = clientInfo.getChatSessions().get(chatSessionIndex).getChatSessionID();

			int numOfMessagesAlreadySelected = args.readInt();
			
			UserMessage[] messages;
			
			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				messages = conn.selectMessages(chatSessionID, numOfMessagesAlreadySelected, ServerSettings.NUMBER_OF_MESSAGES_TO_READ_FROM_THE_DATABASE_AT_A_TIME);
			}
			
			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
			payload.writeInt(ClientCommandResultType.GET_WRITTEN_TEXT.id);
			payload.writeInt(chatSessionIndex);

			for (int i = 0; i < messages.length; i++) {

				UserMessage message = messages[i];
				byte[] messageBytes = message.getText();
				byte[] fileNameBytes = message.getFileName();
				byte[] usernameBytes = message.getUsername().getBytes();
				long timeWritten = message.getTimeWritten();
				ClientContentType contentType = message.getContentType();
				
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
					List<Integer> memberIDS = chatSession.getMembers();

					payload.writeInt(chatSessionID);

					// The one that is subtracted is attributed to the user inquring this command
					payload.writeInt(memberIDS.size() - 1);
					try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
						for (int j = 0; j < memberIDS.size(); j++) {

							int clientID = memberIDS.get(j);

							boolean isActive;
							List<ClientInfo> member = ActiveClients.getClient(clientID);

							byte[] usernameBytes;
							byte[] iconBytes = conn.selectUserIcon(clientID).orElse(EmptyArrays.EMPTY_BYTE_ARRAY);

							if (member == null) {
								usernameBytes = conn.getUsername(clientID).orElse("null").getBytes();
								isActive = false;
							} else {
								ClientInfo random = member.get(0);
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

					if (!chatSession.getActiveMembers().contains(clientInfo)) {
						chatSession.getActiveMembers().add(clientInfo);
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
				Account account = accounts[i];

				if (account.clientID() == clientInfo.getClientID()) {
					continue;
				}
				
				payload.writeInt(account.clientID());
				
				String email = account.email();
				payload.writeInt(email.length());
				payload.writeBytes(email.getBytes());
				
				String displayName = account.displayName();
				payload.writeInt(displayName.length());
				payload.writeBytes(displayName.getBytes());
				
				byte[] profilePhoto = account.profilePhoto();
				payload.writeInt(profilePhoto.length);
				payload.writeBytes(profilePhoto);
			}
			
			channel.writeAndFlush(payload);
		}
		case ACCEPT_VOICE_CALL -> {
		}
		case START_VOICE_CALL -> {
			int chatSessionIndex = args.readInt();
			int chatSessionID = clientInfo.getChatSessions().get(chatSessionIndex).getChatSessionID();
			VoiceChat voiceChat = ServerUDP.createVoiceChat(chatSessionID);

			{
				ByteBuf payload = channel.alloc().ioBuffer();
				payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
				payload.writeInt(ClientCommandResultType.START_VOICE_CALL.id);
				payload.writeInt(ServerSettings.UDP_PORT);
				payload.writeInt(voiceChat.key());
//				payload.writeBytes(voiceChat.aesKey().getSecretKeyEncoded());
				channel.writeAndFlush(payload);
			}

			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.VOICE_CALL_INCOMING.id);
			payload.writeInt(ServerSettings.UDP_PORT);
			payload.writeInt(chatSessionID);
			payload.writeInt(voiceChat.key());
			payload.writeInt(clientInfo.getClientID());
//			payload.writeBytes(voiceChat.aesKey().getSecretKeyEncoded());

			for (ClientInfo activeMember : clientInfo.getChatSessions().get(chatSessionIndex).getActiveMembers()) {
				if (activeMember.getClientID() == clientInfo.getClientID()) {
					continue;
				}
				
				activeMember.getChannel().writeAndFlush(payload);
			}

			getLogger().debug("Voice chat added");
		}
		case REQUEST_DONATION_PAGE_URL -> {
			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
			payload.writeInt(ClientCommandResultType.GET_DONATION_PAGE.id);
			payload.writeBytes(ServerSettings.Donations.DONATION_HTML_PAGE_URL.getBytes());

			channel.writeAndFlush(payload);
		}
		case REQUEST_SOURCE_CODE_PAGE_URL -> {
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
	
	/**
	 * Executes a given action for every active device associated with the specified account/clientID.
	 *
	 * @param clientID the ID of the account whose active devices are to be processed
	 * @param action the operation to perform on each active device
	 */
	private static void forActiveAccounts(int clientID, Consumer<ClientInfo> action) {
		List<ClientInfo> activeClients =  ActiveClients.getClient(clientID);
		
		if (activeClients == null) {
			return;
		}
		
		for (ClientInfo clientInfo : activeClients) {
			action.accept(clientInfo);
		}
	}

	public static void refreshChatSession(ChatSession chatSession) {
		List<ClientInfo> activeMembers = chatSession.getActiveMembers();
		for (int i = 0; i < activeMembers.size(); i++) {
			executeCommand(activeMembers.get(i), ClientCommandType.FETCH_CHAT_SESSIONS, Unpooled.EMPTY_BUFFER);
		}
	}

}
