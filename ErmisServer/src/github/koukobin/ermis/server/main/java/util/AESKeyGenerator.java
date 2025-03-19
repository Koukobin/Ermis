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
import java.util.Arrays;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.KeyGenerator;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;

import io.netty.buffer.ByteBuf;
import javax.crypto.spec.SecretKeySpec;

/**
 * @author Ilias Koukovinis
 *
 */
public final class AESKeyGenerator {

	private static final SecureRandom secureRandom = new SecureRandom();
	
	private AESKeyGenerator() {}
	
	public static byte[] genereateRawSecretKey() {
		// KeyGenerator keyGen = KeyGenerator.getInstance("AES");
		// keyGen.init(256); // Key size: 128, 192, or 256 bits
		byte[] key = new byte[256 / 8];
		secureRandom.nextBytes(key);
		return new byte[] {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
	}

	public static AESGCMCipher generateAESKeyWithoutIV() {
		try {
			KeyGenerator keyGen = KeyGenerator.getInstance("AES");
			keyGen.init(256); // Key size: 128, 192, or 256 bits
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
	
    private static final int IV_LENGTH = 12; // Standard IV length for GCM
    private static final int TAG_LENGTH = 16; // 128-bit authentication tag
    
	public static byte[] decrypt(SecretKey secretKey, byte[] fullCiphertext) {
		System.out.println(new String(fullCiphertext));
	    if (fullCiphertext.length < IV_LENGTH + TAG_LENGTH) {
	        throw new IllegalArgumentException("Ciphertext too short");
	    }

	    // Extract IV
	    byte[] iv = Arrays.copyOfRange(fullCiphertext, 0, IV_LENGTH);
	    byte[] ciphertext = Arrays.copyOfRange(fullCiphertext, IV_LENGTH, fullCiphertext.length);

	    Cipher cipher = null;
		try {
			cipher = Cipher.getInstance("AES/GCM/NoPadding");
		} catch (NoSuchAlgorithmException | NoSuchPaddingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	    GCMParameterSpec spec = new GCMParameterSpec(TAG_LENGTH * 8, iv);
	    try {
			cipher.init(Cipher.DECRYPT_MODE, secretKey, spec);
		} catch (InvalidKeyException | InvalidAlgorithmParameterException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	    try {
			return cipher.doFinal(ciphertext);
		} catch (IllegalBlockSizeException | BadPaddingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return ciphertext;
	}
	
	public static String bytesToHex(byte[] bytes) {
		StringBuilder sb = new StringBuilder();
		for (byte b : bytes) {
			sb.append(String.format("%02x", b));
		}
		return sb.toString();
	}
}
