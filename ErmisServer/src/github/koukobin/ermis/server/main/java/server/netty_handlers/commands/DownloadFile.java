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

import java.util.Optional;

import github.koukobin.ermis.common.LoadedInMemoryFile;
import github.koukobin.ermis.common.message_types.ClientCommandResultType;
import github.koukobin.ermis.common.message_types.ClientCommandType;
import github.koukobin.ermis.common.message_types.FileType;
import github.koukobin.ermis.common.message_types.ServerInfoMessage;
import github.koukobin.ermis.common.message_types.ServerMessageType;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.ErmisDatabase;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import io.netty.buffer.ByteBuf;
import io.netty.channel.epoll.EpollSocketChannel;

/**
 * @author Ilias Koukovinis
 *
 */
public class DownloadFile implements ICommand {

	@Override
	public void execute(ClientInfo clientInfo, EpollSocketChannel channel, ByteBuf args) {
		int chatSessionIndex = args.readInt();
		int messageID = args.readInt();
		FileType fileType = FileType.fromId(args.readByte());

		int chatSessionID = clientInfo.getChatSessions().get(chatSessionIndex).getChatSessionID();

		Optional<LoadedInMemoryFile> optionalFile;
		try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
			optionalFile = conn.getFile(messageID, chatSessionID);
		}

		optionalFile.ifPresentOrElse((LoadedInMemoryFile file) -> {
			byte[] fileBytes = file.getFileBytes();
			byte[] fileNameBytes = file.getFileName().getBytes();

			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
			switch (fileType) {
			case IMAGE -> {
				payload.writeInt(ClientCommandResultType.DOWNLOAD_IMAGE.id);

				// Include the message ID of the file so the
				// client can associate it to the correct message
				payload.writeInt(messageID);
			}
			case FILE -> {
				payload.writeInt(ClientCommandResultType.DOWNLOAD_FILE.id);

				// Include the message ID of the file so the
				// client can associate it to the correct message
				payload.writeInt(messageID);
			}
			case VOICE -> {
				payload.writeInt(ClientCommandResultType.DOWNLOAD_VOICE.id);

				// Include the message ID of the file so the
				// client can associate it to the correct message
				payload.writeInt(messageID);
			}
			default -> {
				final String log = """
						How the fuck have we reached here. This log CANNOT happen. This log SHOULD NOT happen.
						I have placed it here purely for debugging purposes (Additionally, because I have started to go insane).
						It is virtually impossible for you to actually witness this log. In the astronomically rare instance that you do - you are fucked.
						This indicates there is a significant flaw in the server's internal structure.
						For more details: Unexpected value in switch statement - {} - where either DOWNLOAD_IMAGE or DOWNLOAD_FILE was expected.
						Anyways... I am gonna go to sleep now.
						""";
				getLogger().fatal(log, fileType);
			}
			}
			payload.writeInt(chatSessionID);
			payload.writeInt(fileNameBytes.length);
			payload.writeBytes(fileNameBytes);
			payload.writeBytes(fileBytes);

			channel.writeAndFlush(payload);
		}, () -> {
			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.SERVER_INFO.id);
			payload.writeInt(ServerInfoMessage.ERROR_OCCURED_WHILE_TRYING_TO_FETCH_FILE_FROM_DATABASE.id);
			channel.writeAndFlush(payload);
		});
	}

	@Override
	public ClientCommandType getCommand() {
		return ClientCommandType.DOWNLOAD_FILE;
	}

}
