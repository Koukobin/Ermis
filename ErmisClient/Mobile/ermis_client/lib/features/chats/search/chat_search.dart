/* Copyright (C) 2026 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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

import '../../../core/models/message.dart';
import '../../../core/networking/common/message_types/content_type.dart';
import '../../../core/models/chat_session.dart';

extension on Message {
  String get searchableText => switch (contentType) {
        MessageContentType.file => fileName,
        _ => text,
      };
}

class ChatSearch {
  const ChatSearch({this.recentMessageLimit = 50});

  final int recentMessageLimit;

  bool matches(ChatSession session, String query) {
    if (query.isEmpty) return true;
    if (session.toString().contains(query)) return true;

    Iterable<Message> recentMessages = 
        ([...session.messages]
            ..sort((a, b) => b.epochSecond.compareTo(a.epochSecond)))
          .take(recentMessageLimit);

    if (recentMessages.any((m) => m.searchableText.contains(query))) {
      return true;
    }

    return false;
  }

  /// Matching sessions first, original order otherwise. Never mutates [sessions].
  List<ChatSession> rank(Iterable<ChatSession> sessions, String query) {
    final matching = <ChatSession>[];
    final rest = <ChatSession>[];
    for (final session in sessions) {
      if (matches(session, query)) {
        matching.add(session);
      } else {
        rest.add(session);
      }
    }
    return [...matching, ...rest];
  }
}