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

import java.io.IOException;
import java.net.URL;
import java.util.List;
import java.util.ResourceBundle;

import com.jfoenix.controls.JFXButton;
import com.jfoenix.controls.JFXListCell;
import com.jfoenix.controls.JFXListView;

import github.koukobin.ermis.client.main.java.context_menu.MyContextMenu;
import github.koukobin.ermis.client.main.java.context_menu.MyContextMenuItem;
import github.koukobin.ermis.client.main.java.controllers.chat_interface.dialogs.SendChatRequestDialog;
import github.koukobin.ermis.client.main.java.service.client.Client;
import github.koukobin.ermis.client.main.java.service.client.models.ChatRequest;
import github.koukobin.ermis.client.main.java.util.Threads;
import io.github.palexdev.materialfx.controls.MFXProgressSpinner;
import javafx.application.Platform;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.fxml.FXML;
import javafx.scene.Node;
import javafx.scene.control.Button;
import javafx.scene.control.TextField;
import javafx.scene.input.KeyEvent;
import javafx.scene.input.MouseButton;
import javafx.scene.input.MouseEvent;

/**
 * @author Ilias Koukovinis
 *
 */
public class ChatRequestsController extends GeneralController {

	@FXML
	private JFXListView<ChatRequest> chatRequestsListView;
	
	@FXML
	private TextField searchForChatRequestsTextField;
	
	@FXML
	private JFXButton addChatRequestButton;
	
	@Override
	public void initialize(URL location, ResourceBundle resources) {

		final MyContextMenuItem delete = new MyContextMenuItem("Delete");
		final MyContextMenuItem accept = new MyContextMenuItem("Accept");
		final MyContextMenu contextMenu = new MyContextMenu(chatRequestsListView);
		contextMenu.addItems(accept, delete);
		
		chatRequestsListView.setOnMouseClicked((MouseEvent e) -> {

			if (!(e.getPickResult().getIntersectedNode() instanceof JFXListCell<?> cell)) {
				return;
			}
			
			if (e.getButton() == MouseButton.PRIMARY /* Left Click */ || e.getButton() == MouseButton.SECONDARY /* Right Click */) {

				ChatRequest chatRequest = (ChatRequest) cell.getItem();
				delete.setOnAction(new EventHandler<ActionEvent>() {
					@Override
					public void handle(ActionEvent event) {
						try {
							Client.getCommands().declineChatRequest(chatRequest.clientID());
						} catch (IOException ioe) {
							ioe.printStackTrace();
						}
					}
				});
				accept.setOnAction(new EventHandler<ActionEvent>() {

					@Override
					public void handle(ActionEvent event) {
						try {
							Client.getCommands().acceptChatRequest(chatRequest.clientID());
						} catch (IOException ioe) {
							ioe.printStackTrace();
						}
					}
				});
				
				contextMenu.show((Node) e.getSource(), e.getSceneX(), e.getScreenY());
			}
		});
		
		addChatRequestButton.setOnAction(new EventHandler<ActionEvent>() {

			@Override
			public void handle(ActionEvent event) {
				try {
					SendChatRequestDialog dialog = new SendChatRequestDialog(getStage(), getParentRoot());
					dialog.showAndWait();

					if (!dialog.isCanceled()) {
						int clientID = dialog.getChatRequest();
						Client.getCommands().sendChatRequest(clientID);
					}
				} catch (IOException ioe) {
					ioe.printStackTrace();
				}
			}
		});
	}
	
	@FXML
	public void searchChatRequests(KeyEvent event) {
		
		int num;

		try {
			num = Integer.parseInt(searchForChatRequestsTextField.getText());
		} catch (NumberFormatException nfe) {
			return;
		}
		
		List<ChatRequest> items = chatRequestsListView.getItems();

		// A simple bubble sort algorithm that sorts items based on the user's input (num)
		for (int i = 0; i < items.size(); i++) {
			
			boolean swapped = false;
			
			// reverse loop so sorted items appear from top to bottom and not from bottom to top
			for (int j = items.size() - 1; j > 0; j--) {

				int a = Math.abs(items.get(j).clientID() - num);
				int b = Math.abs(items.get(j - 1).clientID() - num);

				if (a < b) {
					ChatRequest temp = items.get(j);
					items.set(j, items.get(j - 1));
					items.set(j - 1, temp);
					swapped = true;
				}

			}
			
			 // If no swaps were made, the list is sorted and hence the break
			if (!swapped) {
				break;
			}
		}
	}
	
	@FXML
	public void refreshChatRequestsListView(ActionEvent event) throws IOException {
		Client.getCommands().fetchChatRequests();

		MFXProgressSpinner progressSpinner = new MFXProgressSpinner();
		Button refreshButton = (Button) event.getSource();
		
		refreshButton.setDisable(true);
		getRoot().getChildren().remove(chatRequestsListView);
		getRoot().getChildren().add(progressSpinner);
		
		// Just like in the ChatsController, set a timer of 1 second and subsequently remove progress spinner
		// Very lazy but works perfectly fine
		Platform.runLater(() -> {
			Threads.delay(1000, () -> {
				refreshButton.setDisable(false);
				getRoot().getChildren().remove(progressSpinner);
				getRoot().getChildren().add(chatRequestsListView);
			});
		});
	}
	
	public void clearChatRequests() {
		chatRequestsListView.getItems().clear();
	}
	
	public void addChatRequests(List<ChatRequest> chatRequests) {
		for (ChatRequest chatRequest : chatRequests) {
			addChatRequest(chatRequest);
		}
	}
	
	public void addChatRequest(ChatRequest chatRequest) {
		chatRequestsListView.getItems().add(chatRequest);
	}
	
}

