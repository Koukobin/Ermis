

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