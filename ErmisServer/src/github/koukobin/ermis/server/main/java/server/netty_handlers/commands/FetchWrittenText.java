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

import github.koukobin.ermis.common.message_types.ClientCommandResultType;
import github.koukobin.ermis.common.message_types.ClientCommandType;
import github.koukobin.ermis.common.message_types.ClientContentType;
import github.koukobin.ermis.common.message_types.MessageDeliveryStatus;
import github.koukobin.ermis.common.message_types.ServerMessageType;
import github.koukobin.ermis.common.message_types.UserMessage;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.ErmisDatabase;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import io.netty.buffer.ByteBuf;
import io.netty.channel.epoll.EpollSocketChannel;

/**
 * @author Ilias Koukovinis
 *
 */
public class FetchWrittenText implements ICommand {

	public static final int NUMBER_OF_MESSAGES_TO_READ_FROM_THE_DATABASE_AT_A_TIME = 30;
	
	@Override
	public void execute(ClientInfo clientInfo, EpollSocketChannel channel, ByteBuf args) {
		int chatSessionIndex = args.readInt();
		int chatSessionID = clientInfo.getChatSessions().get(chatSessionIndex).getChatSessionID();

		int numOfMessagesAlreadySelected = args.readInt();
		getLogger().debug("Num of messages already selected: {}", numOfMessagesAlreadySelected);

		UserMessage[] messages;
		try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
			messages = conn.selectMessages(chatSessionID, numOfMessagesAlreadySelected,
					NUMBER_OF_MESSAGES_TO_READ_FROM_THE_DATABASE_AT_A_TIME,
					clientInfo.getClientID());
		}

		getLogger().debug("Selected a total of {} messages", messages.length);

		ByteBuf payload = channel.alloc().ioBuffer();
		payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
		payload.writeInt(ClientCommandResultType.GET_WRITTEN_TEXT.id);
		payload.writeInt(chatSessionIndex);

		for (int i = 0; i < messages.length; i++) {
			UserMessage message = messages[i];
			int senderClientID = message.getClientID();
			int messageID = message.getMessageID();
			byte[] messageBytes = message.getText();
			byte[] fileNameBytes = message.getFileName();
			long timeWritten = message.getTimeWritten();
			ClientContentType contentType = message.getContentType();

			payload.writeInt(contentType.id);
			payload.writeInt(senderClientID);
			payload.writeInt(messageID);

			payload.writeLong(timeWritten);
			if (senderClientID == clientInfo.getClientID()) {
				payload.writeBoolean(message.isRead());
			} else {
				if (!message.isRead()) {
					ByteBuf s = channel.alloc().ioBuffer();
					s.writeInt(ServerMessageType.MESSAGE_DELIVERY_STATUS.id);
					s.writeInt(MessageDeliveryStatus.LATE_DELIVERED.id);
					s.writeInt(chatSessionID);
					s.writeInt(messageID);
					forActiveAccounts(senderClientID, (ClientInfo ci) -> {
						s.retain();
						ci.getChannel().writeAndFlush(s.duplicate());
					});
					s.release();
					assert s.refCnt() == 0;
				}
			}

			switch (contentType) {
			case TEXT -> {
				payload.writeInt(messageBytes.length);
				payload.writeBytes(messageBytes);
			}
			case FILE, IMAGE, VOICE -> {
				payload.writeInt(fileNameBytes.length);
				payload.writeBytes(fileNameBytes);
			}
			}
		}

		channel.writeAndFlush(payload);
	}

	@Override
	public ClientCommandType getCommand() {
		return ClientCommandType.FETCH_WRITTEN_TEXT;
	}

}
