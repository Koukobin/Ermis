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

import 'package:ermis_client/generated/l10n.dart';
import 'package:ermis_client/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> showToastDialog(String msg) async {
  await Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      textColor: Colors.white,
      fontSize: 16.0);
}

/// This method must be used for dialogs that utilize the Hero animation to work correctly.
/// It ensures the dialog is displayed using a transparent `PageRouteBuilder`,
/// allowing Hero animations to function properly.
Future<T?> showHeroDialog<T extends Object?>(BuildContext context,
    {required RoutePageBuilder pageBuilder}) async {
  return await Navigator.of(context).push(PageRouteBuilder(
    opaque: false,
    barrierDismissible: false,
    pageBuilder: pageBuilder,
  ));
}

class WhatsAppPopupDialog extends StatefulWidget {
  final Widget child;

  const WhatsAppPopupDialog({super.key, required this.child});

  @override
  State<WhatsAppPopupDialog> createState() => _WhatsAppPopupDialogState();
}

class _WhatsAppPopupDialogState extends State<WhatsAppPopupDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastEaseInToSlowEaseOut,
    );

    // Launch animation
    Future.delayed(Duration(milliseconds: 150), _controller.forward);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

Future<void> showWhatsAppDialog(
  BuildContext context, {
  String? title,
  required List<TextButton> buttons,
  required String content,
}) async {
  await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => WhatsAppPopupDialog(
            child: AlertDialog(
              title: title == null ? null : Text(title),
              content: Text(content),
              actionsAlignment: MainAxisAlignment.end,
              actions: [...buttons],
            ),
          ));
}

Future<void> showPermissionDeniedDialog(
    BuildContext context, Permission permission) async {
  await showWhatsAppDialog(
    context,
    buttons: [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          openAppSettings();
        },
        child: const Text("Open Settings"),
      ),
      TextButton(
        onPressed: Navigator.of(context).pop,
        child: const Text("Ok"),
      ),
    ],
    content: "$permission is denied",
  );
}

Future<void> showConfirmationDialog(BuildContext context, String content,
    GestureTapCallback runOnConfirmation) async {
  final bool? shouldExit = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return WhatsAppPopupDialog(
        child: AlertDialog(
          title: const Text("Are you sure?"),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: const Text("No", style: TextStyle(fontSize: 18)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm
              child: const Text("Yes", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      );
    },
  );

  if (shouldExit ?? false) {
    runOnConfirmation();
  }
}

Future<void> showLogoutConfirmationDialog(
    BuildContext context, String content, VoidCallback onYes) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return WhatsAppPopupDialog(
        child: AlertDialog(
          title: Text('Logout?'),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(S.current.cancel),
            ),
            TextButton(
              onPressed: () {
                onYes();
                Navigator.of(context).pop();
              },
              child: Text(S.current.logout_capitalized,
                  style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showExceptionDialog(BuildContext context, String exception) async {
  await showSimpleAlertDialog(
    context: context,
    title: "An error occurred",
    content: exception,
  );
}

Future<T> showLoadingDialog<T>(
    BuildContext context, Future<T> executeWhileLoading) async {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissal by tapping outside
    builder: (BuildContext context) {
      return const Center(
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
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
      action: action,
    ),
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
      return WhatsAppPopupDialog(
        child: AlertDialog(
          backgroundColor: appColors.tertiaryColor,
          title: Text(
            title,
          ),
          content: Text(
            content,
            style: TextStyle(color: appColors.inferiorColor),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: appColors.primaryColor,
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    },
  );
}

Widget createSimpleAlertDialog(
    BuildContext context, String title, String content) {
  return WhatsAppPopupDialog(
    child: AlertDialog(
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
    ),
  );
}

class Test extends StatefulWidget {
  final Widget child;
  const Test({super.key, required this.child});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 50.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic, // Smooth transition curve
      ),
    );

    // Launch animation
    _animationController.forward();
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return widget.child;
      },
    );
  }
}

class InputDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final TextInputType keyboardType;
  final TextEditingController controller;

  const InputDialog({
    super.key,
    required this.title,
    required this.hintText,
    required this.keyboardType,
    required this.controller,
  });

  @override
  State<InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog>
    with TickerProviderStateMixin {
  late AnimationController focusedBorderAnimationController;
  late Animation<double> focusedBorderAnimation;
  late AnimationController unfocusedBorderAnimationController;
  late Animation<double> unfocusedBorderanimation;
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusedBorderAnimationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    focusedBorderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: focusedBorderAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    unfocusedBorderAnimationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    unfocusedBorderanimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: unfocusedBorderAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    Future.delayed(
      Duration(milliseconds: 100),
      unfocusedBorderAnimationController.forward,
    );
    focusNode = FocusNode()
      ..addListener(() {
        if (focusedBorderAnimationController.isCompleted) {
          focusedBorderAnimationController
              .reverse()
              .whenComplete(unfocusedBorderAnimationController.forward);
        } else if (unfocusedBorderAnimationController.isCompleted) {
          unfocusedBorderAnimationController
              .reverse()
              .whenComplete(focusedBorderAnimationController.forward);
        }
      });
  }

  @override
  void dispose() {
    focusedBorderAnimationController.dispose();
    unfocusedBorderAnimationController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final S localizations = S.of(context);

    return WhatsAppPopupDialog(
      child: AlertDialog(
        backgroundColor: appColors.tertiaryColor.withOpacity(0.95),
        title: Text(
          widget.title,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              focusNode: focusNode,
              cursorColor: appColors.primaryColor,
              style: TextStyle(color: appColors.inferiorColor),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(color: appColors.inferiorColor),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
            const SizedBox(height: 5),
            AnimatedBuilder(
              animation: unfocusedBorderanimation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 2),
                  painter: UnderlinePainter(
                      unfocusedBorderanimation, appColors.inferiorColor),
                );
              },
            ),
            AnimatedBuilder(
              animation: focusedBorderAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 2),
                  painter: UnderlinePainter(
                      focusedBorderAnimation, appColors.primaryColor),
                );
              },
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: appColors.secondaryColor,
            ),
            child: Text(
              localizations.cancel,
              style: TextStyle(color: appColors.inferiorColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: appColors.primaryColor,
            ),
            child: Text(localizations.ok),
          ),
        ],
      ),
    );
  }
}

Future<String> showInputDialog({
  required BuildContext context,
  required String title,
  TextInputType keyboardType = TextInputType.text,
  String hintText = "",
}) async {
  final TextEditingController controller = TextEditingController();

  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return InputDialog(
        title: title,
        hintText: hintText,
        keyboardType: keyboardType,
        controller: controller,
      );
    },
  );

  return controller.text.trim();
}

class UnderlinePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  UnderlinePainter(this.animation, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2.0;

    final double currentWidth = animation.value * size.width / 2;

    // Draw the underline starting from the middle of the line
    canvas.drawLine(
      Offset(size.width / 2 - currentWidth, 0),
      Offset(size.width / 2 + currentWidth, 0),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
