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

import 'package:ermis_client/core/models/member.dart';
import 'package:ermis_client/core/models/message_events.dart';
import 'package:ermis_client/core/services/database/extensions/chat_messages_extension.dart';
import 'package:ermis_client/core/services/database/extensions/unread_messages_extension.dart';
import 'package:ermis_client/core/util/message_notification.dart';
import 'package:ermis_client/core/networking/common/message_types/client_status.dart';
import 'package:ermis_client/core/util/transitions_util.dart';
import 'package:ermis_client/enums/chat_back_drop_enum.dart';
import 'package:ermis_client/features/voice_call/web_rtc/voice_call_webrtc.dart';
import 'package:ermis_client/mixins/event_bus_subscription_mixin.dart';
import 'package:ermis_client/features/messaging/presentation/input_field.dart';
import 'package:ermis_client/features/messaging/presentation/message_bubble.dart';
import 'package:ermis_client/features/messaging/presentation/choose_friends_screen.dart';
import 'package:ermis_client/generated/l10n.dart';
import 'package:ermis_client/theme/app_colors.dart';
import 'package:ermis_client/core/widgets/scroll/custom_scroll_view.dart';
import 'package:ermis_client/core/services/database/database_service.dart';
import 'package:ermis_client/core/services/settings_json.dart';
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

class MessagingInterface extends StatefulWidget {
  final int chatSessionIndex;
  final ChatSession chatSession;

  const MessagingInterface({
    super.key,
    required this.chatSessionIndex,
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

  late final int _chatSessionIndex;
  late ChatSession _chatSession; // Not final because can be updated by server

  List<Message> _messages = []; // Not final because can be updated by server

  bool _isEditingMessage = false;
  final Set<Message> _messagesBeingEdited = {};

  @override
  void initState() {
    super.initState();

    MessageInterfaceTracker._isScreenInstanceActive = true;

    _chatSessionIndex = widget.chatSessionIndex;
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
    });
  }

  Future<List<Message>> _retrieveFurtherLocalMessages() async {
    List<Message> messages = await ErmisDB.getConnection().retrieveChatMessages(
      chatSessionID: _chatSession.chatSessionID,
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

      Message message = event.message;

      if (message.chatSessionID == _chatSession.chatSessionID) {
        return;
      }

      ErmisDB.getConnection().insertUnreadMessage(
        UserInfoManager.serverInfo,
        message.chatSessionID,
        message.messageID,
      );

      SettingsJson settingsJson = SettingsJson();
      settingsJson.loadSettingsJson();
      handleChatMessageNotificationForeground(
        event.chatSession,
        message,
        settingsJson,
        _sendTextMessage,
      );
    });

    subscribe(AppEventBus.instance.on<FileDownloadedEvent>(), (event) {
      if (mounted) setState(() {});
    });

    subscribe(AppEventBus.instance.on<ImageDownloadedEvent>(), (event) {
      if (mounted) setState(() {});
    });

    subscribe(AppEventBus.instance.on<MessageDeletedEvent>(), (event) {
      ChatSession session = event.chatSession;
      int messageID = event.messageId;

      if (session.chatSessionID != _chatSession.chatSessionID) {
        return;
      }

      _messagesBeingEdited.removeWhere((Message message) => message.messageID == messageID);

      if (mounted) setState(() {});
    });

    subscribe(AppEventBus.instance.on<MessageDeliveryStatusEvent>(), (event) {
      Message message = event.message;

      if (message.chatSessionID == _chatSession.chatSessionID) {
        setState(() {});
      }
    });

    subscribe(AppEventBus.instance.on<ChatSessionsEvent>(), (event) {
      setState(() {
        _chatSession = event.sessions.firstWhere((ChatSession session) =>
            session.chatSessionID == _chatSession.chatSessionID);
      });
    });

  }

  @override
  void dispose() {
    MessageInterfaceTracker._isScreenInstanceActive = false;
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build0(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: _isEditingMessage
          ? _buildEditMessageAppBar(appColors)
          : _buildMainAppBar(appColors),
      body: Container(
        decoration: _getDecoration(SettingsJson().chatsBackDrop),
        child: Column(
          children: [
            _buildMessageList(appColors),
            _buildInputField(appColors),
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
                UserAvatar(
                  imageBytes: _chatSession.members[0].icon.profilePhoto,
                  status: _chatSession.members[0].status,
                ),
                const SizedBox(width: 10),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth - 150),
                  child: Text(
                    S.current.chat_with(widget.chatSession.members[0].username),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    // VoiceCallThing.initiateVoiceCall(
                    //   context,
                    //   chatSessionIndex: _chatSessionIndex,
                    //   chatSessionID: _chatSession.chatSessionID,
                    // );
                    pushSlideTransition(
                        context,
                        VoiceCallWebrtc(
                          chatSessionIndex: _chatSessionIndex,
                          chatSessionID: _chatSession.chatSessionID,
                          member: _chatSession.members[0],
                          isInitiator: true,
                        ));
                  },
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

  void _sendTextMessage(String text) {
    Message pendingMessage = Client.instance().sendMessageToClient(text, widget.chatSessionIndex);
    _addMessage(pendingMessage);
  }

  void _addMessage(Message msg) {
    if (mounted) {
      setState(() {
        _messages.add(msg);
      });
      return;
    }
    _messages.add(msg);
  }

  Widget _buildMessageList(AppColors appColors) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ScrollViewFixer.createScrollViewWithAppBarSafety(scrollView: InfiniteScrollList(
          reverse: true,
          itemCount: _messages.length,
          isLoaded: true,
          itemBuilder: (context, index) {
            final Message message = _messages[_messages.length - index - 1];
            final Message? previousMessage;

            if (index != _messages.length - 1) {
              previousMessage = _messages[_messages.length - index - 2];
            } else {
              previousMessage = null;
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
                    decoration: _isEditingMessage && _messagesBeingEdited.contains(message)
                        ? BoxDecoration(
                            color: appColors.secondaryColor.withAlpha(100),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 1.5),
                          )
                        : null,
                    child: MessageBubble(
                      message: message,
                      previousMessage: previousMessage,
                      appColors: appColors,
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
                  case MessageContentType.text:
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

  Widget _buildInputField(AppColors appColors) {
    return InputField(chatSessionIndex: _chatSessionIndex, messages: _messages);
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
            UserAvatar(imageBytes: Uint8List(0), status: ClientStatus.offline),
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

// class MessagingInterfaceState1 extends LoadingState<MessagingInterface> {
//   late final int _chatSessionIndex;
//   late final ChatSession _chatSession;

//   final List<Message> _messages = List.empty(growable: true);
//   final TextEditingController _inputController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _chatSessionIndex = widget.chatSessionIndex;
//     _chatSession = widget.chatSession;

//     if (!_chatSession.haveChatMessagesBeenCached) {
//       Client.getInstance().getCommands.fetchWrittenText(_chatSessionIndex);
//     } else {
//       _printMessages(_chatSession.getMessages, _chatSessionIndex, 1);
//       setState(() {
//         isLoading = false;
//       });
//     }

//     Client.getInstance().whenAlreadyWrittenTextReceived((ChatSession chatSession) {
//       List<Message> messages = chatSession.getMessages;
//       for (var i = 0; i < messages.length; i++) {
//         _printMessage(messages[i], chatSession.chatSessionIndex, 1);
//       }
//       setState(() {
//         isLoading = false;
//       });
//     });

//     Client.getInstance().whenMessageReceived((Message msg, int chatSessionIndex) {
//       _printMessage(msg, chatSessionIndex, 1);
//     });

//     Client.getInstance().whenFileDownloaded((LoadedInMemoryFile file) async {
//       await saveFileToDownloads(context, file.fileBytes, file.fileName);
//       showSimpleAlertDialog(context: context, title: "Info", content: "Downloaded file");
//     });
//     Client.getInstance().whenImageDownloaded((LoadedInMemoryFile file, int messageID) async {
//       for (final message in _messages) {
//         if (message.messageID != messageID) {
//           continue;
//         }

//         setState(() {
//           message.fileName = Uint8List.fromList(utf8.encode(file.fileName));
//           message.imageBytes = file.fileBytes;
//         });
//       }
//     });
//   }

//   void _sendMessage() {
//     if (_inputController.text.trim().isEmpty) return; // if message is empty return

//     Client.getInstance().sendMessageToClient(_inputController.text, _chatSessionIndex);
//     _inputController.clear();
//   }

//   void _printMessages(List<Message> messages, int chatSessionIndex, int activeChatSessionIndex) {
//     setState(() {
//       _messages.addAll(messages);
//     });
//   }

//   void _printMessage(Message msg, int chatSessionIndex, int activeChatSessionIndex) {
//     setState(() {
//       _messages.add(msg);
//     });
//   }

//   @override
//   Widget build0(BuildContext context) {
//     final appColors = Theme.of(context).extension<AppColors>()!;

//     return Scaffold(
//       backgroundColor: appColors.tertiaryColor,
//       appBar: AppBar(
//         backgroundColor: appColors.tertiaryColor,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back,
//               color: appColors.inferiorColor), // Back arrow icon
//           onPressed: () {
//             Navigator.pop(context); // Navigate back
//           },
//         ),
//         title: Row(
//           children: [
//             CircleAvatar(
//               backgroundImage: widget.chatSession.getMembers[0].getIcon.isEmpty ? null : MemoryImage(widget.chatSession.getMembers[0].getIcon),
//               backgroundColor: Colors.grey[200],
//               child: widget.chatSession.getMembers[0].getIcon.isEmpty
//                   ? Icon(
//                       Icons.person,
//                       color: Colors.grey,
//                     )
//                   : null,
//             ),
//             const SizedBox(width: 10),
//             Text("Chat with ${widget.chatSession.getMembers[0].username}", style: TextStyle(color: appColors.inferiorColor)),
//           ],
//         ),
//         bottom: DividerBottom(dividerColor: appColors.inferiorColor),
//       ),
//       body: Column(
//         children: [
//           // Message Area
//           Expanded(
//             child: ListView.builder(
//               scrollDirection: Axis.vertical,
//               addAutomaticKeepAlives: false,
//               reverse: true,
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 // Choose index like this, in order for the messages
//                 // to be displayed from recent to oldest.
//                 // Not my proudest code, but it works
//                 final Message message = _messages[_messages.length - 1 - index];
//                 bool isMessageOwner = message.clientID == Client.getInstance().clientID;

//                 var dateTime = DateTime.fromMillisecondsSinceEpoch(
//                     message.getTimeWritten,
//                     isUtc: true);
//                 var dateLocal = dateTime.toLocal();
//                 String formattedTime = DateFormat("HH:mm").format(dateLocal);

//                 Widget messageWidget;
//                 switch (message.contentType) {
//                   case ContentType.text:
//                     messageWidget = Text(utf8.decode(message.getText!.toList()));
//                     break;
//                   case ContentType.file:
//                     messageWidget = Row(
//                       children: [
//                         Text(utf8.decode(message.getFileName!.toList())),
//                         GestureDetector(
//                           onTap: () {
//                             showSimpleAlertDialog(
//                                 context: context,
//                                 title: "Notice",
//                                 content: "Downloading file");
//                             Client.getInstance().getCommands.downloadFile(
//                                 message.getMessageID, _chatSessionIndex);
//                           },
//                           child: const Icon(
//                             Icons.download,
//                             size: 24, // Control the icon size here
//                           ),
//                         ),
//                       ],
//                     );
//                     break;
//                   case ContentType.image:
//                     Image? image = message.imageBytes != null ? Image.memory(message.imageBytes!) : null;
//                     messageWidget = Column(
//                       children: [
//                         GestureDetector(
//                           onDoubleTap: () {
//                             Client.getInstance().getCommands.downloadImage(message.getMessageID, _chatSessionIndex);
//                           },
//                           onTap: () {
//                             print("On tap");
//                           },
//                           child: Container(
//                             width: 225,
//                             height: 150,
//                             color: appColors.secondaryColor,
//                             child: FittedBox(fit: BoxFit.contain, child: image),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Row(
//                             children: [
//                               Text(utf8.decode(message.getFileName!.toList())),
//                               GestureDetector(
//                                 onTap: () {
//                                   if (image == null) {
//                                     Client.getInstance()
//                                         .getCommands
//                                         .downloadFile(message.getMessageID,
//                                             _chatSessionIndex);
//                                   } else {
//                                     saveFileToDownloads(
//                                         context,
//                                         message.imageBytes!,
//                                         String.fromCharCodes(
//                                             message.fileName!));
//                                   }
//                                 },
//                                 child: const Icon(
//                                   Icons.download,
//                                   size: 24, // Control the icon size here
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     );
//                     break;
//                 }

//                 Container container = Container(
//                   margin:
//                       const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: isMessageOwner ? appColors.primaryColor : const Color.fromARGB(100, 100, 100, 100),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: messageWidget,
//                 );

//                 Row row = Row(
//                   mainAxisSize: MainAxisSize.min, // Only takes space needed by its children
//                   children: [],
//                 );

//                 if (isMessageOwner) {
//                   row.children.addAll([container, Text(formattedTime, style: TextStyle(color: appColors.inferiorColor))]);
//                 } else {
//                   row.children.addAll([Text(formattedTime, style: TextStyle(color: appColors.inferiorColor)), container]);
//                 }

//                 return Align(
//                   alignment: isMessageOwner
//                       ? Alignment.centerRight
//                       : Alignment.centerLeft,
//                   child: row,
//                 );
//               },
//             ),
//           ),
//           // Input Field
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             color: appColors.tertiaryColor,
//             child: Row(
//               children: [
//                 SizedBox(width: 5),
//                 TestWidget(chatSessionIndex: _chatSessionIndex),
//                 SizedBox(width: 15),
//                 Expanded(
//                   child: TextField(
//                     controller: _inputController,
//                     decoration: InputDecoration(
//                       hintText: "Type a message...",
//                       filled: true,
//                       fillColor: appColors.secondaryColor,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(25),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: _sendMessage,
//                   icon: Icon(Icons.send, color: appColors.inferiorColor),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget buildLoadingScreen() {
//     final appColors = Theme.of(context).extension<AppColors>()!;
//     return Scaffold(
//       backgroundColor: appColors.tertiaryColor,
//       appBar: AppBar(
//         backgroundColor: appColors.tertiaryColor,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back,
//               color: appColors.inferiorColor), // Back arrow icon
//           onPressed: () {
//             Navigator.pop(context); // Navigate back
//           },
//         ),
//         title: Row(
//           children: [
//             CircleAvatar(
//               backgroundImage: widget.chatSession.getMembers[0].getIcon.isEmpty ? null : MemoryImage(widget.chatSession.getMembers[0].getIcon),
//               backgroundColor: Colors.grey[200],
//               child: widget.chatSession.getMembers[0].getIcon.isEmpty
//                   ? Icon(
//                       Icons.person,
//                       color: Colors.grey,
//                     )
//                   : null,
//             ),
//             const SizedBox(width: 10),
//             Text("Chat with ${widget.chatSession.getMembers[0].username}", style: TextStyle(color: appColors.inferiorColor)),
//           ],
//         ),
//         bottom: DividerBottom(dividerColor: appColors.inferiorColor),
//       ),
//       body: Center(child: CircularProgressIndicator()),
//     );
//   }
// }
