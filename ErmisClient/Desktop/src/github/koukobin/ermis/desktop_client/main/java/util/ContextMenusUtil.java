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
package github.koukobin.ermis.desktop_client.main.java.util;

import github.koukobin.ermis.desktop_client.main.java.context_menu.MyContextMenuItem;
import io.github.palexdev.materialfx.controls.MFXContextMenu;
import io.github.palexdev.materialfx.controls.MFXTooltip;
import javafx.event.EventHandler;
import javafx.scene.Node;
import javafx.scene.input.MouseButton;
import javafx.scene.input.MouseEvent;
import javafx.util.Duration;

/**
 * This utility class provides an easy way to add context menus to various items
 * throughout the application removing a lot of redundant code
 * 
 * @author Ilias Koukovinis
 *
 */
public final class ContextMenusUtil {

	private ContextMenusUtil() {}

	public static void installContextMenu(Node owner, Duration du, MyContextMenuItem... items) {

		final MFXContextMenu contextMenu = new MFXContextMenu(owner);
		contextMenu.addItems(items);

		MFXTooltip tooltip = setupTooltip(owner, du);

		EventHandler<? super MouseEvent> previousMouseEventHandler = owner.getOnMouseClicked();
		owner.setOnMouseClicked((MouseEvent e) -> {
			if (previousMouseEventHandler != null) {
				previousMouseEventHandler.handle(e);
			}
			if (e.getButton() == MouseButton.SECONDARY) {
				contextMenu.show((Node) e.getSource(), e.getScreenX(), e.getScreenY());
				tooltip.uninstall();

				contextMenu.setOnHidden((e2) -> tooltip.install());
			}
		});
	}

	/**
	 * Sets up a tooltip to guide users on using the context menu.
	 *
	 * @param owner the Node for which the tooltip is created
	 * @return the configured MFXTooltip
	 */
	private static MFXTooltip setupTooltip(Node owner, Duration du) {
		MFXTooltip tooltip = new MFXTooltip(owner);
		tooltip.setText("Right-click for more actions!");
		tooltip.setShowDelay(du);
		tooltip.install();
		return tooltip;
	}
}
