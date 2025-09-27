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

import 'package:ermis_mobile/constants/app_constants.dart';
import 'package:ermis_mobile/core/event_bus/app_event_bus.dart';
import 'package:ermis_mobile/core/models/message_events.dart';
import 'package:ermis_mobile/core/networking/user_info_manager.dart';
import 'package:ermis_mobile/core/services/database/database_service.dart';
import 'package:ermis_mobile/core/services/database/extensions/unread_messages_extension.dart';
import 'package:ermis_mobile/core/services/settings_json.dart';
import 'package:ermis_mobile/core/util/dialogs_utils.dart';
import 'package:ermis_mobile/features/chats/chat_popup_menu_button.dart';
import 'package:ermis_mobile/features/chats/chat_user_avatar.dart';
import 'package:ermis_mobile/features/chats/first_friend_made_achievement_popup.dart';
import 'package:ermis_mobile/features/chats/chat_search_field.dart';
import 'package:ermis_mobile/features/chats/send_chat_request_button.dart';
import 'package:ermis_mobile/mixins/event_bus_subscription_mixin.dart';
import 'package:ermis_mobile/generated/l10n.dart';
import 'package:ermis_mobile/core/widgets/convulted_state.dart';
import 'package:ermis_mobile/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../../core/models/message.dart';
import '../../core/networking/common/message_types/content_type.dart';
import '../../core/util/transitions_util.dart';
import '../../core/widgets/scroll/custom_scroll_view.dart';
import '../messaging/presentation/messaging_interface.dart';
import '../../core/models/chat_session.dart';
import '../../core/data_sources/api_client.dart';
import '../../core/util/top_app_bar_utils.dart';

class Chats extends StatefulWidget {
  const Chats({super.key});

  @override
  State<Chats> createState() => _ChatsState();

  int getTotalUnreadMessagesCount() {
    Iterable<List<int>> iter =
        _ChatsState.unreadMessageCounts.values.whereType<List<int>>();

    int totalCount = 0;
    for (final unreadMessages in iter) {
      totalCount += unreadMessages.length;
    }

    return totalCount;
  }
}

class _ChatsState extends ConvultedState<Chats> with EventBusSubscriptionMixin {
  List<ChatSession>? _conversations;
  Set<ChatSession> selectedConversations = {}; // Set instead of list to prevent duplicates

  /// Maps each chat session's ID to its corresponding [List] of unread messages
  static final Map<int /* chat session id */,
          List<int /* message id */ >? /* unread messages count */ >
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

  _ChatsState() : super(ConvultedTask.normal);

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    _conversations = UserInfoManager.chatSessions;
    // If conversations is null, set task to loading
    if (_conversations == null) {
      task = ConvultedTask.loading;
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

        if (_conversations!.length > event.sessions.length) {
          if (SettingsJson().hasUserMadeFirstFriend) {
            showToastDialog(S().new_chat);
            return;
          }

          SettingsJson().setHasUserMadeFirstFriend(true);
          SettingsJson().saveSettingsJson();

          FirstFriendMadeAchievementPopup.show(context);
        }
      }

      notifyUserOfNewPotentialChat();

      _conversations = [...event.sessions];
      task = ConvultedTask.normal;
      setState(() {});
    });

    subscribe(AppEventBus.instance.on<ChatSessionsStatusesEvent>(), (event) {
      setState(() {}); // Since chat sessions were updated simply setState
    });

    // Whenever text changes performs search
    _searchController.addListener(() {
      if (!mounted) {
        return;
      }
      performSearch();
    });

    _focusNode = FocusNode();
  }

  void retrieveUnreadMessages() async {
    for (final ChatSession session in _conversations ?? const []) {
      List<int>? messages = await ErmisDB.getConnection().retrieveUnreadMessages(
        UserInfoManager.serverInfo,
        session.chatSessionID,
      );
      unreadMessageCounts[session.chatSessionID] = messages;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget normalBuild(BuildContext context) {
    return _buildMainScaffold(
        context,
        ErmisAppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  task = ConvultedTask.searching;
                });
                // Variable to skip first call of focusNode which will be by textfield
                bool hasSkippedInitialFocus = false;
                void listener() {
                  if (!hasSkippedInitialFocus) {
                    hasSkippedInitialFocus = true;
                    return;
                  }
                  setState(() {
                    task = ConvultedTask.normal;
                  });
                  _focusNode.removeListener(listener);
                }

                _focusNode.addListener(listener);
              },
            ),
            const ChatPopupMenuButton(),
            const SizedBox(width: 15),
          ],
        ));
  }

  @override
  Widget searchingBuild(BuildContext context) {
    return _buildMainScaffold(
        context,
        ErmisAppBar(
          title: ChatSearchField(
            searchController: _searchController,
            focusNode: _focusNode,
          ),
        ));
  }

  @override
  Widget editingBuild(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return _buildMainScaffold(
        context,
        AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: appColors.inferiorColor),
            onPressed: () {
              setState(() {
                task = ConvultedTask.normal;
                selectedConversations.clear();
              });
            },
          ),
          title: Text(selectedConversations.length.toString()),
          actions: [
            IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(S.current.delete_this_chat_question),
                        content: Text(S.current
                            .deleting_this_chat_will_permanently_delete_all_prior_messages),
                        actions: [
                          TextButton(
                            onPressed: Navigator.of(context).pop, // Cancel
                            child: Text(S.current.cancel),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              for (ChatSession cs in selectedConversations) {
                                Client.instance()
                                    .commands
                                    ?.deleteChatSession(cs.chatSessionIndex);
                              }
                            }, // Confirm
                            child: Text(S.current.delete_chat),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.delete_outline)),
          ],
        ));
  }

  @override
  Widget loadingBuild(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: ErmisAppBar(),
      backgroundColor: appColors.secondaryColor,
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildMainScaffold(BuildContext context, PreferredSizeWidget appBar) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return StreamBuilder<Object>(
        stream: _stream,
        builder: (context, snapshot) {
          return Scaffold(
            appBar: appBar,
            backgroundColor: appColors.secondaryColor,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.endFloat, // Position bottom right
            floatingActionButton: const SendChatRequestButton(),
            body: ScrollViewFixer.createScrollViewWithAppBarSafety(
              scrollView: RefreshIndicator(
                // if user scrolls downwards refresh chat requests
                onRefresh: () async => _refreshContent(),
                color: appColors.primaryColor,
                child: _conversations!.isNotEmpty
                    ? ListView.separated(
                        itemCount: _conversations!.length,
                        itemBuilder: (context, index) => buildChatButton(index),
                        separatorBuilder: (context, index) => const Divider(
                          color: Colors.transparent,
                          height: 10,
                        ),
                      )
                    :
                    // Wrap in a list view to ensure it is scrollable for refresh indicator
                    ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height - 150,
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 96.0),
                                    child: Image.asset(
                                      AppConstants.ermisCryingPath,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: appColors.primaryColor,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(24)),
                                    border: Border.all(
                                      color: appColors.secondaryColor,
                                    ),
                                  ),
                                  child: Text(
                                    S.current.no_conversations_available,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: appColors.secondaryColor,
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
              ),
            ),
          );
        });
  }

  Widget buildChatButton(int sessionIndex) {
    ChatSession chatSession = _conversations![sessionIndex];
    int startingIndex = chatSession.toString().indexOf(_searchController.text);
    int endIndex;

    if (startingIndex == -1) {
      startingIndex = 0;
      endIndex = 0;
    } else {
      endIndex = startingIndex + _searchController.text.length;
    }

    void pushMessageInterface(BuildContext context, ChatSession chatSession) {
      pushSlideTransition(
          context,
          MessagingInterface(
            chatSessionIndex: chatSession.chatSessionIndex,
            chatSession: chatSession,
          ));

      final List<int>? unreadMessages =
          unreadMessageCounts[chatSession.chatSessionID];

      if (unreadMessages == null) return;

      ErmisDB.getConnection().deleteUnreadMessages(
        UserInfoManager.serverInfo,
        chatSession.chatSessionID,
        unreadMessages,
      );

      unreadMessageCounts.remove(chatSession.chatSessionID);
    }

    final int? unreadMessages =
        unreadMessageCounts[chatSession.chatSessionID]?.length;

    final appColors = Theme.of(context).extension<AppColors>()!;
    return ListTile(
      onLongPress: () {
        if (task == ConvultedTask.normal) {
          setState(() {
            task = ConvultedTask.editing;
          });
        }

        setState(() {
          // If the value was already in the set, remove it
          if (!selectedConversations.add(chatSession)) {
            selectedConversations.remove(chatSession);
          }
        });

        if (selectedConversations.isEmpty) {
          setState(() {
            task = ConvultedTask.normal;
          });
        }
      },
      onTap: () => pushMessageInterface(context, chatSession),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (unreadMessages != null)
            CircleAvatar(
              backgroundColor: Colors.red,
              radius: 16.0,
              child: Text(
                "$unreadMessages",
                style: TextStyle(
                  color: appColors.inferiorColor,
                  fontSize: 12.0,
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
            child: selectedConversations.contains(chatSession)
                ? Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    key: ValueKey(
                        'selected_$sessionIndex'), // Unique key for the selected state
                  )
                : Text(
                    chatSession.lastMessageSentTime,
                    style: const TextStyle(fontSize: 14),
                  ),
          ),
        ],
      ),
      horizontalTitleGap: chatSession.members.length * 3,
      leading: SizedBox(
        width: chatSession.members.length * 10 + 65,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Only render up to 4 avatars due to space constraints
            for (final (index, member) in chatSession.members.take(4).indexed)
              Positioned(
                left: index * 25,
                top: switch (index % 2) {
                  0 => -5,
                  1 => 10,
                  _ => 0,
                },
                child: ChatUserAvatar(
                  member: member,
                  chatSession: chatSession,
                  pushMessageInterface: pushMessageInterface,
                ),
              ),
            // If members > 4: display remaining members badge
            if (chatSession.members.length > 4)
              Positioned(
                left: 4 * 25 + 12.5,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: appColors.tertiaryColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: appColors.secondaryColor, width: 2.5),
                  ),
                  child: Text(
                    '+${chatSession.members.length - 4}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      subtitle: Text(
        chatSession.lastMessageContent,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      tileColor: selectedConversations.contains(chatSession)
          ? appColors.primaryColor.withAlpha(102)
          : appColors.secondaryColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: Text.rich(
              TextSpan(
                text: chatSession.toString().substring(0, startingIndex),
                style: TextStyle(
                  fontSize: 16,
                  color: appColors.primaryColor,
                ),
                children: [
                  TextSpan(
                    text: chatSession
                        .toString()
                        .substring(startingIndex, endIndex),
                    style: TextStyle(
                        color: appColors.inferiorColor,
                        fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: chatSession.toString().substring(endIndex),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _refreshContent() {
    Client.instance().commands?.fetchChatSessions();
    setState(() {
      task = ConvultedTask.loading;
    });
  }

  void performSearch() {
    for (int i = 0; i < _conversations!.length; i++) {
      for (int j = 0; j < _conversations!.length; j++) {
        bool conversationMessagesContainsText() {
          // Duplicate to prevent any sort of data manipulation
          List<Message> messages = [..._conversations![j].messages];
          messages.sort((a, b) => b.epochSecond.compareTo(a.epochSecond));
          messages =
              messages.getRange(0, 50.clamp(0, messages.length)).toList();

          for (final message in messages) {
            bool contains = message.contentType == MessageContentType.text
                ? message.text.contains(_searchController.text)
                : message.fileName.contains(_searchController.text);
            if (contains) return true;
          }

          return false;
        }

        if (_conversations![j].toString().contains(_searchController.text) ||
            conversationMessagesContainsText()) {
          setState(() {
            ChatSession temp = _conversations![j];
            if (j > 0) {
              _conversations![j] = _conversations![j - 1];
              _conversations![j - 1] = temp;
            }
          });
        }
      }
    }
  }
}
