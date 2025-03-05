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

import java.util.List;

import github.koukobin.ermis.client.main.java.MESSAGE;
import github.koukobin.ermis.client.main.java.service.client.ChatSession.Member;
import github.koukobin.ermis.common.Account;
import github.koukobin.ermis.common.LoadedInMemoryFile;
import github.koukobin.ermis.common.UserDeviceInfo;
import github.koukobin.ermis.common.message_types.MessageDeliveryStatus;
import io.netty.buffer.ByteBuf;

/**
 * @author Ilias Koukovinis
 *
 */

public final class Events {

	private Events() {}

	/** Tagging interface */
	public interface IMessage {}
	
	public static class EntryMessage implements IMessage {
        private final ByteBuf buffer;
        public EntryMessage(ByteBuf buffer) { this.buffer = buffer; }
        public ByteBuf getBuffer() { return buffer; }
    }

	public static class UsernameReceivedEvent implements IMessage {
		private final String displayName;
        public UsernameReceivedEvent(String displayName) { this.displayName = displayName; }
        public String getDisplayName() { return displayName; }
    }

    public static class MessageReceivedEvent implements IMessage {
        private final MESSAGE message;
        private final ChatSession chatSession;
        public MessageReceivedEvent(MESSAGE message, ChatSession chatSession) {
            this.message = message;
            this.chatSession = chatSession;
        }
        public MESSAGE getMessage() { return message; }
        public ChatSession getChatSession() { return chatSession; }
    }

    public static class MessageDeliveryStatusEvent implements IMessage {
        private final MessageDeliveryStatus deliveryStatus;
        private final MESSAGE message;
        public MessageDeliveryStatusEvent(MessageDeliveryStatus deliveryStatus, MESSAGE message) {
            this.deliveryStatus = deliveryStatus;
            this.message = message;
        }
        public MessageDeliveryStatus getDeliveryStatus() { return deliveryStatus; }
        public MESSAGE getMessage() { return message; }
    }

    public static class WrittenTextEvent implements IMessage {
        private final ChatSession chatSession;
        public WrittenTextEvent(ChatSession chatSession) { this.chatSession = chatSession; }
        public ChatSession getChatSession() { return chatSession; }
    }

    public static class ServerMessageInfoEvent implements IMessage {
        private final String message;
        public ServerMessageInfoEvent(String message) { this.message = message; }
        public String getMessage() { return message; }
    }

    public static class FileDownloadedEvent implements IMessage {
        private final LoadedInMemoryFile file;
        public FileDownloadedEvent(LoadedInMemoryFile file) { this.file = file; }
        public LoadedInMemoryFile getFile() { return file; }
    }

    public static class ImageDownloadedEvent implements IMessage {
        private final LoadedInMemoryFile file;
        private final int messageID;
        public ImageDownloadedEvent(LoadedInMemoryFile file, int messageID) {
            this.file = file;
            this.messageID = messageID;
        }
        public LoadedInMemoryFile getFile() { return file; }
        public int getMessageID() { return messageID; }
    }

    public static class ClientIdEvent implements IMessage {
        private final int clientId;
        public ClientIdEvent(int clientId) { this.clientId = clientId; }
        public int getClientId() { return clientId; }
    }

    public static class ChatRequestsEvent implements IMessage {
        private final List<ChatRequest> requests;
        public ChatRequestsEvent(List<ChatRequest> requests) { this.requests = requests; }
        public List<ChatRequest> getRequests() { return requests; }
    }

    public static class ChatSessionsEvent implements IMessage {
        private final List<ChatSession> sessions;
        public ChatSessionsEvent(List<ChatSession> sessions) { this.sessions = sessions; }
        public List<ChatSession> getSessions() { return sessions; }
    }

    public static class OtherAccountsEvent implements IMessage {
        private final List<Account> accounts;
        public OtherAccountsEvent(List<Account> accounts) { this.accounts = accounts; }
        public List<Account> getAccounts() { return accounts; }
    }

    public static class ProfilePhotoEvent implements IMessage {
        private final byte[] photoBytes;
        public ProfilePhotoEvent(byte[] photoBytes) { this.photoBytes = photoBytes; }
        public byte[] getPhotoBytes() { return photoBytes; }
    }
    
    public static class DonationPageEvent implements IMessage {
        private final String donationPageURL;
        public DonationPageEvent(String donationPageURL) { this.donationPageURL = donationPageURL; }
        public String getDonationPageURL() { return donationPageURL; }
    }
    
    public static class SourceCodePageEvent implements IMessage {
        private final String sourceCodePageURL;
        public SourceCodePageEvent(String sourceCodePageURL) { this.sourceCodePageURL = sourceCodePageURL; }
        public String getSourceCodePageURL() { return sourceCodePageURL; }
    }
    
    public static class ServerSourceCodeEvent implements IMessage {
        private final String sourceCodeUrl;
        public ServerSourceCodeEvent(String sourceCodeUrl) { this.sourceCodeUrl = sourceCodeUrl; }
        public String getSourceCodeUrl() { return sourceCodeUrl; }
    }
    
    public static class VoiceCallIncomingEvent implements IMessage {
        private final int chatSessionID;
        private final int chatSessionIndex;
        private final int voiceCallKey;
        private final int udpServerPort;
        private final Member member;
        public VoiceCallIncomingEvent(int chatSessionID, int chatSessionIndex, int voiceCallKey, Member member, int udpServerPort) {
            this.chatSessionID = chatSessionID;
            this.chatSessionIndex = chatSessionIndex;
            this.voiceCallKey = voiceCallKey;
            this.member = member;
            this.udpServerPort = udpServerPort;
        }
        public int getChatSessionID() { return chatSessionID; }
        public int getChatSessionIndex() { return chatSessionIndex; }
        public int getVoiceCallKey() { return voiceCallKey; }
        public Member getMember() { return member; }
        public int getUdpServerPort() { return udpServerPort; }
    }
    
    public static class StartVoiceCallResultEvent implements IMessage {
        private final int key;
        private final int udpServerPort;

        public StartVoiceCallResultEvent(int key, int udpServerPort) {
            this.key = key;
            this.udpServerPort = udpServerPort;
        }

        public int getKey() {
            return key;
        }

        public int getUdpServerPort() {
            return udpServerPort;
        }
    }

    public static class MessageDeletionUnsuccessfulEvent implements IMessage {
        public MessageDeletionUnsuccessfulEvent() {}
    }

    public static class MessageDeletedEvent implements IMessage {
        private final ChatSession chatSession;
        private final int messageId;

        public MessageDeletedEvent(ChatSession chatSession, int messageId) {
            this.chatSession = chatSession;
            this.messageId = messageId;
        }

        public ChatSession getChatSession() {
            return chatSession;
        }

        public int getMessageID() {
            return messageId;
        }
    }

    public static class AddProfilePhotoResultEvent implements IMessage {
        private final boolean success;

        public AddProfilePhotoResultEvent(boolean success) {
            this.success = success;
        }

        public boolean isSuccess() {
            return success;
        }
    }

    public static class UserDevicesEvent implements IMessage {
        private final List<UserDeviceInfo> devices;

        public UserDevicesEvent(List<UserDeviceInfo> devices) {
            this.devices = devices;
        }

        public List<UserDeviceInfo> getDevices() {
            return devices;
        }
    }

}
