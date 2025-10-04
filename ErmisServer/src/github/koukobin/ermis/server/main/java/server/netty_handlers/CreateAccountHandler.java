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
import java.nio.charset.Charset;
import java.util.EnumMap;
import java.util.Map;
import java.util.UUID;

import javax.mail.MessagingException;

import github.koukobin.ermis.common.DeviceType;
import github.koukobin.ermis.common.UserDeviceInfo;
import github.koukobin.ermis.common.entry.AddedInfo;
import github.koukobin.ermis.common.entry.CreateAccountInfo;
import github.koukobin.ermis.common.entry.CreateAccountInfo.Action;
import github.koukobin.ermis.common.entry.CreateAccountInfo.Credential;
import github.koukobin.ermis.common.message_types.ServerMessageType;
import github.koukobin.ermis.common.results.GeneralResult;
import github.koukobin.ermis.server.main.java.configs.DatabaseSettings;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.ErmisDatabase;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import github.koukobin.ermis.server.main.java.server.util.EmailCreator;
import github.koukobin.ermis.server.main.java.server.util.EmailCreator.Verification.VerificationEmailTemplate;
import github.koukobin.ermis.server.main.java.server.util.EmailerService;
import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;


/**
 * @author Ilias Koukovinis
 * 
 */
public final class CreateAccountHandler extends EntryHandler {

	private DeviceType deviceType = DeviceType.UNSPECIFIED;
	private String osName = "Unknown";
	private UUID deviceUUID = null;

	private final Map<Credential, String> credentials = new EnumMap<>(Credential.class);

	CreateAccountHandler(ClientInfo clientInfo) {
		super(clientInfo);
	}

	@Override
	public void handlerAdded(ChannelHandlerContext ctx) {
		// Do nothing.
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
		case FETCH_REQUIREMENTS -> {
			ByteBuf payload = ctx.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.ENTRY.id);
			payload.writeInt(DatabaseSettings.Client.Username.REQUIREMENTS.getMaxLength());
			payload.writeInt(DatabaseSettings.Client.Username.REQUIREMENTS.getInvalidCharacters().length());
			payload.writeBytes(DatabaseSettings.Client.Username.REQUIREMENTS.getInvalidCharacters().getBytes());

			payload.writeInt(DatabaseSettings.Client.Password.REQUIREMENTS.getMaxLength());
			payload.writeFloat(DatabaseSettings.Client.Password.REQUIREMENTS.getMinEntropy());
			payload.writeBytes(DatabaseSettings.Client.Password.REQUIREMENTS.getInvalidCharacters().getBytes());

			ctx.channel().writeAndFlush(payload);

			getLogger().debug("Sending credential requirements!");
		}
		case SET_UUID -> {
			String deviceUUIDString = (String) msg.readCharSequence(msg.readableBytes(), Charset.defaultCharset());
			deviceUUID = UUID.fromString(deviceUUIDString);
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

			CreateAccountInfo.CredentialValidation.Result result;

			if (EmailerService.isValidEmailAddress(email)) {
				try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
					result = conn.checkIfUserMeetsRequirementsToCreateAccount(username, password, email);
				}
			} else {
				result = CreateAccountInfo.CredentialValidation.Result.INVALID_EMAIL_ADDRESS;
			}

			ByteBuf payload = ctx.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.ENTRY.id);
			payload.writeInt(result.id);
			ctx.channel().writeAndFlush(payload);

			if (result.resultHolder.isSuccessful()) {
				onUserMeetsRequirements(ctx);
			} else {
//				EntryHandler.registrationFailed(ctx);
				credentials.clear();
			}

		}
	}

	private void onUserMeetsRequirements(ChannelHandlerContext ctx) {
		String email = credentials.get(Credential.EMAIL);
		String username = credentials.get(Credential.USERNAME);

		VerificationHandler verificationHandler = new VerificationHandler(clientInfo, email) {

			@Override
			public GeneralResult executeWhenVerificationSuccessful() {
				if (deviceUUID == null)
					deviceUUID = UUID.randomUUID();

				UserDeviceInfo deviceInfo = new UserDeviceInfo(deviceUUID, deviceType, osName);

				String password = credentials.get(Credential.PASSWORD);

				GeneralResult result;
				try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
					result = conn.createAccount(username, password, deviceInfo, email);
				}

				if (!result.isSuccessful()) {
					return result;
				}

				clientInfo.setEmail(email);
				clientInfo.setUsername(username);

				String backupCodes = result.getAddedInfo().get(AddedInfo.BACKUP_VERIFICATION_CODES);

				try {
					String emailBody = EmailCreator.BackupVerification
							.createEmail(EmailCreator.BackupVerification.EmailTemplate.of(email, backupCodes));
					EmailerService.sendEmailWithHTML("Backup verification codes", emailBody, email);
				} catch (MessagingException me) {
					getLogger().error("An error occured while trying to send email", me);
				}

				return result;
			}

			@Override
			public String createEmailMessage(String generatedVerificationCode) {
				return EmailCreator.Verification.CreateAccount
						.createEmail(VerificationEmailTemplate.of(email, generatedVerificationCode));
			}
		};

		ctx.pipeline().replace(CreateAccountHandler.this, VerificationHandler.class.getName(), verificationHandler);
	}
}
