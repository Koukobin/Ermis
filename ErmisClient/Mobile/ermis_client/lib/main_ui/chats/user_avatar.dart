import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class UserAvatar extends StatelessWidget {
  final Uint8List imageBytes;
  final bool isOnline;

  const UserAvatar({
    super.key,
    required this.imageBytes,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Stack(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: imageBytes.isEmpty ? null : MemoryImage(imageBytes),
          backgroundColor: Colors.grey[200],
          child: imageBytes.isEmpty
              ? Icon(
                  Icons.person,
                  color: Colors.grey,
                )
              : null,
        ),
        // Online/Offline Indicator
        Positioned(
          bottom: 0,
          left: 30,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isOnline
                  ? Colors.green
                  : Colors.red, // Online or offline color
              shape: BoxShape.circle,
              border: Border.all(
                color: appColors
                    .secondaryColor, // Border to separate the indicator from the avatar
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}