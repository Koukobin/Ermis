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

import 'package:ermis_mobile/core/networking/handlers/commands/account_commands.dart';
import 'package:ermis_mobile/core/networking/handlers/commands/chat_commands.dart';
import 'package:ermis_mobile/core/networking/handlers/commands/misc_commands.dart';
import 'package:ermis_mobile/core/networking/handlers/commands/profile_commands.dart';
import 'package:ermis_mobile/core/networking/handlers/commands/session_commands.dart';
import 'package:ermis_mobile/core/networking/common/results/command_response_type.dart';
import 'package:ermis_mobile/core/data/models/network/byte_buf.dart';
import 'commands/download_commands.dart';

class CommandResponseHandler
    with
        DownloadCommands,
        ProfileCommands,
        AccountCommands,
        SessionCommands,
        ChatCommands,
        UnrelatedCommands {
  static final crh = CommandResponseHandler._internal().._init();

  late final Map<CommandResponseType, Function(ByteBuf)> actions;

  CommandResponseHandler._internal();

  factory CommandResponseHandler() {
    return crh;
  }

  void _init() {
    actions = {
      CommandResponseType.downloadFile: downloadFile,
      CommandResponseType.downloadImage: downloadImage,
      CommandResponseType.downloadVoice: downloadVoice,
      CommandResponseType.downloadVideo: downloadVideo,
      CommandResponseType.fetchProfileInfo: fetchProfileInfo,
      CommandResponseType.getDisplayName: getDisplayName,
      CommandResponseType.getClientId: getClientId,
      CommandResponseType.fetchAccountStatus: fetchAccountStatus,
      CommandResponseType.getOtherAccountsAssociatedWithDevice:
          getOtherAccountsAssociatedWithDevice,
      CommandResponseType.getChatSessionIndices: getChatSessionIndices,
      CommandResponseType.getChatSessions: getChatSessions,
      CommandResponseType.getChatSessionStatuses: getChatSessionStatuses,
      CommandResponseType.getChatRequests: getChatRequests,
      CommandResponseType.getWrittenText: getWrittenText,
      CommandResponseType.deleteChatMessage: deleteChatMessage,
      CommandResponseType.fetchVoiceCallHistory: fetchVoiceCallHistory,
      CommandResponseType.fetchAccountIcon: fetchAccountIcon,
      CommandResponseType.fetchUserDevices: fetchUserDevices,
      CommandResponseType.setAccountIcon: setAccountIcon,
      CommandResponseType.getDonationPageURL: getDonationPageURL,
      CommandResponseType.getSourceCodePageURL: getSourceCodePageURL,
      CommandResponseType.fetchSignallingServerPort: fetchSignallingPortUrl,
    };
  }

  void handle(CommandResponseType commandResponse, ByteBuf msg) {
    actions[commandResponse]?.call(msg);
  }
}
