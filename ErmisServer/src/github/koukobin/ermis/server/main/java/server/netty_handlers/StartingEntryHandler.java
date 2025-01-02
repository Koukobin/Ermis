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

import github.koukobin.ermis.common.entry.EntryType;
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

	public StartingEntryHandler() {
		super(new ClientInfo());
	}

//	public StartingEntryHandler(ClientInfo clientInfo) {
//		super(clientInfo);
//	}

	@Override
	public void handlerAdded(ChannelHandlerContext ctx) {
		ctx.channel().writeAndFlush(Unpooled.EMPTY_BUFFER); // Message denoting server is ready for messages
		clientInfo.setChannel(ctx.channel());
	}

	@Override
	public void channelRead0(ChannelHandlerContext ctx, ByteBuf msg) throws IOException {

		EntryType entryType = EntryType.fromId(msg.readInt());

		switch (entryType) {
		case LOGIN -> tryLogin(ctx, msg, clientInfo);
		case CREATE_ACCOUNT -> {
			getLogger().debug("Moving into account creation!");
			ctx.pipeline().replace(this, CreateAccountHandler.class.getName(), new CreateAccountHandler(clientInfo));
		}
		default -> getLogger().debug("Unknown registration type");
		}

	}

	private static void tryLogin(ChannelHandlerContext ctx, ByteBuf msg, ClientInfo clientInfo) {
		// If no readable bytes in buffer, transition to LoginHandler
		if (msg.readableBytes() == 0) {
			getLogger().debug("Moving into login!");
			ctx.pipeline().replace(ctx.handler(), LoginHandler.class.getName(), new LoginHandler(clientInfo));
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
				if (!conn.isLoggedIn(email, clientInfo.getInetAddress())) {
					getLogger().debug("Client not logged in: {}", clientInfo);
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
