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

import github.koukobin.ermis.server.main.java.server.util.MessageByteBufCreator;
import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.ReplayingDecoder;

/**
 * @author Ilias Koukovinis
 *
 */
public abstract class Decoder extends ReplayingDecoder<ByteBuf> {

	private boolean isDecodingSuccessful;
	private boolean hasReadLength = false;
	private int length;

	protected Decoder() {}

	@Override
	protected void decode(ChannelHandlerContext ctx, ByteBuf in, List<Object> out) throws Exception {
		if (!hasReadLength) {
			length = in.readInt();

			int readerIndex = in.readerIndex();
			isDecodingSuccessful = decodeMessage(ctx, length, in);
			in.readerIndex(readerIndex);

			checkpoint();
			hasReadLength = true;
		}

		if (isDecodingSuccessful) {
			ByteBuf payload = in.readRetainedSlice(length);
			out.add(payload);
		} else {
			in.skipBytes(length);
		}

		isDecodingSuccessful = false;

		hasReadLength = false;
		checkpoint();
	}

	/**
	 * 
	 * @param ctx
	 * @param length
	 * @param in
	 * @return Whether or not handling message was successful
	 */
	public abstract boolean decodeMessage(ChannelHandlerContext ctx, int length, ByteBuf in);

	protected static void sendMessageExceedsMaximumMessageLength(ChannelHandlerContext ctx, int maxLength) {
		MessageByteBufCreator.sendMessageExceedsMaximumMessageLength(ctx, maxLength);
	}

	protected static void createErrorResponse(ChannelHandlerContext ctx, String message) {
		MessageByteBufCreator.sendMessageInfo(ctx, message);
	}
}
