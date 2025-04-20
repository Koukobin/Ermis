/* Copyright (C) 2025 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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

import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;

import javax.crypto.spec.SecretKeySpec;

/**
 * @author Ilias Koukovinis
 *
 */
public final class AESKeyGenerator {

	private static final SecureRandom secureRandom = new SecureRandom();

	/**
	 * Standard IV length for GCM
	 */
	private static final int GCM_IV_LENGTH = 12;

	/**
	 * 128-bit authentication tag
	 */
	@SuppressWarnings("unused")
	private static final int TAG_LENGTH = 16;

	private AESKeyGenerator() {}

	public static byte[] generateRawSecretKey() {
		byte[] key = new byte[256 / 8];
		secureRandom.nextBytes(key);
		return key;
	}

	public static AESGCMCipher generateAESCipher() {
		try {
			KeyGenerator keyGen = KeyGenerator.getInstance("AES");
			keyGen.init(256); // 256 bit key size
			SecretKey secretKey = keyGen.generateKey();

			byte[] iv = new byte[12];
			secureRandom.nextBytes(iv);

			Cipher encryptionCipher = Cipher.getInstance("AES/GCM/NoPadding");
			encryptionCipher.init(Cipher.ENCRYPT_MODE, secretKey, new GCMParameterSpec(128, iv));

			return new AESGCMCipher(secretKey, encryptionCipher);
		} catch (NoSuchAlgorithmException | NoSuchPaddingException | InvalidKeyException
				| InvalidAlgorithmParameterException e) {
			e.printStackTrace(); // Shouldn't happen
			throw new RuntimeException(e);
		}
	}

	public static byte[] decrypt(byte[] key, byte[] iv, byte[] ciphertext) {
		if (ciphertext.length < GCM_IV_LENGTH) {
			throw new IllegalArgumentException("Ciphertext too short");
		}

		try {
			Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
			SecretKeySpec keySpec = new SecretKeySpec(key, "AES");
			GCMParameterSpec gcmSpec = new GCMParameterSpec(128, iv);
			cipher.init(Cipher.DECRYPT_MODE, keySpec, gcmSpec);

			return cipher.doFinal(ciphertext);
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}

	}
}
