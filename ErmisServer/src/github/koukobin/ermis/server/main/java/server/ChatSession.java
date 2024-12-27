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
package github.koukobin.ermis.server.main.java.server;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

/**
 * @author Ilias Koukovinis
 *
 */
public final class ChatSession {

	private final int chatSessionID;

	private List<ClientInfo> activeMembers;
	private List<Integer> membersClientIDS;

	public ChatSession(int chatSessionID) {
		this.chatSessionID = chatSessionID;
		this.activeMembers = new ArrayList<>();
		this.membersClientIDS = new ArrayList<>();
	}

	public ChatSession(int chatSessionID, List<ClientInfo> activeMembers, List<Integer> membersClientIDS) {
		this.chatSessionID = chatSessionID;
		this.activeMembers = activeMembers;
		this.membersClientIDS = membersClientIDS;
	}

	public void setActiveMembers(List<ClientInfo> activeMembers) {
		this.activeMembers = activeMembers;
	}

	public void setMembers(List<Integer> membersClientIDS) {
		this.membersClientIDS = membersClientIDS;
	}

	public int getChatSessionID() {
		return chatSessionID;
	}

	public List<ClientInfo> getActiveMembers() {
		return activeMembers;
	}

	public List<Integer> getMembers() {
		return membersClientIDS;
	}

	@Override
	public int hashCode() {
		return Objects.hash(chatSessionID);
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
		return Objects.equals(activeMembers, other.activeMembers)
				&& chatSessionID == other.chatSessionID
				&& Objects.equals(membersClientIDS, other.membersClientIDS);
	}

	@Override
	public String toString() {
		return "ChatSession [chatSessionID=" + chatSessionID + ", activeMembers=" + activeMembers + ", members="
				+ membersClientIDS + "]";
	}
}
