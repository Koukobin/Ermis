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
public final class SettingsInfo {

	public static final URL SETTINGS_LOCATION = ChatInterfaceInfo.class.getResource(GeneralAppInfo.MAIN_PROJECT_PATH + "resources/view/chat_interface/settings/settings.fxml");
	public static final URL HELP_SETTINGS_LOCATION = ChatInterfaceInfo.class.getResource(GeneralAppInfo.MAIN_PROJECT_PATH + "resources/view/chat_interface/settings/help-settings.fxml");

	public static class AccountSettings {

		public static final URL ACCOUNT_SETTINGS_LOCATION = ChatInterfaceInfo.class.getResource(GeneralAppInfo.MAIN_PROJECT_PATH + "resources/view/chat_interface/settings/account-settings.fxml");
		
		public static final String ACCOUNT_SETTINGS_FOCUSED_CSS_LOCATION = ChatInterfaceInfo.class
				.getResource(GeneralAppInfo.MAIN_PROJECT_PATH + "resources/css/chat_interface/settings/account-settings-focused.css")
				.toExternalForm();
		
		private AccountSettings() {}
	}
	
	private SettingsInfo() {}
}
