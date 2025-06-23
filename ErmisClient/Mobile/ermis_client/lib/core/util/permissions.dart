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
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dialogs_utils.dart';

Future<(bool, List<Permission>?)> checkAndRequestPermissions(List<Permission> permissions) async {
  bool isPermitted = true;
  List<Permission>? permissionsDenied;

  for (Permission permission in permissions) {
    bool isSpecificPermissionPermitted = await checkAndRequestPermission(permission);
    isPermitted &= isSpecificPermissionPermitted;

    if (!isSpecificPermissionPermitted) {
      permissionsDenied ??= [];
      permissionsDenied.add(permission);
    }
  }

  return (isPermitted, permissionsDenied);
}

Future<bool> checkAndRequestPermission(Permission permission) async {
  try {
    if (await permission.request().isPermanentlyDenied ||
        await permission.request().isDenied) {
      return false;
    }
  } on PlatformException {
    // Evaluate to true by default; this may
    // occur while in background service
    return true;
  }

  return true;
}

Future<bool> requestAllPermissions() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

  if (kDebugMode) {
    showToastDialog("Android Version:${androidInfo.version.sdkInt.toString()}");
  }

  // WARNING: very shitty code
  bool success = true;

  if (androidInfo.version.sdkInt <= 29) {
    success = await checkAndRequestPermission(Permission.storage);
  } else if (androidInfo.version.sdkInt < 33) {
    success = await checkAndRequestPermission(Permission.manageExternalStorage);
  } else if (androidInfo.version.sdkInt >= 33) {
    const permissions = [
      Permission.photos,
      Permission.audio,
      Permission.videos,
      Permission.microphone,
    ];

    for (Permission permission in permissions) {
      success &= await checkAndRequestPermission(permission);
    }
  }

  success &= await checkAndRequestPermission(Permission.notification);

  if (!success) openAppSettings();
  return success;
}