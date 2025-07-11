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
package github.koukobin.ermis.desktop_client.main.java.info.chat_interface;

import java.net.URL;

import github.koukobin.ermis.desktop_client.main.java.info.GeneralAppInfo;

/**
 * @author Ilias Koukovinis
 *
 */
public final class ChatInterfaceInfo {

	public static final URL FXML_LOCATION = ChatInterfaceInfo.class.getResource(GeneralAppInfo.MAIN_PROJECT_PATH + "resources/view/chat_interface/chat-interface.fxml");
	public static final String NOTIFICATION_SOUND_LOCATION = ChatInterfaceInfo.class.getResource(GeneralAppInfo.MAIN_PROJECT_PATH +  "resources/sounds/notification.wav").toExternalForm();
	
	public static final int STAGE_MIN_HEIGHT = 700;
	public static final int STAGE_MIN_WIDTH = 995;

	public static final URL MESSAGING_LOCATION = ChatInterfaceInfo.class.getResource(GeneralAppInfo.MAIN_PROJECT_PATH +  "resources/view/chat_interface/messaging.fxml");
	public static final URL CHATS_LOCATION = ChatInterfaceInfo.class.getResource(GeneralAppInfo.MAIN_PROJECT_PATH +  "resources/view/chat_interface/chats.fxml");
	public static final URL CHATS_REQUESTS_INTERFACE_LOCATION = ChatInterfaceInfo.class.getResource(GeneralAppInfo.MAIN_PROJECT_PATH +  "resources/view/chat_interface/chat-requests.fxml");

	private ChatInterfaceInfo() {}
}
