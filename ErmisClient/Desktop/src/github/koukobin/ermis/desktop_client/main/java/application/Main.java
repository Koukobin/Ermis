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
package github.koukobin.ermis.desktop_client.main.java.application;

import java.io.IOException;
import java.util.Optional;
import java.util.concurrent.CompletableFuture;

import github.koukobin.ermis.desktop_client.main.java.application.chat_interface.ChatInterface;
import github.koukobin.ermis.desktop_client.main.java.application.decide_server_to_connect.ChooseServerDialog;
import github.koukobin.ermis.desktop_client.main.java.application.entry.EntryInterface;
import github.koukobin.ermis.desktop_client.main.java.application.loading_screen.LoadingScreen;
import github.koukobin.ermis.desktop_client.main.java.application.starting_screen.StartingScreenInterface;
import github.koukobin.ermis.desktop_client.main.java.database.ClientDatabase;
import github.koukobin.ermis.desktop_client.main.java.database.models.LocalAccountInfo;
import github.koukobin.ermis.desktop_client.main.java.database.models.ServerInfo;
import github.koukobin.ermis.desktop_client.main.java.service.client.Client;
import github.koukobin.ermis.desktop_client.main.java.service.client.ClientInitializationException;
import github.koukobin.ermis.desktop_client.main.java.util.HostServicesUtil;
import github.koukobin.ermis.desktop_client.main.java.util.dialogs.CustomDialogButtonTypes;
import github.koukobin.ermis.desktop_client.main.java.util.dialogs.DialogsUtil;
import javafx.application.Application;
import javafx.application.Platform;
import javafx.scene.control.ButtonType;
import javafx.stage.Stage;

/**
 * @author Ilias Koukovinis
 *
 */
public class Main extends Application {

	public static void main(String[] args) {
		launch(args);
	}

	@Override
	public void start(Stage primaryStage) throws IOException {
		System.setProperty("prism.lcdtext", "false"); // Disable LCD anti-aliasing to improve text clarity
		HostServicesUtil.inititalize(getHostServices()); // Initialize HostServicesUtil

		// Show the starting screen and wait for it to close
		{
			StartingScreenInterface startingScreen = new StartingScreenInterface();
			startingScreen.showAndWait();
		}

		// Select server to connect to
		{
			boolean retry = true;
			LoadingScreen loadingScreen = new LoadingScreen();

			while (retry) {
				try {
					ChooseServerDialog dialog = new ChooseServerDialog();
					dialog.showAndWait();

					if (dialog.isCanceled()) {
						return;
					}

					ServerInfo serverInfo = dialog.getResult();
					if (serverInfo == null) {
						DialogsUtil.showErrorDialog("Server information cannot be empty!");
						continue;
					}

					Client.ServerCertificateVerification verify = dialog.shouldCheckServerCertificate()
							? Client.ServerCertificateVerification.VERIFY
							: Client.ServerCertificateVerification.IGNORE;

					CompletableFuture<ClientInitializationException> clientInitialization = CompletableFuture.supplyAsync(() -> {
	    				try {
	    					Client.initialize(serverInfo, verify);
	    					Client.syncWithServer();
	    					Optional<LocalAccountInfo> optionalInfo = ClientDatabase.getDBConnection().getLastUsedAccount(serverInfo);
							optionalInfo.ifPresent(Client::attemptHashedLogin);
						} catch (ClientInitializationException cie) {
							return cie;
						} finally {
							Platform.runLater(loadingScreen::close); // close loading screen
						}
						return null;
					});

					// Display loading screen while connecting
					loadingScreen.showAndWait();

					ClientInitializationException cie = clientInitialization.get();

					if (cie != null) {
						throw cie;
					}

					retry = false;
				} catch (Exception e) {

					Optional<ButtonType> exceptionDialogResult = DialogsUtil.showExceptionDialog(e);

	    			if (!exceptionDialogResult.isPresent() || exceptionDialogResult.get() == CustomDialogButtonTypes.EXIT_BUTTON) {
						return;
					}
				}
			}
		}

		Client.initiateMessageDispatcher();
		while (!Client.isLoggedIn()) {
			EntryInterface entryInterface = new EntryInterface();
			entryInterface.showAndWait();
		}

		// Start the chat interface
		ChatInterface chatInterface = new ChatInterface(primaryStage);
		chatInterface.start();
	}

}

