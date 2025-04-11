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

import 'dart:typed_data';
import 'package:ermis_client/core/data/models/network/byte_buf.dart';
import 'package:ermis_client/core/models/message_events.dart';
import 'package:ermis_client/core/networking/message_transmitter.dart';
import 'package:ermis_client/core/models/chat_session.dart';
import '../../event_bus/app_event_bus.dart';
import '../../event_bus/event_bus.dart';

final EventBus _eventBus = AppEventBus.instance;

class VoiceCallHandler {
  static void handle(ByteBuf msg) {
    int mansPort = msg.readInt32();
    int chatSessionID = msg.readInt32();
    int clientID = msg.readInt32();
    Uint8List aesKey = msg.readBytes(msg.readableBytes);

    ChatSession session = Info.chatSessionIDSToChatSessions[chatSessionID]!;

    Member? member;
    for (var j = 0; j < session.members.length; j++) {
      if (session.members[j].clientID == clientID) {
        member = session.members[j];
      }
    }

    if (member == null) throw new Exception("What the fuck is this");

    _eventBus.fire(VoiceCallIncomingEvent(
      chatSessionID: chatSessionID,
      chatSessionIndex: session.chatSessionIndex,
      aesKey: aesKey,
      member: member,
      mansPort: mansPort,
    ));
  }
}
