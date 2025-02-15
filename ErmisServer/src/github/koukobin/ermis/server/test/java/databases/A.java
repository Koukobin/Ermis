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
package github.koukobin.ermis.server.test.java.databases;

import java.util.Iterator;

import github.koukobin.ermis.common.message_types.UserMessage;
import github.koukobin.ermis.server.main.java.configs.ServerSettings;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.ErmisDatabase;

/**
 * @author Ilias Koukovinis
 *
 */
public class A {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		UserMessage[] messages;

		try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
			messages = conn.selectMessages(210, 
					0,
					ServerSettings.NUMBER_OF_MESSAGES_TO_READ_FROM_THE_DATABASE_AT_A_TIME,
					0);
			for (UserMessage userMessage : messages) {
				System.out.println(userMessage);
			}
		}
	}

}
