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

import 'dart:typed_data';

import 'package:ermis_client/features/authentication/domain/client_status.dart';
import 'package:ermis_client/theme/app_colors.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final Uint8List imageBytes;
  final ClientStatus status;

  const UserAvatar({
    super.key,
    required this.imageBytes,
    required this.status,
  });

  UserAvatar.empty({super.key}) : imageBytes = Uint8List(0), status = ClientStatus.offline;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Stack(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[200],
          backgroundImage: imageBytes.isEmpty ? null : MemoryImage(imageBytes),
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
              color: switch (status) {
                ClientStatus.online => Colors.green,
                ClientStatus.offline => Colors.red,
                ClientStatus.doNotDisturb => Colors.amber,
                ClientStatus.invisible => Colors.blueGrey,
              },
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