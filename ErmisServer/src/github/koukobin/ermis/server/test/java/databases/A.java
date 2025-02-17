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

import java.io.UnsupportedEncodingException;
import java.util.Iterator;

import com.github.luben.zstd.Zstd;

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
	 * @throws UnsupportedEncodingException 
	 */
	public static void main(String[] args) throws UnsupportedEncodingException {
		String d1 = new String(new byte[] { 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, (byte) 147, 100,
				102, 103, 108, 106, 107, 110, 100, 115, 102, 103, 104, 106, 108, 107, 59, 59, 59, 59, 59, 59, 59, 59,
				59, 59, 59, 59, 59, 100, 115, 102, 103, 106, 107, 104, 108, 100, 115, 102, 103, 107, 108, 104, 106, 100,
				115, 103, 102, 107, 106, 104, 108, 100, 115, 103, 102, 104, 107, 108, 106, 115, 100, 103, 102, 107, 108,
				104, 106, 100, 115, 102, 103, 107, 108, 104, 106, 100, 102, 115, 103, 107, 108, 106, 104, 100, 115, 102,
				103, 115, 108, 107, 106, 104, 100, 103, 115, 102, 107, 108, 104, 106, 103, 100, 102, 108, 104, 106, 107,
				103, 100, 102, 115, 108, 107, 106, 104, 103, 100, 102, 115, 107, 104, 106, 108, 100, 102, 103, 115, 106,
				107, 104, 108, 102, 103, 100, 115, 107, 106, 104, 100, 102, 103, 108, 104, 106, 107, 103 }, "utf8");
		byte[] d = { 40, (byte) 181, 47, (byte) 253, 96, (byte) 243, 0, (byte) 245, 0, 0, 112, 0, 0, 2,
				0, 1,
				(byte) 223, 109, 115, 103, 66, 121, 116, 101, 115, 5, 0, 62, (byte) 160, 2, 75,
				1, 5, (byte) 180,
				(byte) 130, 16, 80, (byte) 220, 2, 44 };
		System.out.println(d1);
		System.out.println(new String(Zstd.compress(d1.getBytes())));
		System.out.println(new String(Zstd.decompress(Zstd.compress(d1.getBytes()), (int) Zstd.decompressedSize(Zstd.compress(d1.getBytes())))));
		UserMessage[] messages;

//		try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
//			messages = conn.selectMessages(210, 
//					0,
//					ServerSettings.NUMBER_OF_MESSAGES_TO_READ_FROM_THE_DATABASE_AT_A_TIME,
//					0);
//			for (UserMessage userMessage : messages) {
//				System.out.println(userMessage);
//			}
//		}
	}

}
