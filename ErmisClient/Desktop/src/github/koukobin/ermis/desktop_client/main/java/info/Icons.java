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
package github.koukobin.ermis.desktop_client.main.java.info;

import javafx.scene.image.Image;

/**
 * @author Ilias Koukovinis
 *
 */
public final class Icons {

	public static final String ICONS_PATH = GeneralAppInfo.MAIN_PROJECT_PATH + "resources/icons/";

	public static final Image PRIMARY_APPLICATION_ICON_92 = new Image(Icons.class.getResource(ICONS_PATH + "primary-application-icon-92.png").toExternalForm());
	public static final Image PRIMARY_APPLICATION_ICON_256 = new Image(Icons.class.getResource(ICONS_PATH + "primary-application-icon-256.png").toExternalForm());
	public static final Image PRIMARY_APPLICATION_ICON_512 = new Image(Icons.class.getResource(ICONS_PATH + "primary-application-icon-512.png").toExternalForm());

	// Material design icons
	public static final String MATERIAL_DESIGN_ICONS_PATH = ICONS_PATH + "material_design_icons/";
	
	public static final Image ACCOUNT_LOW_RES = new Image(Icons.class.getResource(MATERIAL_DESIGN_ICONS_PATH + "account_low_res.png").toExternalForm());
	public static final Image ACCOUNT_HIGH_RES = new Image(Icons.class.getResource(MATERIAL_DESIGN_ICONS_PATH + "account_high_res.png").toExternalForm());
	public static final Image CHATS = new Image(Icons.class.getResource(MATERIAL_DESIGN_ICONS_PATH + "chats.png").toExternalForm());
	public static final Image CHAT_REQUESTS = new Image(Icons.class.getResource(MATERIAL_DESIGN_ICONS_PATH + "chat-requests.png").toExternalForm());

	public static final Image EDIT = new Image(Icons.class.getResource(MATERIAL_DESIGN_ICONS_PATH + "edit.png").toExternalForm());
	public static final Image CHECK = new Image(Icons.class.getResource(MATERIAL_DESIGN_ICONS_PATH + "check.png").toExternalForm());

	public static final Image ADD = new Image(Icons.class.getResource(MATERIAL_DESIGN_ICONS_PATH + "add.png").toExternalForm());
	public static final Image ADD_CIRCLE = new Image(Icons.class.getResource(MATERIAL_DESIGN_ICONS_PATH + "add-circle.png").toExternalForm());
	public static final Image ATTACH = new Image(Icons.class.getResource(MATERIAL_DESIGN_ICONS_PATH + "attach.png").toExternalForm());
	public static final Image DOWNLOAD = new Image(Icons.class.getResource(MATERIAL_DESIGN_ICONS_PATH + "download.png").toExternalForm());
	
	public static final Image CODE = new Image(Icons.class.getResource(MATERIAL_DESIGN_ICONS_PATH + "code.png").toExternalForm());
	public static final Image PASSWORD = new Image(Icons.class.getResource(MATERIAL_DESIGN_ICONS_PATH + "password.png").toExternalForm());

	public static final Image HELP = new Image(Icons.class.getResource(MATERIAL_DESIGN_ICONS_PATH + "help.png").toExternalForm());
	public static final Image LOGOUT = new Image(Icons.class.getResource(MATERIAL_DESIGN_ICONS_PATH + "logout.png").toExternalForm());

	public static final Image REFRESH = new Image(Icons.class.getResource(MATERIAL_DESIGN_ICONS_PATH + "refresh.png").toExternalForm());
	public static final Image SEARCH = new Image(Icons.class.getResource(MATERIAL_DESIGN_ICONS_PATH + "search.png").toExternalForm());

	public static final Image SEND = new Image(Icons.class.getResource(MATERIAL_DESIGN_ICONS_PATH + "send.png").toExternalForm());
	public static final Image SETTINGS = new Image(Icons.class.getResource(MATERIAL_DESIGN_ICONS_PATH + "settings.png").toExternalForm());

	private Icons() {}
}
