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
package github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.hashing;

import java.security.SecureRandom;
import java.util.Base64;

import com.password4j.HashingFunction;
import com.password4j.Password;

/**
 * @author Ilias Koukovinis
 *
 */
public final class HashUtil {

	private static final SecureRandom secureRandom = new SecureRandom();
	private static final Base64.Encoder encoder = Base64.getEncoder();

	private HashUtil() {}

	public static SimpleHash createHash(String string, int saltLength, HashingFunction hashingFunction) {
		byte[] salt = new byte[saltLength];
		secureRandom.nextBytes(salt);

		return new SimpleHash(Password.hash(string).addSalt(encoder.encodeToString(salt)).with(hashingFunction));
	}

	public static SimpleHash createHash(String string, String salt, HashingFunction hashingFunction) {
		return new SimpleHash(Password.hash(string).addSalt(salt).with(hashingFunction));
	}
}
