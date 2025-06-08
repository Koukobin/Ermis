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

import 'package:ermis_client/core/data/models/network/byte_buf.dart';
import 'package:ermis_client/core/models/member.dart';
import 'package:ermis_client/core/models/message_events.dart';
import 'package:ermis_client/core/models/chat_session.dart';
import 'package:ermis_client/core/networking/common/message_types/voice_call_message_type.dart';
import 'package:ermis_client/core/networking/user_info_manager.dart';
import '../../event_bus/app_event_bus.dart';
import '../../event_bus/event_bus.dart';

final EventBus _eventBus = AppEventBus.instance;

class VoiceCallHandler {
  static void handle(ByteBuf msg) {
    VoiceCallMessageType voiceCallMessageType = VoiceCallMessageType.fromId(msg.readInt32());

    switch (voiceCallMessageType) {
      case VoiceCallMessageType.incomingVoiceCall:
        int chatSessionID = msg.readInt32();
        int clientID = msg.readInt32();

        ChatSession session = UserInfoManager.chatSessionIDSToChatSessions[chatSessionID]!;

        Member? member;
        for (var j = 0; j < session.members.length; j++) {
          if (session.members[j].clientID == clientID) {
            member = session.members[j];
          }
        }

        _eventBus.fire(VoiceCallIncomingEvent(
          chatSessionID: chatSessionID,
          chatSessionIndex: session.chatSessionIndex,
          member: member ?? session.members[0],
        ));
        break;
      case VoiceCallMessageType.cancelIncomingVoiceCall:
        int chatSessionID = msg.readInt32();

        _eventBus.fire(CancelVoiceCallIncomingEvent(
          chatSessionID: chatSessionID,
        ));
        break;
      case VoiceCallMessageType.acceptVoiceCall:
        int chatSessionID = msg.readInt32();
        int clientID = msg.readInt32();

        ChatSession session = UserInfoManager.chatSessionIDSToChatSessions[chatSessionID]!;

        Member? member;
        for (var j = 0; j < session.members.length; j++) {
          if (session.members[j].clientID == clientID) {
            member = session.members[j];
          }
        }

        _eventBus.fire(VoiceCallAcceptedEvent(
          chatSessionID: chatSessionID,
          chatSessionIndex: session.chatSessionIndex,
          member: member ?? session.members[0],
        ));
        break;
    }
  }
}

