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
package github.koukobin.ermis.desktop_client.main.java.application.decide_server_to_connect;

import java.net.MalformedURLException;
import java.net.PortUnreachableException;
import java.net.URL;
import java.net.UnknownHostException;
import java.util.Map;

import github.koukobin.ermis.desktop_client.main.java.database.ClientDatabase;
import github.koukobin.ermis.desktop_client.main.java.database.models.ServerInfo;
import github.koukobin.ermis.desktop_client.main.java.general_dialogs.MFXActionDialog;
import github.koukobin.ermis.desktop_client.main.java.util.dialogs.DialogsUtil;
import io.github.palexdev.materialfx.controls.MFXButton;
import io.github.palexdev.materialfx.controls.MFXTextField;
import io.github.palexdev.materialfx.enums.FloatMode;
import javafx.scene.Parent;
import javafx.scene.input.MouseEvent;
import javafx.stage.Stage;

/**
 * @author Ilias Koukovinis
 *
 */
class AddServerDialog extends MFXActionDialog {

	private ServerInfo serverInfo;
	
	AddServerDialog(Stage stage, Parent rootPane, ClientDatabase.DBConnection serverInfoDatabaseConnection) {
		
		super(stage, rootPane);
		
		MFXTextField newServerTextField = new MFXTextField();
		newServerTextField.setFloatMode(FloatMode.ABOVE);
		newServerTextField.setPromptText("Server URL");
		newServerTextField.setFont(defaultFont);
		newServerTextField.setPrefColumnCount(25);
		
		dialogContent.setContent(newServerTextField);
		dialogContent.clearActions();
		dialogContent.addActions(
				Map.entry(new MFXButton("Save"), (MouseEvent e) -> {
					try {
						serverInfoDatabaseConnection.addServerInfo(new ServerInfo(new URL(newServerTextField.getText())));
					} catch (PortUnreachableException | UnknownHostException | MalformedURLException x) {
						DialogsUtil.showExceptionDialog(x);
					}
				}),
				Map.entry(new MFXButton("Add"), (MouseEvent e) -> {
					try {

						serverInfo = new ServerInfo(new URL(newServerTextField.getText()));

						isCanceled = false;
						super.close();
					} catch (MalformedURLException | UnknownHostException | PortUnreachableException x) {
						DialogsUtil.showExceptionDialog(x);
					}
				}), Map.entry(new MFXButton("Cancel"), (MouseEvent e) -> {
					isCanceled = true;
					super.close();
				}));
		
		dialogContent.setHeaderText("Add Server Dialog");
		dialogContent.autosize();
	}

	public ServerInfo getServerInfo() {
		return serverInfo;
	}
}
