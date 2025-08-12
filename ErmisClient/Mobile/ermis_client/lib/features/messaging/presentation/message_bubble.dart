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

import 'package:ermis_mobile/core/models/chat_session.dart';
import 'package:flutter/material.dart';

import '../../../core/util/custom_date_formatter.dart';
import '../../../core/widgets/profile_photos/user_profile_photo.dart';
import '../../../generated/l10n.dart';

abstract class MessageBubble extends StatelessWidget {
  final ChatSession chatSession;

  const MessageBubble({super.key, required this.chatSession});

  Widget buildNewDayLabel({
    required DateTime previousMessageDate,
    required DateTime currentMessageDate,
  }) {
    final bool isNewDay =
        previousMessageDate.difference(currentMessageDate).inDays != 0;

    if (!isNewDay) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: !isNewDay
            ? Text(S.current.today)
            : Text(CustomDateFormatter.formatDate(
                currentMessageDate, "yyyy-MM-dd")),
      ),
    );
  }

  Widget buildUserProfile({
    required int currentMessageClientID,
    required int? previousMessageClientID,
    required bool isMessageOwner,
  }) {
    if (isMessageOwner) return const SizedBox.shrink();

    if (previousMessageClientID == currentMessageClientID) {
      return const SizedBox.shrink();
    }

    // Return user profile only in group chats; in 1:1 convos it is redundant.
    if (chatSession.members.length == 1) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: UserProfilePhoto(
        radius: 15,
        removeBorder: false,
        profileBytes: chatSession.members
            .where((m) => m.clientID == currentMessageClientID)
            .firstOrNull
            ?.icon
            .profilePhoto,
      ),
    );
  }
}
