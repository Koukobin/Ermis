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

import github.koukobin.ermis.common.message_types.MessageDeliveryStatus;
import github.koukobin.ermis.desktop_client.main.java.service.client.Events;
import github.koukobin.ermis.desktop_client.main.java.service.client.GlobalMessageDispatcher;
import github.koukobin.ermis.desktop_client.main.java.service.client.UserInfoManager;
import github.koukobin.ermis.desktop_client.main.java.service.client.models.Message;
import io.netty.buffer.ByteBuf;

/**
 * @author Ilias Koukovinis
 *
 */
public class MessageDeliveryStatusHandler implements MessageHandler {

	@Override
	public void handleMessage(ByteBuf msg) {
		MessageDeliveryStatus status = MessageDeliveryStatus.fromId(msg.readInt());

		Message pendingMessage;

		if (status == MessageDeliveryStatus.LATE_DELIVERED) {
		    int chatSessionID = msg.readInt();
		    int generatedMessageID = msg.readInt();

		    pendingMessage = UserInfoManager.chatSessionIDSToChatSessions.get(chatSessionID)
		            .getMessages()
		            .stream()
		            .filter(m -> m.getMessageID() == generatedMessageID)
		            .findFirst()
		            .orElseThrow();
		} else if (status == MessageDeliveryStatus.REJECTED) {
		    int tempMessageID = msg.readInt();
		    pendingMessage = UserInfoManager.pendingMessagesQueue.remove(tempMessageID);
		} else {
		    int tempMessageID = msg.readInt();
		    int generatedMessageID = msg.readInt();

		    pendingMessage = UserInfoManager.pendingMessagesQueue.get(tempMessageID);
		    if (status == MessageDeliveryStatus.DELIVERED) {
		        UserInfoManager.pendingMessagesQueue.remove(tempMessageID);
		    }

		    pendingMessage.setMessageID(generatedMessageID);
		}

		pendingMessage.setDeliveryStatus(status);

		GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.MessageDeliveryStatusEvent(status, pendingMessage));
				
	}

}
