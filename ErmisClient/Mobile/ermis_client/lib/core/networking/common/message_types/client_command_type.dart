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

import '../../../exceptions/EnumNotFoundException.dart';
import 'command_level.dart';

enum ClientCommandType {
  // Account Management
  changeUsername(CommandLevel.heavy, 100),
  changePassword(CommandLevel.heavy, 101),
  addAccountIcon(CommandLevel.heavy, 102),
  setAccountStatus(CommandLevel.light, 103),
  logoutThisDevice(CommandLevel.light, 104),
  logoutOtherDevice(CommandLevel.light, 105),
  logoutAllDevices(CommandLevel.light, 106),
  deleteAccount(CommandLevel.heavy, 107),
  addOrSwitchToNewAccount(CommandLevel.heavy, 108),

  // User Information Requests
  fetchProfileInformation(CommandLevel.heavy, 200),
  fetchUsername(CommandLevel.light, 201),
  fetchClientId(CommandLevel.light, 202),
  fetchAccountStatus(CommandLevel.light, 203),
  fetchUserDevices(CommandLevel.heavy, 204),
  fetchAccountIcon(CommandLevel.heavy, 205),
  fetchOtherAccountsAssociatedWithDevice(CommandLevel.heavy, 206),

  // Chat Management
  fetchChatRequests(CommandLevel.light, 300),
  fetchChatSessionIndices(CommandLevel.light, 301),
  fetchChatSessions(CommandLevel.light, 314),
  fetchChatSessionStatuses(CommandLevel.light, 315),
  sendChatRequest(CommandLevel.heavy, 302),
  acceptChatRequest(CommandLevel.heavy, 303),
  declineChatRequest(CommandLevel.heavy, 304),
  deleteChatSession(CommandLevel.heavy, 305),
  addUserInChatSession(CommandLevel.heavy, 306),
  createGroup(CommandLevel.heavy, 307),
  deleteChatMessage(CommandLevel.heavy, 308),
  fetchWrittenText(CommandLevel.heavy, 309),
  downloadFile(CommandLevel.heavy, 310),
  startVoiceCall(CommandLevel.heavy, 312),
  acceptVoiceCall(CommandLevel.heavy, 313),

  // External Pages
  requestDonationPage(CommandLevel.light, 400),
  requestSourceCodePage(CommandLevel.light, 401),

  	// Voice call history
	fetchVoiceCallHistory(CommandLevel.heavy, 500),

  // Other
	fetchSignallingServerPort(CommandLevel.light, 600);

  final CommandLevel commandLevel;
  final int id;
  const ClientCommandType(this.commandLevel, this.id);

  // This function mimics the fromId functionality and throws an exception when no match is found.
  static ClientCommandType fromId(int id) {
    try {
      return ClientCommandType.values.firstWhere((type) => type.id == id);
    } catch (e) {
      throw EnumNotFoundException('No ClientCommandType found for id $id');
    }
  }

  CommandLevel getCommandLevel() => commandLevel;
}