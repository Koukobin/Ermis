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




import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

Future<void> confirmDialog(BuildContext context, String content, GestureTapCallback runOnConfirmation) async {
  final shouldExit = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Are you sure?"),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Confirm
            child: const Text("Yes"),
          ),
        ],
      );
    },
  );

  if (shouldExit ?? false) {
    runOnConfirmation();
  }
}

Future<void> showExceptionDialog(BuildContext context, String exception) async {
  await showSimpleAlertDialog(
    context: context,
    title: "An error occurred",
    content: exception,
  );
}

Future<T> showLoadingDialog<T>(BuildContext context, Future<T> executeWhileLoading) async {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissal by tapping outside
    builder: (BuildContext context) {
      return Center(
        child: CircularProgressIndicator(),
      );
    },
  );

  T result = await executeWhileLoading;
  Navigator.of(context).pop();
  return result;
}

Future<void> showErrorDialog(BuildContext context, String message) async {
  await showSimpleAlertDialog(
    context: context,
    title: "Error",
    content: message,
  );
}

void showSnackBarDialog({
  required BuildContext context,
  required String content,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(content)),
  );
}

Future<void> showSimpleAlertDialog({
  required BuildContext context,
  required String title,
  required String content,
}) async {
  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      final appColors = Theme.of(context).extension<AppColors>()!;
      return AlertDialog(
        backgroundColor: appColors.tertiaryColor,
        title: Text(
          title,
          style: TextStyle(
            color: appColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          content,
          style: TextStyle(color: appColors.inferiorColor),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: appColors.primaryColor,
            ),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

AlertDialog createSimpleAlertDialog(BuildContext context, String title, String content) {
  return AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: <Widget>[
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('OK'),
      ),
    ],
  );
}

Future<String?> showInputDialog({
  required BuildContext context,
  required String title,
  String hintText = "",
}) async {
  final TextEditingController controller = TextEditingController();
  String? input;

  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      final appColors = Theme.of(context).extension<AppColors>()!;
      return AlertDialog(
        backgroundColor: appColors.tertiaryColor.withOpacity(0.9),
        title: Text(
          title,
          style: TextStyle(
            color: appColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          cursorColor: appColors.primaryColor,
          style: TextStyle(color: appColors.inferiorColor),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: appColors.inferiorColor),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: appColors.secondaryColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: appColors.primaryColor),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              input = null; // Clear input if canceled
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: appColors.secondaryColor,
            ),
            child: Text('Cancel', style: TextStyle(color: appColors.inferiorColor),),
          ),
          ElevatedButton(
            onPressed: () {
              input = controller.text.trim();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: appColors.primaryColor,
            ),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );

  return input;
}
