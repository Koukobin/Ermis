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
package github.koukobin.ermis.desktop_client.main.java.controllers.entry;

import java.io.IOException;
import java.util.Optional;

import github.koukobin.ermis.common.entry.EntryType.CredentialInterface;
import github.koukobin.ermis.desktop_client.main.java.service.client.Client;
import github.koukobin.ermis.desktop_client.main.java.util.dialogs.DialogsUtil;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.scene.control.Button;
import javafx.scene.control.ButtonType;
import javafx.scene.control.TextInputDialog;

/**
 * @author Ilias Koukovinis
 *
 */
public class VerificationDialog {

	private TextInputDialog verificationCodeDialog;
	private int verificationCode;
	
	private Client.Entry<? extends CredentialInterface> verificationEntry;
	
	public VerificationDialog(Client.Entry<? extends CredentialInterface> verificationEntry) {
		this.verificationEntry = verificationEntry;
		
		String headerText = "Enter the code that was sent to your email to verify it is really you";

		ButtonType resendVerificationCodeButtonType = new ButtonType("Resend verification code");
		verificationCodeDialog = DialogsUtil.createTextInputDialog(headerText, null, "Verification Code",
				resendVerificationCodeButtonType, ButtonType.OK);

		Button resendVerificationCodeButton = (Button) verificationCodeDialog.getDialogPane()
				.lookupButton(resendVerificationCodeButtonType);
		resendVerificationCodeButton.pressedProperty().addListener(new ChangeListener<Boolean>() {

			@Override
			public void changed(ObservableValue<? extends Boolean> observable, Boolean oldValue,
					Boolean newValue) {
				try {
					VerificationDialog.this.verificationEntry.resendVerificationCode();
				} catch (IOException ioe) {
					ioe.printStackTrace();
				}
			}
		});
	}

	public void showAndWait() {
		Optional<String> result = verificationCodeDialog.showAndWait();

		if (!result.isPresent()) {
			return;
		}

		try {
			verificationCode = Integer.parseInt(result.get());
		} catch (NumberFormatException nfe) {
			DialogsUtil.showErrorDialog("Verification code must be a number!");
			verificationCodeDialog.showAndWait();
		}
	}

	public int getVerificationCode() {
		return verificationCode;
	}
}
