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
import java.util.function.Consumer;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import github.koukobin.ermis.server.main.java.server.ActiveClients;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.ChannelInboundHandlerAdapter;
import io.netty.util.ReferenceCounted;

/**
 * Abstract base class for handling client-specific messages and requests over a
 * channel.
 * 
 * This class is intended to be extended by specific handlers that process
 * various types of client messages (e.g., MessageHandler, CommandHandler). It
 * manages the basic channel reading logic, ensures message cleanup, and handles
 * exceptions. Subclasses are required to implement the message processing logic
 * via the `channelRead0` method.
 * 
 * The class ensures that incoming messages are released automatically, and it
 * provides a logger for error handling.
 * 
 * @author Ilias Koukovinis
 * 
 */
abstract sealed class AbstractChannelClientHandler extends
		ChannelInboundHandlerAdapter permits MessageHandler, StartingEntryHandler, EntryHandler, CommandHandler {

	private static final Logger LOGGER = LogManager.getLogger("server");

	protected final ClientInfo clientInfo;

	/**
	 * Dictates whether of not to automatically release incoming messages after
	 * proccessing. For most cases, this should be set to true to avoid memory
	 * leaks, but in some instances you may not want the message to be released
	 * immediately after {@code channelRead0} is called.
	 */
	private final boolean autoRelease;

	/**
	 * Initializes an instance of the AbstractChannelClientHandler with auto release
	 * for incoming messages set to {@code true}.
	 * 
	 * @param clientInfo  The information associated with the client for handling their requests.
	 * @param autoRelease If {@code true}, incoming messages will be automatically released after processing.
	 */
	protected AbstractChannelClientHandler(ClientInfo clientInfo) {
		this(clientInfo, true);
	}

	protected AbstractChannelClientHandler(ClientInfo clientInfo, boolean autoRelease) {
		this.clientInfo = clientInfo;
		this.autoRelease = autoRelease;
	}

	@Override
	// Finaly ensures this method is not ovveridable
	public final void channelRead(ChannelHandlerContext ctx, Object msg) {
		boolean release = true;
		try {
			if (msg instanceof ByteBuf imsg) {
				channelRead0(ctx, imsg);
			} else {
				release = false;
				ctx.fireChannelRead(msg);
			}
		} catch (Exception ioe) {
			exceptionCaught(ctx, ioe);
		} finally {
			if (autoRelease && release) {
				if (msg instanceof ReferenceCounted referenceCounted) {
					if (referenceCounted.refCnt() > 0) {
						referenceCounted.release();
					} else {
						LOGGER.error("Illegal reference count");
					}
				}
			}
		}
	}

	/**
	 * Abstract method to process the incoming ByteBuf message. Note: ByteBuf
	 * message is automatically released since this class extends
	 * SimpleChannelInboundHandler.
	 */
	public abstract void channelRead0(ChannelHandlerContext ctx, ByteBuf msg) throws IOException;

	@Override
	public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
		LOGGER.error("Exception caught", cause);
	}

	/**
	 * Convience method for calling
	 * {@link github.koukobin.ermis.server.main.java.server.ActiveClients#forActiveAccounts(int, Consumer)}
	 */
	protected void forActiveAccounts(Consumer<ClientInfo> action) {
		ActiveClients.forActiveAccounts(clientInfo.getClientID(), action);
	}

	protected static final Logger getLogger() {
		return LOGGER;
	}
}

