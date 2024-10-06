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
package main.java.server.netty_handlers;

import java.util.EnumMap;
import java.util.Map;

import javax.mail.MessagingException;

import org.chatapp.commons.EnumIntConverter;
import org.chatapp.commons.ResultHolder;
import org.chatapp.commons.entry.CreateAccountInfo.Credential;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import main.java.configs.ServerSettings;
import main.java.databases.postgresql.chatapp_database.ChatAppDatabase;
import main.java.server.ClientInfo;

/**
 * @author Ilias Koukovinis
 * 
 */
final class CreateAccountHandler extends EntryHandler {

	private Map<Credential, String> credentials = new EnumMap<>(Credential.class);
	
	CreateAccountHandler(ClientInfo clientInfo) {
		super(clientInfo);
	}
	
	@Override
	public void doEntryAction(ByteBuf msg) {
		// Do nothing
	}
	
	@Override
	public void channelRead(ChannelHandlerContext ctx, ByteBuf msg) throws Exception {
		
		{
			Credential credential = EnumIntConverter.getIntAsEnum(msg.readInt(), Credential.class);

			byte[] payloadBytes = new byte[msg.readableBytes()];
			msg.readBytes(payloadBytes);

			credentials.put(credential, new String(payloadBytes));
		}
		
		if (credentials.size() == Credential.values().length) {
			
			String username = credentials.get(Credential.USERNAME);
			String password = credentials.get(Credential.PASSWORD);
			String email = credentials.get(Credential.EMAIL);
			
			ResultHolder resultHolder;
			try (ChatAppDatabase.GeneralPurposeDBConnection conn = ChatAppDatabase.getGeneralPurposeConnection()) {
				resultHolder = conn.checkIfUserMeetsRequirementsToCreateAccount(username, password, email);
			}
			
			ByteBuf payload = ctx.alloc().ioBuffer();
			payload.writeBoolean(resultHolder.isSuccesfull());
			
			if (resultHolder.isSuccesfull()) {
				success(ctx);
			} else {
				failed(ctx);
			}
			
			byte[] resultMessageBytes = resultHolder.getResultMessage().getBytes();
			payload.writeBytes(resultMessageBytes);
			
			ctx.channel().writeAndFlush(payload);
		}
	}

	@Override
	protected Runnable onSuccess(ChannelHandlerContext ctx) {
		return new Runnable() {
			
			@Override
			public void run() {
				
				String email = credentials.get(Credential.EMAIL);
				
				VerificationHandler verificationHandler = new VerificationHandler(
						clientInfo,
						email) {

					@Override
					public ResultHolder executeWhenVerificationSuccesfull() throws MessagingException {
						
						String username = credentials.get(Credential.USERNAME);
						String password = credentials.get(Credential.PASSWORD);

						try (ChatAppDatabase.GeneralPurposeDBConnection conn = ChatAppDatabase.getGeneralPurposeConnection()) {
							return conn.createAccount(username, password, clientInfo.getChannel().remoteAddress().getAddress(), email);
						}
					}

					@Override
					public String createEmailMessage(String generatedVerificationCode) {
						return ServerSettings.EmailCreator.Verification.CreateAccount.createEmail(email, generatedVerificationCode);
					}
				};

				ctx.pipeline().replace(CreateAccountHandler.this, VerificationHandler.class.getName(), verificationHandler);
			}
			
		};
	}
}