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
package github.koukobin.ermis.desktop_client.main.java.service.client.handlers;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import github.koukobin.ermis.common.LoadedInMemoryFile;
import github.koukobin.ermis.common.message_types.ClientCommandResultType;
import github.koukobin.ermis.common.message_types.ClientContentType;
import github.koukobin.ermis.common.message_types.MessageDeliveryStatus;
import github.koukobin.ermis.desktop_client.main.java.service.client.Client;
import github.koukobin.ermis.desktop_client.main.java.service.client.Events;
import github.koukobin.ermis.desktop_client.main.java.service.client.GlobalMessageDispatcher;
import github.koukobin.ermis.desktop_client.main.java.service.client.UserInfoManager;
import github.koukobin.ermis.desktop_client.main.java.service.client.models.ChatRequest;
import github.koukobin.ermis.desktop_client.main.java.service.client.models.ChatSession;
import github.koukobin.ermis.desktop_client.main.java.service.client.models.Message;
import github.koukobin.ermis.desktop_client.main.java.service.client.models.ChatSession.Member;
import io.netty.buffer.ByteBuf;

/**
 * @author Ilias Koukovinis
 *
 */
public class CommandResultHandler implements MessageHandler {

	private static final Logger logger = LoggerFactory.getLogger(CommandResultHandler.class);
	
	@Override
	public void handleMessage(ByteBuf msg) {
		ClientCommandResultType commandResult = ClientCommandResultType.fromId(msg.readInt());

		switch (commandResult) {
		case DOWNLOAD_FILE -> {
			int chatSessionID = msg.readInt();
			int messageID = msg.readInt();

			byte[] fileNameBytes = new byte[msg.readInt()];
			msg.readBytes(fileNameBytes);

			byte[] fileBytes = new byte[msg.readableBytes()];
			msg.readBytes(fileBytes);

			GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.FileDownloadedEvent(new LoadedInMemoryFile(new String(fileNameBytes), fileBytes)));
		}
		case DOWNLOAD_IMAGE -> {
			int chatSessionID = msg.readInt();
			int messageID = msg.readInt();

			byte[] fileNameBytes = new byte[msg.readInt()];
			msg.readBytes(fileNameBytes);

			byte[] fileBytes = new byte[msg.readableBytes()];
			msg.readBytes(fileBytes);

			GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.ImageDownloadedEvent(new LoadedInMemoryFile(new String(fileNameBytes), fileBytes), messageID));
		}
		case DOWNLOAD_VOICE -> {
			int chatSessionID = msg.readInt();
			int messageID = msg.readInt();

			byte[] fileNameBytes = new byte[msg.readInt()];
			msg.readBytes(fileNameBytes);

			byte[] fileBytes = new byte[msg.readableBytes()];
			msg.readBytes(fileBytes);

			GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.VoiceDownloadedEvent(new LoadedInMemoryFile(new String(fileNameBytes), fileBytes), messageID));
		}
		case FETCH_PROFILE_INFO -> {
			UserInfoManager.clientID = msg.readInt();
			GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.ClientIdEvent(UserInfoManager.clientID));

			byte[] usernameBytes = new byte[msg.readInt()];
			msg.readBytes(usernameBytes);

			UserInfoManager.username = new String(usernameBytes);

			GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.UsernameReceivedEvent(UserInfoManager.username));

			long lastUpdatedEpochSecond = msg.readLong();

			byte[] profilePhoto = new byte[msg.readableBytes()];
			msg.readBytes(profilePhoto);
			UserInfoManager.accountIcon = profilePhoto;
			
			GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.ReceivedProfilePhotoEvent(UserInfoManager.accountIcon));
		}
		case GET_DISPLAY_NAME -> {
			byte[] usernameBytes = new byte[msg.readableBytes()];
			msg.readBytes(usernameBytes);

			UserInfoManager.username = new String(usernameBytes);

			GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.UsernameReceivedEvent(UserInfoManager.username));
		}
		case GET_CLIENT_ID -> {
			UserInfoManager.clientID = msg.readInt();
			GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.ClientIdEvent(UserInfoManager.clientID));
		}
		case GET_CHAT_SESSIONS_INDICES -> {
			UserInfoManager.chatSessions = new ArrayList<>();

			int i = 0;
			while (msg.readableBytes() > 0) {
				int chatSessionIndex = i;
				int chatSessionID = msg.readInt();

				ChatSession chatSession = UserInfoManager.chatSessionIDSToChatSessions.get(chatSessionID);
				if (chatSession == null) {
					chatSession = new ChatSession(chatSessionID, chatSessionIndex);
					UserInfoManager.chatSessionIDSToChatSessions.put(chatSessionID, chatSession);
				} else {
					chatSession.setChatSessionIndex(chatSessionIndex);
				}

				UserInfoManager.chatSessions.add(chatSession);

				i++;
			}

	        GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.ChatSessionsIndicesReceivedEvent(UserInfoManager.chatSessions));

			try {
				Client.getCommands().fetchChatSessions(); // Proceed to fetching chat sessions
			} catch (IOException ioe) {
				logger.error(ioe.getMessage(), ioe);
			}
		}
		case GET_CHAT_SESSIONS -> {
			Map<Integer /* client id */, Member> cache = new HashMap<>();

			while (msg.readableBytes() > 0) {
				int chatSessionIndex = msg.readInt();
				ChatSession chatSession;

				try {
					chatSession = UserInfoManager.chatSessions.get(chatSessionIndex);
				} catch (IndexOutOfBoundsException ioobe) {
					continue; // This could happen potentially if this chat session had been cached in local
								// database and when the conditional request was it did not know what to do and
								// it sent -1. Outdated chat sessions will be deleted after new chat sessions
								// have been processed
				}

				Set<Member> members = new HashSet<>(chatSession.getMembers());
				int membersSize = msg.readInt();

				if (membersSize == -1) {
					// Infer session has been deleted since membersSize is -1

					UserInfoManager.chatSessions.remove(chatSessionIndex);
					UserInfoManager.chatSessionIDSToChatSessions.remove(chatSession.getChatSessionID());

					continue;
				}

				for (int j = 0; j < membersSize; j++) {
					int memberID = msg.readInt();

					Member member;
					if (cache.containsKey(memberID)) {
						member = cache.get(memberID);
					} else {
						int usernameLength = msg.readInt();
						byte[] usernameBytes = new byte[usernameLength];
						msg.readBytes(usernameBytes);

						byte[] iconBytes = new byte[msg.readInt()];
						msg.readBytes(iconBytes);
						long iconLastUpdatedAt = msg.readLong();

						member = new ChatSession.Member(new String(usernameBytes), memberID, iconBytes);

						cache.put(memberID, member);
					}

					members.add(member);
				}

				chatSession.setMembers(new ArrayList<>(members));
			}

			GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.ChatSessionsEvent(UserInfoManager.chatSessions));
		}
		case GET_CHAT_SESSIONS_STATUSES -> {
	        // Do nothing.
		}
		case GET_CHAT_REQUESTS -> {
			UserInfoManager.chatRequests.clear();

			int friendRequestsLength = msg.readInt();

			for (int i = 0; i < friendRequestsLength; i++) {
				int clientID = msg.readInt();
				UserInfoManager.chatRequests.add(new ChatRequest(clientID));
			}

			GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.ChatRequestsEvent(UserInfoManager.chatRequests));
		}
		case GET_WRITTEN_TEXT -> {
			ChatSession chatSession;

			int chatSessionIndex = msg.readInt();
			chatSession = UserInfoManager.chatSessions.get(chatSessionIndex);

			List<Message> messages = chatSession.getMessages();
			while (msg.readableBytes() > 0) {
				ClientContentType contentType = ClientContentType.fromId(msg.readInt());

				int senderClientID = msg.readInt();
				int messageID = msg.readInt();

				String username;

				byte[] messageBytes = null;
				byte[] fileNameBytes = null;

				long epochSecond = msg.readLong();

				boolean isRead;
				if (senderClientID == Client.getClientID()) {
					isRead = msg.readBoolean();
					username = Client.getDisplayName();
				} else {
					isRead = true;
					username = chatSession.getMembers().stream()
							.filter((Member member) -> member.getClientID() == senderClientID).findFirst()
							.orElseThrow(() -> new NoSuchElementException("Could not find username of member"))
							.getUsername();
				}

				switch (contentType) {
				case TEXT -> {
					messageBytes = new byte[msg.readInt()];
					msg.readBytes(messageBytes);
				}
				case FILE, IMAGE, VOICE -> {
					fileNameBytes = new byte[msg.readInt()];
					msg.readBytes(fileNameBytes);
				}
				}

				if (contentType != null) {
					Message message = new Message(
							username, 
							senderClientID, 
							messageID, 
							chatSession.getChatSessionID(),
							chatSessionIndex,
							messageBytes, 
							fileNameBytes, 
							epochSecond, 
							contentType,
							MessageDeliveryStatus.DELIVERED);
					messages.add(message);
				}
			}
			
			messages.sort(Comparator.comparing(Message::getMessageID));
			
			chatSession.setHaveChatMessagesBeenCached(true);
			GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.WrittenTextEvent(chatSession));
		}
		case GET_DONATION_PAGE_URL -> {
			byte[] donationPageURL = new byte[msg.readableBytes()];
			msg.readBytes(donationPageURL);

			GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.DonationPageEvent(new String(donationPageURL)));
		}
		case GET_SOURCE_CODE_PAGE_URL -> {
			byte[] htmlPageURL = new byte[msg.readableBytes()];
			msg.readBytes(htmlPageURL);

			GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.ServerSourceCodeEvent(new String(htmlPageURL)));
		}
		case FETCH_ACCOUNT_ICON -> {
			UserInfoManager.accountIcon = new byte[msg.readableBytes()];
			
			if (UserInfoManager.accountIcon.length > 0) {
				msg.readBytes(UserInfoManager.accountIcon);
				
	            GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.ReceivedProfilePhotoEvent(UserInfoManager.accountIcon));
			}
		}
		case SET_ACCOUNT_ICON -> {
			boolean isSuccessful = msg.readBoolean();
			if (!isSuccessful) {
				break;
			}

			UserInfoManager.commitPendingProfilePhoto();
			GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.AddProfilePhotoResultEvent(isSuccessful));
		}
		case FETCH_LINKED_DEVICES -> {
			// TODO
		}
		case FETCH_OTHER_ACCOUNTS_ASSOCIATED_WITH_IP_ADDRESS -> {
			// TODO
		}
		case DELETE_CHAT_MESSAGE -> {
			int chatSessionID = msg.readInt();

	        while (msg.readableBytes() > 0) {
	            int messageID = msg.readInt();
	            boolean success = msg.readBoolean();

	            if (!success) {
	              GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.MessageDeletionUnsuccessfulEvent());
	              continue;
	            }


	            GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.MessageDeletedEvent(UserInfoManager.chatSessionIDSToChatSessions.get(chatSessionID), messageID));
			}
		}
		}

	}

}
