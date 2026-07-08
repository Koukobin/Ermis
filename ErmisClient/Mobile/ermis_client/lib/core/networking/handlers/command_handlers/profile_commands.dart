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

import '../../../data/models/network/byte_buf.dart';
import '../../../event_bus/app_event_bus.dart';
import '../../../models/message_events.dart';
import '../../../services/database/models/local_user_info.dart';
import '../../intermediary_service.dart';
import '../../user_info_manager.dart';

final AppEventBus _eventBus = AppEventBus.instance;

mixin ProfileCommands {
  void getDisplayName(ByteBuf msg) {
    final usernameBytes = msg.readBytes(msg.readableBytes);
    UserInfoManager.username = utf8.decode(usernameBytes);
    _eventBus.fire(UsernameReceivedEvent(UserInfoManager.username!));
  }

  void fetchProfileInfo(ByteBuf msg) {
    // ClientID
    UserInfoManager.clientID = msg.readInt32();
    _eventBus.fire(ClientIdReceivedEvent(UserInfoManager.clientID));

    // Username
    final usernameBytes = msg.readBytes(msg.readInt32());
    UserInfoManager.username = utf8.decode(usernameBytes);
    _eventBus.fire(UsernameReceivedEvent(UserInfoManager.username!));

    int lastUpdatedEpochSecond = msg.readInt64();

    // Profile photo
    UserInfoManager.profilePhoto = msg.readBytes(msg.readableBytes);
    _eventBus.fire(ProfilePhotoReceivedEvent(UserInfoManager.profilePhoto!));

    IntermediaryService().addLocalUserInfo(
      server: UserInfoManager.serverInfo,
      info: LocalUserInfo(
        displayName: UserInfoManager.username!,
        clientID: UserInfoManager.clientID,
        profilePhoto: UserInfoManager.profilePhoto!,
        lastUpdatedEpochSecond: lastUpdatedEpochSecond,
      ),
    );
  }

  void fetchAccountIcon(ByteBuf msg) {
    UserInfoManager.profilePhoto = msg.readBytes(msg.readableBytes);
    _eventBus
        .fire(ProfilePhotoReceivedEvent(UserInfoManager.profilePhoto!));
  }

  void setAccountIcon(ByteBuf msg) {
    bool isSuccessful = msg.readBoolean();
    if (!isSuccessful) {
      return;
    }

    // Deduce epoch second
    int lastUpdatedEpochSecond = (DateTime.now().millisecondsSinceEpoch / 1000).toInt();
    UserInfoManager.commitPendingProfilePhoto(lastUpdatedEpochSecond);

    _eventBus.fire(AddProfilePhotoResultEvent(isSuccessful));
  }
}