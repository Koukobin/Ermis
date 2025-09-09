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

import 'package:ermis_mobile/core/models/account.dart';
import 'package:ermis_mobile/core/models/chat_request.dart';
import 'package:ermis_mobile/core/models/chat_session.dart';
import 'package:ermis_mobile/core/models/message.dart';
import 'package:ermis_mobile/core/models/user_device.dart';
import 'package:ermis_mobile/core/models/voice_call_history.dart';
import 'package:ermis_mobile/core/networking/common/message_types/client_status.dart';
import 'package:ermis_mobile/core/services/database/models/local_user_info.dart';
import 'package:ermis_mobile/core/services/database/models/server_info.dart';
import 'package:flutter/foundation.dart';

import '../services/database/models/local_account_info.dart';
import 'handlers/intermediary_service.dart';

class UserInfoManager {
  static String? username;
  static int clientID = -1;
  static ClientStatus? accountStatus;
  static Uint8List? profilePhoto;
  static List<UserDeviceInfo>? userDevices;
  static List<Account>? otherAccounts;

  static final Map<int, ChatSession> chatSessionIDSToChatSessions = {};
  static List<ChatSession>? chatSessions;
  static List<ChatRequest>? chatRequests;
  static final Map<int, List<VoiceCallHistory>> chatSessionIDSToVoiceCallHistory = {};
  
  static final Map<int /* temporary message id */, Message> pendingMessagesQueue = {};
  static int lastPendingMessageID = 0;

  static late ServerInfo serverInfo;

  static Uint8List? _pendingAccountIcon;

  /// This field distinguishes whether or not client
  /// is actually connected to the server or is offline
  // static late bool isConnectionActive;

  static set pendingAccountIcon(Uint8List pendingAccountIcon) => _pendingAccountIcon = pendingAccountIcon;
  static void commitPendingProfilePhoto(int lastUpdatedEpochSecond) {
    UserInfoManager.profilePhoto = UserInfoManager._pendingAccountIcon;
    _pendingAccountIcon = null;

    IntermediaryService().addLocalUserInfo(
      server: serverInfo,
      info: LocalUserInfo(
        displayName: username!,
        clientID: clientID,
        profilePhoto: profilePhoto!,
        lastUpdatedEpochSecond: lastUpdatedEpochSecond,
      ),
    );
  }

  static Future<LocalUserInfo?> fetchProfileInformation() async {
    LocalUserInfo? userInfo = await IntermediaryService().fetchLocalUserInfo(server: serverInfo);

    if (userInfo != null) {
      clientID = userInfo.clientID;
      username = userInfo.displayName;
      profilePhoto = userInfo.profilePhoto;
    }

    return userInfo;
  }

  static Future<LocalAccountInfo> fetchAccountInformation() async {
    LocalAccountInfo? info = await IntermediaryService().fetchLocalAccountInfo(server: serverInfo);
    return info!;
  }

  static Future<List<ChatSession>> fetchLocalChatSessions() async {
    List<ChatSession> sessions = await IntermediaryService().fetchChatSessions(server: serverInfo);

    for (ChatSession session in sessions) {
      chatSessionIDSToChatSessions[session.chatSessionID] = session;
    }

    chatSessions = sessions;
    return sessions;
  }

  /// Resets all user information; useful for when switching between accounts
  static void resetUserInformation() {
    username = null;
    clientID = -1;
    accountStatus = null;
    profilePhoto = null;
    userDevices = null;

    chatSessionIDSToChatSessions.clear();
    chatSessions = null;
    chatRequests = null;
    chatSessionIDSToVoiceCallHistory.clear();

    otherAccounts = null;
    pendingMessagesQueue.clear();
    lastPendingMessageID = 0;
  }

  static void resetServerInformation() {
    serverInfo = ServerInfo.empty();
  }
}
