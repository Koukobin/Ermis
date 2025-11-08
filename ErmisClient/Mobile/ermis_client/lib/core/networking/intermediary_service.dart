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

import 'package:ermis_mobile/core/models/chat_session.dart';
import 'package:ermis_mobile/core/models/member.dart';
import 'package:ermis_mobile/core/services/database/database_service.dart';
import 'package:ermis_mobile/core/services/database/extensions/accounts_extension.dart';
import 'package:ermis_mobile/core/services/database/extensions/chat_sessions_extension.dart';
import 'package:ermis_mobile/core/services/database/extensions/members_extension.dart';
import 'package:ermis_mobile/core/services/database/models/local_account_info.dart';
import 'package:ermis_mobile/core/services/database/models/local_user_info.dart';
import 'package:ermis_mobile/core/services/database/models/server_info.dart';

class IntermediaryService {
  static IntermediaryService? _instance;

  IntermediaryService._();

  factory IntermediaryService() {
    _instance ??= IntermediaryService._();
    return _instance!;
  }

  DBConnection get _conn => ErmisDB.getConnection();

  Future<List<ChatSession>> fetchChatSessions({
    required LocalAccountInfo? accountInfo,
    required ServerInfo server,
  }) async {
    accountInfo ??= await IntermediaryService().fetchLastUsedAccount(
      server: server,
    );
    if (accountInfo == null) return [];

    LocalUserInfo? userInfo =  await _conn.getLocalUserInfo(server, accountInfo.email);
    return _conn.fetchChatSessions(
      server: server,
      clientIDExclude: userInfo?.clientID ?? -1,
    );
  }

  Future<List<Member>> fetchMembersAssociatedWithChatSession({
    required int chatSessionID,
    required LocalAccountInfo accountInfo,
    required ServerInfo server,
  }) {
    return _conn.fetchMembersAssociatedWithChatSession(
      server: server,
      serverAccountEmail: accountInfo.email,
      chatSessionID: chatSessionID,
    );
  }

  Future<List<int>> fetchChatSessionsIDs({
    required LocalAccountInfo accountInfo,
    required ServerInfo server,
  }) {
    return _conn.fetchChatSessionIDS(server: server, email: accountInfo.email);
  }

  void insertChatSession({
    required ServerInfo server,
    required ChatSession session,
  }) async {
    await _conn.insertChatSession(server.toString(), session.chatSessionID);
    await _conn.insertMembers(serverUrl: server.toString(), members: session.members);
    _conn.insertChatSessionMembers(
      serverUrl: server.toString(),
      chatSessionId: session.chatSessionID,
      memberIDs: session.members.map((m) => m.clientID).toList(),
    );
  }

  Future<void> deleteChatSession({
    required ServerInfo server,
    required ChatSession session,
  }) {
    return _conn.deleteChatSession(server.toString(), session.chatSessionID);
  }

  Future<LocalUserInfo?> fetchLocalUserInfo({
    required LocalAccountInfo? accountInfo,
    required ServerInfo server,
  }) async {
    accountInfo ??= await IntermediaryService().fetchLastUsedAccount(
      server: server,
    );
    if (accountInfo == null) return null;

    return _conn.getLocalUserInfo(server, accountInfo.email);
  }

  Future<LocalAccountInfo?> fetchLastUsedAccount({required ServerInfo server}) {
    return _conn.getLastUsedAccount(server);
  }

  Future<void> addLocalUserInfo({
    required ServerInfo server,
    required LocalUserInfo info,
  }) async {
    await _conn.insertLocalUserInfo(server, info);
  }

  // Future<void> updateLocalMessages(int chatSessionId, List<Map<String, dynamic>> messages) async {
  //   // Perform any necessary data transformation or validation
  //   for (var message in messages) {
  //     await _databaseService.insertChatMessage(chatSessionId, message);
  //   }
  // }
}
