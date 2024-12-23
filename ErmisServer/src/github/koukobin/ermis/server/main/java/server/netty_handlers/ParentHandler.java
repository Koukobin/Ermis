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
package github.koukobin.ermis.server.main.java.server.netty_handlers;

import java.io.IOException;
import java.time.Instant;
import java.util.concurrent.TimeUnit;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.google.common.base.Throwables;

import github.koukobin.ermis.server.main.java.server.ClientInfo;
import github.koukobin.ermis.server.main.java.server.util.MessageByteBufCreator;
import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.SimpleChannelInboundHandler;

/**
 * @author Ilias Koukovinis
 * 
 */
abstract sealed class ParentHandler extends SimpleChannelInboundHandler<ByteBuf> permits MessageHandler, StartingEntryHandler, EntryHandler, CommandHandler {

	protected static final Logger logger = LogManager.getLogger("server");

	private static final int MAX_REQUESTS_PER_SECOND = 10;
	private static final int BLOCK_DURATION_SECONDS = 10;

	private int requestCount;
	private boolean isBanned;
	private Instant lastMessageSent;

	protected final ClientInfo clientInfo;

	protected ParentHandler(ClientInfo clientInfo) {
		this.clientInfo = clientInfo;

		this.requestCount = 0;
		this.isBanned = false;
		this.lastMessageSent = Instant.now();
	}

	// Ensure this method is not ovveridable
	public final void channelRead(ChannelHandlerContext ctx, ByteBuf msg) throws Exception {
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
			if (requestCount > MAX_REQUESTS_PER_SECOND) {
				
				isBanned = true;
				
				// Block incoming messages for a certain time interval
				ctx.executor().schedule(() -> isBanned = false, BLOCK_DURATION_SECONDS, TimeUnit.SECONDS);
				MessageByteBufCreator.sendMessageInfo(ctx,
						"You have exceeded the maximum number of requests you can make per second. "
						+ "Consequently, you have been banned from any kind of interaction with the server for a short time interval.");
				return;
			}
		}

		lastMessageSent = currentTime;

		super.channelRead(ctx, msg); // Calls channelRead0
	}

	/**
	 * Abstract method to process the incoming ByteBuf message. Note: ByteBuf
	 * message is automatically released since this class extends
	 * SimpleChannelInboundHandler.
	 */
	public abstract void channelRead0(ChannelHandlerContext ctx, ByteBuf msg) throws IOException;

	@Override
	public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
		logger.error("Exception caught: {}", Throwables.getStackTraceAsString(cause));
	}
}

