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

enum ClientCommandResultType {
  // Account Management
  setAccountIcon(100),

  // Profile User Information Requests
  fetchProfileInfo(200),
  getDisplayName(201),
  getClientId(202),
  fetchUserDevices(203),
  fetchAccountStatus(204),
  fetchAccountIcon(205),
  getOtherAccountsAssociatedWithDevice(206),

  // Chat Management
  getChatRequests(300),
  getChatSessions(301),
  getChatSessionIndices(304),
  getChatSessionStatuses(305),
  getWrittenText(302),
  deleteChatMessage(303),

  // File Management
  downloadFile(400),
  downloadImage(401),
  downloadVoice(402),

  // Start voice call
  startVoiceCall(500),

  // External Pages
  getDonationPageURL(600),
  getSourceCodePageURL(601),

  // Other
  fetchSignallingServerPort(700);

  final int id;
  const ClientCommandResultType(this.id);
  
  static ClientCommandResultType fromId(int id) {
    try {
      return ClientCommandResultType.values
          .firstWhere((type) => type.id == id);
    } catch (e) {
      throw EnumNotFoundException('No $ClientCommandResultType found for id $id');
    }
  }
}
