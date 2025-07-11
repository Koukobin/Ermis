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
package github.koukobin.ermis.desktop_client.main.java.general_dialogs;

import java.util.Map;

import io.github.palexdev.materialfx.controls.MFXButton;
import javafx.scene.Parent;
import javafx.scene.input.MouseEvent;
import javafx.stage.Stage;

/**
 * @author Ilias Koukovinis
 *
 */
public class MFXActionDialog extends MFXDialog {

	protected boolean isCanceled = true;
	
	protected MFXActionDialog(Stage stage, Parent rootPane) {
		super(stage, rootPane);
		
		dialogContent.addActions(
				Map.entry(new MFXButton("Confirm"), (MouseEvent e) -> {
					isCanceled = false;
					super.close();
				}), Map.entry(new MFXButton("Cancel"), (MouseEvent e) -> {
					super.close();
				}));
	}
	
	public boolean isCanceled() {
		return isCanceled;
	}
}
