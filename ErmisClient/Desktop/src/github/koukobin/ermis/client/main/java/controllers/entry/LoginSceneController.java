/* Copyright (C) 2022 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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
package github.koukobin.ermis.client.main.java.controllers.entry;

import java.io.IOException;
import java.net.URL;
import java.util.EnumMap;
import java.util.ResourceBundle;

import github.koukobin.ermis.client.main.java.info.entry.EntryInfo;
import github.koukobin.ermis.client.main.java.service.client.io_client.Client;
import github.koukobin.ermis.client.main.java.service.client.io_client.Client.BackupVerificationEntry;
import github.koukobin.ermis.client.main.java.util.UITransitions;
import github.koukobin.ermis.client.main.java.util.dialogs.DialogsUtil;
import github.koukobin.ermis.common.entry.EntryType;
import github.koukobin.ermis.common.entry.LoginInfo;
import github.koukobin.ermis.common.entry.LoginInfo.PasswordType;
import github.koukobin.ermis.common.results.ResultHolder;

import com.jfoenix.controls.JFXButton;

import javafx.animation.Interpolator;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.layout.AnchorPane;
import javafx.scene.layout.StackPane;
import javafx.util.Duration;

/**
 * @author Ilias Koukovinis
 * 
 */
public final class LoginSceneController extends GeneralEntryController {

	private PasswordType passwordType;
	
	@FXML
	private StackPane parentContainer;
	@FXML
	private AnchorPane loginAnchorPane;
	@FXML
	private JFXButton switchToCreateAccountSceneButton;
	@FXML
	private JFXButton togglePasswordTypeButton;
	
	@Override
	public void initialize(URL location, ResourceBundle resources) {
		registrationType = EntryType.LOGIN;
		passwordType = PasswordType.PASSWORD;
	}
	
	@FXML
	public void flipPasswordType(ActionEvent event) {

		passwordType = switch (passwordType) {
		case PASSWORD -> PasswordType.BACKUP_VERIFICATION_CODE;
		case BACKUP_VERIFICATION_CODE -> PasswordType.PASSWORD;
		};
		
		switch (passwordType) {
		case PASSWORD -> {
			passwordFieldTextHidden.setPromptText("password");
			passwordFieldTextVisible.setPromptText("password");
			togglePasswordTypeButton.setText("Use backup verification code");
		}
		case BACKUP_VERIFICATION_CODE -> {
			passwordFieldTextHidden.setPromptText("backup verification code");
			passwordFieldTextVisible.setPromptText("backup verification code");
			togglePasswordTypeButton.setText("Use password");
		}
		}
	}
	
	@Override
	public void register(ActionEvent event) throws IOException {
		
		Client.LoginEntry loginEntry = Client.createNewLoginEntry();
		loginEntry.sendEntryType();

        EnumMap<LoginInfo.Credential, String> loginCredentials = new EnumMap<>(LoginInfo.Credential.class);
        loginCredentials.put(LoginInfo.Credential.EMAIL, getEmail());
        loginCredentials.put(LoginInfo.Credential.PASSWORD, getPassword());

		if (getPasswordType() != PasswordType.PASSWORD) {
			loginEntry.togglePasswordType();
		}
		
		boolean isSuccesfull = sendAndValidateCredentials(loginEntry, loginCredentials);
		
		if (!isSuccesfull) {
			return;
		}
		
		if (getPasswordType() == PasswordType.PASSWORD) {
			isSuccesfull = performVerification();
		} else {
			
			BackupVerificationEntry backupVerificationEntry = Client.createNewBackupVerificationEntry();
			
			ResultHolder entryResult = backupVerificationEntry.getResult();
			isSuccesfull = entryResult.isSuccessful();
			String resultMessage = entryResult.getResultMessage();
			
			if (isSuccesfull) {
				DialogsUtil.showSuccessDialog(resultMessage);
			} else {
				DialogsUtil.showErrorDialog(resultMessage);
			}
		}

		if (!isSuccesfull) {
			return;
		}
		
		closeEntry(event);
	}
	
	@Override
	public void switchScene(ActionEvent event) throws IOException {

		FXMLLoader loader = new FXMLLoader(EntryInfo.CreateAccount.FXML_LOCATION);
		final Parent root = loader.load();
		
		CreateAccountSceneController createAccountController = loader.getController();
		createAccountController.setFXMLLoader(this.originalFXMLLoader);
		this.originalFXMLLoader.setController(createAccountController);
		
		Scene scene = switchToCreateAccountSceneButton.getScene();
		switchToCreateAccountSceneButton.setDisable(true);
		
		scene.getStylesheets().add(EntryInfo.CreateAccount.CSS_LOCATION);

		Runnable transition = UITransitions.newBuilder()
				.setDirection(UITransitions.Direction.YAxis.BOTTOM_TO_TOP)
				.setDuration(Duration.seconds(1))
				.setInterpolator(Interpolator.EASE_OUT)
				.setNewComponent(root)
				.setOldComponent(loginAnchorPane)
				.setParentContainer((StackPane) scene.getRoot())
				.build();

		transition.run();
	}
	
	public PasswordType getPasswordType() {
		return passwordType;
	}
}