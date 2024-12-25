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

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;

/**
 * Simple decoder intended for lightweight operations with small message sizes.
 * This decoder is typically replaced with the main decoder after registration.
 *
 * @author Ilias Koukovinis
 *
 */
public final class SimpleDecoder extends Decoder {

    /**
     * The maximum allowable length for a message processed by this decoder.
     * This value is deliberately small to suit simple operations.
     */
	public static final int MAX_LENGTH = 500; 

    /**
     * Validates and processes incoming messages.
     * 
     * @param ctx the channel handler context
     * @param length the length of the incoming message
     * @param in the message data buffer
     * @return {@code true} if the message is valid and within length limits; {@code false} otherwise
     */
	@Override
	public boolean handleMessage(ChannelHandlerContext ctx, int length, ByteBuf in) {

		// Validate message length
		if (MAX_LENGTH < length) {
			sendMessageExceedsMaximumMessageLength(ctx, MAX_LENGTH);
			return false; // Failure
		}

		return true; // Success
	}

}
