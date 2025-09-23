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

import java.nio.charset.Charset;
import java.util.UUID;

import github.koukobin.ermis.common.Account;
import github.koukobin.ermis.common.message_types.ClientCommandResultType;
import github.koukobin.ermis.common.message_types.ClientCommandType;
import github.koukobin.ermis.common.message_types.ServerMessageType;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.ErmisDatabase;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import io.netty.buffer.ByteBuf;
import io.netty.channel.epoll.EpollSocketChannel;

/**
 * @author Ilias Koukovinis
 *
 */
public class FetchOtherAccountsAssociatedWithDevice implements ICommand {

	@Override
	public void execute(ClientInfo clientInfo, EpollSocketChannel channel, ByteBuf args) {
		ByteBuf payload = channel.alloc().ioBuffer();
		payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
		payload.writeInt(ClientCommandResultType.FETCH_OTHER_ACCOUNTS_ASSOCIATED_WITH_IP_ADDRESS.id);

		String uuidString = (String) args.readCharSequence(args.readableBytes(), Charset.defaultCharset());
		UUID uuid = UUID.fromString(uuidString);

		Account[] accounts;
		try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
			accounts = conn.getAccountsAssociatedWithDevice(uuid);
		}

		for (int i = 0; i < accounts.length; i++) {
			Account account = accounts[i];
			if (account.clientID() == clientInfo.getClientID()) {
				continue;
			}

			payload.writeInt(account.clientID());

			String email = account.email();
			payload.writeInt(email.length());
			payload.writeBytes(email.getBytes());

			String displayName = account.displayName();
			payload.writeInt(displayName.length());
			payload.writeBytes(displayName.getBytes());
		}

		channel.writeAndFlush(payload);
	}

	@Override
	public ClientCommandType getCommand() {
		return ClientCommandType.FETCH_OTHER_ACCOUNTS_ASSOCIATED_WITH_IP_ADDRESS;
	}

}
