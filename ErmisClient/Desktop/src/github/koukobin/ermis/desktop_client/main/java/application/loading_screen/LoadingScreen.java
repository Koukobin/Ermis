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
package github.koukobin.ermis.desktop_client.main.java.application.loading_screen;

import github.koukobin.ermis.desktop_client.main.java.info.Icons;
import io.github.palexdev.materialfx.controls.MFXProgressSpinner;
import javafx.scene.Scene;
import javafx.scene.layout.StackPane;
import javafx.scene.paint.Color;
import javafx.stage.Stage;
import javafx.stage.StageStyle;

/**
 * @author Ilias Koukovinis
 *
 */
public class LoadingScreen {

	private Stage stage;

	public LoadingScreen() {

		MFXProgressSpinner spinner = new MFXProgressSpinner();
		spinner.setPrefSize(100, 100);
		
		StackPane root = new StackPane();
		root.setStyle("-fx-background-color: transparent;");
		root.getChildren().add(spinner);

		Scene scene = new Scene(root);
		scene.setFill(Color.TRANSPARENT);

		stage = new Stage();
		stage.initStyle(StageStyle.TRANSPARENT); // Removes window decorations
		stage.getIcons().add(Icons.PRIMARY_APPLICATION_ICON_256);
		stage.setScene(scene);
	}

	public void show() {
		stage.show();
	}
	
	public void showAndWait() {
		stage.showAndWait();
	}
	
	public void close() {
		stage.close();
	}
	
}
