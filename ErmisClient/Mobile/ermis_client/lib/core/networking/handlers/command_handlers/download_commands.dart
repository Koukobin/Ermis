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

import 'dart:convert';

import '../../../data/models/network/byte_buf.dart';
import '../../../event_bus/app_event_bus.dart';
import '../../../models/file_heap.dart';
import '../../../models/message_events.dart';
import '../../common/message_types/content_type.dart';
import '../../user_info_manager.dart';

final AppEventBus _eventBus = AppEventBus.instance;

mixin DownloadCommands {
  void downloadVideo(ByteBuf msg) {
    final messageID = msg.readInt32();
    final chatSessionID = msg.readInt32();
    final fileNameLength = msg.readInt32();
    final fileNameBytes = msg.readBytes(fileNameLength);
    final fileBytes = msg.readBytes(msg.readableBytes);

    final file = LoadedInMemoryFile(utf8.decode(fileNameBytes), fileBytes);

    for (final message in UserInfoManager.chatSessionIDSToChatSessions[chatSessionID]!.messages) {
      if (message.messageID == messageID) {
        message.addFields({
          MessageFields.fileName: utf8.encode(file.fileName),
          MessageFields.fileBytes: file.fileBytes,
        });
        break;
      }
    }

    _eventBus.fire(VideoDownloadedEvent(file, messageID));
  }

  void downloadVoice(ByteBuf msg) {
    final messageID = msg.readInt32();
    final chatSessionID = msg.readInt32();
    final fileNameLength = msg.readInt32();
    final fileNameBytes = msg.readBytes(fileNameLength);
    final fileBytes = msg.readBytes(msg.readableBytes);

    final file = LoadedInMemoryFile(utf8.decode(fileNameBytes), fileBytes);

    for (final message in UserInfoManager.chatSessionIDSToChatSessions[chatSessionID]!.messages) {
      if (message.messageID == messageID) {
        message.addFields({
          MessageFields.fileName: utf8.encode(file.fileName),
          MessageFields.fileBytes: file.fileBytes,
        });
        break;
      }
    }

    _eventBus.fire(VoiceDownloadedEvent(file, messageID));
  }

  void downloadImage(ByteBuf msg) {
    final messageID = msg.readInt32();
    final chatSessionID = msg.readInt32();
    final fileNameLength = msg.readInt32();
    final fileNameBytes = msg.readBytes(fileNameLength);
    final fileBytes = msg.readBytes(msg.readableBytes);

    final file = LoadedInMemoryFile(utf8.decode(fileNameBytes), fileBytes);

    for (final message in UserInfoManager.chatSessionIDSToChatSessions[chatSessionID]!.messages) {
      if (message.messageID == messageID) {
        message.addFields({
          MessageFields.fileName: utf8.encode(file.fileName),
          MessageFields.fileBytes: file.fileBytes,
        });
        break;
      }
    }

    _eventBus.fire(ImageDownloadedEvent(file, messageID));
  }

  void downloadFile(ByteBuf msg) {
    final messageID = msg.readInt32();
    final chatSessionID = msg.readInt32();
    final fileNameLength = msg.readInt32();
    final fileNameBytes = msg.readBytes(fileNameLength);
    final fileBytes = msg.readBytes(msg.readableBytes);

    final file = LoadedInMemoryFile(utf8.decode(fileNameBytes), fileBytes);

    for (final message in UserInfoManager.chatSessionIDSToChatSessions[chatSessionID]!.messages) {
      if (message.messageID == messageID) {
        message.addFields({
          MessageFields.fileName: utf8.encode(file.fileName),
          MessageFields.fileBytes: file.fileBytes,
        });
        break;
      }
    }

    _eventBus.fire(FileDownloadedEvent(file, messageID));
  }
}