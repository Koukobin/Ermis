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

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.util.ResourceBundle;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.jfoenix.controls.JFXButton;

import github.koukobin.ermis.desktop_client.main.java.info.Icons;
import github.koukobin.ermis.desktop_client.main.java.info.chat_interface.SettingsInfo;
import github.koukobin.ermis.desktop_client.main.java.service.client.Client;
import github.koukobin.ermis.desktop_client.main.java.service.client.GlobalMessageDispatcher;
import github.koukobin.ermis.desktop_client.main.java.service.client.UserInfoManager;
import github.koukobin.ermis.desktop_client.main.java.service.client.Events.AddProfilePhotoResultEvent;
import github.koukobin.ermis.desktop_client.main.java.service.client.Events.ClientIdEvent;
import github.koukobin.ermis.desktop_client.main.java.service.client.Events.ReceivedProfilePhotoEvent;
import github.koukobin.ermis.desktop_client.main.java.service.client.Events.UsernameReceivedEvent;
import github.koukobin.ermis.desktop_client.main.java.util.UITransitions;
import github.koukobin.ermis.desktop_client.main.java.util.UITransitions.Direction.Which;
import github.koukobin.ermis.desktop_client.main.java.util.dialogs.MFXDialogsUtil;
import javafx.animation.Interpolator;
import javafx.application.Platform;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.fxml.FXML;
import javafx.scene.Cursor;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.effect.DropShadow;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.HBox;
import javafx.scene.layout.StackPane;
import javafx.scene.paint.Color;
import javafx.scene.paint.ImagePattern;
import javafx.scene.shape.Circle;
import javafx.stage.FileChooser;
import javafx.util.Duration;

/**
 * @author Ilias Koukovinis
 *
 */
public class AccountSettingsController extends GeneralController {

	private static final Logger logger = LoggerFactory.getLogger(AccountSettingsController.class);

	@FXML
	private Circle addProfilePhotoIcon;

	@FXML
	private Label clientIDLabel;

	@FXML private TextField changeDisplayNameTextField;
	@FXML private JFXButton changeDisplayNameButton;
	@FXML private ImageView displayNameButtonImageView;
	@FXML private HBox changeDisplayNameHbox;

	@Override
	public void initialize(URL location, ResourceBundle resources) {
		{
			// Change cursor when hovering over the button
			addProfilePhotoIcon.setOnMouseEntered(event -> addProfilePhotoIcon.setCursor(Cursor.HAND));
			addProfilePhotoIcon.setOnMouseExited(event -> addProfilePhotoIcon.setCursor(Cursor.DEFAULT));

			setProfileIcon(UserInfoManager.accountIcon);

			addProfilePhotoIcon.setStrokeWidth(1.5);
			addProfilePhotoIcon.setStroke(Color.ROYALBLUE);
		}

		GlobalMessageDispatcher.getDispatcher()
			.observeMessages()
			.ofType(ReceivedProfilePhotoEvent.class)
			.subscribe((ReceivedProfilePhotoEvent event) -> {
				Platform.runLater(() -> {
					addProfilePhotoIcon.setFill(new ImagePattern(new Image(new ByteArrayInputStream(event.getPhotoBytes()))));
					addProfilePhotoIcon.setEffect(null);
				});
		});

		GlobalMessageDispatcher.getDispatcher()
			.observeMessages()
			.ofType(AddProfilePhotoResultEvent.class)
			.subscribe((AddProfilePhotoResultEvent event) -> {
				if (event.isSuccess()) {
					Platform.runLater(() -> {
						addProfilePhotoIcon.setFill(new ImagePattern(new Image(new ByteArrayInputStream(UserInfoManager.accountIcon))));
						addProfilePhotoIcon.setEffect(null);
					});
					return;
				}

				MFXDialogsUtil.showSimpleInformationDialog(getStage(), getRoot(), "Failed to add profile photo");
		});

		GlobalMessageDispatcher.getDispatcher()
			.observeMessages()
			.ofType(ClientIdEvent.class)
			.subscribe((ClientIdEvent event) -> {
				clientIDLabel.setText(String.valueOf(event.getClientId()));
		});

		GlobalMessageDispatcher.getDispatcher()
			.observeMessages()
			.ofType(UsernameReceivedEvent.class)
			.subscribe((UsernameReceivedEvent event) -> {
				changeDisplayNameTextField.setText(event.getDisplayName());
		});

		clientIDLabel.setText(String.valueOf(Client.getClientID()));

		changeDisplayNameTextField.setText(Client.getDisplayName());
		disableDisplayNameTextField();

		EventHandler<ActionEvent> handler = new EventHandler<ActionEvent>() {

			private int count = 0;

			@Override
			public void handle(ActionEvent event) {

				enableDisplayNameTextField();

				changeDisplayNameButton.setOnAction(new EventHandler<ActionEvent>() {

					@Override
					public void handle(ActionEvent event) {

						String newDisplayName = changeDisplayNameTextField.getText();

						if (newDisplayName.isBlank()) {
							return;
						}

						try {
							Client.getCommands().changeDisplayName(newDisplayName);
						} catch (IOException ioe) {
							logger.error(ioe.getMessage(), ioe);
						}
					}
				});

				// Listener to disable TextField and remove CSS once it loses focus
				ChangeListener<Boolean> focusListener = new ChangeListener<>() {

					private boolean set = false;

					@Override
					public void changed(ObservableValue<? extends Boolean> observable, 
							Boolean oldValue,
							Boolean newValue) {

						if (Boolean.TRUE.equals(newValue)) {
							return;
						}

						if (!set) {
							count++;
							set = true;
						}

						if (count == 2) {
							disableDisplayNameTextField();
							changeDisplayNameTextField.focusedProperty().removeListener(this);
							changeDisplayNameButton.focusedProperty().removeListener(this);
							changeDisplayNameButton.setOnAction((event) -> handle(event));
							count = 0;
						}
					}
				};

				// Listener to disable TextField and remove CSS once it loses focus
				ChangeListener<Boolean> focusListener2 = new ChangeListener<>() {

					private boolean set = false;

					@Override
					public void changed(ObservableValue<? extends Boolean> observable, 
							Boolean oldValue,
							Boolean newValue) {

						if (Boolean.TRUE.equals(newValue)) {
							return;
						}

						if (!set) {
							count++;
							set = true;
						}
					}
				};

				changeDisplayNameButton.focusedProperty().addListener(focusListener);
				changeDisplayNameTextField.focusedProperty().addListener(focusListener2);
			}
		};

		changeDisplayNameButton.setOnAction(handler);
	}

	private void enableDisplayNameTextField() {
		enableTextField(changeDisplayNameHbox, changeDisplayNameTextField, displayNameButtonImageView);
	}

	private void disableDisplayNameTextField() {
		disableTextField(changeDisplayNameHbox, changeDisplayNameTextField, displayNameButtonImageView);
	}

	private static void enableTextField(HBox hbox, TextField textField, ImageView textFieldButtonImageView) {
		textField.setDisable(false);
		textField.setEditable(true);
		textField.setFocusTraversable(true);
		textField.requestFocus();
		hbox.getStylesheets().add(SettingsInfo.AccountSettings.ACCOUNT_SETTINGS_FOCUSED_CSS_LOCATION);
		textFieldButtonImageView.setImage(Icons.CHECK);
	}

	private static void disableTextField(HBox hbox, TextField textField, ImageView textFieldButtonImageView) {
		textField.setDisable(true);
		textField.setEditable(false);
		textField.setFocusTraversable(false);
		hbox.getStylesheets().remove(SettingsInfo.AccountSettings.ACCOUNT_SETTINGS_FOCUSED_CSS_LOCATION);
		textFieldButtonImageView.setImage(Icons.EDIT);
	}

	public void setProfileIcon(byte[] iconBytes) {
		boolean isProfileEmpty = iconBytes == null || iconBytes.length == 0;

		if (isProfileEmpty) {
			addProfilePhotoIcon.setFill(new ImagePattern(Icons.ACCOUNT_HIGH_RES));
			addProfilePhotoIcon.setEffect(new DropShadow(+10d, 0d, +6d, Color.ROYALBLUE));
		} else {
			addProfilePhotoIcon.setFill(new ImagePattern(new Image(new ByteArrayInputStream(UserInfoManager.accountIcon))));
		}
	}

	@FXML
	public void addAccountIcon(MouseEvent event) throws IOException {
		FileChooser fileChooser = new FileChooser();
		fileChooser.setTitle("Add account icon");
		File iconFile = fileChooser.showOpenDialog(getStage());

		if (iconFile == null) {
			return;
		}

		Client.getCommands().addAccountIcon(iconFile);
	}

	@FXML
	public void transitionBackToPlainSettings(ActionEvent event) {
		Runnable transition = UITransitions.newBuilder()
				.setDirection(UITransitions.Direction.XAxis.LEFT_TO_RIGHT)
				.setDuration(Duration.seconds(0.5))
				.setInterpolator(Interpolator.EASE_BOTH)
				.setNewComponent(RootReferences.getSettingsRoot())
				.setOldComponent(getRoot())
				.setParentContainer((StackPane) getRoot().getParent())
				.setWhich(Which.OLD)
				.build();

		transition.run();
	}
}
