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
package github.koukobin.ermis.desktop_client.main.java.service.client;

import java.util.ArrayList;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;

import github.koukobin.ermis.common.message_types.ServerMessageType;
import github.koukobin.ermis.desktop_client.main.java.service.client.Events.IMessage;
import github.koukobin.ermis.desktop_client.main.java.service.client.Events.ServerMessageInfoEvent;
import github.koukobin.ermis.desktop_client.main.java.service.client.handlers.ClientMessageHandler;
import github.koukobin.ermis.desktop_client.main.java.service.client.handlers.CommandResultHandler;
import github.koukobin.ermis.desktop_client.main.java.service.client.handlers.MessageDeliveryStatusHandler;
import github.koukobin.ermis.desktop_client.main.java.service.client.handlers.MessageHandler;
import io.netty.buffer.ByteBuf;
import io.reactivex.rxjava3.core.Observable;
import io.reactivex.rxjava3.subjects.PublishSubject;

/**
 * @author Ilias Koukovinis
 *
 */
public final class GlobalMessageDispatcher {

	private static final GlobalMessageDispatcher dispatcher = new GlobalMessageDispatcher();

	public static GlobalMessageDispatcher getDispatcher() {
		return dispatcher;
	}

	public final List<MessageListener> listeners = new ArrayList<>();

	private interface MessageListener {
		void onMessageReceived(ByteBuf message);
	}

	public void addListener(MessageListener listener) {
		listeners.add(listener);
	}

	public void removeListener(MessageListener listener) {
		listeners.remove(listener);
	}

	private Map<ServerMessageType, MessageHandler> handlers = new EnumMap<>(ServerMessageType.class);
	public final PublishSubject<IMessage> messageSubject = PublishSubject.create();

	public GlobalMessageDispatcher() {
		// Register handlers for different message types
		handlers.put(ServerMessageType.CLIENT_MESSAGE, new ClientMessageHandler());
		handlers.put(ServerMessageType.COMMAND_RESULT, new CommandResultHandler());
		handlers.put(ServerMessageType.ENTRY, new MessageHandler() {

			@Override
			public void handleMessage(ByteBuf msg) {
//				listeners.forEach((MessageListener ml) -> {
//					if (ml instanceof EntryMessage) {
//						ml.onMessageReceived(msg);
//					}
//				});
				messageSubject.onNext(new Events.EntryMessage(msg));
			}
		});
		handlers.put(ServerMessageType.MESSAGE_DELIVERY_STATUS, new MessageDeliveryStatusHandler());
		handlers.put(ServerMessageType.SERVER_INFO, new MessageHandler() {

			@Override
			public void handleMessage(ByteBuf msg) {
				byte[] content = new byte[msg.readableBytes()];
				msg.readBytes(content);

				messageSubject.onNext(new ServerMessageInfoEvent(new String(content)));
			}
		});
		handlers.put(ServerMessageType.VOICE_CALLS, new MessageHandler() {

			@Override
			public void handleMessage(ByteBuf msg) {
				// Do nothing.
			}
		});
	}

	public void dispatchMessage(ByteBuf message) {
		ServerMessageType msgType = ServerMessageType.fromId(message.readInt());
		MessageHandler handler = handlers.get(msgType);
		if (handler != null) {
			handler.handleMessage(message);
		} else {
			System.out.println("No handler found for message type: " + msgType);
		}
	}

	public Observable<IMessage> observeMessages() {
		return messageSubject;
	}
}
