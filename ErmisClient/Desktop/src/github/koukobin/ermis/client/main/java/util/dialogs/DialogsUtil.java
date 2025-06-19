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

import java.util.Optional;

import com.google.common.base.Throwables;

import github.koukobin.ermis.client.main.java.info.GeneralAppInfo;
import github.koukobin.ermis.client.main.java.info.Icons;
import javafx.scene.control.Alert;
import javafx.scene.control.ChoiceDialog;
import javafx.scene.control.Dialog;
import javafx.scene.control.DialogPane;
import javafx.scene.control.TextArea;
import javafx.scene.control.TextInputDialog;
import javafx.scene.control.Alert.AlertType;
import javafx.scene.control.ButtonType;
import javafx.scene.image.Image;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.Priority;
import javafx.scene.layout.Region;
import javafx.stage.Stage;

/**
 * @author Ilias Koukovinis
 *
 */
public class DialogsUtil {

	private DialogsUtil() {}

	public static Alert createConfirmationDialog() {
		return createConfirmationDialog("Confirmation!", "Are you sure you want to move foward with this action");
	}

	public static Alert createConfirmationDialog(String headerText, String contentText) {
		return createConfirmationDialog(headerText, contentText, new ButtonType[0]);
	}

	public static Alert createConfirmationDialog(String headerText, String contentText, ButtonType... buttons) {
		return createConfirmationDialog(headerText, contentText, AlertType.CONFIRMATION, buttons);
	}

	public static Alert createConfirmationDialog(String headerText, String contentText, AlertType alertType, ButtonType... buttons) {

		Alert alert = new Alert(alertType);
		alert.setTitle(GeneralAppInfo.TITLE);
		alert.getDialogPane().getScene().getWindow().sizeToScene();
		alert.setHeaderText(headerText);
		addButtons(alert, buttons);
		addPrimaryApplicationIon(alert);

		TextArea textArea = new TextArea(contentText);
		textArea.setEditable(false);
		textArea.setWrapText(false);
		textArea.setMaxWidth(Double.MAX_VALUE);
		textArea.setMaxHeight(Double.MAX_VALUE);
		GridPane.setVgrow(textArea, Priority.ALWAYS);
		GridPane.setHgrow(textArea, Priority.ALWAYS);

		GridPane content = new GridPane();
		content.setMaxWidth(Double.MAX_VALUE);
		content.add(textArea, 0, 1);
		alert.getDialogPane().setExpandableContent(content);

		return alert;
	}

	public static void showInfoDialog(String contentText) {

		Alert alert = new Alert(AlertType.INFORMATION);
		alert.setTitle(GeneralAppInfo.TITLE);
		alert.setHeaderText(null);
		alert.setContentText(contentText);
		alert.getDialogPane().setMinHeight(Region.USE_PREF_SIZE);
		addPrimaryApplicationIon(alert);

		alert.showAndWait();
	}

	public static void showSuccessDialog(String contentText) {

		TextArea textArea = new TextArea(contentText);
		textArea.setEditable(false);
		textArea.setWrapText(true);
		GridPane gridPane = new GridPane();
		gridPane.setMaxWidth(Double.MAX_VALUE);
		gridPane.add(textArea, 0, 0);

		Alert alert = new Alert(AlertType.INFORMATION);
		alert.setTitle(GeneralAppInfo.TITLE);
		alert.setHeaderText("Success!");
		alert.setContentText(contentText);
		alert.getDialogPane().setMinHeight(Region.USE_PREF_SIZE);
		alert.getDialogPane().setContent(gridPane);
		addPrimaryApplicationIon(alert);

		alert.showAndWait();
	}

	public static void showErrorDialog(String contentText) {

		Alert alert = new Alert(AlertType.ERROR);
		alert.setTitle(GeneralAppInfo.TITLE);
		alert.setHeaderText("Error!");
		alert.setContentText(contentText);
		alert.getDialogPane().setMinHeight(Region.USE_PREF_SIZE);
		addPrimaryApplicationIon(alert);

		alert.showAndWait();
	}
	
	public static Optional<ButtonType> showExceptionDialog(Throwable exception) {
		return DialogsUtil.createConfirmationDialog("An error occured: " + exception.getMessage(),
				Throwables.getStackTraceAsString(exception), AlertType.ERROR,
				CustomDialogButtonTypes.EXIT_BUTTON, CustomDialogButtonTypes.RETRY_BUTTON).showAndWait();
	}

	public static Alert createCustomAlertDialog(String headerText, String contentText, AlertType alertType,
			ButtonType... buttons) {

		Alert alert = new Alert(alertType);
		alert.setTitle(GeneralAppInfo.TITLE);
		alert.setHeaderText(headerText);
		alert.setContentText(contentText);
		addButtons(alert, buttons);
		addPrimaryApplicationIon(alert);

		return alert;
	}

	public static TextInputDialog createTextInputDialog(String headerText, String contentText, String defaultValue, ButtonType... buttons) {

		TextInputDialog serverToConnectToTD = new TextInputDialog(defaultValue);
		serverToConnectToTD.setHeaderText(headerText);
		serverToConnectToTD.setContentText(contentText);
		serverToConnectToTD.setTitle(GeneralAppInfo.TITLE);
		serverToConnectToTD.getDialogPane().getScene().getWindow().sizeToScene();
		addButtons(serverToConnectToTD, buttons);
		addPrimaryApplicationIon(serverToConnectToTD);

		return serverToConnectToTD;
	}
	
	public static <T> ChoiceDialog<T> createChoiceDialog(String headerText, String contentText, T defaultChoice, T[] choices, ButtonType... buttons){

		ChoiceDialog<T> choiceDialog = new ChoiceDialog<>(defaultChoice, choices);
		choiceDialog.setHeaderText(headerText);
		choiceDialog.setContentText(contentText);
		choiceDialog.setTitle(GeneralAppInfo.TITLE);
		choiceDialog.getDialogPane().getScene().getWindow().sizeToScene();
		addButtons(choiceDialog, buttons);
		addPrimaryApplicationIon(choiceDialog);

		return choiceDialog;
	}

	private static void addButtons(Dialog<?> dialog, ButtonType[] buttons) {

		if (buttons.length == 0) {
			return;
		}

		DialogPane dialogPane = dialog.getDialogPane();
		dialogPane.getButtonTypes().clear();
		dialogPane.getButtonTypes().addAll(buttons);
	}

	private static void addPrimaryApplicationIon(Dialog<?> dialog) {
		addIcon(dialog, Icons.PRIMARY_APPLICATION_ICON_256);
	}

	private static void addIcon(Dialog<?> dialog, Image image) {
		Stage stage = (Stage) dialog.getDialogPane().getScene().getWindow();
		stage.getIcons().add(image);
	}
}