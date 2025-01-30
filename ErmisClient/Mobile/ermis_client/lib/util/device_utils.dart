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

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:ermis_client/client/common/user_device.dart';

Future<String> getDeviceDetails() async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    var androidInfo = await deviceInfo.androidInfo;
    return androidInfo.model;
  }

  if (Platform.isIOS) {
    var iosInfo = await deviceInfo.iosInfo;
    return iosInfo.utsname.machine;
  }

  return Platform.operatingSystem;
}

Future<DeviceType> getDeviceType() async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    return DeviceType.mobile;
  }

  if (Platform.isIOS) {
    var iosInfo = await deviceInfo.iosInfo;
    
    if (iosInfo.model.contains("iPad")){
      return DeviceType.tablet;
    }

    return DeviceType.mobile;
  }

  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    return DeviceType.desktop;
  }

  return DeviceType.unknown;
}