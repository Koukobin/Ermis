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
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import github.koukobin.ermis.server.main.java.configs.ServerSettings;

/**
 * @author Ilias Koukovinis
 *
 */
public class ActiveClients {

	/**
	 * Map to track active clients
	 */
	private static final Map<Integer, List<ClientInfo>> clientIDSToActiveClients = new ConcurrentHashMap<>(ServerSettings.SERVER_BACKLOG);
	
	private ActiveClients() {}
	
	public static List<ClientInfo> getClient(int clientID) {
		return clientIDSToActiveClients.get(clientID);
	}
	
	public static void addClient(ClientInfo clientInfo) {
		clientIDSToActiveClients.putIfAbsent(clientInfo.getClientID(), new ArrayList<>());
		clientIDSToActiveClients.get(clientInfo.getClientID()).add(clientInfo);
	}
	
	public static void removeClient(ClientInfo clientInfo) {
		int clientID = clientInfo.getClientID();
		List<ClientInfo> clients = clientIDSToActiveClients.get(clientID);
		
		if (clients == null) {
			return;
		}
		
		clients.remove(clientInfo);
		
		if (clients.isEmpty()) {
			clientIDSToActiveClients.remove(clientID);
		}
	}

}
