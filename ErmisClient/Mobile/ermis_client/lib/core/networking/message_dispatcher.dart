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


import 'package:ermis_client/core/event_bus/app_event_bus.dart';
import 'package:ermis_client/core/networking/common/message_types/server_info_message.dart';
import 'package:ermis_client/core/networking/handlers/client_message_handler.dart';
import 'package:ermis_client/core/networking/handlers/command_result_handler.dart';
import 'package:ermis_client/core/networking/common/results/client_command_result_type.dart';
import 'package:ermis_client/core/networking/handlers/message_delivery_status_handler.dart';
import 'package:ermis_client/core/networking/handlers/voice_call_handler.dart';
import 'package:ermis_client/core/data/models/network/input_stream.dart';
import 'package:ermis_client/core/models/message_events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'common/message_types/server_message_type.dart';
import '../event_bus/event_bus.dart';
import '../data/models/network/byte_buf.dart';

class MessageDispatcher {
  final EventBus _eventBus = AppEventBus.instance;
  final ByteBufInputStream _inputStream;
  MessageDispatcher({required ByteBufInputStream inputStream}) : _inputStream = inputStream;

  void debute() {
    _inputStream.listen(
      (ByteBuf data) {
        if (data.capacity > 0) {
          _dispatch(data);
        }
      },
      onDone: () {
        _inputStream.socket.destroy();
        SystemNavigator.pop();
      },
      onError: (e) {
        if (kDebugMode) {
          debugPrint(e.toString());
        }
      },
    );
  }

  void _dispatch(ByteBuf data) {
    try {
      ServerMessageType msgType = ServerMessageType.fromId(data.readInt32());
      switch (msgType) {
        case ServerMessageType.entry:
          _eventBus.fire(EntryMessage(data));
          break;
        case ServerMessageType.serverMessageInfo:
          ServerInfoMessage? infoMessage = ServerInfoMessage.fromId(data.readInt32());
          _eventBus.fire(ServerMessageInfoEvent(infoMessage!.stringMessage));
          break;
        case ServerMessageType.voiceCallIncoming:
          VoiceCallHandler.handle(data);
          break;
        case ServerMessageType.messageDeliveryStatus:
          MessageDeliveryStatusHandler.handle(data);
          break;
        case ServerMessageType.clientMessage:
          ClientMessageHandler.handle(data);
          break;
        case ServerMessageType.commandResult:
          final commandResult = ClientCommandResultType.fromId(data.readInt32());
          CommandResultHandler.handle(commandResult, data);
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(e.toString());
      }
    }
  }
}