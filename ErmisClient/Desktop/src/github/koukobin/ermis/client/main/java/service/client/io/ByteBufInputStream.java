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
package github.koukobin.ermis.client.main.java.service.client.io;

import java.io.IOException;
import java.io.InputStream;

import com.github.luben.zstd.Zstd;
import com.google.common.primitives.Ints;

import github.koukobin.ermis.common.util.CompressionDetector;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;

/**
 * @author Ilias Koukovinis
 *
 */
public class ByteBufInputStream implements AutoCloseable {

	private final InputStream in;

	public ByteBufInputStream(InputStream in) {
		this.in = in;
	}

	public ByteBuf read() throws IOException {
		byte[] lengthOfMsgBytes = new byte[Integer.BYTES];
		read(lengthOfMsgBytes);

		int lengthOfMsg = Ints.fromByteArray(lengthOfMsgBytes);

		byte[] msgBytes = new byte[lengthOfMsg];
		read(msgBytes);

		if (CompressionDetector.isZstdCompressed(msgBytes)) {
			return zstdDecompress(msgBytes);
		}

		return Unpooled.wrappedBuffer(msgBytes);
	}

	private void read(byte[] b) throws IOException {
		read(b, 0, b.length);
	}

	private void read(byte[] b, int off, int len) throws IOException {
		int readPos = off;
		while (readPos < len) {
			int numOfBytesToRead = len - readPos;
			int count = in.read(b, readPos, numOfBytesToRead);
			readPos += count;
		}
	}

	private static ByteBuf zstdDecompress(byte[] compressedData) throws IOException {
		try {
			byte[] decompressedBytes = Zstd.decompress(compressedData, (int) Zstd.decompressedSize(compressedData));
			return Unpooled.wrappedBuffer(decompressedBytes);
		} catch (Exception e) {
			throw new IOException("Failed to decompress data", e);
		}
	}

	@Override
	public void close() throws IOException {
		in.close();
	}
}
