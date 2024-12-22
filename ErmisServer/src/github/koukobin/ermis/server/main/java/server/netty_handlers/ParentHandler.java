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
abstract sealed class ParentHandler extends SimpleChannelInboundHandler<ByteBuf> permits MessageHandler, StartingEntryHandler, EntryHandler {

	protected static final Logger logger = LogManager.getLogger("server");
	
	protected final ClientInfo clientInfo;

	protected ParentHandler(ClientInfo clientInfo) {
		this.clientInfo = clientInfo;
	}

	// Ensure this method is not ovveridable
	public final void channelRead(ChannelHandlerContext ctx, ByteBuf msg) throws Exception {
		super.channelRead(ctx, msg);
	}
	
	public final void channelRead0(ChannelHandlerContext ctx, ByteBuf msg) throws IOException {
		

		channelRead1(ctx, msg);
	}
	
	/**
	 * Note: ByteBuf message is automatically released since this class extends
	 * SimpleChannelInboundHandler.
	 */
	public abstract void channelRead1(ChannelHandlerContext ctx, ByteBuf msg) throws IOException;
	
	@Override
	public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
		logger.debug(Throwables.getStackTraceAsString(cause));
	}
}

