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

import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

import io.netty.channel.Channel;
import io.netty.channel.epoll.EpollSocketChannel;

/**
 * @author Ilias Koukovinis
 *
 */
public final class ClientInfo {

	private String username;
	private String email;
	private int clientID;
	
	private List<ChatSession> chatSessions;
	private List<Integer> chatRequestsClientIDS;
	
	private EpollSocketChannel channel;

	public ClientInfo() {
		chatSessions = new ArrayList<>();
		chatRequestsClientIDS = new ArrayList<>();
	}

	public ClientInfo(String username, String email, int clientID, List<ChatSession> chatSessions, List<Integer> chatRequests, EpollSocketChannel channel) {
		this.username = username;
		this.email = email;
		this.clientID = clientID;
		this.chatSessions = chatSessions;
		this.chatRequestsClientIDS = chatRequests;
		this.channel = channel;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public void setClientID(int clientID) {
		this.clientID = clientID;
	}

	public void setChatSessions(List<ChatSession> chatSessions) {
		this.chatSessions = chatSessions;
	}

	public void setChatRequests(List<Integer> chatRequests) {
		this.chatRequestsClientIDS = chatRequests;
	}

	public void setChannel(Channel channel) {
		this.channel = (EpollSocketChannel) channel;
	}
	
	public String getUsername() {
		return username;
	}

	public String getEmail() {
		return email;
	}

	public int getClientID() {
		return clientID;
	}

	public List<ChatSession> getChatSessions() {
		return chatSessions;
	}

	public List<Integer> getChatRequests() {
		return chatRequestsClientIDS;
	}

	public EpollSocketChannel getChannel() {
		return channel;
	}
	
	public InetSocketAddress getInetSocketAddress() {
		return channel.remoteAddress();
	}
	
	public InetAddress getInetAddress() {
		return channel.remoteAddress().getAddress();
	}

	@Override
	public int hashCode() {
		return Objects.hashCode(clientID);
	}

	public void clear() {
		username = null;
		email = null;
		clientID = -1;
		chatRequestsClientIDS = null;
		chatSessions = null;
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
		
		ClientInfo other = (ClientInfo) obj;
		return Objects.equals(channel, other.channel) 
				&& Objects.equals(chatRequestsClientIDS, other.chatRequestsClientIDS)
				&& Objects.equals(chatSessions, other.chatSessions) 
				&& clientID == other.clientID
				&& Objects.equals(email, other.email)
				&& Objects.equals(username, other.username);
	}

	@Override
	public String toString() {
		return username + clientID;
	}

}

