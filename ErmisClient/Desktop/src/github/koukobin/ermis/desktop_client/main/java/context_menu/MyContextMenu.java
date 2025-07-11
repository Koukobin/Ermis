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
package github.koukobin.ermis.desktop_client.main.java.context_menu;

import io.github.palexdev.materialfx.controls.MFXContextMenu;
import javafx.scene.Node;

/**
 * This class fasciliates an easy switch if the need to change the context menu
 * arises, in which case we would not have to refactor the whole codebase.
 * 
 * This custom context menu item simplifys the menu management across the
 * application.
 * 
 * @author Ilias Koukovinis
 *
 */
public class MyContextMenu extends MFXContextMenu {

	public MyContextMenu(Node owner) {
		super(owner);
	}

	public void addItem(MyContextMenuItem item) {
		super.addItem(item);
	}

	public void addItems(MyContextMenuItem... items) {
		super.addItems(items);
	}
}
