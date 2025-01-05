/* Copyright (C) 2024 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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
import 'dart:typed_data';

import 'message_types/content_type.dart';

class Message {
  late String username;
  late int clientID;
  late int messageID;
  late int chatSessionID;
  late int chatSessionIndex;
  Uint8List? text;
  Uint8List? fileName;
  Uint8List? imageBytes;
  late int timeWritten;
  late MessageContentType contentType;
  bool isSent = false;

  Message(
      {required this.username,
      required this.clientID,
      required this.messageID,
      required this.chatSessionID,
      required this.chatSessionIndex,
      this.text,
      this.fileName,
      required this.timeWritten,
      required this.contentType,
      required this.isSent});

  Message.empty();

  void setUsername(String username) => this.username = username;
  void setIsSent(bool isSent) => this.isSent = isSent;
  void setClientID(int clientID) => this.clientID = clientID;
  void setMessageID(int messageID) => this.messageID = messageID;
  void setChatSessionID(int chatSessionID) => this.chatSessionID = chatSessionID;
  void setChatSessionIndex(int chatSessionIndex) => this.chatSessionIndex = chatSessionIndex;
  void setText(Uint8List? text) => this.text = text;
  void setFileName(Uint8List? fileName) => this.fileName = fileName;
  void setTimeWritten(int timeWritten) => this.timeWritten = timeWritten;
  void setContentType(MessageContentType contentType) => this.contentType = contentType;

  String get getUsername => username;
  int get getClientID => clientID;
  int get getMessageID => messageID;
  int get getChatSessionID => chatSessionID;
  int get getChatSessionIndex => chatSessionIndex;
  String? get getText => text == null ? null : utf8.decode(text!);
  Uint8List? get getFileName => fileName;
  int get getTimeWritten => timeWritten;
  MessageContentType get getContentType => contentType;
  bool get getIsSent => isSent;

  @override
  int get hashCode => messageID.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Message) return false;
    return chatSessionID == other.chatSessionID &&
        chatSessionIndex == other.chatSessionIndex &&
        clientID == other.clientID &&
        contentType == other.contentType &&
        messageID == other.messageID &&
        text == other.text &&
        fileName == other.fileName &&
        timeWritten == other.timeWritten &&
        username == other.username;
  }

  @override
  String toString() {
    return 'Message{username: $username, clientID: $clientID, messageID: $messageID, chatSessionID: $chatSessionID, '
        'chatSessionIndex $chatSessionIndex, text: $text, fileName: $fileName, timeWritten: $timeWritten, contentType: $contentType}';
  }
}
