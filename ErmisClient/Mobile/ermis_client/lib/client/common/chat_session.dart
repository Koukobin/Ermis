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
import 'package:ermis_client/client/common/message_types/content_type.dart';
import 'package:intl/intl.dart';

import 'message.dart';

class ChatSession {
  final int _chatSessionID;
  final int _chatSessionIndex;
  List<Member> _members;
  List<Message> _messages;
  bool _haveChatMessagesBeenCached;

  ChatSession(this._chatSessionID, this._chatSessionIndex)
      : _members = [],
        _messages = [],
        _haveChatMessagesBeenCached = false;

  ChatSession.withDetails(this._chatSessionID, this._chatSessionIndex,
      this._messages, this._members, this._haveChatMessagesBeenCached);

  void setMembers(List<Member> members) => _members = members;

  void setMessages(List<Message> messages) => _messages = messages;

  void setHaveChatMessagesBeenCached(bool haveChatMessagesBeenCached) =>
      _haveChatMessagesBeenCached = haveChatMessagesBeenCached;

  int get chatSessionID => _chatSessionID;
  int get chatSessionIndex => _chatSessionIndex;
  List<Member> get getMembers => _members;
  List<Message> get getMessages => _messages;

  String get lastMessageContent {
    Message? message = _messages.lastOrNull;

    if (message == null) {
      return "";
    }

    switch (message.contentType) {
      case ContentType.text:
        return utf8.decode(message.text!.toList());
      case ContentType.file || ContentType.image:
        return utf8.decode(message.fileName!.toList());
    }
  }

  String get lastMessageSentTime {
    Message? message = _messages.lastOrNull;

    if (message == null) {
      return "";
    }

    DateTime localTime =
        DateTime.fromMillisecondsSinceEpoch(message.getTimeWritten, isUtc: true)
            .toLocal();

    if (DateTime.now().difference(localTime).inDays >= 1) {
      return DateFormat("dd/MM/yy").format(localTime);
    }

    return DateFormat("HH:mm").format(localTime);
  }

  bool get haveChatMessagesBeenCached => _haveChatMessagesBeenCached;

  @override
  int get hashCode => _chatSessionID.hashCode ^ _chatSessionIndex.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatSession) return false;
    return _chatSessionID == other._chatSessionID &&
        _chatSessionIndex == other._chatSessionIndex &&
        _haveChatMessagesBeenCached == other._haveChatMessagesBeenCached &&
        _members == other._members &&
        _messages == other._messages;
  }

  @override
  String toString() {
    return _members.map((member) => member.toString()).join(', ');
  }
}

class Member {
  String username;
  int clientID;
  Uint8List icon;
  bool isActive;

  Member(this.username, this.clientID, this.icon, this.isActive);

  void setUsername(String username) => this.username = username;
  void setClientID(int clientID) => this.clientID = clientID;
  void setIcon(Uint8List icon) => this.icon = icon;
  void setIsActive(bool isActive) => this.isActive = isActive;

  String get getUsername => username;
  int get getClientID => clientID;
  Uint8List get getIcon => icon;
  bool get getIsActive => isActive;

  @override
  int get hashCode => clientID.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Member) return false;
    return clientID == other.clientID &&
        icon == other.icon &&
        username == other.username &&
        isActive == other.isActive;
  }

  @override
  String toString() => '$username@$clientID';
}
