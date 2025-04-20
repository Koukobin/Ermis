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

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.StringJoiner;

import github.koukobin.ermis.client.main.java.MESSAGE;

/**
 * @author Ilias Koukovinis
 *
 */
public class ChatSession {

	public static class Member {

		private String username;
		private int clientID;
		private byte[] icon;

		public Member() {}
		
		public Member(String username, int clientID, byte[] icon) {
			this.username = username;
			this.clientID = clientID;
			this.icon = icon.clone();
		}

		public void setUsername(String username) {
			this.username = username;
		}

		public void setClientID(int clientID) {
			this.clientID = clientID;
		}
		
		public void setIcon(byte[] icon) {
			this.icon = icon.clone();
		}
		
		public String getUsername() {
			return username;
		}

		public int getClientID() {
			return clientID;
		}
		
		public byte[] getIcon() {
			return icon.clone();
		}

		@Override
		public int hashCode() {
			return Objects.hash(clientID);
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
			
			Member other = (Member) obj;
			return clientID == other.clientID 
					&& Arrays.equals(icon, other.icon)
					&& Objects.equals(username, other.username);
		}
		
		@Override
		public String toString() {
			return username + "@" + clientID;
		}
	}

	private final int chatSessionID;
	private int chatSessionIndex; // Index of chat session that the server uses to access said chat session for the specific user

	private List<Member> members;
	private List<MESSAGE> messages;

	private boolean haveChatMessagesBeenCached;

	public ChatSession(int chatSessionID, int chatSessionIndex) {
		this.chatSessionID = chatSessionID;
		this.chatSessionIndex = chatSessionIndex;
		this.members = Collections.emptyList();
		this.messages = new ArrayList<>();
	}

	public ChatSession(int chatSessionID, int chatSessionIndex, List<MESSAGE> messages, List<Member> members, boolean haveChatMessagesBeenCached) {
		this.chatSessionID = chatSessionID;
		this.chatSessionIndex = chatSessionIndex;
		this.members = members;
		this.messages = messages;
		this.haveChatMessagesBeenCached = haveChatMessagesBeenCached;
	}

	public void setMembers(List<Member> members) {
		this.members = members;
	}

	public void setMessages(List<MESSAGE> messages) {
		this.messages = messages;
	}
	
	public void setChatSessionIndex(int chatSessionIndex) {
		this.chatSessionIndex = chatSessionIndex;
	}

	public void setHaveChatMessagesBeenCached(boolean haveChatMessagesBeenCached) {
		this.haveChatMessagesBeenCached = haveChatMessagesBeenCached;
	}

	public int getChatSessionID() {
		return chatSessionID;
	}

	public int getChatSessionIndex() {
		return chatSessionIndex;
	}

	public List<Member> getMembers() {
		return members;
	}

	public List<MESSAGE> getMessages() {
		return messages;
	}

	public boolean haveChatMessagesBeenCached() {
		return haveChatMessagesBeenCached;
	}

	@Override
	public int hashCode() {
		return Objects.hash(chatSessionID, chatSessionIndex);
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

		ChatSession other = (ChatSession) obj;
		return chatSessionID == other.chatSessionID 
				&& chatSessionIndex == other.chatSessionIndex
				&& haveChatMessagesBeenCached == other.haveChatMessagesBeenCached
				&& Objects.equals(members, other.members) 
				&& Objects.equals(messages, other.messages);
	}

	@Override
	public String toString() {
		StringJoiner joiner = new StringJoiner(", ");
		for (int i = 0; i < members.size(); i++) {
			joiner.add(members.get(i).toString());
		}
		return joiner.toString();
	}
}
