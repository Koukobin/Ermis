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
import java.util.ResourceBundle;

import github.koukobin.ermis.client.main.java.info.GeneralAppInfo;
import github.koukobin.ermis.client.main.java.service.client.Client;
import github.koukobin.ermis.client.main.java.util.HostServicesUtil;
import github.koukobin.ermis.client.main.java.util.UITransitions;
import github.koukobin.ermis.client.main.java.util.UITransitions.Direction.Which;
import javafx.animation.Interpolator;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.Label;
import javafx.scene.layout.StackPane;
import javafx.util.Duration;

/**
 * @author Ilias Koukovinis
 *
 */
public class HelpSettingsController extends GeneralController {

	@FXML
	private Label versionLabel;
	
	@Override
	public void initialize(URL location, ResourceBundle resources) {
		versionLabel.setText(GeneralAppInfo.VERSION);
	}
	
	@FXML
	public void getSourceCodeWebsite(ActionEvent event) {
		HostServicesUtil.getHostServices().showDocument(GeneralAppInfo.SOURCE_CODE_HTML_PAGE_URL);
	}
	
	@FXML
	public void getDonationWebsite(ActionEvent event) throws IOException {
		Client.getCommands().requestDonationHTMLPage();
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
