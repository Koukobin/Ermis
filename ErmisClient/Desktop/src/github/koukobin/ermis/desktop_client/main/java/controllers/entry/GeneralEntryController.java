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
package github.koukobin.ermis.desktop_client.main.java.controllers.entry;

import github.koukobin.ermis.common.entry.AddedInfo;
import github.koukobin.ermis.common.entry.EntryType;
import github.koukobin.ermis.common.entry.EntryType.CredentialInterface;
import github.koukobin.ermis.desktop_client.main.java.database.ClientDatabase;
import github.koukobin.ermis.desktop_client.main.java.database.models.LocalAccountInfo;
import github.koukobin.ermis.desktop_client.main.java.service.client.Client;
import github.koukobin.ermis.desktop_client.main.java.service.client.models.EntryResult;
import github.koukobin.ermis.desktop_client.main.java.util.dialogs.DialogsUtil;
import github.koukobin.ermis.common.entry.Resultable;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.jfoenix.controls.JFXCheckBox;

import javafx.application.Platform;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.fxml.Initializable;
import javafx.scene.Node;
import javafx.scene.control.PasswordField;
import javafx.scene.control.TextField;
import javafx.stage.Stage;

/**
 * @author Ilias Koukovinis
 * 
 */
public abstract sealed class GeneralEntryController implements Initializable permits LoginSceneController, CreateAccountSceneController {

	private static final Logger logger = LoggerFactory.getLogger(GeneralEntryController.class);
	
	protected EntryType registrationType;
	
	protected FXMLLoader originalFXMLLoader;
	
	@FXML
	protected TextField emailTextField;
	@FXML
	protected TextField passwordFieldTextVisible;
	@FXML
	protected PasswordField passwordFieldTextHidden;
	@FXML
	protected JFXCheckBox changePasswordVisibilityCheckBox;

	public void closeEntry(ActionEvent event) {
		Platform.runLater(() -> {
			Node node = (Node) event.getSource();
			Stage stage = (Stage) node.getScene().getWindow();
			stage.hide();
		});
	}

	@FXML
	public void changePasswordVisibility(ActionEvent event) {
		if (changePasswordVisibilityCheckBox.isSelected()) {
			passwordFieldTextVisible.setText(passwordFieldTextHidden.getText());
			passwordFieldTextHidden.setVisible(false);
			passwordFieldTextVisible.setVisible(true);
			return;
		}

		passwordFieldTextHidden.setText(passwordFieldTextVisible.getText());
		passwordFieldTextVisible.setVisible(false);
		passwordFieldTextHidden.setVisible(true);
	}
	
	@FXML
	public abstract void switchScene(ActionEvent event) throws IOException;
	
	@FXML
	public abstract void register(ActionEvent event) throws IOException;

	@SuppressWarnings({ "unchecked", "rawtypes" })
	protected boolean sendAndValidateCredentials(Client.Entry clientEntry, Map<? extends CredentialInterface, String> credentials) {
		// Artificial wait before sending credentials because in a testing enviroment,
		// there is a high probability of receiveing server response so quickly
		// that the client doesn't have enough time to start listening for the result
		// before it arrives.
		CompletableFuture.runAsync(() -> {
			try {
				Thread.sleep(100);
				clientEntry.sendCredentials(credentials);
			} catch (IOException ioe) {
				logger.error(ioe.getMessage(), ioe);
			} catch (InterruptedException ie) {
				logger.error(ie.getMessage(), ie);
				Thread.currentThread().interrupt();
			}
		});

		Resultable entryResult = clientEntry.getResult();
		boolean isSuccessful = entryResult.isSuccessful();
		String resultMessage = entryResult.message();

		if (!isSuccessful) {
			DialogsUtil.showErrorDialog(resultMessage);
		}
	
		return isSuccessful;
	}

	protected boolean performVerification(String email, Client.Entry<? extends CredentialInterface> entry) throws IOException {
		VerificationDialog verificationDialog = new VerificationDialog(entry);
		EntryResult<Resultable> entryResult;

		boolean success = false;

		while (!entry.isVerificationComplete()) {
			verificationDialog.showAndWait();
			entry.sendVerificationCode(verificationDialog.getVerificationCode());

			entryResult = entry.getVerificationResult();
			success = entryResult.resultHolder().isSuccessful();
			String resultMessage = entryResult.resultHolder().message();

			if (success) {
				DialogsUtil.showSuccessDialog(resultMessage);

				String passwordHash = entryResult.addedInfo().get(AddedInfo.PASSWORD_HASH);
				UUID deviceUUID = UUID.fromString(entryResult.addedInfo().get(AddedInfo.DEVICE_UUID));

				var accountInfo = new LocalAccountInfo(email, passwordHash, deviceUUID, LocalDateTime.now());
				ClientDatabase.getDBConnection().addUserAccount(Client.getServerInfo(), accountInfo);
				break;
			}

			DialogsUtil.showErrorDialog(resultMessage);
		}

		return success;
	}

	public void setFXMLLoader(FXMLLoader loader) {
		this.originalFXMLLoader = loader;
	}

	public String getEmail() {
		return emailTextField.getText();
	}

	public String getPassword() {
		return changePasswordVisibilityCheckBox.isSelected() ? passwordFieldTextVisible.getText()
				: passwordFieldTextHidden.getText();
	}

	public EntryType getRegistrationType() {
		return registrationType;
	}

	public GeneralEntryController getController() {
		return originalFXMLLoader.getController();
	}
}
