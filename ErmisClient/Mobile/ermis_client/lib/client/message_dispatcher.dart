
import 'dart:convert';

import 'package:ermis_client/client/app_event_bus.dart';
import 'package:ermis_client/client/command_result_handler.dart';
import 'package:ermis_client/client/common/results/client_command_result_type.dart';
import 'package:ermis_client/client/io/input_stream.dart';
import 'package:ermis_client/client/message_events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'common/message_types/server_message_type.dart';
import 'event_bus.dart';
import 'io/byte_buf.dart';

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
          Uint8List content = data.readBytes(data.readableBytes);
          _eventBus.fire(ServerMessageInfoEvent(utf8.decode(content)));
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