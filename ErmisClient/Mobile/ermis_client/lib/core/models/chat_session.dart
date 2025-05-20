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

import 'package:ermis_client/core/models/member.dart';
import 'package:ermis_client/core/networking/common/message_types/content_type.dart';
import 'package:ermis_client/core/util/datetime_utils.dart';
import 'package:ermis_client/core/util/custom_date_formatter.dart';
import 'message.dart';

class ChatSession {
  int chatSessionID;
  int chatSessionIndex;
  List<Member> _members;
  List<int> memberIDs;
  List<Message> _messages;
  bool _hasLatestMessages;

  ChatSession(this.chatSessionID, this.chatSessionIndex)
      : _members = [],
        _messages = [],
        _hasLatestMessages = false,
        memberIDs = [];

  ChatSession.withDetails(
    this.chatSessionID,
    this.chatSessionIndex,
    this._messages,
    this._members,
    this._hasLatestMessages,
    this.memberIDs,
  );

  void setMembers(List<Member> members) => _members = members;
  void setMessages(List<Message> messages) => _messages = messages;
  void setHasLatestMessages(bool hasLatestMessages) => _hasLatestMessages = hasLatestMessages;

  List<Member> get members => _members;
  List<Message> get messages => _messages;

  String get lastMessageContent {
    Message? message = _messages.lastOrNull;

    if (message == null) {
      return "";
    }

    switch (message.contentType) {
      case MessageContentType.text:
        return message.text;
      case MessageContentType.file || MessageContentType.image || MessageContentType.voice:
        return message.fileName;
    }
  }

  String get lastMessageSentTime {
    Message? message = _messages.lastOrNull;

    if (message == null) {
      return "";
    }

    DateTime localTime =
        EpochDateTime.fromSecondsSinceEpoch(message.epochSecond).toLocal();

    if (DateTime.now().difference(localTime).inDays >= 1) {
      return CustomDateFormatter.formatDate(localTime, "dd/MM/yy");
    }

    return CustomDateFormatter.formatDate(localTime, "HH:mm");
  }

  bool get hasLatestMessages => _hasLatestMessages;

  @override
  int get hashCode => Object.hash(
        chatSessionID,
        chatSessionIndex,
        Object.hashAll(_members),
        Object.hashAll(memberIDs),
        Object.hashAll(_messages),
        _hasLatestMessages,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatSession) return false;

    return chatSessionID == other.chatSessionID &&
        chatSessionIndex == other.chatSessionIndex &&
        _hasLatestMessages == other._hasLatestMessages &&
        _members == other._members &&
        _messages == other._messages;
  }

  @override
  String toString() {
    return _members.map((member) => member.toString()).join(', ');
  }
}
