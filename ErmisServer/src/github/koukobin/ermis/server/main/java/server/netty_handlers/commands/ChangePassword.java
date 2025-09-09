/* Copyright (C) 2025 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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
package github.koukobin.ermis.server.main.java.server.netty_handlers.commands;

import java.io.IOException;

import github.koukobin.ermis.common.entry.LoginInfo;
import github.koukobin.ermis.common.message_types.ClientCommandType;
import github.koukobin.ermis.common.results.GeneralResult;
import github.koukobin.ermis.server.main.java.configs.ServerSettings;
import github.koukobin.ermis.server.main.java.configs.ServerSettings.EmailCreator.Verification.VerificationEmailTemplate;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.ErmisDatabase;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import github.koukobin.ermis.server.main.java.server.netty_handlers.CreateAccountHandler;
import github.koukobin.ermis.server.main.java.server.netty_handlers.LoginHandler;
import github.koukobin.ermis.server.main.java.server.netty_handlers.StartingEntryHandler;
import github.koukobin.ermis.server.main.java.server.netty_handlers.VerificationHandler;
import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandler;
import io.netty.channel.epoll.EpollSocketChannel;

/**
 * @author Ilias Koukovinis
 *
 */
public class ChangePassword implements ICommand {

	@Override
	public void execute(ClientInfo clientInfo, EpollSocketChannel channel, ByteBuf args) {
		byte[] emailAddress = new byte[args.readInt()];
		args.readBytes(emailAddress);

		byte[] newPasswordBytes = new byte[args.readableBytes()];
		args.readBytes(newPasswordBytes);

		removeAuthenticationHandlers(channel);

		channel.pipeline().addLast(StartingEntryHandler.class.getName(), new StartingEntryHandler());
		channel.pipeline().addLast(VerificationHandler.class.getName(),
				new VerificationHandler(clientInfo, clientInfo.getEmail()) {

					@Override
					public GeneralResult executeWhenVerificationSuccessful() throws IOException {
						// Although database performs authentication and verifies entered email is
						// indeed associated with the actual user account, confirm it proactively here
						// as well
						String enteredEmail = new String(emailAddress);

						if (!clientInfo.getEmail().equals(enteredEmail)) {
							return new GeneralResult(LoginInfo.Login.Result.ERROR_WHILE_LOGGING_IN);
						}

						String newPassword = new String(newPasswordBytes);

						GeneralResult result;
						try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
							result = conn.changePassword(enteredEmail, newPassword, clientInfo.getClientID());
						}

						return result;
					}

			@Override
			public String createEmailMessage(String generatedVerificationCode) {
				return ServerSettings.EmailCreator.Verification.ChangePassword.createEmail(VerificationEmailTemplate.of(clientInfo.getEmail(), generatedVerificationCode));
			}
		});
	}

	/**
	 * Check if authentication handlers are already present in the pipeline - in
	 * which case remove them and readd them.
	 * 
	 * This exact code also exists in {@link AddOrSwitchToNewAccount}; perhaps this
	 * should be refactored to utilize reflection in order to fetch all subclasses
	 * of {@link EntryHandler} and {@link StartingEntryHandler} and subsequently
	 * remove them (This could easily be done via the Reflections API
	 * {@link Reflections}).
	 */
	private static void removeAuthenticationHandlers(EpollSocketChannel channel) {
		{
			ChannelHandler handler = channel.pipeline().get(StartingEntryHandler.class);
			if (handler != null) {
				channel.pipeline().remove(handler);
			}
		}

		{
			ChannelHandler handler = channel.pipeline().get(CreateAccountHandler.class);
			if (handler != null) {
				channel.pipeline().remove(handler);
			}
		}

		{
			ChannelHandler handler = channel.pipeline().get(LoginHandler.class);
			if (handler != null) {
				channel.pipeline().remove(handler);
			}
		}
	}

	@Override
	public ClientCommandType getCommand() {
		return ClientCommandType.CHANGE_PASSWORD;
	}

}
