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
package github.koukobin.ermis.client.main.java.service.client.models;

import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.Objects;

import github.koukobin.ermis.common.message_types.ClientContentType;
import github.koukobin.ermis.common.message_types.MessageDeliveryStatus;

/**
 * @author Ilias Koukovinis
 *
 */
public final class Message {

	private String username;
	private int clientID;
	private int messageID;
	private int chatSessionID;
	private int chatSessionIndex;
	private byte[] text;
	private byte[] fileName;
	private long epochSecond;
	private ClientContentType contentType;
	private MessageDeliveryStatus deliveryStatus;

    public Message(String username,
    		int clientID,
    		int messageID,
    		int chatSessionID,
    		int chatSessionIndex,
			byte[] text,
			byte[] fileName,
			long epochSecond,
			ClientContentType contentType,
			MessageDeliveryStatus deliveryStatus) {
        this.username = username;
        this.clientID = clientID;
        this.messageID = messageID;
        this.chatSessionID = chatSessionID;
        this.chatSessionIndex = chatSessionIndex;
        this.text = text;
        this.fileName = fileName;
        this.epochSecond = epochSecond;
        this.contentType = contentType;
        this.deliveryStatus = deliveryStatus;
    }

	public Message() {
		this.username = "";
		this.clientID = 0;
		this.messageID = 0;
		this.chatSessionID = 0;
		this.chatSessionIndex = 0;
		this.text = null;
		this.fileName = null;
		this.epochSecond = 0;
		this.contentType = ClientContentType.TEXT; // Assuming a default value
		this.deliveryStatus = MessageDeliveryStatus.SENDING;
	}

	// Setters
	public void setUsername(String username) {
		this.username = username;
	}

	public void setDeliveryStatus(MessageDeliveryStatus deliveryStatus) {
		this.deliveryStatus = deliveryStatus;
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
        this.text = text;
    }

    public void setFileName(byte[] fileName) {
        this.fileName = fileName;
    }

    public void setEpochSecond(long epochSecond) {
        this.epochSecond = epochSecond;
    }

    public void setContentType(ClientContentType contentType) {
        this.contentType = contentType;
    }

    // Getters
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

    public String getText() {
        return text == null ? "" : new String(text, StandardCharsets.UTF_8);
    }

    public String getFileName() {
        return fileName == null ? "" : new String(fileName, StandardCharsets.UTF_8);
    }

    public long getEpochSecond() {
        return epochSecond;
	}

	public ClientContentType getContentType() {
		return contentType;
	}

	public MessageDeliveryStatus getDeliveryStatus() {
		return deliveryStatus;
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

		if (obj == null) {
			return false;
		}

		if (obj.getClass() != Message.class) {
			return false;
		}

		Message other = (Message) obj;
        return chatSessionID == other.chatSessionID &&
               chatSessionIndex == other.chatSessionIndex &&
               clientID == other.clientID &&
               contentType == other.contentType &&
               messageID == other.messageID &&
               Arrays.equals(text, other.text) &&
               Arrays.equals(fileName, other.fileName) &&
               epochSecond == other.epochSecond &&
               Objects.equals(username, other.username);
    }

    @Override
    public String toString() {
        return "Message{" +
                "username='" + username + '\'' +
                ", clientID=" + clientID +
                ", messageID=" + messageID +
                ", chatSessionID=" + chatSessionID +
                ", chatSessionIndex=" + chatSessionIndex +
                ", text=" + (text == null ? "null" : new String(text, StandardCharsets.UTF_8)) +
                ", fileName=" + (fileName == null ? "null" : new String(fileName, StandardCharsets.UTF_8)) +
                ", epochSecond=" + epochSecond +
                ", contentType=" + contentType +
                ", deliveryStatus=" + deliveryStatus +
                '}';
    }
}
