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
package github.koukobin.ermis.desktop_client.main.java.controllers.chat_interface.dialogs;

import github.koukobin.ermis.desktop_client.main.java.general_dialogs.MFXActionDialog;
import io.github.palexdev.materialfx.font.MFXFontIcon;
import javafx.scene.Parent;
import javafx.stage.Stage;

/**
 * @author Ilias Koukovinis
 *
 */
public final class LogoutDialog extends MFXActionDialog {
	
	public LogoutDialog(Stage stage, Parent rootPane)	{

		super(stage, rootPane);

		dialogContent.setContentText("Are you sure you want to logout?");

		MFXFontIcon infoIcon = new MFXFontIcon("mfx-info-circle-filled", 18);
		dialogContent.setHeaderText("Logout");
		dialogContent.setHeaderIcon(infoIcon);
		dialogContent.getStyleClass().add("mfx-info-dialog");
	}
}
