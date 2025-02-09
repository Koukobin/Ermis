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
package github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database;

import java.util.Arrays;
import java.util.Objects;

import github.koukobin.ermis.common.message_types.ClientContentType;

/**
 * @author Ilias Koukovinis
 *
 */
public class DatabaseChatMessage {

	private int clientID;
	private int chatSessionID;

	private byte[] text;
	
	private byte[] fileName;
	private byte[] fileBytes;
	
	private boolean isRead;
	
	private ClientContentType contentType;
	
	public DatabaseChatMessage() {}

	public DatabaseChatMessage(int clientID, int chatSessionID, byte[] text, byte[] fileName, byte[] fileBytes, boolean isRead, ClientContentType contentType) {
		this.clientID = clientID;
		this.chatSessionID = chatSessionID;
		this.text = text;
		this.fileName = fileName;
		this.fileBytes = fileBytes;
		this.isRead = isRead;
		this.contentType = contentType;
	}

	public void setClientID(int clientID) {
		this.clientID = clientID;
	}
	
	public void setChatSessionID(int chatSessionID) {
		this.chatSessionID = chatSessionID;
	}
	
	public void setText(byte[] text) {
		this.text = text;
	}
	
	public void setFileName(byte[] fileName) {
		this.fileName = fileName;
	}
	
	public void setFileBytes(byte[] fileBytes) {
		this.fileBytes = fileBytes;
	}
	
	public void setIsRead(boolean isRead) {
		this.isRead = isRead;
	}
	
	public void setContentType(ClientContentType contentType) {
		this.contentType = contentType;
	}

	public int getClientID() {
		return clientID;
	}

	public int getChatSessionID() {
		return chatSessionID;
	}

	public byte[] getText() {
		return text;
	}

	public byte[] getFileName() {
		return fileName;
	}

	public byte[] getFileBytes() {
		return fileBytes;
	}
	
	public boolean isRead() {
		return isRead;
	}
	
	public ClientContentType getContentType() {
		return contentType;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + Arrays.hashCode(fileBytes);
		result = prime * result + Arrays.hashCode(fileName);
		result = prime * result + Arrays.hashCode(text);
		result = prime * result + Objects.hash(chatSessionID, clientID, contentType, isRead);
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj) {
			return true;
		}

		if (obj == null) {
			return false;
		}

		if (getClass() != obj.getClass()) {
			return false;
		}

		DatabaseChatMessage other = (DatabaseChatMessage) obj;
		return chatSessionID == other.chatSessionID 
				&& clientID == other.clientID 
				&& contentType == other.contentType
				&& Arrays.equals(fileBytes, other.fileBytes) 
				&& Arrays.equals(fileName, other.fileName)
				&& isRead == other.isRead 
				&& Arrays.equals(text, other.text);
	}

	@Override
	public String toString() {
		return "DatabaseChatMessage ["
				+ "clientID=" + clientID +
				", chatSessionID=" + chatSessionID +
				", text=" + Arrays.toString(text)
				+ ", fileName=" + Arrays.toString(fileName)
				+ ", fileBytes=" + Arrays.toString(fileBytes)
				+ ", isRead=" + isRead
				+ ", contentType=" + contentType
				+ "]";
	}
	
}
