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

import 'package:ermis_mobile/core/networking/common/message_types/message_delivery_status.dart';

import '../networking/common/message_types/content_type.dart';

class Message {
  final String _username;
  final int _clientID;

  int _messageID;
  final int _chatSessionID;
  int _chatSessionIndex;

  final Map<MessageFields, Uint8List?> _fields;

  int _epochSecond;
  MessageContentType _contentType;
  MessageDeliveryStatus _deliveryStatus;

  Message({
    required String username,
    required int clientID,
    required int messageID,
    required int chatSessionID,
    required int chatSessionIndex,
    required Map<MessageFields, Uint8List?> fields,
    required int epochSecond,
    required MessageContentType contentType,
    required MessageDeliveryStatus deliveryStatus,
  })  : _deliveryStatus = deliveryStatus,
        _contentType = contentType,
        _epochSecond = epochSecond,
        _fields = fields,
        _clientID = clientID,
        _messageID = messageID,
        _chatSessionIndex = chatSessionIndex,
        _chatSessionID = chatSessionID,
        _username = username;

  Message.empty()
      : _username = '',
        _clientID = 0,
        _messageID = 0,
        _chatSessionID = 0,
        _chatSessionIndex = 0,
        _fields = {},
        _epochSecond = 0,
        _contentType = MessageContentType.text, // Assuming a default value
        _deliveryStatus = MessageDeliveryStatus.sending;

  void setDeliveryStatus(MessageDeliveryStatus deliveryStatus) => _deliveryStatus = deliveryStatus;
  void setMessageID(int messageID) => _messageID = messageID;
  void setChatSessionIndex(int chatSessionIndex) => _chatSessionIndex = chatSessionIndex;

  void addFields(Map<MessageFields, Uint8List?> fields) {
    for (MapEntry<MessageFields, Uint8List?> field in fields.entries) {
      _fields[field.key] = field.value;
    }
  }

  void setEpochSecond(int epochSecond) => _epochSecond = epochSecond;
  void setContentType(MessageContentType contentType) => _contentType = contentType;

  String get username => _username;
  int get clientID => _clientID;
  int get messageID => _messageID;
  int get chatSessionID => _chatSessionID;
  int get chatSessionIndex => _chatSessionIndex;

  String get text {
    Uint8List? fieldText = _fields[MessageFields.text];
    if (fieldText == null) {
      return "";
    }

    return utf8.decode(fieldText.toList(), allowMalformed: true);
  }

  String get fileName {
    Uint8List? fieldFileName = _fields[MessageFields.fileName];
    if (fieldFileName == null) {
      return "";
    }

    return utf8.decode(fieldFileName.toList(), allowMalformed: true);
  }

  Uint8List? get fileBytes {
    return _fields[MessageFields.fileBytes];
  }

  int get epochSecond => _epochSecond;
  MessageContentType get contentType => _contentType;
  MessageDeliveryStatus get deliveryStatus => _deliveryStatus;

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
        _fields == other._fields &&
        _epochSecond == other._epochSecond &&
        _username == other._username;
  }

  @override
  String toString() {
    return 'Message{username: $_username, clientID: $_clientID, messageID: $_messageID, chatSessionID: $_chatSessionID, '
        'chatSessionIndex $_chatSessionIndex, fields: $_fields, timeWritten: $_epochSecond, contentType: $_contentType}';
  }
}
