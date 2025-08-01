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

import '../../../exceptions/enum_not_found_exception.dart';

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
  getChatSessionIndices(302),
  getChatSessionStatuses(303),
  getWrittenText(305),
  deleteChatMessage(306),

  // File Management
  downloadFile(400),
  downloadImage(401),
  downloadVoice(402),

  // Voice calls
  fetchSignallingServerPort(501),
  fetchVoiceCallHistory(502),

  // External Pages
  getDonationPageURL(600),
  getSourceCodePageURL(601);

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
