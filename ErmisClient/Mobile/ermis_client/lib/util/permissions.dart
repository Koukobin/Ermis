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



import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dialogs_utils.dart';

Future<bool> checkPermission(Permission permission) async {
  if (await permission.request().isPermanentlyDenied ||
      await permission.request().isDenied) {
    return false;
  }
  return true;
}

Future<bool> requestPermissions({BuildContext? context}) async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

  if (kDebugMode && context != null) {
    showSimpleAlertDialog(
        context: context,
        title: "Debug Mode",
        content: "Android Version:${androidInfo.version.sdkInt.toString()}");
  }

  // WARNING: very shitty code
  bool success = true;

  if (androidInfo.version.sdkInt <= 29) {
    success = await checkPermission(Permission.storage);
  } else if (androidInfo.version.sdkInt < 33) {
    success = await checkPermission(Permission.manageExternalStorage);
  } else if (androidInfo.version.sdkInt >= 33) {
    const permissions = [
      Permission.photos,
      Permission.audio,
      Permission.videos,
      Permission.microphone
    ];

    for (Permission permission in permissions) {
      bool individualPermissionSuccess = await checkPermission(permission);
      if (!individualPermissionSuccess) success = false;
    }
  }

  if (!success) openAppSettings();
  return success;
}