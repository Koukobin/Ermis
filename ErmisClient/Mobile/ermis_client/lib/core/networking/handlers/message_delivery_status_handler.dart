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

import 'package:ermis_client/core/networking/common/message_types/message_delivery_status.dart';
import 'package:ermis_client/core/data/models/network/byte_buf.dart';
import 'package:ermis_client/core/models/message_events.dart';
import 'package:ermis_client/core/models/message.dart';
import 'package:ermis_client/core/networking/user_info_manager.dart';
import '../../event_bus/app_event_bus.dart';
import '../../event_bus/event_bus.dart';

final EventBus _eventBus = AppEventBus.instance;

class MessageDeliveryStatusHandler {
  static void handle(ByteBuf msg) {
    MessageDeliveryStatus status = MessageDeliveryStatus.fromId(msg.readInt32());

    Message pendingMessage;
    
    if (status == MessageDeliveryStatus.lateDelivered) {
      int chatSessionID = msg.readInt32();
      int generatedMessageID = msg.readInt32();

      pendingMessage = UserInfoManager.chatSessionIDSToChatSessions[chatSessionID]!
          .messages
          .firstWhere((m) => m.messageID == generatedMessageID);
    } else if (status == MessageDeliveryStatus.rejected) {
      int tempMessageID = msg.readInt32();
      pendingMessage = UserInfoManager.pendingMessagesQueue.remove(tempMessageID)!;
    } else {
      int tempMessageID = msg.readInt32();
      int generatedMessageID = msg.readInt32();

      pendingMessage = UserInfoManager.pendingMessagesQueue[tempMessageID]!;
      if (status == MessageDeliveryStatus.delivered) {
        UserInfoManager.pendingMessagesQueue.remove(tempMessageID)!;
      }

      pendingMessage.setMessageID(generatedMessageID);
    }

    pendingMessage.setDeliveryStatus(status);

    _eventBus.fire(MessageDeliveryStatusEvent(
      deliveryStatus: status,
      message: pendingMessage,
    ));
  }
}
