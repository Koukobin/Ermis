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
package github.koukobin.ermis.server.main.java.server.netty_handlers.commands;

import github.koukobin.ermis.common.message_types.ClientCommandType;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import io.netty.buffer.ByteBuf;
import io.netty.channel.epoll.EpollSocketChannel;

/**
 * @author Ilias Koukovinis
 *
 */
public class DeleteAccount implements ICommand {

	@Override
	public void execute(ClientInfo clientInfo, EpollSocketChannel channel, ByteBuf args) {

		byte[] emailAddress = new byte[args.readInt()];
		args.readBytes(emailAddress);

		byte[] passwordBytes = new byte[args.readInt()];
		args.readBytes(passwordBytes);

		String email = new String(emailAddress);

//		channel.pipeline().addLast(DeleteAccountVerificationHandler.class.getName(),
//				new DeleteAccountVerificationHandler(clientInfo, clientInfo.getEmail()) {
//
//					@Override
//					public GeneralResult executeWhenVerificationSuccessful() throws IOException {
//						String password = new String(passwordBytes);
//
//						DeleteAccountSuccess result;
//						try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
//							result = conn.deleteAccount(email, password, clientInfo.getClientID());
//						}
//
//						switch (result) {
//						case SUCCESS -> {
//							channel.close();
//						}
//						case EMAIL_ENTERED_DOES_NOT_MATCH_ACCOUNT -> {
//							MessageByteBufCreator.sendMessageInfo(channel, "Email entered does not match actual email!");
//						}
//						case AUTHENTICATION_FAILED -> {
//							MessageByteBufCreator.sendMessageInfo(channel, "Authentication Failed!");
//						}
//						case FAILURE -> {
//							MessageByteBufCreator.sendMessageInfo(channel, "An error occured while trying to delete your account!");
//						}
//						}
//	
//						return null;
//			}
//			
//			@Override
//			public String createEmailMessage(String account, String generatedVerificationCode) {
//				return ServerSettings.EmailCreator.Verification.DeleteAccount.createEmail(VerificationEmailTemplate.of(email, account, generatedVerificationCode));
//			}
//		});
	}

	@Override
	public ClientCommandType getCommand() {
		return ClientCommandType.DELETE_ACCOUNT;
	}

}
