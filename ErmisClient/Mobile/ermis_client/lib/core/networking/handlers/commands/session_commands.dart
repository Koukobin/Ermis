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
import 'dart:convert';

import '../../../data/models/network/byte_buf.dart';
import '../../../data_sources/api_client.dart';
import '../../../event_bus/app_event_bus.dart';
import '../../../extensions/iterable_extensions.dart';
import '../../../models/chat_session.dart';
import '../../../models/member.dart';
import '../../../models/member_icon.dart';
import '../../../models/message_events.dart';
import '../../common/message_types/client_status.dart';
import '../../intermediary_service.dart';
import '../../user_info_manager.dart';

final AppEventBus _eventBus = AppEventBus.instance;

mixin SessionCommands {
  void getChatSessionStatuses(ByteBuf msg) {
    while (msg.readableBytes > 0) {
      int clientID = msg.readInt32();
      ClientStatus status = ClientStatus.fromId(msg.readInt32());  

      for (final session in UserInfoManager.chatSessions!) {
        Member? member = session.members.firstWhereOrNull((m) => m.clientID == clientID);

        if (member == null) continue;
        member.status = status;

        break; // Since all chat sessions share identical Member objects, only need to update one
      }
    }

    _eventBus.fire(ChatSessionsStatusesEvent(UserInfoManager.chatSessions!));
  }

  void getChatSessions(ByteBuf msg) {
    Map<int /* client id */, Member> cache = {};

    while (msg.readableBytes > 0) {
      int chatSessionIndex = msg.readInt32();
      ChatSession chatSession;

      if (chatSessionIndex >= 0 && chatSessionIndex < UserInfoManager.chatSessions!.length) {
        chatSession = UserInfoManager.chatSessions![chatSessionIndex];
      } else {
        // This could happen potentially if this chat session
        // had been cached in the local database and when the
        // conditional request was made, the server did not know
        // what to do and sent -1. Outdated chat sessions - locally
        // will be deleted after new chat sessions have been processed.
        continue;
      }

      List<Member> members = chatSession.members;

      int membersSize = msg.readInt32();
      if (membersSize == -1) {
        // Infer session has been deleted since membersSize is -1

        UserInfoManager.chatSessions!.removeAt(chatSessionIndex);
        UserInfoManager.chatSessionIDSToChatSessions.remove(chatSession.chatSessionID);

        IntermediaryService().deleteChatSession(
          server: UserInfoManager.serverInfo,
          session: chatSession,
        );

        continue;
      }

      bool isChatSessionChanged = false;
      if (membersSize > 0) {
        isChatSessionChanged = true;
      }

      for (int j = 0; j < membersSize; j++) {
        int memberID = msg.readInt32();

        Member member;
        if (cache.containsKey(memberID)) {
          member = cache[memberID]!;
        } else {
          int usernameLength = msg.readInt32();
          String username = utf8.decode(msg.readBytes(usernameLength));
          String iconID = utf8.decode(msg.readBytes(msg.readInt32()));
          int lastUpdatedAtEpochSecond = msg.readInt64();

          member = Member(
            username,
            memberID,
            MemberIcon.empty(profilePhotoID: iconID),
            ClientStatus.offline,
            lastUpdatedAtEpochSecond,
          );

          cache[memberID] = member;
        }

        // Remove outdated member info before adding renewed one
        members.removeWhere((Member member) => member.clientID == memberID);
        members.add(member);
      }

      if (isChatSessionChanged) {
        IntermediaryService().insertChatSession(
          server: UserInfoManager.serverInfo,
          session: chatSession,
        );
      }
    }

    // Delete outdated chat sessions
    for (final session in UserInfoManager.chatSessionIDSToChatSessions.values) {
      if (UserInfoManager.chatSessions!.contains(session)) continue;

      IntermediaryService().deleteChatSession(
        server: UserInfoManager.serverInfo,
        session: session,
      );
    }

    _eventBus.fire(ChatSessionsEvent(UserInfoManager.chatSessions!));

    Client.instance().commands?.fetchChatSessionsStatuses(); // Proceed to fetching statuses
  }

  void getChatSessionIndices(ByteBuf msg) {
    UserInfoManager.chatSessions = [];

    int i = 0;
    while (msg.readableBytes > 0) {
      int chatSessionIndex = i;
      int chatSessionID = msg.readInt32();

      ChatSession? chatSession = UserInfoManager.chatSessionIDSToChatSessions[chatSessionID];
      if (chatSession == null) {
        chatSession = ChatSession(chatSessionID, chatSessionIndex);
        UserInfoManager.chatSessionIDSToChatSessions[chatSessionID] = chatSession;
      } else {
        chatSession.chatSessionIndex = i;
      }

      UserInfoManager.chatSessions!.add(chatSession);

      i++;
    }

    for (ChatSession session in UserInfoManager.chatSessions!) {
      if (session.chatSessionIndex == -1) {
        UserInfoManager.chatSessions!.remove(session);
        UserInfoManager.chatSessionIDSToChatSessions.remove(session.chatSessionID);

        IntermediaryService().deleteChatSession(
          server: UserInfoManager.serverInfo,
          session: session,
        );
      }
    }

    _eventBus.fire(ChatSessionsIndicesReceivedEvent(UserInfoManager.chatSessions!));

    Client.instance().commands?.fetchChatSessions(); // Proceed to fetching chat sessions
  }
}