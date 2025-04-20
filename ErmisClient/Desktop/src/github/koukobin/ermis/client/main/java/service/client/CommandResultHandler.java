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
package github.koukobin.ermis.client.main.java.service.client;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import github.koukobin.ermis.client.main.java.MESSAGE;
import github.koukobin.ermis.client.main.java.service.client.ChatSession.Member;
import github.koukobin.ermis.client.main.java.service.client.io_client.Client;
import github.koukobin.ermis.client.main.java.service.client.io_client.MessageHandler.I;
import github.koukobin.ermis.common.LoadedInMemoryFile;
import github.koukobin.ermis.common.message_types.ClientCommandResultType;
import github.koukobin.ermis.common.message_types.ClientContentType;
import github.koukobin.ermis.common.message_types.MessageDeliveryStatus;
import io.netty.buffer.ByteBuf;

/**
 * @author Ilias Koukovinis
 *
 */
public class CommandResultHandler implements MESSAGEHandler {

	@Override
	public void handleMessage(ByteBuf msg) {
		ClientCommandResultType commandResult = ClientCommandResultType.fromId(msg.readInt());

		switch (commandResult) {
		case DOWNLOAD_FILE -> {
			byte[] fileNameBytes = new byte[msg.readInt()];
			msg.readBytes(fileNameBytes);

			byte[] fileBytes = new byte[msg.readableBytes()];
			msg.readBytes(fileBytes);

			GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.FileDownloadedEvent(new LoadedInMemoryFile(new String(fileNameBytes), fileBytes)));
		}
		case DOWNLOAD_IMAGE -> {
			int messageID = msg.readInt();
			int fileNameLength = msg.readInt();

			byte[] fileNameBytes = new byte[msg.readInt()];
			msg.readBytes(fileNameBytes);

			byte[] fileBytes = new byte[msg.readableBytes()];
			msg.readBytes(fileBytes);

			GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.ImageDownloadedEvent(new LoadedInMemoryFile(new String(fileNameBytes), fileBytes), messageID));
		}
		case DOWNLOAD_VOICE -> {
			int messageID = msg.readInt();

			byte[] fileNameBytes = new byte[msg.readInt()];
			msg.readBytes(fileNameBytes);

			byte[] fileBytes = new byte[msg.readableBytes()];
			msg.readBytes(fileBytes);

			GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.VoiceDownloadedEvent(new LoadedInMemoryFile(new String(fileNameBytes), fileBytes), messageID));
		}
		case FETCH_PROFILE_INFO -> {
			I.clientID = msg.readInt();
			GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.ClientIdEvent(I.clientID));

			byte[] usernameBytes = new byte[msg.readInt()];
			msg.readBytes(usernameBytes);

			I.username = new String(usernameBytes);

			GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.UsernameReceivedEvent(I.username));

			long lastUpdatedEpochSecond = msg.readLong();

			byte[] profilePhoto = new byte[msg.readableBytes()];
			msg.readBytes(profilePhoto);
			I.accountIcon = profilePhoto;
		}
		case GET_DISPLAY_NAME -> {
			byte[] usernameBytes = new byte[msg.readableBytes()];
			msg.readBytes(usernameBytes);

			I.username = new String(usernameBytes);

			GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.UsernameReceivedEvent(I.username));
		}
		case GET_CLIENT_ID -> {
			I.clientID = msg.readInt();
			GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.ClientIdEvent(I.clientID));
		}
		case GET_CHAT_SESSIONS_INDICES -> {
			I.chatSessions = new ArrayList<>();

			int i = 0;
			while (msg.readableBytes() > 0) {
				int chatSessionIndex = i;
				int chatSessionID = msg.readInt();

				ChatSession chatSession = I.chatSessionIDSToChatSessions.get(chatSessionID);
				if (chatSession == null) {
					chatSession = new ChatSession(chatSessionID, chatSessionIndex);
					I.chatSessionIDSToChatSessions.put(chatSessionID, chatSession);
				} else {
					chatSession.setChatSessionIndex(chatSessionIndex);
				}

				I.chatSessions.add(chatSession);

				i++;
			}

	        GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.ChatSessionsIndicesReceivedEvent(I.chatSessions));

			try {
				Client.getCommands().fetchChatSessions(); // Proceed to fetching chat sessions
			} catch (IOException ioe) {
				ioe.printStackTrace();
			}
		}
		case GET_CHAT_SESSIONS -> {
			Map<Integer /* client id */, Member> cache = new HashMap<>();

			while (msg.readableBytes() > 0) {
				int chatSessionIndex = msg.readInt();
				ChatSession chatSession;

				try {
					chatSession = I.chatSessions.get(chatSessionIndex);
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

					I.chatSessions.remove(chatSessionIndex);
					I.chatSessionIDSToChatSessions.remove(chatSession.getChatSessionID());

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

			GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.ChatSessionsEvent(I.chatSessions));
		}
		case GET_CHAT_SESSIONS_STATUSES -> {
	        // Do nothing.
		}
		case GET_CHAT_REQUESTS -> {
			I.chatRequests.clear();

			int friendRequestsLength = msg.readInt();

			for (int i = 0; i < friendRequestsLength; i++) {
				int clientID = msg.readInt();
				I.chatRequests.add(new ChatRequest(clientID));
			}

			GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.ChatRequestsEvent(I.chatRequests));
		}
		case GET_WRITTEN_TEXT -> {
			ChatSession chatSession;

			int chatSessionIndex = msg.readInt();
			chatSession = I.chatSessions.get(chatSessionIndex);

			List<MESSAGE> messages = chatSession.getMessages();
			while (msg.readableBytes() > 0) {
				ClientContentType contentType = ClientContentType.fromId(msg.readInt());

				int clientID = msg.readInt();
				int messageID = msg.readInt();

				String username;
				{
					byte[] usernameBytes = new byte[msg.readInt()];
					msg.readBytes(usernameBytes);

					username = new String(usernameBytes);
				}

				byte[] messageBytes = null;
				byte[] fileNameBytes = null;

				long epochSecond = msg.readLong();

				boolean isRead;
				if (clientID == Client.getClientID()) {
					isRead = msg.readBoolean();
				} else {
					isRead = true;
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
					MESSAGE message = new MESSAGE(
							username, 
							clientID, 
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
			
			messages.sort(Comparator.comparing(MESSAGE::getMessageID));
			
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
			I.accountIcon = new byte[msg.readableBytes()];
			
			if (I.accountIcon.length > 0) {
				msg.readBytes(I.accountIcon);
				
	            GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.ProfilePhotoEvent(I.accountIcon));
			}
		}
		case SET_ACCOUNT_ICON -> {
			boolean isSuccessful = msg.readBoolean();
			if (!isSuccessful) {
				break;
			}

//			I.accountIcon = Commands. pendingAccountIcon;
			// TODO
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


	            GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.MessageDeletedEvent(I.chatSessionIDSToChatSessions.get(chatSessionID), messageID));
			}
		}
		}

	}

}
