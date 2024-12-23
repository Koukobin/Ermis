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
package github.koukobin.ermis.client.main.java.controllers.chat_interface;

import java.io.File;
import java.io.IOException;
import java.nio.file.FileAlreadyExistsException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

import javax.swing.filechooser.FileSystemView;

import github.koukobin.ermis.client.main.java.info.GeneralAppInfo;
import github.koukobin.ermis.client.main.java.service.client.ChatRequest;
import github.koukobin.ermis.client.main.java.service.client.ChatSession;
import github.koukobin.ermis.client.main.java.service.client.DonationHtmlPage;
import github.koukobin.ermis.client.main.java.service.client.io_client.MessageHandler;
import github.koukobin.ermis.client.main.java.util.HostServicesUtil;
import github.koukobin.ermis.client.main.java.util.dialogs.DialogsUtil;
import github.koukobin.ermis.client.main.java.util.dialogs.MFXDialogsUtil;
import github.koukobin.ermis.common.LoadedInMemoryFile;
import github.koukobin.ermis.common.message_types.UserMessage;
import javafx.application.Platform;
import javafx.scene.layout.Pane;
import javafx.stage.Stage;

/**
 * @author Ilias Koukovinis
 *
 */
class ImplementedMessageHandler extends MessageHandler {
	
	private Stage stage;
	private Pane rootPane;
	
	public ImplementedMessageHandler(Stage stage, Pane rootPane) {
		this.stage = stage;
		this.rootPane = rootPane;
	}
	
	@Override
	public void serverMessageReceived(String message) {
		Platform.runLater(() -> DialogsUtil.showInfoDialog(message));						
	}
	
	@Override
	public void messageReceived(UserMessage message, int chatSessionIndex) {
		Platform.runLater(new Runnable() {
			
			@Override
			public void run() {

				int activeChatSessionIndex = RootReferences.getChatsController().getActiveChatSessionIndex();
				
				RootReferences.getMessagingController().printToMessageArea(
						message,
						chatSessionIndex,
						activeChatSessionIndex);

				RootReferences.getMessagingController().notifyUser(
						message,
						chatSessionIndex,
						activeChatSessionIndex);
			}
		});
	}
	
	@Override
	public void messageSuccesfullySentReceived(ChatSession chatSession, int messageID) {
		RootReferences.getMessagingController().succesfullySentMessage(chatSession, messageID);
	}

	@Override
	public void alreadyWrittenTextReceived(ChatSession chatSession) {
		Platform.runLater(() -> {
			
			int chatSessionIndex = chatSession.getChatSessionIndex();
			List<UserMessage> messages = chatSession.getMessages();
			
			for (int i = 0; i < messages.size(); i++) {
				
				UserMessage message = messages.get(i);

				RootReferences.getMessagingController().printToMessageArea(
						message, 
						chatSessionIndex, 
						RootReferences.getChatsController().getActiveChatSessionIndex());
			}
		});
	}

	@Override
	public void fileDownloaded(LoadedInMemoryFile file) {
		try {

			String dirPathString = FileSystemView.getFileSystemView().getDefaultDirectory().getPath()
					+ "/Documents/" + GeneralAppInfo.GENERAL_NAME + "Downloads/";
			Path dirPath = Paths.get(dirPathString);

			try {
				Files.createDirectory(dirPath);
			} catch (FileAlreadyExistsException faee) {
				// Do nothing
			}

			Path filePath = Paths.get(dirPathString + File.separator + file.getFileName());
			Files.write(filePath, file.getFileBytes());

			Platform.runLater(() -> MFXDialogsUtil.showSimpleInformationDialog(stage, rootPane, "Succesfully saved file!"));
		} catch (IOException ioe) {
			ioe.printStackTrace();
		}
	}
	
	@Override
	public void donationPageReceived(DonationHtmlPage donationPage) {
		Platform.runLater(() -> {
			try {
				String html = donationPage.getHtml();
				Path pathToCreateHtmlFile = Files.createTempFile(donationPage.getHtmlFileName(), ".html");
				Files.write(pathToCreateHtmlFile, html.getBytes());
				String htmlUrl = pathToCreateHtmlFile.toUri().toURL().toString();
				
				HostServicesUtil.getHostServices().showDocument(htmlUrl);
			} catch (IOException ioe) {
				ioe.printStackTrace();
			}
		});
	}
	
	@Override
	public void serverSourceCodeReceived(String serverSourceCodeURL) {
		Platform.runLater(() -> HostServicesUtil.getHostServices().showDocument(serverSourceCodeURL));
	}

	@Override
	public void usernameReceived(String username) {
		// Do nothing.
	}
	
	@Override
	public void clientIDReceived(int clientID) {
		// Do nothing.
	}
	
	@Override
	public void iconReceived(byte[] icon) {
		Platform.runLater(() -> RootReferences.getAccountSettingsController().setIcon(icon));
	}

	@Override
	public void chatSessionsReceived(List<ChatSession> chatSessions) {
		Platform.runLater(() -> {
			RootReferences.getChatsController().clearChatSessions();
			RootReferences.getChatsController().addChatSessions(chatSessions);
		});
	}
	
	@Override
	public void chatRequestsReceived(List<ChatRequest> chatRequests) {
		Platform.runLater(() -> {
			RootReferences.getChatRequestsController().clearChatRequests();
			RootReferences.getChatRequestsController().addChatRequests(chatRequests);
		});
	}

	@Override
	public void messageDeleted(ChatSession chatSession, int messageIDOfDeletedMessage) {
		Platform.runLater(() -> {

			List<UserMessage> messages = chatSession.getMessages();
			for (int i = 0; i < messages.size(); i++) {

				UserMessage message = messages.get(i);

				if (message.getMessageID() == messageIDOfDeletedMessage) {

					messages.remove(i);

					int activeChatSessionIndex = RootReferences.getChatsController().getActiveChatSessionIndex();
					int chatSessionIndex = chatSession.getChatSessionIndex();
					
					if (activeChatSessionIndex == chatSessionIndex) {
						RootReferences.getMessagingController().clearMessages();
						RootReferences.getMessagingController().addMessages(messages.toArray(new UserMessage[0]),
								chatSession.getChatSessionIndex(),
								RootReferences.getChatsController().getActiveChatSessionIndex());
					}

					break;
				}

			}

		});
	}
}


