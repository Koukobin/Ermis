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
import github.koukobin.ermis.common.message_types.ServerMessageType;
import github.koukobin.ermis.common.message_types.VoiceCallMessageType;
import github.koukobin.ermis.server.main.java.configs.ServerSettings;
import github.koukobin.ermis.server.main.java.server.ChatSession;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import io.netty.buffer.ByteBuf;
import io.netty.channel.epoll.EpollSocketChannel;

/**
 * @author Ilias Koukovinis
 *
 */
public class StartVoiceCall implements ICommand {

	@Override
	public void execute(ClientInfo clientInfo, EpollSocketChannel channel, ByteBuf args) {
		int chatSessionIndex = args.readInt();
		ChatSession chatSession = clientInfo.getChatSessions().get(chatSessionIndex);
		int chatSessionID = chatSession.getChatSessionID();

		{
			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.COMMAND_RESULT.id);
			payload.writeInt(ClientCommandResultType.START_VOICE_CALL.id);
			payload.writeInt(ServerSettings.VOICE_CALL_SIGNALLING_SERVER_PORT);
			channel.writeAndFlush(payload);
		}

		ByteBuf payload = channel.alloc().ioBuffer();
		payload.writeInt(ServerMessageType.VOICE_CALLS.id);
		payload.writeInt(VoiceCallMessageType.INCOMING_VOICE_CALL.id);
		payload.writeInt(ServerSettings.VOICE_CALL_SIGNALLING_SERVER_PORT);
		payload.writeInt(chatSessionID);
		payload.writeInt(clientInfo.getClientID());

		for (ClientInfo activeMember : chatSession.getActiveMembers()) {
			if (activeMember.getChannel().equals(clientInfo.getChannel())) {
				continue;
			}

			payload.retain();
			activeMember.getChannel().writeAndFlush(payload);
		}

		payload.release();

		getLogger().debug("Voice chat added");
	}

	@Override
	public ClientCommandType getCommand() {
		return ClientCommandType.START_VOICE_CALL;
	}

}
