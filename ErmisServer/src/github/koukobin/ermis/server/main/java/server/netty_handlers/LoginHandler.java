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

import java.nio.charset.Charset;
import java.util.EnumMap;
import java.util.Map;
import java.util.UUID;
import java.util.Map.Entry;

import javax.mail.MessagingException;

import github.koukobin.ermis.common.DeviceType;
import github.koukobin.ermis.common.UserDeviceInfo;
import github.koukobin.ermis.common.entry.AddedInfo;
import github.koukobin.ermis.common.entry.LoginInfo;
import github.koukobin.ermis.common.entry.LoginInfo.Action;
import github.koukobin.ermis.common.entry.LoginInfo.Credential;
import github.koukobin.ermis.common.entry.LoginInfo.PasswordType;
import github.koukobin.ermis.common.message_types.ServerMessageType;
import github.koukobin.ermis.common.results.GeneralResult;
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
public final class LoginHandler extends EntryHandler {

	private PasswordType passwordType = PasswordType.PASSWORD;

	private UUID deviceUUID = null;
	private DeviceType deviceType = DeviceType.UNSPECIFIED;
	private String osName = "Unknown";

	private final Map<Credential, String> credentials = new EnumMap<>(Credential.class);

	LoginHandler(ClientInfo clientInfo) {
		super(clientInfo);
	}

	@Override
	public void executeEntryAction(ChannelHandlerContext ctx, ByteBuf msg) {
		int readerIndex = msg.readerIndex();

		Action action = Action.fromId(msg.readInt());

		switch (action) {
		case TOGGLE_PASSWORD_TYPE -> {
			passwordType = PasswordType.fromId(msg.readInt());
		}
		case ADD_DEVICE_INFO -> {
			deviceType = DeviceType.fromId(msg.readInt());

			byte[] osNameBytes = new byte[msg.readableBytes()];
			msg.readBytes(osNameBytes);
			osName = new String(osNameBytes);
		}
		case SET_UUID -> {
			String deviceUUIDString = (String) msg.readCharSequence(msg.readableBytes(), Charset.defaultCharset());
			deviceUUID = UUID.fromString(deviceUUIDString);
		}
		}

		msg.readerIndex(readerIndex);
	}

	@Override
	public void channelRead1(ChannelHandlerContext ctx, ByteBuf msg) {
		{
			Credential credential = Credential.fromId(msg.readInt());

			byte[] msgBytes = new byte[msg.readableBytes()];
			msg.readBytes(msgBytes);

			credentials.put(credential, new String(msgBytes));
		}

		if (credentials.size() == Credential.values().length) {
			String email = credentials.get(Credential.EMAIL);

			LoginInfo.CredentialsExchange.Result result;
			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				result = conn.checkIfUserMeetsRequirementsToLogin(email);
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
		String password = credentials.get(Credential.PASSWORD);

		if (deviceUUID == null)
			deviceUUID = UUID.randomUUID();

		UserDeviceInfo deviceInfo = new UserDeviceInfo(deviceUUID, deviceType, osName);

		switch (passwordType) {
		case BACKUP_VERIFICATION_CODE -> {
			GeneralResult entryResult;

			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				entryResult = conn.loginUsingBackupVerificationCode(email, password, deviceInfo);
			}

			if (entryResult.isSuccessful()) {
				clientInfo.setEmail(email);
				login(ctx, clientInfo);

				String newlyGeneratedCodes = entryResult.getAddedInfo().get(AddedInfo.BACKUP_VERIFICATION_CODES);

				if (newlyGeneratedCodes != null) {
					try {
						String emailBody = EmailCreator.BackupVerification.createEmail(
								EmailCreator.BackupVerification.EmailTemplate.of(email, newlyGeneratedCodes));
						EmailerService.sendEmailWithHTML("Backup verification codes", emailBody, email);
					} catch (MessagingException me) {
						getLogger().error("An error occured while trying to send email", me);
					}
				}
			} else {
//				EntryHandler.registrationFailed(ctx);
				credentials.clear();
			}

			ByteBuf payload = ctx.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.ENTRY.id);
			payload.writeInt(entryResult.getIDable().getID());

			for (Entry<AddedInfo, String> addedInfo : entryResult.getAddedInfo().entrySet()) {
				AddedInfo key = addedInfo.getKey();
				byte[] valueBytes = addedInfo.getValue().getBytes();

				payload.writeInt(key.id);
				payload.writeInt(valueBytes.length);
				payload.writeBytes(valueBytes);
			}

			ctx.channel().writeAndFlush(payload);
		}
		case PASSWORD -> {
			VerificationHandler verificationHandler = new VerificationHandler(clientInfo, email) {

				@Override
				public GeneralResult executeWhenVerificationSuccessful() {
					GeneralResult result;
					try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
						result = conn.loginUsingPassword(email, password, deviceInfo);
					}

					if (result.isSuccessful()) {
						clientInfo.setEmail(email);
					}

					return result;
				}

				@Override
				public String createEmailMessage(String generatedVerificationCode) {
					return EmailCreator.Verification.Login
							.createEmail(VerificationEmailTemplate.of(email, generatedVerificationCode));
				}
			};

			ctx.pipeline().replace(LoginHandler.this, VerificationHandler.class.getName(), verificationHandler);
		}
		}
	}
}

