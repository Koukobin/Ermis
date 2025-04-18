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

import 'package:ermis_client/core/models/chat_session.dart';
import 'package:ermis_client/core/services/database/database_service.dart';

class IntermediaryService {
  final DBConnection _databaseService = ErmisDB.getConnection();

  IntermediaryService();

  Future<List<Member>> fetchMembersAssociatedWithChatSession({
    required ServerInfo server,
    required int chatSessionID,
  }) async {
    return await _databaseService.fetchMembersAssociatedWithChatSession(
      server: server,
      chatSessionID: chatSessionID,
    );
  }

  Future<List<int>> fetchChatSessions({
    required ServerInfo server,
  }) async {
    return await _databaseService.fetchChatSessions(server: server);
  }

  void insertChatSession({
    required ServerInfo server,
    required ChatSession session,
  }) async {
    await _databaseService.insertChatSession(server.toString(), session.chatSessionID);
    await _databaseService.insertMembers(serverUrl: server.toString(), members: session.members);
    _databaseService.insertChatSessionMembers(
      serverUrl: server.toString(),
      chatSessionId: session.chatSessionID,
      memberIDs: session.members.map((m) => m.clientID).toList(),
    );
  }

  Future<LocalUserInfo?> fetchLocalUserInfo({
    required ServerInfo server,
  }) async {
    // A bit lazy, but will suffice for now
    LocalAccountInfo? accountInfo = await _databaseService.getLastUsedAccount(server);
    return _databaseService.getLocalUserInfo(server, accountInfo!.email);
  }

  Future<void> deleteChatSession({required ServerInfo server, required ChatSession session}) async {
    await _databaseService.deleteChatSession(server.toString(), session.chatSessionID);
  }

  Future<void> addLocalUserInfo({
    required ServerInfo server,
    required LocalUserInfo info,
  }) async {
    await _databaseService.insertLocalUserInfo(server, info);
  }

  // Future<void> updateLocalMessages(int chatSessionId, List<Map<String, dynamic>> messages) async {
  //   // Perform any necessary data transformation or validation
  //   for (var message in messages) {
  //     await _databaseService.insertChatMessage(chatSessionId, message);
  //   }
  // }
}
