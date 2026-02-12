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
package github.koukobin.ermis.desktop_client.main.java.service.client.handlers;

import github.koukobin.ermis.common.message_types.ClientContentType;
import github.koukobin.ermis.common.message_types.MessageDeliveryStatus;
import github.koukobin.ermis.desktop_client.main.java.service.client.Events;
import github.koukobin.ermis.desktop_client.main.java.service.client.GlobalMessageDispatcher;
import github.koukobin.ermis.desktop_client.main.java.service.client.UserInfoManager;
import github.koukobin.ermis.desktop_client.main.java.service.client.models.ChatSession;
import github.koukobin.ermis.desktop_client.main.java.service.client.models.Message;
import io.netty.buffer.ByteBuf;

/**
 * @author Ilias Koukovinis
 *
 */
public class ClientMessageHandler implements MessageHandler {

	@Override
	public void handleMessage(ByteBuf msg) {
		Message message = new Message();

		ClientContentType contentType = ClientContentType.fromId(msg.readInt());
		long epochSecond = msg.readLong();

		byte[] text = null;
		byte[] fileNameBytes = null;

		switch (contentType) {
		case TEXT -> {
			text = new byte[msg.readInt()];
			msg.readBytes(text);
		}
		case FILE, IMAGE, VOICE -> {
			fileNameBytes = new byte[msg.readInt()];
			msg.readBytes(fileNameBytes);
		}
		default -> {
			text = "Error: content type not recognized".getBytes();

			// Skip message content
			msg.skipBytes(msg.readInt());
		}
		}

		byte[] usernameBytes = new byte[msg.readInt()];
		msg.readBytes(usernameBytes);
		String username = new String(usernameBytes);

		int clientID = msg.readInt();
		int messageID = msg.readInt();
		int chatSessionID = msg.readInt();

		message.setContentType(contentType);
		message.setUsername(username);
		message.setClientID(clientID);
		message.setMessageID(messageID);
		message.setChatSessionID(chatSessionID);
		message.setChatSessionIndex(
				UserInfoManager.chatSessionIDSToChatSessions.get(chatSessionID).getChatSessionIndex()
		);
		message.setText(text);
		message.setFileName(fileNameBytes);
		message.setEpochSecond(epochSecond);
		message.setDeliveryStatus(MessageDeliveryStatus.DELIVERED);

		ChatSession chatSession = UserInfoManager.chatSessionIDSToChatSessions.get(chatSessionID);

		if (chatSession.haveChatMessagesBeenCached()) {
			chatSession.getMessages().add(message);
		}

		GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.MessageReceivedEvent(message, chatSession));
	}

}
