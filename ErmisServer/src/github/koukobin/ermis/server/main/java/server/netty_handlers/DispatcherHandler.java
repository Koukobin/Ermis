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

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import github.koukobin.ermis.common.message_types.ClientMessageType;
import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.ChannelInboundHandlerAdapter;

/**
 * @author Ilias Koukovinis
 *
 */
public final class DispatcherHandler extends ChannelInboundHandlerAdapter {

	private static final Logger LOGGER = LogManager.getLogger("server");

	@Override
	public void handlerRemoved(ChannelHandlerContext ctx) {
		LOGGER.debug("Dispatcher removed");
	}

	@Override
	public void channelInactive(ChannelHandlerContext ctx) {
		LOGGER.debug("Dispatcher inactive");
	}

	@Override
	public void channelRead(ChannelHandlerContext ctx, Object msgObject) throws Exception {
		ByteBuf msg = (ByteBuf) msgObject;
		ClientMessageType messageType = ClientMessageType.fromId(msg.readInt());

		switch (messageType) {
		case CLIENT_CONTENT -> {
			ctx.fireChannelRead(msg); // Fires the next handler in the pipeline i.e the MessageHandler
		}
		case ENTRY -> {
			ChannelHandlerContext handler = ctx.pipeline().context(CommandHandler.class);

			// If EntryHandler is not found, fallback to StartingEntryHandler
			if (handler == null) {
//				handler = ctx.pipeline().get(StartingEntryHandler.class);
				ctx.fireChannelRead(msg);
				return;

//				// If that handler is still not found, log error and terminate method
//				if (handler == null) {
//					LOGGER.error("Neither EntryHandler nor StartingEntryHandler found in pipeline.");
//					return;
//				}
			}

			handler.fireChannelRead(msg);
		}
		case COMMAND -> {
			ctx.pipeline().context(MessageHandler.class).fireChannelRead(msg);
		}
		default -> {
			LOGGER.debug("Client message type not recognized");
			msg.release();
		}
		}
	}

	@Override
	public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
		LOGGER.error("An error occured in the message dispatching handler", cause);
	}

}
