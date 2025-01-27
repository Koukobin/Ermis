/* Copyright (C) 2025 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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
package github.koukobin.ermis.client.main.java.database;

import java.util.Arrays;
import java.util.Objects;

import github.koukobin.ermis.common.message_types.ClientContentType;

/**
 * @author Ilias Koukovinis
 *
 */
public class Message {
    private String username;
    private int clientID;
    private int messageID;
    private int chatSessionID;
    private int chatSessionIndex;
    private byte[] text;
    private byte[] fileName;
    private byte[] imageBytes;
    private long timeWritten;
    private ClientContentType contentType;
    private boolean isSent;

    public Message(String username, int clientID, int messageID, int chatSessionID, int chatSessionIndex,
                   byte[] text, byte[] fileName, long timeWritten, ClientContentType contentType, boolean isSent) {
        this.username = username;
        this.clientID = clientID;
        this.messageID = messageID;
        this.chatSessionID = chatSessionID;
        this.chatSessionIndex = chatSessionIndex;
        this.text = text.clone();
        this.fileName = fileName.clone();
        this.timeWritten = timeWritten;
        this.contentType = contentType;
        this.isSent = isSent;
    }

    // Empty constructor with default values
    public Message() {
        this.username = "";
        this.clientID = 0;
        this.messageID = 0;
        this.chatSessionID = 0;
        this.chatSessionIndex = 0;
        this.text = null;
        this.fileName = null;
        this.timeWritten = 0;
        this.contentType = ClientContentType.TEXT; // Assuming default content type
        this.isSent = false;
    }

    public String getText() {
        return text != null ? new String(text) : "";
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public void setIsSent(boolean isSent) {
        this.isSent = isSent;
    }

    public void setClientID(int clientID) {
        this.clientID = clientID;
    }

    public void setMessageID(int messageID) {
        this.messageID = messageID;
    }

    public void setChatSessionID(int chatSessionID) {
        this.chatSessionID = chatSessionID;
    }

    public void setChatSessionIndex(int chatSessionIndex) {
        this.chatSessionIndex = chatSessionIndex;
    }

    public void setText(byte[] text) {
        this.text = text.clone();
    }

    public void setFileName(byte[] fileName) {
        this.fileName = fileName.clone();
    }
    
    public void setImageBytes(byte[] imageBytes) {
    	this.imageBytes = imageBytes.clone();
    }

    public void setTimeWritten(long timeWritten) {
        this.timeWritten = timeWritten;
    }

    public void setContentType(ClientContentType contentType) {
        this.contentType = contentType;
    }

    public String getUsername() {
        return username;
    }

    public int getClientID() {
        return clientID;
    }

    public int getMessageID() {
        return messageID;
    }

    public int getChatSessionID() {
        return chatSessionID;
    }

    public int getChatSessionIndex() {
        return chatSessionIndex;
    }

    public byte[] getFileName() {
        return fileName.clone();
    }

    public byte[] getImageBytes() {
        return imageBytes.clone();
    }
    
    public long getTimeWritten() {
        return timeWritten;
    }

    public ClientContentType getContentType() {
        return contentType;
    }

    public boolean isSent() {
        return isSent;
    }

    @Override
    public int hashCode() {
        return Objects.hash(messageID);
    }

	@Override
	public boolean equals(Object obj) {
		if (this == obj) {
			return true;
		}

		if (obj == null || getClass() != obj.getClass()) {
			return false;
		}

		Message message = (Message) obj;
		return chatSessionID == message.chatSessionID &&
                chatSessionIndex == message.chatSessionIndex &&
                clientID == message.clientID &&
                contentType == message.contentType &&
                messageID == message.messageID &&
                Arrays.equals(text, message.text) &&
                Arrays.equals(fileName, message.fileName) &&
                timeWritten == message.timeWritten &&
                username.equals(message.username);
    }

    @Override
    public String toString() {
        return "Message{" +
                "username='" + username + '\'' +
                ", clientID=" + clientID +
                ", messageID=" + messageID +
                ", chatSessionID=" + chatSessionID +
                ", chatSessionIndex=" + chatSessionIndex +
                ", text=" + Arrays.toString(text) +
                ", fileName=" + Arrays.toString(fileName) +
                ", timeWritten=" + timeWritten +
                ", contentType=" + contentType +
                '}';
    }
}
