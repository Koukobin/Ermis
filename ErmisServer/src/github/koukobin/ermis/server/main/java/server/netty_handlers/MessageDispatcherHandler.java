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

import java.util.Map;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import github.koukobin.ermis.common.message_types.ClientMessageType;
import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandler;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.SimpleChannelInboundHandler;

/**
 * @author Ilias Koukovinis
 *
 */
public final class MessageDispatcherHandler extends SimpleChannelInboundHandler<ByteBuf> {

	private static final Logger logger = LogManager.getLogger("server");
	
	private Map<String, ChannelHandler> pipelineMap;
	
	@Override
	public void handlerAdded(ChannelHandlerContext ctx) {
		pipelineMap = ctx.pipeline().toMap();
		
		ByteBuf payload = ctx.alloc().ioBuffer();
		for (String pipelineHandler : pipelineMap.keySet()) {
			payload.writeInt(pipelineHandler.length());
			payload.writeBytes(pipelineHandler.getBytes());
		}
		
		ctx.channel().writeAndFlush(payload);
	}
	
	@Override
	protected void channelRead0(ChannelHandlerContext ctx, ByteBuf msg) throws Exception {
		ClientMessageType messageType = ClientMessageType.fromId(msg.readInt());

		switch (messageType) {
		case CLIENT_CONTENT -> {
			ctx.fireChannelRead(msg);
		}
		case CREATE_ACCOUNT -> {
			((EntryHandler) ctx.pipeline().get(CreateAccountHandler.class.getName())).channelRead0(ctx, msg);
		}
		case LOGIN -> {
			((EntryHandler) ctx.pipeline().get(LoginHandler.class.getName())).channelRead0(ctx, msg);
		}
		case COMMAND -> {
			((CommandHandler) ctx.pipeline().get(CommandHandler.class.getName())).channelRead0(ctx, msg);
		}
		default -> logger.debug("Client message type not recognized");
		}
	}

	@Override
    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
        logger.error("An error occured in the message dispatching handler", cause);
    }

}
