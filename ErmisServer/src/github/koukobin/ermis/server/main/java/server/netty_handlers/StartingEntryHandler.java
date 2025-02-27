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
import java.net.InetAddress;

import github.koukobin.ermis.common.entry.EntryType;
import github.koukobin.ermis.server.main.java.configs.GeneralServerInfo;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.ErmisDatabase;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.ChannelHandlerContext;

/**
 * @author Ilias Koukovinis
 * 
 */
public final class StartingEntryHandler extends AbstractChannelClientHandler {

	private static final ByteBuf versionBuffer = Unpooled.unreleasableBuffer(Unpooled.wrappedBuffer(GeneralServerInfo.VERSION.getBytes()));
	
	public StartingEntryHandler() {
		super(new ClientInfo());
	}

	@Override
	public void handlerAdded(ChannelHandlerContext ctx) {
		ctx.channel().writeAndFlush(versionBuffer.duplicate());
		clientInfo.setChannel(ctx.channel());
	}

	@Override
	public void channelRead0(ChannelHandlerContext ctx, ByteBuf msg) throws IOException {
		msg.markReaderIndex();
		EntryType.fromId(msg.readInt()).ifPresentOrElse((EntryType entryType) -> {
			switch (entryType) {
			case LOGIN -> tryToLogin(ctx, msg, clientInfo);
			case CREATE_ACCOUNT -> {
				getLogger().debug("Moving into account creation!");

				if (ctx.pipeline().get(CreateAccountHandler.class) != null) {
					return;
				}

				if (ctx.pipeline().get(LoginHandler.class) != null) {
					ctx.pipeline().replace(LoginHandler.class, CreateAccountHandler.class.getName(), new CreateAccountHandler(clientInfo));
				} else {
					ctx.pipeline().addLast(CreateAccountHandler.class.getName(), new CreateAccountHandler(clientInfo));
				}
			}
			default -> getLogger().debug("Unknown registration type");
			}
		}, () -> {
			msg.resetReaderIndex();
			ctx.fireChannelRead(msg);
		});
	}

	private static void tryToLogin(ChannelHandlerContext ctx, ByteBuf msg, ClientInfo clientInfo) {
		// If no readable bytes in buffer, transition to LoginHandler
		if (msg.readableBytes() == 0) {
			getLogger().debug("Moving into login!");

			if (ctx.pipeline().get(LoginHandler.class) != null) {
				return;
			}

			if (ctx.pipeline().get(CreateAccountHandler.class) != null) {
				ctx.pipeline().replace(CreateAccountHandler.class, LoginHandler.class.getName(), new LoginHandler(clientInfo));
			} else {
				ctx.pipeline().addLast(LoginHandler.class.getName(), new LoginHandler(clientInfo));
			}

			return;
		}

		// Otherwise, authenticate client via email and passwordHash
		boolean isSuccessful = false;
		try {
			int emailLength = msg.readInt();
			byte[] emailBytes = new byte[emailLength];
			msg.readBytes(emailBytes);

			byte[] passwordHashBytes = new byte[msg.readableBytes()];
			msg.readBytes(passwordHashBytes);

			String email = new String(emailBytes);
			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				InetAddress address = clientInfo.getInetAddress();
				if (!conn.isLoggedIn(email, address)) {
					getLogger().debug("IP: {}, failed to login into email: {}, via password hash", address, email);
					return;
				}

				isSuccessful = conn.checkAuthenticationViaHash(email, new String(passwordHashBytes));
			}

			if (isSuccessful) {
				clientInfo.setEmail(email);
				EntryHandler.login(ctx, clientInfo);

				getLogger().debug("Successful login");
			}
		} catch (Exception e) {
			getLogger().debug("Error during authentication", e);
		} finally {
			// Regardless of authentication outcome inform success to user
			ctx.channel().writeAndFlush(Unpooled.copyBoolean(isSuccessful));
		}

	}

}
