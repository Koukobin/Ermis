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


import '../../../core/exceptions/EnumNotFoundException.dart';
import 'command_level.dart';

enum ClientCommandType {
  // Account Management
  changeUsername(CommandLevel.heavy, 100),
  changePassword(CommandLevel.heavy, 101),
  addAccountIcon(CommandLevel.heavy, 102),
  logoutThisDevice(CommandLevel.light, 103),
  logoutOtherDevice(CommandLevel.light, 104),
  logoutAllDevices(CommandLevel.light, 105),
  deleteAccount(CommandLevel.heavy, 106),
  addNewAccount(CommandLevel.heavy, 107),
	switchAccount(CommandLevel.heavy, 108),

  // User Information Requests
  fetchUsername(CommandLevel.light, 200),
  fetchClientId(CommandLevel.light, 201),
  fetchUserDevices(CommandLevel.heavy, 202),
  fetchAccountIcon(CommandLevel.heavy, 203),
  fetchOtherAccountsAssociatedWithDevice(CommandLevel.heavy, 204),

  // Chat Management
  fetchChatRequests(CommandLevel.light, 300),
  fetchChatSessions(CommandLevel.light, 301),
  sendChatRequest(CommandLevel.heavy, 302),
  acceptChatRequest(CommandLevel.heavy, 303),
  declineChatRequest(CommandLevel.heavy, 304),
  deleteChatSession(CommandLevel.heavy, 305),
  addUserInChatSession(CommandLevel.heavy, 306),
  createGroup(CommandLevel.heavy, 307),
  deleteChatMessage(CommandLevel.heavy, 308),
  fetchWrittenText(CommandLevel.heavy, 309),
  downloadFile(CommandLevel.heavy, 310),
  downloadImage(CommandLevel.heavy, 311),
  startVoiceCall(CommandLevel.heavy, 312),
  acceptVoiceCall(CommandLevel.heavy, 313),

  // External Pages
  requestDonationPage(CommandLevel.light, 400),
  requestSourceCodePage(CommandLevel.light, 401),

  // Other
	fetchSignallingServerPort(CommandLevel.light, 500);

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