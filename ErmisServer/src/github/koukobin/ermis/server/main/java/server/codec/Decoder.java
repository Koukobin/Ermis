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

import java.time.Instant;
import java.util.List;
import java.util.concurrent.TimeUnit;

import github.koukobin.ermis.server.main.java.server.util.MessageByteBufCreator;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.ReplayingDecoder;

/**
 * @author Ilias Koukovinis
 *
 */
public abstract class Decoder extends ReplayingDecoder<ByteBuf> {

	private static final int maxRequestsPerSecond = 10;
	private static final int blockDurationSeconds = 10;

	private int requestCount;
	private boolean isBanned;
	private Instant lastMessageSent;
	
	private boolean isDecodingSuccesful;
	private boolean hasReadLength = false;
	private int length;

	protected Decoder() {
		this.requestCount = 0;
		this.isBanned = false;
		this.lastMessageSent = Instant.now();
	}
	
	@Override
	protected void decode(ChannelHandlerContext ctx, ByteBuf in, List<Object> out) throws Exception {

		if (isBanned) {
			return; // Ignore further processing for this request
		}
		
		Instant currentTime = Instant.now();

		// If a second has passed since the last message was sent reset the request count.
		// Otherwise increment it and check whether or not it has exceeded the limit
		if (currentTime.getEpochSecond() - lastMessageSent.getEpochSecond() >= 1) {
			requestCount = 1;
		} else {
			requestCount++;
			if (requestCount > maxRequestsPerSecond) {
				
				isBanned = true;
				
				// Block incoming messages for a certain time interval
				ctx.executor().schedule(() -> isBanned = false, blockDurationSeconds, TimeUnit.SECONDS);
				MessageByteBufCreator.sendMessageInfo(ctx,
						"You have exceeded the maximum number of requests you can make per second. "
						+ "Consequently, you have been banned from any kind of interaction with the server for a short time interval.");
				return;
			}
		}
		
		lastMessageSent = currentTime;
		
		if (!hasReadLength) {

			length = in.readInt();

			int readerIndex = in.readerIndex();
			isDecodingSuccesful = handleMessage(ctx, length, in);
			in.readerIndex(readerIndex);

			checkpoint();
			hasReadLength = true;
		}

		if (isDecodingSuccesful) {
			ByteBuf payload = in.readRetainedSlice(length);
			out.add(payload);
		} else {
			in.skipBytes(length);
			isDecodingSuccesful = false;
		}

		hasReadLength = false;
		checkpoint();
	}
	
	/**
	 * 
	 * @param ctx
	 * @param length
	 * @param in
	 * @return Whether or not handling message was succesfull
	 */
	public abstract boolean handleMessage(ChannelHandlerContext ctx, int length, ByteBuf in);

	protected static void sendMessageExceedsMaximumMessageLength(ChannelHandlerContext ctx, int maxLength) {
		MessageByteBufCreator.sendMessageInfo(ctx, "Message length exceeds maximum length (" + maxLength + " characters)");
	}
	
	protected static void createErrorResponse(ChannelHandlerContext ctx, String message) {
		MessageByteBufCreator.sendMessageInfo(ctx, message);
	}
}
