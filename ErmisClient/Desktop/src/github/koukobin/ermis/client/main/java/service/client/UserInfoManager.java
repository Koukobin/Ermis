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
package github.koukobin.ermis.client.main.java.service.client;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import github.koukobin.ermis.client.main.java.service.client.models.ChatRequest;
import github.koukobin.ermis.client.main.java.service.client.models.ChatSession;
import github.koukobin.ermis.client.main.java.service.client.models.Message;

public class UserInfoManager {
	public static String username;
	public static int clientID;
	public static byte[] accountIcon;
	public static final Map<Integer, ChatSession> chatSessionIDSToChatSessions = new HashMap<>();
	public static final Map<Integer, Message> pendingMessagesQueue = new HashMap<>();
	public static List<ChatSession> chatSessions = new ArrayList<>();
	public static List<ChatRequest> chatRequests = new ArrayList<>();

	private static byte[] pendingAccountIcon;

	private UserInfoManager() {}

	public static void pendingAccountIcon(byte[] pendingAccountIcon) {
		UserInfoManager.pendingAccountIcon = pendingAccountIcon;
	}

	public static void commitPendingProfilePhoto() {
		UserInfoManager.accountIcon = UserInfoManager.pendingAccountIcon;
		pendingAccountIcon = null;
	}
}
