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
package github.koukobin.ermis.client.main.java.general_dialogs;

import java.util.Map;

import github.koukobin.ermis.client.main.java.info.GeneralAppInfo;
import github.koukobin.ermis.client.main.java.info.Icons;
import io.github.palexdev.materialfx.dialogs.MFXGenericDialog;
import io.github.palexdev.materialfx.dialogs.MFXGenericDialogBuilder;
import io.github.palexdev.materialfx.dialogs.MFXStageDialog;
import io.github.palexdev.materialfx.enums.ScrimPriority;
import javafx.event.EventHandler;
import javafx.scene.Node;
import javafx.scene.Parent;
import javafx.scene.effect.BoxBlur;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.Pane;
import javafx.scene.text.Font;
import javafx.stage.Modality;
import javafx.stage.Stage;

/**
 * @author Ilias Koukovinis
 *
 */
public class MFXDialog extends MFXStageDialog {

	protected static final Font defaultFont = Font.font(14);
	
	private static final BoxBlur blur = new BoxBlur(3, 3, 3);
	
	protected final MFXGenericDialog dialogContent;
	
	public MFXDialog(Stage stage, Parent rootPane) {
		
		dialogContent = MFXGenericDialogBuilder.build()
				.makeScrollable(true)
				.get();

		super.initModality(Modality.APPLICATION_MODAL);
		super.setDraggable(true);
		super.setTitle(GeneralAppInfo.TITLE);
		super.setOwnerNode((Pane) rootPane);
		super.setScrimPriority(ScrimPriority.NODE);
		super.setScrimOwner(true);

		if (stage != null && rootPane != null) {
			super.initOwner(stage);
			super.setOnHidden(e -> rootPane.setEffect(null));
			super.setOnShown(e -> rootPane.setEffect(blur));
		}

		super.setOnCloseRequest((e) -> this.close());
		super.setContent(dialogContent);
		super.getIcons().add(Icons.PRIMARY_APPLICATION_ICON_256);
	}

	@SafeVarargs
	public final void addActions(Map.Entry<Node, EventHandler<MouseEvent>>... actions) {
		dialogContent.addActions(actions);
	}
	
	public void setHeaderText(String headerText) {
		dialogContent.setHeaderText(headerText);
	}
	
	public void setContent(Node node) {
		dialogContent.setContent(node);
	}
	
	public void setContentText(String text) {
		dialogContent.setContentText(text);
	}
	
	public void setHeaderIcon(Node icon) {
		dialogContent.setHeaderIcon(icon);
	}
	
	public void addStyleClass(String style) {
		dialogContent.getStyleClass().add(style);
	}
}
