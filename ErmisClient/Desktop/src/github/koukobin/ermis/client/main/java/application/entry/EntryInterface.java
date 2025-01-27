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

package github.koukobin.ermis.client.main.java.application.entry;

import java.io.IOException;

import github.koukobin.ermis.client.main.java.controllers.entry.CreateAccountSceneController;
import github.koukobin.ermis.client.main.java.controllers.entry.GeneralEntryController;
import github.koukobin.ermis.client.main.java.controllers.entry.LoginSceneController;
import github.koukobin.ermis.client.main.java.info.GeneralAppInfo;
import github.koukobin.ermis.client.main.java.info.Icons;
import github.koukobin.ermis.client.main.java.info.entry.EntryInfo;
import github.koukobin.ermis.common.entry.EntryType;
import github.koukobin.ermis.common.entry.LoginInfo.PasswordType;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Stage;

/**
 * @author Ilias Koukovinis
 *
 */
public class EntryInterface {

	private final FXMLLoader loader;

	private Stage stage;
	
	public EntryInterface() throws IOException {

		loader = new FXMLLoader(EntryInfo.Login.FXML_LOCATION);
		final Parent root = loader.load();
		final GeneralEntryController controller = loader.getController();
		controller.setFXMLLoader(loader);

		Scene scene = new Scene(root);
		root.getStylesheets().add(EntryInfo.Login.CSS_LOCATION);
		
		stage = new Stage();
		stage.setOnCloseRequest((event) -> System.exit(0));
		stage.getIcons().add(Icons.PRIMARY_APPLICATION_ICON_256);
		stage.setTitle(GeneralAppInfo.TITLE);
		stage.setResizable(false);
		stage.setScene(scene);
	}
	
	public void show() {
		stage.show();
	}
	
	public void showAndWait() {
		stage.showAndWait();
	}
	
	public String getUsername() {
		if (loader.getController() instanceof CreateAccountSceneController createAccountController) {
			return createAccountController.getUsername();
		}
	
		throw new UnsupportedOperationException("Can only get username when creating account!");
	}

	public String getEmail() {
		return loader.<GeneralEntryController>getController().getEmail();
	}

	public String getPassword() {
		return loader.<GeneralEntryController>getController().getPassword();
	}
	
	public PasswordType getPasswordType() {
		if (loader.getController() instanceof LoginSceneController loginController) {
			return loginController.getPasswordType();
		}
	
		throw new UnsupportedOperationException("Can only get password type when logging in!");
	}

	public EntryType getRegistrationType() {
		return loader.<GeneralEntryController>getController().getRegistrationType();
	}
}
