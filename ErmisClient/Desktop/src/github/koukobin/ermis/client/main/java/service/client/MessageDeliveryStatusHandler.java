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
package github.koukobin.ermis.client.main.java.service.client;

import github.koukobin.ermis.client.main.java.MESSAGE;
import github.koukobin.ermis.client.main.java.service.client.io_client.MessageHandler.I;
import github.koukobin.ermis.common.message_types.MessageDeliveryStatus;
import io.netty.buffer.ByteBuf;

/**
 * @author Ilias Koukovinis
 *
 */
public class MessageDeliveryStatusHandler implements MESSAGEHandler {

	@Override
	public void handleMessage(ByteBuf msg) {
		MessageDeliveryStatus status = MessageDeliveryStatus.fromId(msg.readInt());

		MESSAGE pendingMessage;

		if (status == MessageDeliveryStatus.LATE_DELIVERED) {
		    int chatSessionID = msg.readInt();
		    int generatedMessageID = msg.readInt();

		    pendingMessage = I.chatSessionIDSToChatSessions.get(chatSessionID)
		            .getMessages()
		            .stream()
		            .filter(m -> m.getMessageID() == generatedMessageID)
		            .findFirst()
		            .orElseThrow();
		} else if (status == MessageDeliveryStatus.REJECTED) {
		    int tempMessageID = msg.readInt();
		    pendingMessage = I.pendingMessagesQueue.remove(tempMessageID);
		} else {
		    int tempMessageID = msg.readInt();
		    int generatedMessageID = msg.readInt();

		    pendingMessage = I.pendingMessagesQueue.get(tempMessageID);
		    if (status == MessageDeliveryStatus.DELIVERED) {
		        I.pendingMessagesQueue.remove(tempMessageID);
		    }

		    pendingMessage.setMessageID(generatedMessageID);
		}

		pendingMessage.setDeliveryStatus(status);

		GlobalMessageDispatcher.getDispatcher().messageSubject.onNext(new Events.MessageDeliveryStatusEvent(status, pendingMessage));
				
	}

}
