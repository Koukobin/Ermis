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

import 'package:ermis_mobile/core/models/member.dart';
import 'package:ermis_mobile/core/models/message_events.dart';
import 'package:ermis_mobile/core/models/voice_call_history.dart';
import 'package:ermis_mobile/core/services/database/extensions/chat_messages_extension.dart';
import 'package:ermis_mobile/core/services/database/extensions/unread_messages_extension.dart';
import 'package:ermis_mobile/enums/chat_back_drop_enum.dart';
import 'package:ermis_mobile/features/messaging/widgets/bubbles/voice_call_bubble.dart';
import 'package:ermis_mobile/features/voice_call/web_rtc/voice_call_webrtc.dart';
import 'package:ermis_mobile/mixins/event_bus_subscription_mixin.dart';
import 'package:ermis_mobile/features/messaging/presentation/input_field.dart';
import 'package:ermis_mobile/features/messaging/widgets/bubbles/message_bubbles/message_bubble.dart';
import 'package:ermis_mobile/features/messaging/presentation/choose_friends_screen.dart';
import 'package:ermis_mobile/generated/l10n.dart';
import 'package:ermis_mobile/theme/app_colors.dart';
import 'package:ermis_mobile/core/widgets/scroll/custom_scroll_view.dart';
import 'package:ermis_mobile/core/services/database/database_service.dart';
import 'package:ermis_mobile/core/services/settings_json.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/event_bus/app_event_bus.dart';
import '../../../constants/app_constants.dart';
import '../../../core/networking/user_info_manager.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/data_sources/api_client.dart';
import '../../../core/models/chat_session.dart';
import '../../../core/models/message.dart';
import '../../../core/networking/common/message_types/content_type.dart';
import '../../../core/util/dialogs_utils.dart';
import '../../../core/util/top_app_bar_utils.dart';
import '../../../core/widgets/scroll/infinite_scroll_list.dart';
import '../../../core/widgets/profile_photos/user_avatar.dart';
import '../../../theme/doodle_painter.dart';
import '../../voice_call/web_rtc/call_info.dart';
import '../widgets/scroll_to_latest_message_button.dart';

class MessagingInterface extends StatefulWidget {
  final ChatSession chatSession;

  const MessagingInterface({
    super.key,
    required this.chatSession,
  });

  @override
  State<MessagingInterface> createState() => _MessagingInterfaceState();
}

/// This class tracks whether or not a [MessagingInterface] instance is currently active or not
class MessageInterfaceTracker {
  static bool _isScreenInstanceActive = false;
  static bool get isScreenInstanceActive => _isScreenInstanceActive;
}

class _MessagingInterfaceState extends LoadingState<MessagingInterface> with EventBusSubscriptionMixin {

  int get _chatSessionID => _chatSession.chatSessionID;
  int get _chatSessionIndex => _chatSession.chatSessionIndex;
  late ChatSession _chatSession; // Not final because can be updated by server

  List<Message> _messages = []; // Not final because can be updated by server
  List<VoiceCallHistory>? _voiceCallsHistory = []; // Not final because can be updated by server

  bool _isEditingMessage = false;
  final Set<Message> _messagesBeingEdited = {};

  final ScrollController _scrollController = ScrollController();

  final List<int> unreadMessages = [];

  @override
  void initState() {
    super.initState();

    MessageInterfaceTracker._isScreenInstanceActive = true;

    _chatSession = widget.chatSession;

    Future(() async {
      // Fetch cached messages or load from the server
      if (!_chatSession.hasLatestMessages) {
        List<Message> messages = await _retrieveFurtherLocalMessages();
        _chatSession.setMessages(messages);

        if (messages.isNotEmpty) {
          setState(() {
            _messages = messages;
            isLoading = false;
          });
        }

        // Ensure messages are up to date
        Client.instance().commands?.refetchWrittenText(_chatSessionIndex); // BOTH ARE IMPORTANT
        Client.instance().commands?.refetchWrittenText(_chatSessionIndex); // BOTH ARE IMPORTANT
      } else {
        setState(() {
          _messages = _chatSession.messages;
          isLoading = false;
        });
      }

      _setupListeners(); // Register message listeners

      void retrieveUnreadMessages() async {
        List<int>? messages =
            await ErmisDB.getConnection().retrieveUnreadMessages(
          UserInfoManager.serverInfo,
          _chatSessionID,
        );

        if (messages == null) return;
        unreadMessages.addAll(messages);
        unreadMessages.sort((a, b) => a.compareTo(b));

        ErmisDB.getConnection().deleteUnreadMessages(
          UserInfoManager.serverInfo,
          _chatSessionID,
          unreadMessages,
        );
      }

      retrieveUnreadMessages();
    });

    _voiceCallsHistory = UserInfoManager.chatSessionIDSToVoiceCallHistory[_chatSession.chatSessionID];
  }

  Future<List<Message>> _retrieveFurtherLocalMessages() async {
    List<Message> messages = await ErmisDB.getConnection().retrieveChatMessages(
      chatSessionID: _chatSessionID,
      serverInfo: UserInfoManager.serverInfo,
      offset: _messages.length,
    );

    for (final m in messages) {
      m.setChatSessionIndex(_chatSessionIndex);
    }

    return messages;
  }

  void _setupListeners() {
    subscribe(AppEventBus.instance.on<ChatSessionsStatusesEvent>(), (event) {
      setState(() {}); // Since chat sessions were updated simply setState
    });

    subscribe(AppEventBus.instance.on<WrittenTextEvent>(), (event) {
      List<Message> messages = event.chatSession.messages;

      setState(() {
        _messages = messages;
        isLoading = false;
      });
    });

    subscribe(AppEventBus.instance.on<MessageReceivedEvent>(), (event) {
      // Since messages was updated by the message handler simply setState
      setState(() {});
    });

    subscribe(AppEventBus.instance.on<MessageDeletedEvent>(), (event) {
      ChatSession session = event.chatSession;
      int messageID = event.messageId;

      if (session.chatSessionID != _chatSessionID) {
        return;
      }

      _messagesBeingEdited.removeWhere((Message message) => message.messageID == messageID);

      if (mounted) setState(() {});
    });

    subscribe(AppEventBus.instance.on<MessageDeliveryStatusEvent>(), (event) {
      Message message = event.message;

      if (message.chatSessionID == _chatSessionID) {
        setState(() {});
      }
    });

    subscribe(AppEventBus.instance.on<ChatSessionsEvent>(), (event) {
      setState(() {
        // After a comprehensive review of the code, this line is
        // probably unnecessary/redundant; keeping it for now because
        // I don't want to break any functionality
        _chatSession = event.sessions.firstWhere((ChatSession session) =>
            session.chatSessionID == _chatSessionID);
      });
    });

    subscribe(AppEventBus.instance.on<VoiceCallHistoryReceivedEvent>(), (event) {
      if (event.chatSessionID != _chatSessionID) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    MessageInterfaceTracker._isScreenInstanceActive = false;
     _scrollController.dispose();
    super.dispose();
  }

  void pushVoiceCall() {
    // VoiceCallThing.initiateVoiceCall(
    //   context,
    //   chatSessionIndex: _chatSessionIndex,
    //   chatSessionID: _chatSession.chatSessionID,
    // );
    pushVoiceCallWebRTC(
      context,
      CallInfo(
        chatSessionID: _chatSessionID,
        chatSessionIndex: _chatSessionIndex,
        member: _chatSession.members[0],
        isInitiator: true,
      ),
    );
  }

  @override
  Widget build0(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: _isEditingMessage
          ? _buildEditMessageAppBar(appColors)
          : _buildMainAppBar(appColors),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: ScrollToLatestMessageButton(scrollController: _scrollController),
      body: Container(
        decoration: _getDecoration(SettingsJson().chatsBackDrop),
        child: Stack(
          children: [
            if (SettingsJson().ermisDoodlesEnabled)
              // Wrap LayoutBuilder in RepaintBoundary to ensure
              // the former is cached and ultimately reduce
              // performance overhead.
              RepaintBoundary(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Because it is certain that the doodles will
                    // not have been loaded on the first execution
                    // of the doodle painter, configure doodler to
                    // repaint after a certain time interval.
                    if (!ErmisDoodlePainter.areDoodlesLoaded()) {
                      Future.delayed(
                        const Duration(milliseconds: 300),
                        () => setState(() {}),
                      );
                    }

                    return CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: ErmisDoodlePainter(),
                    );
                  },
                ),
              ),
            Column(
              children: [
                _buildMessageList(appColors),
                InputField(chatSessionIndex: _chatSessionIndex, messages: _messages),
              ],
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildMainAppBar(AppColors appColors) {
    return AppBar(
      backgroundColor: appColors.tertiaryColor,
      leading: BackButton(
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: -5, // Decrease space between leading and title
      title: LayoutBuilder(builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                for (final member in _chatSession.members)
                  UserAvatar(
                    imageBytes: member.icon.profilePhoto,
                    status: member.status,
                  ),
                const SizedBox(width: 10),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * 0.45, // Number chosen arbitrarily
                  ),
                  child: Text(
                    S.current.chat_with(widget.chatSession.members
                        .map((m) => m.username)
                        .join(', ')),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  // Disable group chat voice/video calls - for now.
                  onPressed: _chatSession.members.length == 1 ? pushVoiceCall : null,
                  icon: const Icon(Icons.phone_outlined),
                ),
                PopupMenuButton<VoidCallback>(
                  position: PopupMenuPosition.under,
                  menuPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  onSelected: (VoidCallback callback) {
                    callback();
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: () {
                        // FUCK
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Text(S.current.chat_theme),
                    ),
                    PopupMenuItem(
                      value: () async {
                        List<Member> members = await showChooseFriendsScreen(
                          context,
                          membersToExclude: _chatSession.members,
                        );

                        if (members.isEmpty) return;
                        List<int> memberIds = members.map((member) => member.clientID).toList();
                        Client.instance().commands?.addUsersInChatSession(_chatSession.chatSessionIndex, memberIds);
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Text(S.current.add_user),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      }),
      bottom: DividerBottom(dividerColor: appColors.inferiorColor),
    );
  }

  Widget _buildMessageList(AppColors appColors) {
    List<Object> combined = [
      ..._messages,
      ..._voiceCallsHistory ?? [],
    ];
    combined.sort((a, b) {
      int getTimestamp(Object item) {
        if (item is Message) {
          return item.epochSecond;
        }

        if (item is VoiceCallHistory) {
          return item.tsDebuted;
        }

        throw Exception("What the fuck is going on");
      }

      return getTimestamp(a).compareTo(getTimestamp(b));
    });

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ScrollViewFixer.createScrollViewWithAppBarSafety(
            scrollView: InfiniteScrollList(
          reverse: true,
          itemCount: combined.length,
          isLoaded: true,
          controller: _scrollController,
          itemBuilder: (context, index) {
            final Object message = combined[combined.length - index - 1];

            int? previousMessageEpochSecond;
            int? previousMessageClientID;

            // Search for previous message bubble
            if (index != combined.length - 1) {
              Object? previousMessage;

              int num = 2;
              while (previousMessage == null) {
                int previousMessageIndex = combined.length - index - num;
                if (previousMessageIndex < 0 ||
                    previousMessageIndex > combined.length) {
                  break;
                }

                final obj = combined[previousMessageIndex];
                previousMessage = obj;

                if (obj is Message) {
                  previousMessageEpochSecond = obj.epochSecond;
                  previousMessageClientID = obj.clientID;
                }

                if (obj is VoiceCallHistory) {
                  previousMessageEpochSecond = obj.tsDebuted;
                  previousMessageClientID = obj.initiatorClientID;
                }

                num++;
              }
            }

            if (message is VoiceCallHistory) {
              return VoiceCallBubble(
                entry: message,
                pushVoiceCall: pushVoiceCall,
                chatSession: _chatSession,
                previousMessageClientID: previousMessageClientID,
                previousMessageEpochSecond: previousMessageEpochSecond,
              );
            }

            if (message is! Message) {
              return Text("Unrecognized message: $message");
            }

            return GestureDetector(
                onLongPress: () {
                  setState(() {
                    _isEditingMessage = true;
                    if (!_messagesBeingEdited.add(message)) {
                      _messagesBeingEdited.remove(message);
                    }
                  });
                },
                child: Container(
                    decoration: _isEditingMessage &&
                            _messagesBeingEdited.contains(message)
                        ? BoxDecoration(
                            color: appColors.secondaryColor.withAlpha(100),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: appColors.inferiorColor, width: 1.5),
                          )
                        : null,
                    child: Column(
                      children: [
                        if (message.messageID == unreadMessages.firstOrNull)
                          Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            decoration: BoxDecoration(
                              color: appColors.tertiaryColor.withAlpha(170),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                              decoration: BoxDecoration(
                                color: appColors.primaryColor.withAlpha(175),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(S().new_message),
                            ),
                          ),
                        MessageBubble(
                          message: message,
                          previousMessageClientID: previousMessageClientID,
                          previousMessageEpochSecond: previousMessageEpochSecond,
                          chatSession: _chatSession,
                          appColors: appColors,
                        ),
                      ],
                    )));
          },
          reLoadingTop: () async {
            // If user reaches top of conversation retrieve more messages
            if (kDebugMode) debugPrint("Fetching written text");

            List<Message> messages = await _retrieveFurtherLocalMessages();
            if (messages.isEmpty) {
              Client.instance().commands?.fetchWrittenText(_chatSessionIndex);
              return;
            }

            setState(() {
              _messages.addAll(messages);
            });
          },
          reLoadingBottom: () {
            // If user scrolls below the bottom of conversation refresh
            if (kDebugMode) debugPrint("Refetching written text");

            Client.instance().commands?.refetchWrittenText(_chatSessionIndex);
          },
        )),
      ),
    );
  }

  AppBar _buildEditMessageAppBar(AppColors appColors) {
    return AppBar(
      leading: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _isEditingMessage = false;
                _messagesBeingEdited.clear();
              });
            },
          ),
        ],
      ),
      title: Row(
        children: [
          Text("${_messagesBeingEdited.length}"),
        ],
      ),
      actions: [
        if (_messagesBeingEdited.length == 1) ...[
          IconButton(
              onPressed: () {
                Message message = _messagesBeingEdited.single;

                String data;
                switch (message.contentType) {
                  case MessageContentType.text || MessageContentType.gif:
                    data = message.text;
                    break;
                  case MessageContentType.file || MessageContentType.image || MessageContentType.voice:
                    data = message.fileName;
                    break;
                }

                Clipboard.setData(ClipboardData(text: data));
                showSnackBarDialog(
                    context: context, content: S.current.message_copied);
                setState(() {
                  _isEditingMessage = false;
                  _messagesBeingEdited.clear();
                });
              },
              icon: const Icon(Icons.copy)),
        ],
        IconButton(
            onPressed: () async {
              List<int> messageIDs = _messagesBeingEdited.map((Message message) => message.messageID).toList();
              await showWhatsAppDialog(
                context,
                buttons: [
                  TextButton(
                    onPressed: Navigator.of(context).pop,
                    child: Text(S.current.cancel),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Client.instance().commands?.deleteMessages(_chatSessionIndex, messageIDs);
                      showSnackBarDialog(context: context, content: S.current.attempting_delete_message);
                    },
                    child: Text(S.current.delete),
                  ),
                ],
                content: S.current.confirm_delete_message,
              );

              setState(() {
                _isEditingMessage = false;
                _messagesBeingEdited.clear();
              });
            },
            icon: const Icon(Icons.delete_outline)),
        const SizedBox(width: 15),
      ],
      bottom: DividerBottom(dividerColor: appColors.inferiorColor),
    );
  }

  @override
  Widget buildLoadingScreen() {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      backgroundColor: appColors.tertiaryColor,
      appBar: AppBar(
        backgroundColor: appColors.tertiaryColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: appColors.inferiorColor,
          ), // Back arrow icon
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            UserAvatar.empty(),
            const SizedBox(width: 10),
            Text(S.current.chat_with(widget.chatSession.members[0].username),
                style: TextStyle(color: appColors.inferiorColor)),
          ],
        ),
        bottom: DividerBottom(dividerColor: appColors.inferiorColor),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  BoxDecoration _getDecoration(ChatBackDrop chatsBackDrop) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    switch (chatsBackDrop) {
      case ChatBackDrop.gradient:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: SettingsJson().gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        );
      case ChatBackDrop.abstract:
        return BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConstants.parthenonasPath),
            fit: BoxFit.cover,
          ),
        );
      case ChatBackDrop.ermis:
        return BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConstants.ermisBackgroundPath),
            fit: BoxFit.cover,
          ),
        );
      case ChatBackDrop.monotone:
        return BoxDecoration(
          color: appColors.secondaryColor,
        );
      case ChatBackDrop.custom:
        return BoxDecoration(
          color: appColors.secondaryColor,
        );
    }
  }
}

