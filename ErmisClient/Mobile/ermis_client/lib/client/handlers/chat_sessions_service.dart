import 'package:ermis_client/core/models/chat_session.dart';
import 'package:ermis_client/core/services/database_service.dart';

class IntermediaryService {
  final DBConnection _databaseService = ErmisDB.getConnection();

  IntermediaryService();

  Future<List<Member>> fetchMembersAssociatedWithChatSession({
    required ServerInfo server,
    required int chatSessionID,
  }) async {
    return await _databaseService.fetchMembersAssociatedWithChatSession(server: server, chatSessionID: chatSessionID);
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
    await _databaseService.insertMembers(serverUrl: server.toString(), members: session.getMembers);
    _databaseService.insertChatSessionMembers(
      serverUrl: server.toString(),
      chatSessionId: session.chatSessionID,
      memberIDs: session.getMembers.map((m) => m.clientID).toList(),
    );
  }

  Future<LocalUserInfo?> fetchLocalUserInfo({
    required ServerInfo server,
  }) async {
    // A bit lazy, but will suffice for now
    LocalAccountInfo? accountInfo = await _databaseService.getLastUsedAccount(server);
    return _databaseService.getLocalUserInfo(server, accountInfo!.email);
  }

  // Future<void> updateLocalMessages(int chatSessionId, List<Map<String, dynamic>> messages) async {
  //   // Perform any necessary data transformation or validation
  //   for (var message in messages) {
  //     await _databaseService.insertChatMessage(chatSessionId, message);
  //   }
  // }
}
