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
import java.util.EnumMap;
import java.util.Map;

import javax.mail.MessagingException;

import github.koukobin.ermis.common.DeviceType;
import github.koukobin.ermis.common.UserDeviceInfo;
import github.koukobin.ermis.common.entry.AddedInfo;
import github.koukobin.ermis.common.entry.CreateAccountInfo;
import github.koukobin.ermis.common.entry.CreateAccountInfo.Action;
import github.koukobin.ermis.common.entry.CreateAccountInfo.Credential;
import github.koukobin.ermis.common.results.EntryResult;
import github.koukobin.ermis.common.results.ResultHolder;
import github.koukobin.ermis.server.main.java.configs.DatabaseSettings;
import github.koukobin.ermis.server.main.java.configs.ServerSettings.EmailCreator.Verification.VerificationEmailTemplate;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.ErmisDatabase;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import github.koukobin.ermis.server.main.java.server.util.EmailerService;
import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;

import static github.koukobin.ermis.server.main.java.configs.ServerSettings.EmailCreator.Verification.CreateAccount.createEmail;

/**
 * @author Ilias Koukovinis
 * 
 */
final class CreateAccountHandler extends EntryHandler {

	private DeviceType deviceType = DeviceType.UNSPECIFIED;
	private String osName = "Unknown";

	private Map<Credential, String> credentials = new EnumMap<>(Credential.class);

	CreateAccountHandler(ClientInfo clientInfo) {
		super(clientInfo);
	}

	@Override
	public void channelActive(ChannelHandlerContext ctx) {
		ByteBuf payload = ctx.alloc().ioBuffer();
		payload.writeInt(DatabaseSettings.Client.Username.REQUIREMENTS.getMaxLength());
		payload.writeInt(DatabaseSettings.Client.Username.REQUIREMENTS.getInvalidCharacters().length());
		payload.writeBytes(DatabaseSettings.Client.Username.REQUIREMENTS.getInvalidCharacters().getBytes());
		
		payload.writeInt(DatabaseSettings.Client.Password.REQUIREMENTS.getMaxLength());
		payload.writeDouble(DatabaseSettings.Client.Password.REQUIREMENTS.getMinEntropy());
		payload.writeBytes(DatabaseSettings.Client.Password.REQUIREMENTS.getInvalidCharacters().getBytes());
		
		ctx.channel().writeAndFlush(ctx);
	}

	@Override
	public void executeEntryAction(ChannelHandlerContext ctx, ByteBuf msg) {

		int readerIndex = msg.readerIndex();

		Action action = Action.fromId(msg.readInt());

		switch (action) {
		case ADD_DEVICE_INFO -> {
			deviceType = DeviceType.fromId(msg.readInt());

			byte[] osNameBytes = new byte[msg.readableBytes()];
			msg.readBytes(osNameBytes);
			osName = new String(osNameBytes);
		}
		}

		msg.readerIndex(readerIndex);
	}

	@Override
	public void channelRead1(ChannelHandlerContext ctx, ByteBuf msg) throws IOException {

		{
			Credential credential = Credential.fromId(msg.readInt());

			byte[] payloadBytes = new byte[msg.readableBytes()];
			msg.readBytes(payloadBytes);

			credentials.put(credential, new String(payloadBytes));
		}

		if (credentials.size() == Credential.values().length) {

			String username = credentials.get(Credential.USERNAME);
			String password = credentials.get(Credential.PASSWORD);
			String email = credentials.get(Credential.EMAIL);

			ResultHolder resultHolder;

			if (EmailerService.isValidEmailAddress(email)) {
				try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
					resultHolder = conn.checkIfUserMeetsRequirementsToCreateAccount(username, password, email);
				}
			} else {
				resultHolder = CreateAccountInfo.CredentialValidation.Result.INVALID_EMAIL_ADDRESS.resultHolder;
			}

			byte[] resultMessageBytes = resultHolder.getResultMessage().getBytes();

			ByteBuf payload = ctx.alloc().ioBuffer();
			payload.writeBoolean(resultHolder.isSuccessful());
			payload.writeBytes(resultMessageBytes);
			ctx.channel().writeAndFlush(payload);
			
			if (resultHolder.isSuccessful()) {
				super.registrationSuccessful(ctx);
			} else {
				EntryHandler.registrationFailed(ctx);
			}
		}
	}

	@Override
	protected void onSuccessfulRegistration(ChannelHandlerContext ctx) {
		String email = credentials.get(Credential.EMAIL);

		VerificationHandler verificationHandler = new VerificationHandler(clientInfo, email) {

			@Override
			public EntryResult executeWhenVerificationSuccessful() {

				String address = clientInfo.getChannel().remoteAddress().getAddress().getHostName();
				String username = credentials.get(Credential.USERNAME);
				String password = credentials.get(Credential.PASSWORD);

				UserDeviceInfo deviceInfo = new UserDeviceInfo(address, deviceType, osName);

				EntryResult result;
				try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
					result = conn.createAccount(username, password, deviceInfo, email);
				}

				if (!result.isSuccessful()) {
					return result;
				}

				clientInfo.setEmail(email);
				clientInfo.setUsername(username);

				try {
					EmailerService.sendEmail("Backup verification codes", result.getAddedInfo().get(AddedInfo.BACKUP_VERIFICATION_CODES), email);
				} catch (MessagingException me) {
					getLogger().error("An error occured while trying to send email", me);
				}
				
				return result;
			}

			@Override
			public String createEmailMessage(String account, String generatedVerificationCode) {
				return createEmail(VerificationEmailTemplate.of(email, account, generatedVerificationCode));
			}
		};

		ctx.pipeline().replace(CreateAccountHandler.this, VerificationHandler.class.getName(), verificationHandler);
	}
}
