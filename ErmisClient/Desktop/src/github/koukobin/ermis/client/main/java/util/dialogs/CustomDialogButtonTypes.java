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
package github.koukobin.ermis.client.main.java.util.dialogs;

import javafx.scene.control.ButtonType;
import javafx.scene.control.ButtonBar.ButtonData;

/**
 * @author Ilias Koukovinis
 * 
 */
public final class CustomDialogButtonTypes {

	public static final ButtonType RETRY_BUTTON = new ButtonType("Retry", ButtonData.NEXT_FORWARD);
	public static final ButtonType EXIT_BUTTON = new ButtonType("Exit", ButtonData.CANCEL_CLOSE);

	public static final ButtonType OK_BUTTON = ButtonType.OK;
	public static final ButtonType CANCEL_BUTTON = ButtonType.CANCEL;
	public static final ButtonType CLOSE_BUTTON = ButtonType.CLOSE;

	public static final ButtonType APPLY_BUTTON = ButtonType.APPLY;
	public static final ButtonType FINISH_BUTTON = ButtonType.FINISH;

	public static final ButtonType NEXT_BUTTON = ButtonType.NEXT;
	public static final ButtonType PREVIOUS_BUTTON = ButtonType.PREVIOUS;

	public static final ButtonType NO_BUTTON = ButtonType.NO;
	public static final ButtonType YES_BUTTON = ButtonType.YES;

	private CustomDialogButtonTypes() {}
}