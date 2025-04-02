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
import 'dart:math';

import 'package:ermis_client/constants/app_constants.dart';
import 'package:ermis_client/core/event_bus/app_event_bus.dart';
import 'package:ermis_client/core/models/message_events.dart';
import 'package:ermis_client/languages/generated/l10n.dart';
import 'package:ermis_client/features/chats/widgets/interactive_user_avatar.dart';
import 'package:ermis_client/features/chats/temp.dart';
import 'package:ermis_client/features/settings/linked_devices_settings.dart';
import 'package:ermis_client/features/settings/settings_interface.dart';
import 'package:ermis_client/theme/app_colors.dart';
import 'package:ermis_client/core/util/dialogs_utils.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../core/util/transitions_util.dart';
import '../../core/widgets/scroll/custom_scroll_view.dart';
import '../messaging/presentation/choose_friends_screen.dart';
import '../splash_screen/splash_screen.dart';
import '../messaging/presentation/messaging_interface.dart';
import '../../core/models/chat_session.dart';
import '../../core/data_sources/api_client.dart';
import '../../core/util/top_app_bar_utils.dart';

void _pushMessageInterface(BuildContext context, ChatSession chatSession) {
  pushSlideTransition(
      context,
      MessagingInterface(
        chatSessionIndex: chatSession.chatSessionIndex,
        chatSession: chatSession,
      ));
}

class ChatUserAvatar extends InteractiveUserAvatar {
  ChatUserAvatar({
    super.key,
    required super.chatSession,
    required super.member,
  }) : super(onAvatarClicked: (BuildContext context, VoidCallback popContext) {
          final appColors = Theme.of(context).extension<AppColors>()!;
          return [
            IconButton(
                onPressed: () {
                  popContext();
                  _pushMessageInterface(context, chatSession);
                },
                icon: Icon(
                  Icons.chat_outlined,
                  color: appColors.primaryColor,
                )),
            IconButton(
                onPressed: () {
                  popContext();
                  showSnackBarDialog(
                      context: context,
                      content: S.current.functionality_not_implemented);
                },
                icon: Icon(
                  Icons.phone_outlined,
                  color: appColors.primaryColor,
                )),
            IconButton(
                onPressed: () {
                  popContext();
                  showSnackBarDialog(
                      context: context,
                      content: S.current.functionality_not_implemented);
                },
                icon: Icon(
                  Icons.video_call_outlined,
                  color: appColors.primaryColor,
                )),
            IconButton(
                onPressed: () {
                  popContext();
                  showSnackBarDialog(
                      context: context,
                      content: S.current.functionality_not_implemented);
                },
                icon: Icon(
                  Icons.info_outline,
                  color: appColors.primaryColor,
                )),
          ];
        });
}

class Chats extends StatefulWidget {
  const Chats({super.key});

  @override
  State<Chats> createState() => ChatsState();
}

class ChatsState extends TempState<Chats> {
  List<ChatSession>? _conversations;
  Set<ChatSession> selectedConversations = {}; // Set instead of list to prevent duplicates

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
  late final Stream<int> _stream = Stream.periodic(Duration(seconds: 5), (x) => x).asBroadcastStream();

  ChatsState() : super(Task.normal);

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final List<StreamSubscription<Object>> _subscriptions = [];

  @override
  void initState() {
    super.initState();

    _conversations = Client.instance().chatSessions;
    // If conversations is equal to null, set task to loading
    if (_conversations == null) {
      task = Task.loading;
    }

    _subscriptions.add(AppEventBus.instance.on<ChatSessionsEvent>().listen((event) {
      _updateChatSessions(event.sessions);
    }));

    // Whenever text changes performs search
    _searchController.addListener(() {
      if (!mounted) {
        return;
      }
      performSearch();
    });

    _focusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _removeSubscriptions();
    super.dispose();
  }

  void _removeSubscriptions() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
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
                  task = Task.searching;
                });
                // Variable to skip first call of focusNode which will be by textfield
                bool hasSkippedInitialFocus = false;
                void listener() {
                  if (!hasSkippedInitialFocus) {
                    hasSkippedInitialFocus = true;
                    return;
                  }
                  setState(() {
                    task = Task.normal;
                  });
                  _focusNode.removeListener(listener);
                }

                _focusNode.addListener(listener);
              },
            ),
            PopupMenuButton<VoidCallback>(
              position: PopupMenuPosition.under,
              menuPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              onSelected: (VoidCallback callback) {
                callback();
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: () async {
                    List<Member> members = await showChooseFriendsScreen(context);

                    if (members.isEmpty) return;
                    List<int> memberIds = members.map((member) => member.clientID).toList();
                    Client.instance().commands.createGroup(memberIds);
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Text(
                    "New Group",
                    style: const TextStyle(
                        color: Colors.green,
                        fontStyle: FontStyle.italic,
                        fontSize: 15),
                  ),
                ),
                PopupMenuItem(
                  value: () {
                    // FUCK
                    SendChatRequestButton.showAddChatRequestDialog(context);
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Text(
                    S.current.new_chat,
                    style: const TextStyle(
                        color: Colors.green,
                        fontStyle: FontStyle.italic,
                        fontSize: 15),
                  ),
                ),
                PopupMenuItem(
                  value: () {
                    pushSlideTransition(context, const LinkedDevicesScreen());
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Text(S.current.linked_devices,
                      style: const TextStyle(
                          color: Colors.green,
                          fontStyle: FontStyle.italic,
                          fontSize: 15)),
                ),
                PopupMenuItem(
                  value: () {
                    pushSlideTransition(context, const SettingsScreen());
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Text(
                    S.current.settings,
                    style: const TextStyle(
                        color: Colors.green,
                        fontStyle: FontStyle.italic,
                        fontSize: 15),
                  ),
                ),
                PopupMenuItem(
                  value: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SplashScreen()),
                      (route) => false, // Removes all previous routes
                    );
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Text(
                    S.current.sign_out,
                    style: const TextStyle(
                        color: Colors.green,
                        fontStyle: FontStyle.italic,
                        fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 15),
          ],
        ));
  }

  @override
  Widget searchingBuild(BuildContext context) {
    return _buildMainScaffold(
        context,
        ErmisAppBar(
          title: SearchField(
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
                task = Task.normal;
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
                        content: Text(S.current.deleting_this_chat_will_permanently_delete_all_prior_messages),
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
                                    .deleteChatSession(cs.chatSessionIndex);
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
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Position at the bottom right
            floatingActionButton: const SendChatRequestButton(),
            body: ScrollViewFixer.createScrollViewWithAppBarSafety(
              scrollView: RefreshIndicator(
                // if user scrolls downwards refresh chat requests
                onRefresh: _refreshContent,
                child: _conversations!.isNotEmpty
                    ? ListView.separated(
                        itemCount: _conversations!.length,
                        itemBuilder: (context, index) => buildChatButton(index),
                        separatorBuilder: (context, index) => const Divider(
                          color: Colors.transparent,
                          height: 10,
                        ),
                      )
                    : // Wrap in a list view to ensure it is scrollable for refresh indicator
                    ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height - 150,
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 96.0),
                                  child: Image.asset(AppConstants.ermisCryingPath),
                                ),
                                const SizedBox(height: 15),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: appColors.primaryColor,
                                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                                    border: Border.all(color: appColors.secondaryColor),
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

    final appColors = Theme.of(context).extension<AppColors>()!;
    return ListTile(
      onLongPress: () {
        if (task == Task.normal) {
          setState(() {
            task = Task.editing;
          });
        }

        // If the value was already in the set, remove it
        if (!selectedConversations.add(chatSession)) {
          setState(() {
            selectedConversations.remove(chatSession);
          });
        }

        if (selectedConversations.isEmpty) {
          setState(() {
            task = Task.normal;
          });
        }
      },
      onTap: () => _pushMessageInterface(context, chatSession),
      trailing: AnimatedSwitcher(
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
                key: ValueKey('selected_$sessionIndex'), // Unique key for the selected state
              )
            : Text(
                chatSession.lastMessageSentTime,
                style: const TextStyle(fontSize: 14),
              ),
      ),
      horizontalTitleGap: chatSession.getMembers.length * 3,
      leading: SizedBox(
        width: chatSession.getMembers.length * 10 + 65,
        child: Stack(
          children: [
            for (final (index, member) in chatSession.getMembers.indexed)
              Positioned(
                left: index * 25,
                top: index * 5.0 * pow(-1, index + 1),
                child: ChatUserAvatar(member: member, chatSession: chatSession),
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
                    text:
                        chatSession.toString().substring(startingIndex, endIndex),
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

  Future<void> _refreshContent() async {
    Client.instance().commands.fetchChatSessions();
    setState(() {
      task = Task.loading;
    });
  }

  void _updateChatSessions(List<ChatSession> chatSessions) {
    if (!mounted) return;
    setState(() {
      _conversations = chatSessions;
      task = Task.normal;
    });
  }

  void performSearch() {
    for (var i = 0; i < _conversations!.length; i++) {
      for (var j = 0; j < _conversations!.length; j++) {
        if (_conversations![j].toString().contains(_searchController.text)) {
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

class SendChatRequestButton extends StatefulWidget {
  const SendChatRequestButton({super.key});

  @override
  State<SendChatRequestButton> createState() => _SendChatRequestButtonState();

  static void showAddChatRequestDialog(BuildContext context) async {
    final String input = await showInputDialog(
      context: context,
      keyboardType: TextInputType.number,
      title: S.current.send_chat_request,
      hintText: S.current.client_id_must_be_a_number,
    );

    if (input.isEmpty) return;
    if (int.tryParse(input) == null) {
      showSnackBarDialog(
        context: context,
        content: S.current.client_id_must_be_a_number,
      );
      return;
    }

    final int clientID = int.parse(input);
    Client.instance().commands.sendChatRequest(clientID);
  }
}

class _SendChatRequestButtonState extends State<SendChatRequestButton> {
  double _widgetOpacity = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('send-chat-request-button'),
      onVisibilityChanged: (VisibilityInfo info) {
        if (!mounted) return;
        if (info.visibleFraction > 0) {
          setState(() {
            _widgetOpacity = 1.0;
          });
          return;
        }

        setState(() {
          _widgetOpacity = 0.0;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _widgetOpacity,
          child: FloatingActionButton(
            onPressed: () => SendChatRequestButton.showAddChatRequestDialog(context),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

class SearchField extends StatefulWidget {
  final TextEditingController searchController;
  final FocusNode focusNode;
  const SearchField({
    super.key,
    required this.searchController,
    required this.focusNode,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 15), () {
      if (mounted) {
        setState(() => _opacity = 1.0);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    widget.focusNode.requestFocus();
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _opacity, // Fully visible when searching
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: appColors.secondaryColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: appColors.secondaryColor, width: 1.5),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: InputDecorationTheme(
              hintStyle: const TextStyle(color: Colors.grey),
              labelStyle: const TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              contentPadding: const EdgeInsets.symmetric(vertical: 5),
            ),
          ),
          child: TextField(
              focusNode: widget.focusNode,
              controller: widget.searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() => _opacity = 0.0);
                      Future.delayed(Duration(milliseconds: 175), () {
                        widget.focusNode.unfocus();
                        widget.searchController.clear();
                      });
                    },
                    child: const Icon(Icons.clear)),
                hintText: S.current.search,
                fillColor: appColors.tertiaryColor,
                filled: true,
              )),
        ),
      ),
    );
  }
}

class AnimatedDropdownMenu extends StatefulWidget {
  const AnimatedDropdownMenu({super.key});

  @override
  State<AnimatedDropdownMenu> createState() => _AnimatedDropdownMenuState();
}

class _AnimatedDropdownMenuState extends State<AnimatedDropdownMenu> with SingleTickerProviderStateMixin {
  String? selectedValue = 'Option 1'; // Default selected value
  bool isOpen = false; // Tracks whether the dropdown is open
  late AnimationController _controller; // Animation controller
  late Animation<double> _expandAnimation; // Animation for height expansion

  final List<String> options = ['Option 1', 'Option 2', 'Option 3'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  void toggleDropdown() {
    setState(() {
      isOpen = !isOpen;
      if (isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: toggleDropdown,
        child: Container(
          width: 250,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              const BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selected item
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedValue ?? S.current.select_an_option,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    Icon(
                      isOpen
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              // Animated Dropdown Options
              SizeTransition(
                sizeFactor: _expandAnimation,
                axisAlignment: -1.0,
                child: Container(
                  color: Colors.grey.shade200,
                  child: Column(
                    children: options.map((option) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedValue = option;
                            isOpen = false;
                            _controller.reverse();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: selectedValue == option
                                    ? Colors.blue
                                    : Colors.transparent,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                option,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: selectedValue == option
                                      ? Colors.blue
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
