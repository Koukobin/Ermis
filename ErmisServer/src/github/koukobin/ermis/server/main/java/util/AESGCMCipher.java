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
package github.koukobin.ermis.server.main.java.util;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.SecretKey;

public final class AESGCMCipher {

	private final SecretKey secretKey;
	private final Cipher encryptionCipher;

	public AESGCMCipher(SecretKey secretKey, Cipher encryptionCipher) {
		this.secretKey = secretKey;
		this.encryptionCipher = encryptionCipher;
	}

	public byte[] encrypt(String message) throws IllegalBlockSizeException, BadPaddingException {
		return encrypt(message.getBytes());
	}

	public byte[] encrypt(byte[] message) throws IllegalBlockSizeException, BadPaddingException {
		return encryptionCipher.doFinal(message);
	}

	public byte[] getSecretKeyEncoded() {
		return secretKey.getEncoded();
	}

	public SecretKey getSecretKey() {
		return secretKey;
	}
}
