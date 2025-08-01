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
import java.util.List;

import github.koukobin.ermis.common.entry.GeneralEntryAction;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import io.netty.buffer.ByteBuf;
import io.netty.channel.Channel;
import io.netty.channel.ChannelHandlerContext;

/**
 * Abstract base class for handling entry-related actions in the application
 * pipeline.
 * 
 * @author Ilias Koukovinis
 *
 */
public abstract sealed class EntryHandler
	extends AbstractChannelClientHandler 
	permits
	    LoginHandler, 
	    CreateAccountHandler, 
	    VerificationHandler {

	protected EntryHandler(ClientInfo clientInfo) {
		super(clientInfo);
	}

	/**
	 * Executes non-related actions to the actual registration, which can be, for
	 * instance, adding device info
	 * 
	 */
	public abstract void executeEntryAction(ChannelHandlerContext ctx, ByteBuf msg) throws IOException;
	public abstract void channelRead1(ChannelHandlerContext ctx, ByteBuf msg) throws IOException;

	@Override
	public final void channelRead0(ChannelHandlerContext ctx, ByteBuf msg) throws IOException {
		msg.markReaderIndex();
		int isAction = msg.readInt();

		if (isAction == GeneralEntryAction.ACTION.id) {
			executeEntryAction(ctx, msg);
			return;
		}
		msg.resetReaderIndex();

		channelRead1(ctx, msg);
	}

	/**
	 * Transitions the pipeline to the message handler.
	 *
	 */
	public static void login(ChannelHandlerContext ctx, ClientInfo clientInfo) {
		// If a message handler already exists, simply remove this handler instead of
		// replacing with new one. This predicament would occur, in an instance, when a
		// client, already authenticated, attempts to add a new account while logged in.
		if (ctx.pipeline().get(MessageHandler.class) != null) {
			ctx.pipeline().remove(MessageHandler.class);
			ctx.pipeline().remove(CommandHandler.class);
		}

		cleanupEntryHandlerPipeline(ctx.channel());

		MessageHandler messageHandler = new MessageHandler(clientInfo);
		ctx.pipeline().addLast(MessageHandler.class.getName(), messageHandler);
		messageHandler.awaitInitialization();
		ctx.pipeline().addLast(CommandHandler.class.getName(), new CommandHandler(clientInfo));
	}

	/**
	 * Removes all entry related handlers from the pipeline; useful for ending and
	 * initiating authentication process while ensuring no leftover handler remains.
	 */
	public static void cleanupEntryHandlerPipeline(Channel channel) {
		class HandlersToBePurged {
			// List instead of array used because compiler throws Cannot create a generic
			// array of Class<? extends EntryHandler>
			private static final List<Class<? extends AbstractChannelClientHandler>> list = List.of(
				    LoginHandler.class,
				    CreateAccountHandler.class,
				    StartingEntryHandler.class,
				    VerificationHandler.class
			);

			// Add private constructor to eliminate annoying sonarlint warning
			private HandlersToBePurged() {}
		}

		for (var handler : HandlersToBePurged.list) {
			if (channel.pipeline().get(handler) != null) {
				channel.pipeline().remove(handler);
				continue;
			}

			getLogger().debug("Handler {} not found in pipeline", handler.getSimpleName());
		}
	}

	/**
	 * Reverts the pipeline to the starting entry handler.
	 *
	 */
	protected static void registrationFailed(ChannelHandlerContext ctx) {
		ctx.pipeline().remove(ctx.handler());

		// Ensure StartingEntryHandler exists
		if (ctx.pipeline().get(StartingEntryHandler.class) == null) {
			ctx.pipeline().addLast(StartingEntryHandler.class.getName(), new StartingEntryHandler());
		}

	}
}
