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

import 'package:ermis_mobile/constants/app_constants.dart';
import 'package:ermis_mobile/generated/l10n.dart';
import 'package:ermis_mobile/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/scroll/custom_scroll_view.dart';
import '../../../core/models/chat_session.dart';

class ChatListView extends StatelessWidget {
  final List<ChatSession> conversations;
  final Widget Function(BuildContext context, ChatSession session) itemBuilder;
  final VoidCallback onRefresh;

  const ChatListView({
    required this.conversations,
    required this.itemBuilder,
    required this.onRefresh,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return ScrollViewFixer.createScrollViewWithAppBarSafety(
      scrollView: RefreshIndicator(
        // if user scrolls downwards refresh chat requests
        onRefresh: () async => onRefresh(),
        color: appColors.primaryColor,
        child: conversations.isEmpty
            // Wrap in list view to ensure it is scrollable for refresh indicator
            ? ListView(children: const [_EmptyConversations()])
            : ListView.separated(
                itemCount: conversations.length,
                itemBuilder: (context, index) =>
                    itemBuilder(context, conversations[index]),
                separatorBuilder: (_, __) => const Divider(
                  color: Colors.transparent,
                  height: 10,
                ),
              ),
      ),
    );
  }
}

class _EmptyConversations extends StatelessWidget {
  const _EmptyConversations();

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return SizedBox(
      height: MediaQuery.of(context).size.height - 150,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 96),
              child: Image.asset(AppConstants.ermisCryingPath),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: appColors.primaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              border: Border.all(color: appColors.secondaryColor),
            ),
            child: Text(
              S.current.noConversationsAvailable,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appColors.secondaryColor,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}