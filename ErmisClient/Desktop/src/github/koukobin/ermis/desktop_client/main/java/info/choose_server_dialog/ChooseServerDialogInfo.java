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
package github.koukobin.ermis.desktop_client.main.java.info.choose_server_dialog;

import github.koukobin.ermis.desktop_client.main.java.info.GeneralAppInfo;

/**
 * @author Ilias Koukovinis
 *
 */
public final class ChooseServerDialogInfo {

	public static final int STAGE_HEIGHT = 225;
	public static final int STAGE_WIDTH = 450;

	public static final String CHOOSE_SERSVER_DIALOG_CSS = GeneralAppInfo.class
			.getResource(GeneralAppInfo.MAIN_PROJECT_PATH + "resources/css/mfx_dialogs/choose-server.css")
			.toExternalForm();
	
	private ChooseServerDialogInfo() {}
}
