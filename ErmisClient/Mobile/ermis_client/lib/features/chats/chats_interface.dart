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

import 'dart:async';

import 'package:ermis_mobile/core/event_bus/app_event_bus.dart';
import 'package:ermis_mobile/core/models/message_events.dart';
import 'package:ermis_mobile/core/networking/user_info_manager.dart';
import 'package:ermis_mobile/core/services/database/database_service.dart';
import 'package:ermis_mobile/core/services/database/extensions/unread_messages_extension.dart';
import 'package:ermis_mobile/core/services/settings_json.dart';
import 'package:ermis_mobile/core/util/dialogs_utils.dart';
import 'package:ermis_mobile/features/chats/first_friend_made_achievement_popup.dart';
import 'package:ermis_mobile/features/chats/widgets/chat_search_field.dart';
import 'package:ermis_mobile/features/chats/widgets/send_chat_request_button.dart';
import 'package:ermis_mobile/mixins/event_bus_subscription_mixin.dart';
import 'package:ermis_mobile/generated/l10n.dart';
import 'package:ermis_mobile/core/widgets/screen_mode_state.dart';
import 'package:ermis_mobile/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../../core/util/transitions_util.dart';
import '../messaging/presentation/messaging_interface.dart';
import '../../core/models/chat_session.dart';
import '../../core/data_sources/api_client.dart';
import '../../core/util/top_app_bar_utils.dart';
import 'widgets/chat_list_view.dart';
import 'search/chat_search.dart';
import 'widgets/chat_popup_menu_button.dart';
import 'widgets/chat_session_tile.dart';
import 'widgets/selection_app_bar.dart';

class Chats extends StatefulWidget {
  const Chats({super.key});

  @override
  State<Chats> createState() => _ChatsState();

  int getTotalUnreadMessagesCount() {
    Iterable<int> iter =
        _ChatsState.unreadMessageCounts.values.whereType<int>();

    int totalCount = iter.fold(0, (previous, current) => previous + current);
    return totalCount;
  }
}

class _ChatsState extends ScreenModeState<Chats> with EventBusSubscriptionMixin {
  List<ChatSession>? _conversations;
  Set<ChatSession> selectedConversations = {}; // Set instead of list to prevent duplicates

  /// Maps each chat session's ID to its corresponding [List] of unread messages
  static final Map<int /* chat session id */, int /* unread messages count */ >
      unreadMessageCounts = {};

  final TextEditingController _searchController = TextEditingController();
  late FocusNode _focusNode;

  /// A periodic stream that triggers a rebuild every five seconds.
  /// This ensures the chat sessions ListView displays the latest message sent.
  /// Without this stream, the UI would not update. Fairly lazy, but it works,
  /// with minimal performance overhead as well. For now, it will suffice.
  ///
  /// The stream is set as a broadcast stream to allow multiple listeners.
  /// Even though it's only referenced once in the code, using the refresh indicator
  /// to refresh the chat session will trigger the stream again. If you wish to see
  /// this for yourself, try the code without the broadcast stream.
  final Stream<int> _stream = Stream.periodic(const Duration(seconds: 5), (x) => x).asBroadcastStream();

  _ChatsState() : super(ScreenMode.normal);

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static const _search = ChatSearch();

  @override
  void initState() {
    super.initState();

    _conversations = UserInfoManager.chatSessions;
    // If conversations is null, set task to loading
    if (_conversations == null) {
      task = ScreenMode.loading;
    }

    _stream.listen((x) {
      retrieveUnreadMessages();
    });

    for (final ChatSession session in _conversations ?? const []) {
      Client.instance().commands?.fetchWrittenText(session.chatSessionIndex);
      Client.instance()
          .commands
          ?.fetchVoiceCallHistory(session.chatSessionIndex);
    }

    subscribe(AppEventBus.instance.on<ChatSessionsEvent>(), (event) {
      void notifyUserOfNewPotentialChat() {
        if (_conversations == null) return;

        if (_conversations!.length < event.sessions.length) {
          if (SettingsJson().hasUserMadeFirstFriend) {
            showToastDialog(S().newChat);
            return;
          }

          SettingsJson().setHasUserMadeFirstFriend(true);
          SettingsJson().saveSettingsJson();

          FirstFriendMadeAchievementPopup.show(context);
        }
      }

      notifyUserOfNewPotentialChat();

      _conversations = [...event.sessions];
      task = ScreenMode.normal;
      setState(() {});
    });

    subscribe(AppEventBus.instance.on<ChatSessionsStatusesEvent>(), (event) {
      setState(() {}); // Since chat sessions were updated simply setState
    });

    _focusNode = FocusNode();
  }

  void retrieveUnreadMessages() async {
    for (final ChatSession session in _conversations ?? const []) {
      int messages = await ErmisDB.getConnection().retrieveUnreadMessagesCount(
        UserInfoManager.serverInfo,
        session.chatSessionID,
      );
      unreadMessageCounts[session.chatSessionID] = messages;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget normalBuild(BuildContext context) => _buildScaffold(
        appBar: ErmisAppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Initiate search
                setState(() => task = ScreenMode.searching);

                // Skip the first focus notification, which comes from the text field itself.
                var hasSkippedInitialFocus = false;
                void onFocusChange() {
                  if (!hasSkippedInitialFocus) {
                    hasSkippedInitialFocus = true;
                    return;
                  }
                  _focusNode.removeListener(onFocusChange);
                  if (mounted) setState(() => task = ScreenMode.normal);
                }

                _focusNode.addListener(onFocusChange);
              },
            ),
            const ChatPopupMenuButton(),
            const SizedBox(width: 15),
          ],
        ),
        conversations: _conversations ?? [],
        floatingActionButton: const SendChatRequestButton(),
      );

  @override
  Widget searchingBuild(BuildContext context) => _buildScaffold(
        appBar: ErmisAppBar(
          title: ChatSearchField(
            searchConsumer: (_) => setState(() {}),
            searchController: _searchController,
            focusNode: _focusNode,
          ),
        ),
        conversations: _search.rank(_conversations ?? [], _searchController.text),
        query: _searchController.text,
      );

  @override
  Widget editingBuild(BuildContext context) => _buildScaffold(
        appBar: SelectionAppBar(
          count: selectedConversations.length,
          onCancel: () {
            // Clear selection
            setState(() {
              task = ScreenMode.normal;
              selectedConversations.clear();
            });
          },
          onDelete: () async {
            // Confirm and delete selected convos
            final confirmed = await showDeleteChatsDialog(context);
            if (!confirmed || !mounted) return;

            final commands = Client.instance().commands;
            for (final session in selectedConversations.toList()) {
              commands?.deleteChatSession(session.chatSessionIndex);
            }
          },
        ),
        conversations: _conversations ?? [],
        floatingActionButton: const SendChatRequestButton(),
      );

  @override
  Widget loadingBuild(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: ErmisAppBar(),
      backgroundColor: appColors.secondaryColor,
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildScaffold({
    required PreferredSizeWidget appBar,
    required List<ChatSession> conversations,
    String query = '',
    Widget? floatingActionButton,
  }) {
    return StreamBuilder<Object>(
      stream: _stream,
      builder: (context, _) {
        final appColors = Theme.of(context).extension<AppColors>()!;
        return Scaffold(
          appBar: appBar,
          backgroundColor: appColors.secondaryColor,
          floatingActionButton: floatingActionButton,
          body: ChatListView(
            conversations: conversations,
            onRefresh: () {
              // Refresh content
              Client.instance().commands?.fetchChatSessions();
              setState(() => task = ScreenMode.loading);
            },
            itemBuilder: (context, session) => ChatSessionTile(
              session: session,
              query: query,
              unreadCount: unreadMessageCounts[session.chatSessionID] ?? 0,
              isSelected: selectedConversations.contains(session),
              onOpen: (BuildContext context, ChatSession session) {
                pushSlideTransition(
                  context,
                  MessagingInterface(chatSession: session),
                );
              },
              onLongPress: () {
                // Toggle search
                setState(() {
                  if (task == ScreenMode.normal) task = ScreenMode.editing;
                  if (!selectedConversations.remove(session)) {
                    selectedConversations.add(session);
                  }
                  if (selectedConversations.isEmpty) task = ScreenMode.normal;
                });
              },
            ),
          ),
        );
      },
    );
  }

}
