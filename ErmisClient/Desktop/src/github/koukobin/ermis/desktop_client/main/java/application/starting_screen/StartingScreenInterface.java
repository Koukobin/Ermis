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
package github.koukobin.ermis.desktop_client.main.java.application.starting_screen;

import github.koukobin.ermis.desktop_client.main.java.info.GeneralAppInfo;
import github.koukobin.ermis.desktop_client.main.java.info.Icons;
import github.koukobin.ermis.desktop_client.main.java.info.starting_screen.StartingScreenInfo;
import github.koukobin.ermis.desktop_client.main.java.util.Threads;
import io.github.palexdev.materialfx.controls.MFXProgressBar;
import javafx.animation.KeyFrame;
import javafx.animation.KeyValue;
import javafx.animation.Timeline;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.ContentDisplay;
import javafx.scene.control.Label;
import javafx.scene.image.ImageView;
import javafx.scene.layout.BorderPane;
import javafx.scene.paint.Color;
import javafx.stage.Stage;
import javafx.stage.StageStyle;
import javafx.util.Duration;

/**
 * @author Ilias Koukovinis
 *
 */
public class StartingScreenInterface {

	private static final int FADE_DURATION_MS = 550;
	private static final int DELAY_BEFORE_CLOSE_MS = 3000;
	
	private Stage stage;

	public StartingScreenInterface() {

		ImageView icon = new ImageView(Icons.PRIMARY_APPLICATION_ICON_512);
		icon.setFitWidth(StartingScreenInfo.ICON_WITDH);
		icon.setFitHeight(StartingScreenInfo.ICON_HEIGHT);
		icon.setPreserveRatio(false);

		Label label = new Label(GeneralAppInfo.GENERAL_NAME);
		label.setGraphic(icon);
		label.setContentDisplay(ContentDisplay.CENTER);

		MFXProgressBar spinner = new MFXProgressBar();
		BorderPane root = new BorderPane();

		Scene scene = new Scene(root, StartingScreenInfo.STAGE_WIDTH, StartingScreenInfo.STAGE_HEIGHT);
		scene.setFill(Color.TRANSPARENT);
		scene.getStylesheets().add(StartingScreenInfo.CSS_LOCATION);

		BorderPane.setAlignment(spinner, Pos.CENTER);
		BorderPane.setMargin(spinner, new Insets(0, 0, 50, 0));
		root.setCenter(label);
		root.setBottom(spinner);

		stage = new Stage();
		stage.initStyle(StageStyle.TRANSPARENT); // Removes window decorations
		stage.getIcons().add(Icons.PRIMARY_APPLICATION_ICON_256);
		stage.setScene(scene);
		stage.setOpacity(1.0f);
	}

	public void show() {
		stage.show();
	}

	public void close() {
		stage.close();
	}
	
	public void showAndWait() {
			
		// Set initial opacity to 0 for fade-in effect
		stage.getScene().getRoot().setOpacity(0.0);

		// Timeline for opacity transition
		Timeline timeline = new Timeline();
		KeyFrame fadeInKeyFrame = new KeyFrame(Duration.millis(FADE_DURATION_MS),
				new KeyValue(stage.getScene().getRoot().opacityProperty(), 1));
		timeline.getKeyFrames().add(fadeInKeyFrame);
		
		// Delay before closing the stage
		timeline.setOnFinished(e -> Threads.delay(DELAY_BEFORE_CLOSE_MS, stage::close));
		timeline.play();

		stage.showAndWait();
	}
	
	public void showAndWait1() {
		stage.showAndWait();
	}

}
