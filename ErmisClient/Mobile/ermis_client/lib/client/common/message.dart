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
  String _username;
  int _clientID;
  int _messageID;
  int _chatSessionID;
  int _chatSessionIndex;
  Uint8List? _text;
  Uint8List? _fileName;
  Uint8List? _imageBytes;
  int _timeWritten;
  MessageContentType _contentType;
  bool _isSent = false;

  Message({
    required String username,
    required int clientID,
    required int messageID,
    required int chatSessionID,
    required int chatSessionIndex,
    Uint8List? text,
    Uint8List? fileName,
    required int timeWritten,
    required MessageContentType contentType,
    required bool isSent,
  })  : _isSent = isSent,
        _contentType = contentType,
        _timeWritten = timeWritten,
        _fileName = fileName,
        _clientID = clientID,
        _messageID = messageID,
        _chatSessionIndex = chatSessionIndex,
        _text = text,
        _chatSessionID = chatSessionID,
        _username = username;

  Message.empty()
      : _username = '',
        _clientID = 0,
        _messageID = 0,
        _chatSessionID = 0,
        _chatSessionIndex = 0,
        _text = null,
        _fileName = null,
        _timeWritten = 0,
        _contentType = MessageContentType.text, // Assuming a default value
        _isSent = false;

  void setUsername(String username) => _username = username;
  void setIsSent(bool isSent) => _isSent = isSent;
  void setClientID(int clientID) => _clientID = clientID;
  void setMessageID(int messageID) => _messageID = messageID;
  void setChatSessionID(int chatSessionID) => _chatSessionID = chatSessionID;
  void setChatSessionIndex(int chatSessionIndex) => _chatSessionIndex = chatSessionIndex;
  void setText(Uint8List? text) => _text = text;
  void setFileName(Uint8List? fileName) => _fileName = fileName;
  set imageBytes(Uint8List? imageBytes) => _imageBytes = imageBytes;
  void setTimeWritten(int timeWritten) => _timeWritten = timeWritten;
  void setContentType(MessageContentType contentType) =>
      _contentType = contentType;

  String get username => _username;
  int get clientID => _clientID;
  int get messageID => _messageID;
  int get chatSessionID => _chatSessionID;
  int get chatSessionIndex => _chatSessionIndex;
  String get text {
    if (_text == null) {
      return "";
    }

    return utf8.decode(_text!.toList(), allowMalformed: true);
  }

  String get fileName {
    if (_fileName == null) {
      return "";
    }

    return utf8.decode(_fileName!.toList(), allowMalformed: true);
  }

  Uint8List? get imageBytes => _imageBytes;
  int get timeWritten => _timeWritten;
  MessageContentType get contentType => _contentType;
  bool get isSent => _isSent;

  @override
  int get hashCode => _messageID.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Message) return false;
    return _chatSessionID == other._chatSessionID &&
        _chatSessionIndex == other._chatSessionIndex &&
        _clientID == other._clientID &&
        _contentType == other._contentType &&
        _messageID == other._messageID &&
        _text == other._text &&
        _fileName == other._fileName &&
        _timeWritten == other._timeWritten &&
        _username == other._username;
  }

  @override
  String toString() {
    return 'Message{username: $_username, clientID: $_clientID, messageID: $_messageID, chatSessionID: $_chatSessionID, '
        'chatSessionIndex $_chatSessionIndex, text: $_text, fileName: $_fileName, timeWritten: $_timeWritten, contentType: $_contentType}';
  }
}
