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

import 'dart:io';
import 'package:ermis_client/core/data/models/network/byte_buf.dart';
import 'package:ermis_client/core/models/member.dart';
import 'package:ermis_client/core/models/message_events.dart';
import 'package:ermis_client/core/models/chat_session.dart';
import 'package:ermis_client/core/networking/common/message_types/voice_call_message_type.dart';
import 'package:ermis_client/core/networking/user_info_manager.dart';
import 'package:flutter/foundation.dart';
import '../../event_bus/app_event_bus.dart';
import '../../event_bus/event_bus.dart';
import '../../models/inet_socket_address.dart';

final EventBus _eventBus = AppEventBus.instance;

class VoiceCallHandler {
  static void handle(ByteBuf msg) {
    VoiceCallMessageType voiceCallMessageType = VoiceCallMessageType.fromId(msg.readInt32());

    switch (voiceCallMessageType) {
      case VoiceCallMessageType.incomingVoiceCall:
        int signallingPort = msg.readInt32();
        int chatSessionID = msg.readInt32();
        int clientID = msg.readInt32();
        Uint8List aesKey = msg.readBytes(msg.readableBytes);

        ChatSession session = UserInfoManager.chatSessionIDSToChatSessions[chatSessionID]!;

        Member? member;
        for (var j = 0; j < session.members.length; j++) {
          if (session.members[j].clientID == clientID) {
            member = session.members[j];
          }
        }

        if (member == null) throw Exception("What the fuck is this");

        _eventBus.fire(VoiceCallIncomingEvent(
          chatSessionID: chatSessionID,
          chatSessionIndex: session.chatSessionIndex,
          aesKey: aesKey,
          member: member,
          signallingPort: signallingPort,
        ));
        break;
      case VoiceCallMessageType.userJoinedVoiceCall:
        int clientID = msg.readInt32();
        int chatSessionID = msg.readInt32();
        int port = msg.readInt32();
        Uint8List rawAddress = msg.readRemainingBytes();
        _eventBus.fire(MemberAddedToVoiceCalll(
          clientID: clientID,
          chatSessionID: chatSessionID,
          socket: JavaInetSocketAddress(InternetAddress.fromRawAddress(rawAddress), port),
        ));

        if (kDebugMode) {
          debugPrint("Mother fucking eventbus");
          debugPrint("Mother fucking eventbus");
          debugPrint("Mother fucking eventbus");
          debugPrint("Mother fucking eventbus");
          debugPrint("Mother fucking eventbus");
        }

        break;
    }
  }
}
