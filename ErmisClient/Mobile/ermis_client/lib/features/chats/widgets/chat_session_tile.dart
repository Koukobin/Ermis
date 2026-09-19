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

import 'package:ermis_mobile/features/chats/widgets/chat_user_avatar.dart';
import 'package:ermis_mobile/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../core/util/basic_markdown_parser.dart';
import '../../../core/models/chat_session.dart';

typedef OpenChatCallback = void Function(BuildContext context, ChatSession session);

class ChatSessionTile extends StatelessWidget {
  final ChatSession session;
  final OpenChatCallback onOpen;
  final VoidCallback onLongPress;
  final String query;
  final int unreadCount;
  final bool isSelected;

  const ChatSessionTile({
    required this.session,
    required this.onOpen,
    required this.onLongPress,
    this.query = '',
    this.unreadCount = 0,
    this.isSelected = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return ListTile(
      onTap: () => onOpen(context, session),
      onLongPress: onLongPress,
      horizontalTitleGap: session.members.length * 3,
      tileColor: isSelected
          ? appColors.primaryColor.withAlpha(102)
          : appColors.secondaryColor,
      leading: _MemberAvatarStack(session: session, onOpenChat: onOpen),
      title: _HighlightedText(
        text: session.toString(),
        query: query,
        style: TextStyle(fontSize: 16, color: appColors.primaryColor),
        highlightStyle: TextStyle(
          color: appColors.inferiorColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: _LastMessagePreview(session.lastMessageContent),
      trailing: _TileTrailing(
        unreadCount: unreadCount,
        sessionIndex: session.chatSessionIndex,
        isSelected: isSelected,
        time: session.lastMessageSentTime,
      ),
    );
  }
}

class _LastMessagePreview extends StatelessWidget {
  const _LastMessagePreview(this.content);

  final String content;

  @override
  Widget build(BuildContext context) {
    return parseMessage(
      content,
      plainBuilder: (text) =>
          Text(text, maxLines: 3, overflow: TextOverflow.ellipsis),
      formattedBuilder: (spans) =>
          RichText(text: spans, maxLines: 3, overflow: TextOverflow.ellipsis),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;
  final TextStyle highlightStyle;

  const _HighlightedText({
    required this.text,
    required this.query,
    required this.style,
    required this.highlightStyle,
  });

  @override
  Widget build(BuildContext context) {
    final start = query.isEmpty ? -1 : text.indexOf(query);
    if (start == -1) return Text(text, style: style);

    final end = start + query.length;
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, start)),
          TextSpan(text: text.substring(start, end), style: highlightStyle),
          TextSpan(text: text.substring(end)),
        ],
      ),
    );
  }
}

class _MemberAvatarStack extends StatelessWidget {
  final ChatSession session;
  final OpenChatCallback onOpenChat;

  const _MemberAvatarStack({
    required this.session,
    required this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final members = session.members;

    // Only render a few avatars due to space constraints
    const maxAvatars = 4;
    const avatarSpacing = 25.0;

    return SizedBox(
      width: members.length * 10 + 65,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final (index, member) in members.take(maxAvatars).indexed)
            Positioned(
              left: index * avatarSpacing,
              top: switch (index % 2) {
                0 => -5,
                1 => 10,
                _ => 0,
              },
              child: ChatUserAvatar(
                member: member,
                chatSession: session,
                pushMessageInterface: onOpenChat,
              ),
            ),
          if (members.length > maxAvatars)
            Positioned(
              left: maxAvatars * avatarSpacing + 12.5,
              top: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: appColors.tertiaryColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: appColors.secondaryColor, width: 2.5),
                ),
                child: Text(
                  '+${members.length - maxAvatars}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TileTrailing extends StatelessWidget {
  final int unreadCount;
  final int sessionIndex;
  final bool isSelected;
  final String time;

  const _TileTrailing({
    required this.unreadCount,
    required this.sessionIndex,
    required this.isSelected,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (unreadCount > 0)
          CircleAvatar(
            backgroundColor: Colors.red,
            radius: 16,
            child: Text(
              '$unreadCount',
              style: TextStyle(
                color: appColors.inferiorColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          },
          child: isSelected
              ? Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  key: ValueKey('selected_$sessionIndex'),
                )
              : Text(time, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}
