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

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.net.URL;
import java.util.List;
import java.util.ResourceBundle;

import com.jfoenix.controls.JFXListCell;
import com.jfoenix.controls.JFXListView;

import github.koukobin.ermis.client.main.java.MESSAGE;
import github.koukobin.ermis.client.main.java.context_menu.MyContextMenuItem;
import github.koukobin.ermis.client.main.java.info.Icons;
import github.koukobin.ermis.client.main.java.service.client.ChatSession;
import github.koukobin.ermis.client.main.java.service.client.ChatSession.Member;
import github.koukobin.ermis.client.main.java.service.client.io_client.Client;
import github.koukobin.ermis.client.main.java.util.ContextMenusUtil;
import github.koukobin.ermis.client.main.java.util.Threads;
import io.github.palexdev.materialfx.controls.MFXProgressSpinner;
import javafx.application.Platform;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.fxml.FXML;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.ListView;
import javafx.scene.control.TextField;
import javafx.scene.image.Image;
import javafx.scene.input.KeyEvent;
import javafx.scene.input.MouseButton;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.HBox;
import javafx.scene.paint.Color;
import javafx.scene.paint.ImagePattern;
import javafx.scene.shape.Circle;
import javafx.util.Duration;

/**
 * @author Ilias Koukovinis
 *
 */
public class ChatsController extends GeneralController {

	@FXML
	private JFXListView<ChatSession> chatSessionsListView;

	@FXML
	private TextField searchForChatSessionsTextField;

	private Cell currentlySelectedCell;

	class Cell extends JFXListCell<ChatSession> {

		public Cell() {
			super();

			setOnMouseClicked((MouseEvent e) -> {
				if (e.getButton() != MouseButton.PRIMARY /* Left Click */) {
					return;
				}

				// If the user clicked the same active cell simply return
				if (this.equals(currentlySelectedCell)) {
					return;
				}
				currentlySelectedCell = this;

				ChatSession chatSession = this.getItem();

				RootReferences.getMessagingController().clearMessages();
				if (!chatSession.haveChatMessagesBeenCached()) {
					try {
						Client.getCommands().fetchWrittenText(chatSession.getChatSessionIndex());
					} catch (IOException ioe) {
						ioe.printStackTrace();
					}
				} else {
					List<MESSAGE> messages = chatSession.getMessages();
					RootReferences.getMessagingController().addMessages(
							messages.toArray(new MESSAGE[0]),
							chatSession.getChatSessionIndex(),
							getActiveChatSessionIndex());
				}
			});

			MyContextMenuItem delete = new MyContextMenuItem("Delete");
			delete.setOnAction(new EventHandler<ActionEvent>() {
				@Override
				public void handle(ActionEvent event) {
					try {
						Client.getCommands().deleteChatSession(getActiveChatSessionIndex());
					} catch (IOException ioe) {
						ioe.printStackTrace();
					}
				}
			});

			ContextMenusUtil.installContextMenu(this, Duration.seconds(2), delete);
		}

		@Override
		public void updateItem(ChatSession chatSession, boolean empty) {
			super.updateItem(chatSession, empty);

			setText(null);
			setGraphic(null);

			if (chatSession == null || empty) {
				return;
			}

			HBox hbox = new HBox();
			hbox.setAlignment(Pos.CENTER_LEFT);
			hbox.setPadding(new Insets(10));

			List<Member> members = chatSession.getMembers();
			for (int i = 0; i < members.size(); i++) {

				byte[] iconBytes = members.get(i).getIcon();

				Image profilePhoto;
				if (iconBytes.length > 0) {
					profilePhoto = new Image(new ByteArrayInputStream(members.get(i).getIcon()));
				} else {
					profilePhoto = Icons.ACCOUNT_LOW_RES;
				}

				Circle circle = new Circle();
				circle.setRadius(25);
				circle.setFill(new ImagePattern(profilePhoto));
				circle.setStroke(Color.SEAGREEN);

				Label label = new Label(members.get(i).toString());
				label.setPadding(new Insets(5));
				hbox.getChildren().addAll(circle, label);
			}

			setGraphic(hbox);
		}

	}

	@Override
	public void initialize(URL location, ResourceBundle resources) {
		chatSessionsListView.setCellFactory((ListView<ChatSession> param) -> new Cell());
	}

	@FXML
	public void searchChatSession(KeyEvent event) {
		String search = searchForChatSessionsTextField.getText();

		List<ChatSession> items = chatSessionsListView.getItems();

		for (int i = 0; i < items.size(); i++) {
			if (items.get(i).toString().contains(search) && i > 0) {
				ChatSession temp = items.get(i);
				items.set(i, items.get(i - 1));
				items.set(i - 1, temp);
			}
		}

		// Ensure the list view refreshes
		chatSessionsListView.refresh();
	}

	@FXML
	public void refreshChatSessionsListView(ActionEvent event) {
		try {
			Client.getCommands().fetchChatSessions();
			currentlySelectedCell = null;

			RootReferences.getMessagingController().clearMessages();
			MFXProgressSpinner progressSpinner = new MFXProgressSpinner();
			Button refreshButton = (Button) event.getSource();

			refreshButton.setDisable(true);
			getRoot().getChildren().remove(chatSessionsListView);
			getRoot().getChildren().add(progressSpinner);

			// Set a timer of 1 second and subsequently remove progress spinner
			// Very lazy but works perfectly fine
			Threads.delay(1000, () -> {
				Platform.runLater(() -> {
					refreshButton.setDisable(false);
					getRoot().getChildren().remove(progressSpinner);
					getRoot().getChildren().add(chatSessionsListView);
				});
			});
		} catch (IOException ioe) {
			ioe.printStackTrace();
		}
	}

	public void clearChatSessions() {
		chatSessionsListView.getItems().clear();
	}

	public void addChatSessions(Iterable<ChatSession> chatSessions) {
		for (ChatSession chatSession : chatSessions) {
			addChatSession(chatSession);
		}
	}

	public void addChatSession(ChatSession chatSession) {
		chatSessionsListView.getItems().add(chatSession);
	}

	public int getActiveChatSessionIndex() {
		// Check wether there is a currently selected cell or not
		if (currentlySelectedCell != null) {
			return chatSessionsListView.getSelectionModel().getSelectedIndex();
		}
		return -1;
	}

	public ChatSession getActiveChatSession() {
		return chatSessionsListView.getSelectionModel().getSelectedItem();
	}

}
