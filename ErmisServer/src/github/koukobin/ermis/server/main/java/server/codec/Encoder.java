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
package github.koukobin.ermis.server.main.java.server.codec;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.github.luben.zstd.Zstd;
import com.google.common.base.Throwables;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.MessageToByteEncoder;

/**
 * @author Ilias Koukovinis
 *
 */
public final class Encoder extends MessageToByteEncoder<ByteBuf> {

	private static final Logger LOGGER = LogManager.getLogger("server");

	private static final int COMPRESSION_LEVEL = 4; // 1 (fastest) to 22 (highest compression)

	@Override
	protected void encode(ChannelHandlerContext ctx, ByteBuf msg, ByteBuf out) throws Exception {
		int readableBytes = msg.readableBytes();

		if (readableBytes < 262144 /* 256 KB */) {
			out.writeInt(readableBytes);
			out.writeBytes(msg);
			return;
		}

		byte[] inputData = new byte[readableBytes];
		msg.readBytes(inputData);

		byte[] compressedData = compress(inputData);

		out.writeInt(compressedData.length);
		out.writeBytes(compressedData);
	}

	private static byte[] compress(byte[] data) {
		try {
			return Zstd.compress(data, COMPRESSION_LEVEL);
		} catch (Exception e) {
			LOGGER.debug(Throwables.getStackTraceAsString(e));
		}
		return data;
	}

	@Override
	public boolean acceptOutboundMessage(Object msg) throws Exception {
		return msg instanceof ByteBuf;
	}
}
