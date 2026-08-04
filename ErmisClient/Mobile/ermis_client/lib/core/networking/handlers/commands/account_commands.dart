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
import 'dart:typed_data';

import '../../../data/models/network/byte_buf.dart';
import '../../../event_bus/app_event_bus.dart';
import '../../../models/account.dart';
import '../../../models/message_events.dart';
import '../../../models/user_device.dart';
import '../../common/message_types/client_status.dart';
import '../../user_info_manager.dart';

final AppEventBus _eventBus = AppEventBus.instance;

mixin AccountCommands {
  void fetchAccountStatus(ByteBuf msg) {
    UserInfoManager.accountStatus = ClientStatus.fromId(msg.readInt32());
    _eventBus.fire(AccountStatusEvent(UserInfoManager.accountStatus!));
  }

  void getClientId(ByteBuf msg) {
    UserInfoManager.clientID = msg.readInt32();
    _eventBus.fire(ClientIdReceivedEvent(UserInfoManager.clientID));
  }

  void getOtherAccountsAssociatedWithDevice(ByteBuf msg) {
    UserInfoManager.otherAccounts = [];

    while (msg.readableBytes > 0) {
      int clientID = msg.readInt32();
      String email = utf8.decode(msg.readBytes(msg.readInt32()));
      String displayName = utf8.decode(msg.readBytes(msg.readInt32()));
      Uint8List profilePhoto = Uint8List(0);

      UserInfoManager.otherAccounts!.add(Account(
        profilePhoto: profilePhoto,
        displayName: displayName,
        email: email,
        clientID: clientID,
      ));
    }

    _eventBus.fire(OtherAccountsEvent(UserInfoManager.otherAccounts!));
  }

   void fetchUserDevices(ByteBuf msg) {
    UserInfoManager.userDevices = [];

    while (msg.readableBytes > 0) {
      DeviceType deviceType = DeviceType.fromId(msg.readInt32());
      String deviceUUID = utf8.decode(msg.readBytes(msg.readInt32()));
      String osName = utf8.decode(msg.readBytes(msg.readInt32()));
      UserInfoManager.userDevices!.add(UserDeviceInfo(deviceUUID, deviceType, osName));
    }
    _eventBus.fire(UserDevicesEvent(UserInfoManager.userDevices!));
  }
}