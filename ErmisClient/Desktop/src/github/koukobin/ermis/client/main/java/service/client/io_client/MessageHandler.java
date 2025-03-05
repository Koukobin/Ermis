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
package github.koukobin.ermis.client.main.java.service.client.io_client;

import java.io.File;
import java.io.IOException;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

import com.google.common.io.Files;

import github.koukobin.ermis.client.main.java.MESSAGE;
import github.koukobin.ermis.client.main.java.service.client.ChatRequest;
import github.koukobin.ermis.client.main.java.service.client.ChatSession;
import github.koukobin.ermis.client.main.java.service.client.DonationHtmlPage;
import github.koukobin.ermis.common.LoadedInMemoryFile;
import github.koukobin.ermis.common.message_types.ClientCommandResultType;
import github.koukobin.ermis.common.message_types.ClientCommandType;
import github.koukobin.ermis.common.message_types.ClientMessageType;
import github.koukobin.ermis.common.message_types.MessageDeliveryStatus;
import github.koukobin.ermis.common.message_types.ClientContentType;
import github.koukobin.ermis.common.message_types.UserMessage;
import github.koukobin.ermis.common.message_types.ServerMessageType;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;

/**
 * 
 * @author Ilias Koukovinis
 * 
 */
public abstract class MessageHandler implements AutoCloseable {

	private ByteBufInputStream in;
	private ByteBufOutputStream out;

	
	public static class I {
		public static String username;
		public static int clientID;
		public static byte[] accountIcon;
		public static final Map<Integer, ChatSession> chatSessionIDSToChatSessions = new HashMap<>();
		public static final Map<Integer, MESSAGE> pendingMessagesQueue = new HashMap<>();
		public static List<ChatSession> chatSessions = new ArrayList<>();
		public static List<ChatRequest> chatRequests = new ArrayList<>();
	}

	private AtomicBoolean isClientListeningToMessages = new AtomicBoolean(false);
	private Commands commands = new Commands();

	int lastPendingMessageID = 0;

	void setByteBufInputStream(ByteBufInputStream in) {
		this.in = in;
	}

	void setByteBufOutputStream(ByteBufOutputStream out) {
		this.out = out;
	}

	public MESSAGE sendMessageToClient(String text, int chatSessionIndex) throws IOException {
		byte[] textBytes = text.getBytes();

		ByteBuf payload = Unpooled.buffer();
		payload.writeInt(ClientMessageType.CLIENT_CONTENT.id);
		payload.writeInt(++lastPendingMessageID);
		payload.writeInt(ClientContentType.TEXT.id);
		payload.writeInt(chatSessionIndex);
		payload.writeInt(textBytes.length);
		payload.writeBytes(textBytes);

		out.write(payload);
		
		return createPendingMessage(textBytes, null, 
				ClientContentType.TEXT,
				I.chatSessions.get(chatSessionIndex).getChatSessionID(), 
				chatSessionIndex,
				lastPendingMessageID);
	}

	public MESSAGE sendFile(File file, int chatSessionIndex) throws IOException {
		byte[] fileNameBytes = file.getName().getBytes();
		byte[] fileBytes = Files.toByteArray(file);

		ByteBuf payload = Unpooled.buffer();
		payload.writeInt(ClientMessageType.CLIENT_CONTENT.id);
		payload.writeInt(++lastPendingMessageID);
		payload.writeInt(ClientContentType.FILE.id);
		payload.writeInt(chatSessionIndex);
		payload.writeInt(fileNameBytes.length);
		payload.writeBytes(fileNameBytes);
		payload.writeBytes(fileBytes);

		out.write(payload);

		return createPendingMessage(null, 
				fileNameBytes, 
				ClientContentType.FILE,
				I.chatSessions.get(chatSessionIndex).getChatSessionID(), 
				chatSessionIndex,
				lastPendingMessageID);
	}

	public MESSAGE createPendingMessage(byte[] text, 
			byte[] fileName, 
			ClientContentType contentType, 
			int chatSessionID,
			int chatSessionIndex, 
			int tempMessageID) {
		final MESSAGE m = new MESSAGE(
				Client.getDisplayName(),
				Client.getClientID(),
				-1,
				chatSessionID,
				chatSessionIndex,
				text,
             	fileName,
             	Instant.now().getEpochSecond(),
             	contentType,
				MessageDeliveryStatus.SENDING);

		I.pendingMessagesQueue.put(tempMessageID, m);
		return m;
	}

	public abstract void usernameReceived(String username);
	public abstract void messageReceived(MESSAGE message, int chatSessionIndex);
	public abstract void messageSuccesfullySentReceived(MessageDeliveryStatus status, MESSAGE pendingMessage);
	public abstract void alreadyWrittenTextReceived(ChatSession chatSession);
	public abstract void serverMessageReceived(String message);
	public abstract void fileDownloaded(LoadedInMemoryFile file);
	public abstract void imageDownloaded(LoadedInMemoryFile file);
	public abstract void donationPageReceived(String donationPage);
	public abstract void serverSourceCodeReceived(String serverSourceCodeURL);
	public abstract void clientIDReceived(int clientID);
	public abstract void chatRequestsReceived(List<ChatRequest> chatRequests);
	public abstract void chatSessionsReceived(List<ChatSession> chatSessions);
	public abstract void messageDeleted(ChatSession chatSession, int messageIDOfDeletedMessage);
	public abstract void messageUnsuccessfulyDeleted(ChatSession chatSession, int messageID);
	public abstract void iconReceived(byte[] icon);
	
	public class Commands {

		public void changeDisplayName(String newDisplayName) throws IOException {

			byte[] newUsernameBytes = newDisplayName.getBytes();

			ByteBuf payload = Unpooled.buffer();
			payload.writeInt(ClientMessageType.COMMAND.id);
			payload.writeInt(ClientCommandType.CHANGE_USERNAME.id);
			payload.writeBytes(newUsernameBytes);

			out.write(payload);
		}
		
		public void changePassword(String newPassword) throws IOException {
			
			byte[] newPasswordBytes = newPassword.getBytes();

			ByteBuf payload = Unpooled.buffer();
			payload.writeInt(ClientMessageType.COMMAND.id);
			payload.writeInt(ClientCommandType.CHANGE_PASSWORD.id);
			payload.writeBytes(newPasswordBytes);

			out.write(payload);
		}

		public void fetchUsername() throws IOException {
			
			ByteBuf payload = Unpooled.buffer();
			payload.writeInt(ClientMessageType.COMMAND.id);
			payload.writeInt(ClientCommandType.FETCH_USERNAME.id);
			
			out.write(payload);
		}
		
		public void fetchClientID() throws IOException {
			
			ByteBuf payload = Unpooled.buffer(Integer.BYTES * 2);
			payload.writeInt(ClientMessageType.COMMAND.id);
			payload.writeInt(ClientCommandType.FETCH_CLIENT_ID.id);
			
			out.write(payload);
		}
		
		public void fetchWrittenText(int chatSessionIndex) throws IOException {
			
			ByteBuf payload = Unpooled.buffer();
			payload.writeInt(ClientMessageType.COMMAND.id);
			payload.writeInt(ClientCommandType.FETCH_WRITTEN_TEXT.id);
			payload.writeInt(chatSessionIndex);
			payload.writeInt(I.chatSessions.get(chatSessionIndex).getMessages().size() /* Amount of messages client already has */);
			
			out.write(payload);
		}
		
		public void fetchChatRequests() throws IOException {
			
			ByteBuf payload = Unpooled.buffer();
			payload.writeInt(ClientMessageType.COMMAND.id);
			payload.writeInt(ClientCommandType.FETCH_CHAT_REQUESTS.id);

			out.write(payload);
		}
		
		public void fetchChatSessions() throws IOException {

			ByteBuf payload = Unpooled.buffer();
			payload.writeInt(ClientMessageType.COMMAND.id);
			payload.writeInt(ClientCommandType.FETCH_CHAT_SESSIONS.id);

			out.write(payload);
		}
		
		public void requestDonationHTMLPage() throws IOException {

			ByteBuf payload = Unpooled.buffer();
			payload.writeInt(ClientMessageType.COMMAND.id);
			payload.writeInt(ClientCommandType.REQUEST_DONATION_PAGE_URL.id);
			
			out.write(payload);
		}
		
		public void requestServerSourceCodeHTMLPage() throws IOException {
			
			ByteBuf payload = Unpooled.buffer();
			payload.writeInt(ClientMessageType.COMMAND.id);
			payload.writeInt(ClientCommandType.REQUEST_SOURCE_CODE_PAGE_URL.id);
			
			out.write(payload);
		}

		public void sendChatRequest(int userClientID) throws IOException {

			ByteBuf payload = Unpooled.buffer();
			payload.writeInt(ClientMessageType.COMMAND.id);
			payload.writeInt(ClientCommandType.SEND_CHAT_REQUEST.id);
			payload.writeInt(userClientID);
			
			out.write(payload);
		}
		
		public void acceptChatRequest(int userClientID) throws IOException {
			
			ByteBuf payload = Unpooled.buffer();
			payload.writeInt(ClientMessageType.COMMAND.id);
			payload.writeInt(ClientCommandType.ACCEPT_CHAT_REQUEST.id);
			payload.writeInt(userClientID);
			
			out.write(payload);
			
			fetchChatRequests();
			fetchChatSessions();
		}
		
		public void declineChatRequest(int userClientID) throws IOException {
			
			ByteBuf payload = Unpooled.buffer();
			payload.writeInt(ClientMessageType.COMMAND.id);
			payload.writeInt(ClientCommandType.DECLINE_CHAT_REQUEST.id);
			payload.writeInt(userClientID);
			
			out.write(payload);

			fetchChatRequests();
		}
		
		public void deleteChatSession(int chatSessionIndex) throws IOException {
			
			ByteBuf payload = Unpooled.buffer();
			payload.writeInt(ClientMessageType.COMMAND.id);
			payload.writeInt(ClientCommandType.DELETE_CHAT_SESSION.id);
			payload.writeInt(chatSessionIndex);
			
			out.write(payload);
			
			fetchChatSessions();
		}
		
		public void deleteMessage(int chatSessionIndex, int messageID) throws IOException {
			
			ByteBuf payload = Unpooled.buffer();
			payload.writeInt(ClientMessageType.COMMAND.id);
			payload.writeInt(ClientCommandType.DELETE_CHAT_MESSAGE.id);
			payload.writeInt(chatSessionIndex);
			payload.writeInt(messageID);
			
			out.write(payload);
		}
		
		public void downloadFile(int messageID, int chatSessionIndex) throws IOException {

			ByteBuf payload = Unpooled.buffer();
			payload.writeInt(ClientMessageType.COMMAND.id);
			payload.writeInt(ClientCommandType.DOWNLOAD_FILE.id);
			payload.writeInt(chatSessionIndex);
			payload.writeInt(messageID);
			
			out.write(payload);
		}
		
		public void logout() throws IOException {
			
			ByteBuf payload = Unpooled.buffer();
			payload.writeInt(ClientMessageType.COMMAND.id);
			payload.writeInt(ClientCommandType.LOGOUT_THIS_DEVICE.id);
			
			out.write(payload);
		}

		public void addAccountIcon(File accountIcon) throws IOException {
			ByteBuf payload = Unpooled.buffer();
			payload.writeInt(ClientMessageType.COMMAND.id);
			payload.writeInt(ClientCommandType.SET_ACCOUNT_ICON.id);
			payload.writeBytes(Files.toByteArray(accountIcon));
			
			out.write(payload);
		}

		public void fetchAccountIcon() throws IOException {
			
			ByteBuf payload = Unpooled.buffer();
			payload.writeInt(ClientMessageType.COMMAND.id);
			payload.writeInt(ClientCommandType.FETCH_ACCOUNT_ICON.id);		
			out.write(payload);
		}

	}
	
	/**
	 * reads incoming messages sent from the server
	 */
	public void startListeningToMessages() throws IOException {
//		if (isClientListeningToMessages()) {
//			throw new IllegalStateException("Client is already listening to messages!");
//		}
//		
//		isClientListeningToMessages.set(true);
//
//		Thread thread = new Thread("Thread-listenToMessages") {
//			
//			@Override
//			public void run() {
//				while (isClientListeningToMessages()) {
//					try {
//						ByteBuf msg = in.read();
//						ServerMessageType msgType = ServerMessageType.fromId(msg.readInt());
//
//						switch (msgType) {
//						case ENTRY -> {
//							
//						}
//						}
//					} catch (Exception e) {
//						e.printStackTrace();
//					}
//				}
//				
//				isClientListeningToMessages.set(false);
//			}
//		};
//		thread.setDaemon(true);
//		thread.start();
		
		getCommands().fetchUsername();
		getCommands().fetchClientID();
		getCommands().fetchChatSessions();
		getCommands().fetchChatRequests();
		getCommands().fetchAccountIcon();
	}

	public void stopListeningToMessages() {
		if (!isClientListeningToMessages()) {
			throw new IllegalStateException("Client isn't listening to messages to stop listening to messages!");
		}
		
		isClientListeningToMessages.set(false);
	}
	
	public boolean isClientListeningToMessages() {
		return isClientListeningToMessages.get();
	}
	
	public Commands getCommands() {
		return commands;
	}

	public Map<Integer, ChatSession> getChatSessionIDSToChatSessions() {
		return I.chatSessionIDSToChatSessions;
	}

	public List<ChatSession> getChatSessions() {
		return I.chatSessions;
	}

	public List<ChatRequest> getChatRequests() {
		return I.chatRequests;
	}

	public String getUsername() {
		return I.username;
	}

	public int getClientID() {
		return I.clientID;
	}
	
	public byte[] getAccountIcon() {
		return I.accountIcon;
	}

	@Override
	public void close() {
		stopListeningToMessages();
	}
}
