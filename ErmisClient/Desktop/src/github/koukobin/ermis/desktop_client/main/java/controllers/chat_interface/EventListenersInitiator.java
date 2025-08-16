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

import java.io.File;
import java.io.IOException;
import java.nio.file.FileAlreadyExistsException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

import javax.swing.filechooser.FileSystemView;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import github.koukobin.ermis.desktop_client.main.java.info.GeneralAppInfo;
import github.koukobin.ermis.desktop_client.main.java.service.client.GlobalMessageDispatcher;
import github.koukobin.ermis.desktop_client.main.java.service.client.Events.ChatRequestsEvent;
import github.koukobin.ermis.desktop_client.main.java.service.client.Events.ChatSessionsEvent;
import github.koukobin.ermis.desktop_client.main.java.service.client.Events.DonationPageEvent;
import github.koukobin.ermis.desktop_client.main.java.service.client.Events.FileDownloadedEvent;
import github.koukobin.ermis.desktop_client.main.java.service.client.Events.MessageDeletedEvent;
import github.koukobin.ermis.desktop_client.main.java.service.client.Events.MessageDeliveryStatusEvent;
import github.koukobin.ermis.desktop_client.main.java.service.client.Events.MessageReceivedEvent;
import github.koukobin.ermis.desktop_client.main.java.service.client.Events.ReceivedProfilePhotoEvent;
import github.koukobin.ermis.desktop_client.main.java.service.client.Events.ServerMessageInfoEvent;
import github.koukobin.ermis.desktop_client.main.java.service.client.Events.ServerSourceCodeEvent;
import github.koukobin.ermis.desktop_client.main.java.service.client.Events.WrittenTextEvent;
import github.koukobin.ermis.desktop_client.main.java.service.client.models.ChatRequest;
import github.koukobin.ermis.desktop_client.main.java.service.client.models.ChatSession;
import github.koukobin.ermis.desktop_client.main.java.service.client.models.Message;
import github.koukobin.ermis.desktop_client.main.java.util.HostServicesUtil;
import github.koukobin.ermis.desktop_client.main.java.util.dialogs.DialogsUtil;
import github.koukobin.ermis.desktop_client.main.java.util.dialogs.MFXDialogsUtil;
import javafx.application.Platform;
import javafx.scene.layout.Pane;
import javafx.stage.Stage;

/**
 * @author Ilias Koukovinis
 *
 */
class EventListenersInitiator {

	private static final Logger logger = LoggerFactory.getLogger(EventListenersInitiator.class);
	
	private EventListenersInitiator() {}

	static void initiateEventListeners(Stage stage, Pane rootPane) {
		// Server Message
		GlobalMessageDispatcher.getDispatcher().observeMessages().ofType(ServerMessageInfoEvent.class)
			.subscribe((ServerMessageInfoEvent event) -> {
				String msg = event.getMessage();
				Platform.runLater(() -> DialogsUtil.showInfoDialog(msg));
		});

		// Message received
		GlobalMessageDispatcher.getDispatcher()
		.observeMessages()
		.ofType(MessageReceivedEvent.class)
		.subscribe((MessageReceivedEvent event) -> {
			Message message = event.getMessage();
			int chatSessionIndex = event.getChatSession().getChatSessionIndex();

			int activeChatSessionIndex = RootReferences.getChatsController().getActiveChatSessionIndex();

			Platform.runLater(() -> {
				RootReferences.getMessagingController().printToMessageArea(
						message,
						chatSessionIndex,
						activeChatSessionIndex);

				RootReferences.getMessagingController().notifyUser(
						message,
						chatSessionIndex,
						activeChatSessionIndex);
			});
		});

		// Message successfully sent received
		GlobalMessageDispatcher.getDispatcher()
		.observeMessages()
		.ofType(MessageDeliveryStatusEvent.class)
		.subscribe((MessageDeliveryStatusEvent event) -> {
			RootReferences.getMessagingController().succesfullySentMessage(event.getMessage(), event.getDeliveryStatus());
		});

		// WrittenText fetched
		GlobalMessageDispatcher.getDispatcher()
			.observeMessages()
			.ofType(WrittenTextEvent.class)
			.subscribe((WrittenTextEvent event) -> {
				ChatSession chatSession = event.getChatSession();
				int chatSessionIndex = chatSession.getChatSessionIndex();
				List<Message> messages = chatSession.getMessages();

				Platform.runLater(() -> {
				for (int i = 0; i < messages.size(); i++) {
					Message message = messages.get(i);
							
					RootReferences.getMessagingController().printToMessageArea(
						message,
						chatSessionIndex,
						RootReferences.getChatsController().getActiveChatSessionIndex());
				}
			});
		});

		// File downloaded
		GlobalMessageDispatcher.getDispatcher()
			.observeMessages()
			.ofType(FileDownloadedEvent.class)
			.subscribe((FileDownloadedEvent event) -> {
				var file = event.getFile();
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
						logger.error(ioe.getMessage(), ioe);
					}
		});

		// Donation page url received

		GlobalMessageDispatcher.getDispatcher()
		.observeMessages()
		.ofType(DonationPageEvent.class)
		.subscribe((DonationPageEvent event) -> {
			Platform.runLater(() -> {
//				String html = donationPage.getHtml();
//				Path pathToCreateHtmlFile = Files.createTempFile(donationPage.getHtmlFileName(), ".html");
//				Files.write(pathToCreateHtmlFile, html.getBytes());
//				String htmlUrl = pathToCreateHtmlFile.toUri().toURL().toString();
				HostServicesUtil.getHostServices().showDocument(event.getDonationPageURL());
			});
		});

		// Server source code url received
		GlobalMessageDispatcher.getDispatcher()
		.observeMessages()
		.ofType(ServerSourceCodeEvent.class)
		.subscribe((ServerSourceCodeEvent event) -> {
			Platform.runLater(() -> HostServicesUtil.getHostServices().showDocument(event.getSourceCodeUrl()));
		});

		// Icon received

		GlobalMessageDispatcher.getDispatcher()
		.observeMessages()
		.ofType(ReceivedProfilePhotoEvent.class)
		.subscribe((ReceivedProfilePhotoEvent event) -> {
			Platform.runLater(() -> RootReferences.getAccountSettingsController().setProfileIcon(event.getPhotoBytes()));
		});
	
		// Chat sessions received

		GlobalMessageDispatcher.getDispatcher()
		.observeMessages()
		.ofType(ChatSessionsEvent.class)
		.subscribe((ChatSessionsEvent event) -> {
			List<ChatSession> chatSessions = event.getSessions();
			Platform.runLater(() -> {
				RootReferences.getChatsController().clearChatSessions();
				RootReferences.getChatsController().addChatSessions(chatSessions);
			});
		});

		// Chat requests received

		GlobalMessageDispatcher.getDispatcher()
		.observeMessages()
		.ofType(ChatRequestsEvent.class)
		.subscribe((ChatRequestsEvent event) -> {
			List<ChatRequest> chatRequests = event.getRequests();
			Platform.runLater(() -> {
				RootReferences.getChatRequestsController().clearChatRequests();
				RootReferences.getChatRequestsController().addChatRequests(chatRequests);
			});
		});

		// Message deleted
		GlobalMessageDispatcher.getDispatcher()
		.observeMessages()
		.ofType(MessageDeletedEvent.class)
		.subscribe((MessageDeletedEvent event) -> {
			ChatSession chatSession = event.getChatSession();
			int messageIDOfDeletedMessage = event.getMessageID();
			Platform.runLater(() -> {

				List<Message> messages = chatSession.getMessages();
				for (int i = 0; i < messages.size(); i++) {

					Message message = messages.get(i);

					if (message.getMessageID() == messageIDOfDeletedMessage) {
						messages.remove(i);

						int activeChatSessionIndex = RootReferences.getChatsController().getActiveChatSessionIndex();
						int chatSessionIndex = chatSession.getChatSessionIndex();

						if (activeChatSessionIndex == chatSessionIndex) {
							RootReferences.getMessagingController().clearMessages();
							RootReferences.getMessagingController().addMessages(messages.toArray(new Message[0]),
									chatSession.getChatSessionIndex(),
									RootReferences.getChatsController().getActiveChatSessionIndex());
						}

						break;
					}
					
				}

			});
		});

	}
}

