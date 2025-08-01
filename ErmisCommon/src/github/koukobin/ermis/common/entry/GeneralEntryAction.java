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
package github.koukobin.ermis.common.entry;

/**
 * 
 * This enum indicates/signifies to the server that the message is an action and
 * not a credential
 * 
 * @author Ilias Koukovinis
 *
 */
public enum GeneralEntryAction {
	ACTION(117 /* Number chosen arbitrarily... */);

	public final int id;

	GeneralEntryAction(int id) {
		this.id = id;
	}
}
