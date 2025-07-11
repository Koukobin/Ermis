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
import io.github.palexdev.materialfx.controls.MFXTextField;
import io.github.palexdev.materialfx.enums.FloatMode;
import javafx.scene.Parent;
import javafx.stage.Stage;

/**
 * @author Ilias Koukovinis
 *
 */
public final class ChangeCredentialsDialog extends MFXActionDialog {

	private MFXTextField newCredentialTextField;

	public enum ChangeCredentialType {
		DISPLAY_NAME, PASSWORD
	}

	public ChangeCredentialsDialog(Stage stage, Parent rootPane, ChangeCredentialType credential) {
		super(stage, rootPane);

		newCredentialTextField = new MFXTextField();
		newCredentialTextField.setFloatMode(FloatMode.ABOVE);
		newCredentialTextField.setFont(defaultFont);
		newCredentialTextField.setPrefColumnCount(20);

		dialogContent.setContent(newCredentialTextField);

		if (credential == ChangeCredentialType.DISPLAY_NAME) {
			newCredentialTextField.setPromptText("New Username");
			dialogContent.setHeaderText("Change Username");
		} else {
			dialogContent.setHeaderText("Change Password");
			newCredentialTextField.setPromptText("New Password");
		}
	}

	public String getNewCredential() {
		return newCredentialTextField.getText();
	}
}
