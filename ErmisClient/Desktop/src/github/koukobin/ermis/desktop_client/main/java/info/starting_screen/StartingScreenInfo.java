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
package github.koukobin.ermis.desktop_client.main.java.info.starting_screen;

import github.koukobin.ermis.desktop_client.main.java.info.GeneralAppInfo;

/**
 * @author Ilias Koukovinis
 *
 */
public final class StartingScreenInfo {

	public static final String CSS_LOCATION = StartingScreenInfo.class.getResource(GeneralAppInfo.MAIN_PROJECT_PATH + "resources/css/starting-screen.css").toExternalForm();
	
	public static final int STAGE_WIDTH = 350;
	public static final int STAGE_HEIGHT = 410;

	public static final int ICON_WITDH = 220;
	public static final int ICON_HEIGHT = 209;

	private StartingScreenInfo() {}
}
