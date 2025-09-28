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

import java.time.Instant;
import java.util.concurrent.TimeUnit;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.google.common.base.Throwables;

import github.koukobin.ermis.common.message_types.ServerInfoMessage;
import github.koukobin.ermis.server.main.java.server.util.MessageByteBufCreator;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.ChannelInboundHandlerAdapter;
import io.netty.util.ReferenceCountUtil;

/**
 * @author Ilias Koukovinis
 *
 */
public final class MessageRateLimiter extends ChannelInboundHandlerAdapter {

	private static final Logger LOGGER = LogManager.getLogger("server");

	private static final int MAX_REQUESTS_PER_DESIGNATED_TIME = 100;
	private static final int DESIGNATED_TIME_SECONDS = 5;
	private static final int BLOCK_DURATION_SECONDS = 10;

	private int requestCount;
	private boolean isBanned;
	private Instant lastMessageSent;

	@Override
	public void handlerAdded(ChannelHandlerContext ctx) {
		this.requestCount = 0;
		this.isBanned = false;
		this.lastMessageSent = Instant.now();
	}

	@Override
	public void channelRead(ChannelHandlerContext ctx, Object msg) {
		if (isBanned) {
			ReferenceCountUtil.release(msg);
			return; // Ignore further processing for this request
		}

		Instant currentTime = Instant.now();

		// If the designated time has passed since the last message was sent - reset the
		// request count. Otherwise, increment it and check whether or not it has
		// exceeded the limit.
		if (currentTime.getEpochSecond() - lastMessageSent.getEpochSecond() >= DESIGNATED_TIME_SECONDS) {
			requestCount = 1;
		} else {
			requestCount++;
			if (requestCount > MAX_REQUESTS_PER_DESIGNATED_TIME) {
				isBanned = true;

				// Block incoming messages for a certain time interval
				ctx.executor().schedule(() -> isBanned = false, BLOCK_DURATION_SECONDS, TimeUnit.SECONDS);
				MessageByteBufCreator.sendMessageInfo(ctx, ServerInfoMessage.TOO_MANY_REQUESTS_MADE.id);
				LOGGER.debug("User temporarily banned from server");
				return;
			}
		}
		lastMessageSent = currentTime;

		ctx.fireChannelRead(msg); // Forward message to next handler in the pipeline
	}

	@Override
	public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
		LOGGER.error("Exception caught: {}", Throwables.getStackTraceAsString(cause));
	}
}
