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


import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.layout.Pane;
import javafx.stage.Stage;

/**
 * @author Ilias Koukovinis
 *
 */
public abstract class GeneralController implements Initializable {

	@FXML
	private Pane root;
	
	protected Pane getRoot() {
		return root;
	}
	
	/**
	 * 
	 * @return the very root node of the entire stage
	 */
	protected Pane getParentRoot() {
		
		Pane parentRoot = null;
		
		Pane parentRootTemp = getRoot();
		while (parentRootTemp != null) {
			parentRoot = parentRootTemp;
			parentRootTemp = (Pane) parentRootTemp.getParent();
		}
		
		return parentRoot;
	}
	
	protected Stage getStage() {
		return (Stage) root.getScene().getWindow();
	}

}
