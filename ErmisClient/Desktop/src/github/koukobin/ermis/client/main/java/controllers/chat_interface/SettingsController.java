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

import java.net.URL;
import java.util.ResourceBundle;

import github.koukobin.ermis.client.main.java.util.UITransitions;
import javafx.animation.Interpolator;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.layout.StackPane;
import javafx.util.Duration;

/**
 * @author Ilias Koukovinis
 *
 */
public class SettingsController extends GeneralController {

	@Override
	public void initialize(URL location, ResourceBundle resources) {
		// Do nothing.
	}

	@FXML
	public void transitionToAccountSettings(ActionEvent event) {
		Runnable transition = UITransitions.newBuilder()
				.setDirection(UITransitions.Direction.XAxis.RIGHT_TO_LEFT)
				.setDuration(Duration.seconds(0.5))
				.setInterpolator(Interpolator.EASE_BOTH)
				.setNewComponent(RootReferences.getAccountSettingsRoot())
				.setOldComponent(getRoot())
				.setParentContainer((StackPane) getRoot().getParent())
				.build();

		transition.run();
	}

	@FXML
	public void transitionToHelpSettings(ActionEvent event) {
		Runnable transition = UITransitions.newBuilder()
				.setDirection(UITransitions.Direction.XAxis.RIGHT_TO_LEFT)
				.setDuration(Duration.seconds(0.5))
				.setInterpolator(Interpolator.EASE_BOTH)
				.setNewComponent(RootReferences.getHelpSettingsRoot())
				.setOldComponent(getRoot())
				.setParentContainer((StackPane) getRoot().getParent())
				.build();

		transition.run();
	}
}
