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

import java.util.List;
import java.util.Objects;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import github.koukobin.ermis.server.main.java.server.util.MessageByteBufCreator;
import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.ReplayingDecoder;

/**
 * @author Ilias Koukovinis
 *
 */
public abstract class Decoder extends ReplayingDecoder<ByteBuf> {

	private static final Logger LOGGER = LogManager.getLogger("server");
	
	private boolean isDecodingSuccessful;
	private boolean hasReadLength = false;
	private int length;
	
	protected Decoder() {}
	
	protected record DecodingResult(boolean isDecodingSuccessful, int length) {
	}

	@Override
	protected void decode(ChannelHandlerContext ctx, ByteBuf in, List<Object> out) throws Exception {
		ByteBuf payload = null;
		if (!hasReadLength) {
			length = in.readInt();
			ByteBuf retainedSlice = in.readRetainedSlice(length);

			// Allocate another ByteBuf since the one obtained through readRetainedSlice has
			// a maximum capacity the exact length provided; and will consequently overflow
			// if capacity is exceeded (By decompressing payload, for instance).
			payload = ctx.alloc().ioBuffer(length);
			payload.writeBytes(retainedSlice);

			int readerIndex = payload.readerIndex();
			isDecodingSuccessful = decodeMessage(ctx, payload);
			payload.readerIndex(readerIndex);

			checkpoint();
			hasReadLength = true;
		}

		if (isDecodingSuccessful) {
			assert payload != null;
			out.add(Objects.requireNonNull(payload));
		}

		isDecodingSuccessful = false;
		hasReadLength = false;
		checkpoint();
	}

	@Override
	public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
		LOGGER.debug("An error occured during decoding: ", cause);
	}
	
	/**
	 * 
	 * @param ctx
	 * @param length
	 * @param in
	 * @return Whether or not handling message was successful
	 */
	public abstract boolean decodeMessage(ChannelHandlerContext ctx, ByteBuf in);

	protected static void sendMessageExceedsMaximumMessageLength(ChannelHandlerContext ctx, int maxLength) {
		MessageByteBufCreator.sendMessageExceedsMaximumMessageLength(ctx, maxLength);
	}

	protected static void createErrorResponse(ChannelHandlerContext ctx, String message) {
		MessageByteBufCreator.sendMessageInfo(ctx, message);
	}
}
