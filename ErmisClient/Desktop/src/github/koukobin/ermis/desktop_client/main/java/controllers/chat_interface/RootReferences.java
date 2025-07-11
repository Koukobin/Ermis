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
package github.koukobin.ermis.desktop_client.main.java.controllers.chat_interface;

import java.io.IOException;

import github.koukobin.ermis.desktop_client.main.java.info.chat_interface.ChatInterfaceInfo;
import github.koukobin.ermis.desktop_client.main.java.info.chat_interface.SettingsInfo;
import javafx.fxml.FXMLLoader;
import javafx.scene.layout.Pane;

/**
 * @author Ilias Koukovinis
 *
 */
final class RootReferences {
	
	private static FXMLLoader MESSAGING_LOADER;
	private static FXMLLoader CHATS_LOADER;
	private static FXMLLoader CHAT_REQUESTS_LOADER;
	private static FXMLLoader SETTINGS_LOADER;
	private static FXMLLoader ACCOUNT_SETTINGS_LOADER;
	private static FXMLLoader HELP_SETTINGS_LOADER;
	
	private static MessagingController MESSAGING_CONTROLLER;
	private static ChatsController CHATS_CONTROLLER;
	private static ChatRequestsController CHAT_REQUESTS_CONTROLLER;
	private static SettingsController SETTINGS_CONTROLLER;
	private static AccountSettingsController ACCOUNT_SETTINGS_CONTROLLER;
	private static HelpSettingsController HELP_SETTINGS_CONTROLLER;
	
	private static Pane MESSAGING_ROOT;
	private static Pane CHATS_ROOT;
	private static Pane CHATS_REQUESTS_ROOT;
	private static Pane SETTINGS_ROOT;
	private static Pane ACCOUNT_SETTINGS_ROOT;
	private static Pane HELP_SETTINGS_ROOT;
	
	private RootReferences() {}
	
	public static void initializeAll() {
		initializeMessaging();
		initializeChats();
		initalizeChatRequests();
		initializeSettings();
		initializeAccountSettings();
		initializeHelpSettings();
	}
	
	public static void initializeMessaging() {
		MESSAGING_LOADER = new FXMLLoader(ChatInterfaceInfo.MESSAGING_LOCATION);
		
		try {
			MESSAGING_ROOT = MESSAGING_LOADER.load();
			MESSAGING_CONTROLLER = MESSAGING_LOADER.getController();
		} catch (IOException ioe) {
			throw new RuntimeException(ioe);
		}
	}
	
	public static void initializeChats() {
		CHATS_LOADER = new FXMLLoader(ChatInterfaceInfo.CHATS_LOCATION);
		
		try {
			CHATS_ROOT = CHATS_LOADER.load();
			CHATS_CONTROLLER = CHATS_LOADER.getController();
		} catch (IOException ioe) {
			throw new RuntimeException(ioe);
		}
	}
	
	public static void initalizeChatRequests() {
		CHAT_REQUESTS_LOADER = new FXMLLoader(ChatInterfaceInfo.CHATS_REQUESTS_INTERFACE_LOCATION);
		
		try {
			CHATS_REQUESTS_ROOT = CHAT_REQUESTS_LOADER.load();
			CHAT_REQUESTS_CONTROLLER = CHAT_REQUESTS_LOADER.getController();
		} catch (IOException ioe) {
			throw new RuntimeException(ioe);
		}
	}
	
	public static void initializeSettings() {
		SETTINGS_LOADER = new FXMLLoader(SettingsInfo.SETTINGS_LOCATION);
		
		try {
			SETTINGS_ROOT = SETTINGS_LOADER.load();
			SETTINGS_CONTROLLER = SETTINGS_LOADER.getController();
		} catch (IOException ioe) {
			throw new RuntimeException(ioe);
		}
	}
	
	public static void initializeAccountSettings() {
		ACCOUNT_SETTINGS_LOADER = new FXMLLoader(SettingsInfo.AccountSettings.ACCOUNT_SETTINGS_LOCATION);
		
		try {
			ACCOUNT_SETTINGS_ROOT = ACCOUNT_SETTINGS_LOADER.load();
			ACCOUNT_SETTINGS_CONTROLLER = ACCOUNT_SETTINGS_LOADER.getController();
		} catch (IOException ioe) {
			throw new RuntimeException(ioe);
		}
	}
	
	public static void initializeHelpSettings() {
		HELP_SETTINGS_LOADER = new FXMLLoader(SettingsInfo.HELP_SETTINGS_LOCATION);
		
		try {
			HELP_SETTINGS_ROOT = HELP_SETTINGS_LOADER.load();
			HELP_SETTINGS_CONTROLLER = HELP_SETTINGS_LOADER.getController();
		} catch (IOException ioe) {
			throw new RuntimeException(ioe);
		}
	}

	public static FXMLLoader getMessagingLoader() {
		return MESSAGING_LOADER;
	}

	public static FXMLLoader getChatsLoader() {
		return CHATS_LOADER;
	}
	
	public static FXMLLoader getChatRequestsLoader() {
		return CHAT_REQUESTS_LOADER;
	}

	public static FXMLLoader getSettingsLoader() {
		return SETTINGS_LOADER;
	}

	public static FXMLLoader getAccountSettingsLoader() {
		return ACCOUNT_SETTINGS_LOADER;
	}

	public static FXMLLoader getHelpSettingsLoader() {
		return HELP_SETTINGS_LOADER;
	}
	
	public static MessagingController getMessagingController() {
		return MESSAGING_CONTROLLER;
	}

	public static ChatsController getChatsController() {
		return CHATS_CONTROLLER;
	}

	public static ChatRequestsController getChatRequestsController() {
		return CHAT_REQUESTS_CONTROLLER;
	}

	public static SettingsController getSettingsController() {
		return SETTINGS_CONTROLLER;
	}

	public static AccountSettingsController getAccountSettingsController() {
		return ACCOUNT_SETTINGS_CONTROLLER;
	}

	public static HelpSettingsController getHelpSettingsController() {
		return HELP_SETTINGS_CONTROLLER;
	}

	public static Pane getMessageRoot() {
		return MESSAGING_ROOT;
	}

	public static Pane getChatsRoot() {
		return CHATS_ROOT;
	}
	
	public static Pane getChatRequestsRoot() {
		return CHATS_REQUESTS_ROOT;
	}

	public static Pane getSettingsRoot() {
		return SETTINGS_ROOT;
	}

	public static Pane getAccountSettingsRoot() {
		return ACCOUNT_SETTINGS_ROOT;
	}

	public static Pane getHelpSettingsRoot() {
		return HELP_SETTINGS_ROOT;
	}
}
