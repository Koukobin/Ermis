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
package github.koukobin.ermis.desktop_client.main.java.controllers.chat_interface;

import java.io.IOException;
import java.net.URL;
import java.util.Optional;
import java.util.ResourceBundle;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import github.koukobin.ermis.desktop_client.main.java.controllers.chat_interface.dialogs.LogoutDialog;
import github.koukobin.ermis.desktop_client.main.java.service.client.Client;
import github.koukobin.ermis.desktop_client.main.java.util.dialogs.CustomDialogButtonTypes;
import github.koukobin.ermis.desktop_client.main.java.util.dialogs.DialogsUtil;
import javafx.application.Platform;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.StackPane;
import javafx.fxml.Initializable;
import javafx.scene.Node;
import javafx.scene.control.ButtonType;
import javafx.stage.Stage;

/**
 * @author Ilias Koukovinis
 *
 */
public class ChatInterfaceController implements Initializable {

	private static final Logger logger = LoggerFactory.getLogger(ChatInterfaceController.class);

	@FXML
	private BorderPane rootBorderPane;

	@FXML
	public StackPane stackPane;

	private Stage stage;

	@Override
	public void initialize(URL arg0, ResourceBundle arg1) {
		try {
			EventListenersInitiator.initiateEventListeners(stage, rootBorderPane);
			Client.startMessageHandler();

			RootReferences.initializeAll();

			rootBorderPane.setCenter(RootReferences.getMessageRoot());
			stackPane.getChildren().add(RootReferences.getChatsRoot());
		} catch (Exception e) {
			Optional<ButtonType> exceptionDialogResult = DialogsUtil.showExceptionDialog(e);

			if (!exceptionDialogResult.isPresent() || exceptionDialogResult.get() == CustomDialogButtonTypes.RETRY_BUTTON) {
				initialize(arg0, arg1);
			} else {
				Platform.exit();
			}
		}
	}

	@FXML
	public void logout(ActionEvent event) throws IOException {
		LogoutDialog dialog = new LogoutDialog(stage, rootBorderPane);
		dialog.showAndWait();

		if (!dialog.isCanceled()) {
			try {
				Client.getCommands().logout();
				closeClient();
				Platform.exit();
			} catch (Exception e) {
				Runtime.getRuntime().halt(0);
			}
		}
	}

	@FXML
	public void transitionToChats(ActionEvent event) {
		transitionBetweenOptionsBar(stackPane, RootReferences.getChatsRoot());
	}

	@FXML
	public void transitionToChatRequests(ActionEvent event) {
		transitionBetweenOptionsBar(stackPane, RootReferences.getChatRequestsRoot());
	}

	@FXML
	public void transitionToSettings(ActionEvent event) {
		transitionBetweenOptionsBar(stackPane, RootReferences.getSettingsRoot());
	}

	private void transitionBetweenOptionsBar(StackPane parentContainer, Node newComponent) {
		Node oldComponent = stackPane.getChildren().get(0);

		if (newComponent.equals(oldComponent)) {
			return;
		}

		parentContainer.getChildren().remove(oldComponent);
		parentContainer.getChildren().add(newComponent);
	}

	public void setStage(Stage stage) {
		this.stage = stage;
	}

	public void closeClient() {
		try {
			Client.close();
		} catch (IOException ioe) {
			logger.error(ioe.getMessage(), ioe);
		}
	}

}