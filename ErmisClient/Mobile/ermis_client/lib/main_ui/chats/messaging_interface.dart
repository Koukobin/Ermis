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
import 'dart:convert';
import 'dart:ui';

import 'package:ermis_client/client/common/message_types/message_delivery_status.dart';
import 'package:ermis_client/client/message_events.dart';
import 'package:ermis_client/generated/l10n.dart';
import 'package:ermis_client/main_ui/chats/voice_call.dart';
import 'package:ermis_client/main_ui/settings/theme_settings.dart';
import 'package:ermis_client/theme/app_colors.dart';
import 'package:ermis_client/util/custom_scroll_view.dart';
import 'package:ermis_client/util/database_service.dart';
import 'package:ermis_client/util/settings_json.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibration/vibration.dart';

import '../../client/app_event_bus.dart';
import '../../constants/app_constants.dart';
import '../../util/custom_date_formatter.dart';
import '../loading_state.dart';
import '../../client/client.dart';
import '../../client/common/chat_session.dart';
import '../../client/common/file_heap.dart';
import '../../client/common/message.dart';
import '../../client/common/message_types/content_type.dart';
import '../../util/dialogs_utils.dart';
import '../../util/file_utils.dart';
import '../../util/notifications_util.dart';
import '../../util/top_app_bar_utils.dart';
import '../scroll/infinite_scroll_list.dart';
import 'user_avatar.dart';

enum _IsOnScreen { hidden, visible }

class MessagingInterface extends StatefulWidget {
  final int chatSessionIndex;
  final ChatSession chatSession;

  const MessagingInterface({
    super.key,
    required this.chatSessionIndex,
    required this.chatSession,
  });

  @override
  State<MessagingInterface> createState() => MessagingInterfaceState();
}

class MessagingInterfaceState extends LoadingState<MessagingInterface> with WidgetsBindingObserver {
  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;

  /// Used to determine whether to send push notification or not
  static final Map<ChatSession, _IsOnScreen> _sessions = {};
  
  late final int _chatSessionIndex;
  late ChatSession _chatSession; // Not final because can be updated by server

  List<Message> _messages = []; // Not final because can be updated by server
  final TextEditingController _inputController = TextEditingController();

  bool _isEditingMessage = false;
  final Set<Message> _messagesBeingEdited = {};

  static final Map<ChatSession, List<StreamSubscription<Object>>> eventBusSubscriptions = {};

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _appLifecycleState = state;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _chatSessionIndex = widget.chatSessionIndex;
    _chatSession = widget.chatSession;

    Future(() async {
      // Fetch cached messages or load from the server
      if (!_chatSession.haveChatMessagesBeenCached) {
        List<Message> messages = await _retrieveLocalMessages();

        if (messages.length > 30) {
          setState(() {
            _messages = messages;
            isLoading = false;
          });
        } else {
          Client.instance().commands.fetchWrittenText(_chatSessionIndex);
        }
      } else {
        setState(() {
          _messages = _chatSession.getMessages;
          isLoading = false;
        });
      }
      _setupListeners(); // Register message listeners
    });
  }

  Future<List<Message>> _retrieveLocalMessages() async {
    List<Message> messages = await ErmisDB.getConnection().retieveChatMessages(
      Client.instance().serverInfo,
      _chatSession.chatSessionID,
    );

    // return messages;
    return [];
  }

  void _setupListeners() {
    if (_sessions.containsKey(_chatSession)) {
      for (final event in eventBusSubscriptions[_chatSession]!) {
        event.cancel();
      }
    }

    _sessions[_chatSession] = _IsOnScreen.visible;

    final a = AppEventBus.instance.on<WrittenTextEvent>().listen((event) {
      if (!mounted) return;
      List<Message> messages = event.chatSession.getMessages;

      _setMessages(messages);
      setState(() {
        isLoading = false;
      });

      ServerInfo serverInfo = Client.instance().serverInfo;
      ErmisDB.getConnection().insertChatMessages(
        serverInfo: serverInfo,
        messages: messages,
      );
    });

    final b = AppEventBus.instance.on<MessageReceivedEvent>().listen((event) {
      ChatSession chatSession = event.chatSession;

      // Since many app event bus listeners of these will exist for each unique chat session...too lazy to write rest
      if (_chatSessionIndex != chatSession.chatSessionIndex) return;

      Message msg = event.message;

      // If message does not originate from the active chat session or the app is in
      // the active state (resumed), abstain from showing the notification
      if (_sessions[_chatSession] == _IsOnScreen.visible && _appLifecycleState == AppLifecycleState.resumed && mounted) {
        setState(() {}); // Since messages was updated by the message handler simply setState
        return;
      }

      // This instance would occur say when a client has two instances of an ermis client app 
      if (msg.clientID == Client.instance().clientID) {
        return;
      }

      SettingsJson settingsJson = SettingsJson();
      settingsJson.loadSettingsJson();

      if (settingsJson.vibrationEnabled) {
        Vibration.vibrate();
      }

      if (!settingsJson.notificationsEnabled) {
        return;
      }
      
      switch (settingsJson.notificationSound) {
        case NotificationSound.osDefault:
          FlutterRingtonePlayer().playNotification();
        case NotificationSound.ermis:
          FlutterRingtonePlayer().play(fromAsset: "assets/sounds/notification.wav");
      }

      if (!settingsJson.showMessagePreview) {
        NotificationService.showSimpleNotification(body: S.current.new_message);
        return;
      }

      String body;
      switch (msg.contentType) {
        case MessageContentType.text:
          body = msg.text;
          break;
        case MessageContentType.file || MessageContentType.image:
          body = S.current.file_received(msg.fileName);
          break;
      }

      NotificationService.showInstantNotification(
        icon: event.chatSession.getMembers[0].getIcon,
        body: S.current.message_by(msg.username),
        contentText: body,
        contentTitle: msg.username,
        summaryText: event.chatSession.toString(),
        replyCallBack: _sendTextMessage,
      );
    });
    eventBusSubscriptions.putIfAbsent(_chatSession, () => []);
    eventBusSubscriptions[_chatSession]!.add(b);

    final c = AppEventBus.instance.on<FileDownloadedEvent>().listen((event) async {
      LoadedInMemoryFile file = event.file;
      String? filePath = await saveFileToDownloads(file.fileName, file.fileBytes);

      if (!mounted) return; // Probably impossible but still check just in case
      if (filePath != null) {
        showSnackBarDialog(context: context, content: S.current.downloaded_file);
        return;
      }

      showExceptionDialog(context, S.current.error_saving_file);
    });

    final d = AppEventBus.instance.on<ImageDownloadedEvent>().listen((event) async {
      _updateImageMessage(event.file, event.messageID);
    });

    final e = AppEventBus.instance.on<MessageDeletionUnsuccessfulEvent>().listen((event) {
      showToastDialog(S.current.message_deletion_unsuccessful);
    });

    final f = AppEventBus.instance.on<MessageDeletedEvent>().listen((event) async {
      ChatSession session = event.chatSession;
      int messageID = event.messageId;

      if (session.chatSessionID != _chatSession.chatSessionID) {
        return;
      }

      _messagesBeingEdited.removeWhere((Message message) => message.messageID == messageID);
      _messages.removeWhere((Message message) => message.messageID == messageID);

      if (mounted) {
        setState(() {});
      }
    });

    final g = AppEventBus.instance.on<MessageDeliveryStatusEvent>().listen((event) async {
      if (!mounted) return;

      Message message = event.message;

      if (message.chatSessionID == _chatSession.chatSessionID) {
        setState(() {});
      }
    });

    final h = AppEventBus.instance.on<ChatSessionsEvent>().listen((event) {
      if (!mounted) return;

      setState(() {
        _chatSession = event.sessions.firstWhere((ChatSession session) =>
            session.chatSessionID == _chatSession.chatSessionID);
      });
    });

    VoiceCallHandler.startListeningForIncomingCalls(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sessions[_chatSession] = _IsOnScreen.hidden;
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _setMessages(List<Message> messages) {
    setState(() {
      _messages = messages;
      // _messages.clear();
      // _messages.addAll(messages);
    });
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

  void _updateImageMessage(LoadedInMemoryFile file, int messageID) {
    if (!mounted) return;
    for (final message in _messages) {
      if (message.messageID == messageID) {
        setState(() {
          message.setFileName(Uint8List.fromList(utf8.encode(file.fileName)));
          message.imageBytes = file.fileBytes;
        });
        break;
      }
    }
  }

  void _sendTextMessage(String text) {
    Message pendingMessage = Client.instance().sendMessageToClient(text, _chatSessionIndex);
    _addMessage(pendingMessage);
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
                  imageBytes: _chatSession.getMembers[0].getIcon,
                  isOnline: _chatSession.getMembers[0].isActive,
                ),
                const SizedBox(width: 10),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth - 75),
                  child: Text(
                    S.current.chat_with(widget.chatSession.getMembers[0].username),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: appColors.inferiorColor),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      VoiceCallHandler.initiateVoiceCall(
                        context,
                        chatSessionIndex: _chatSessionIndex,
                        chatSessionID: _chatSession.chatSessionID,
                      );
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
                        child: Text("Chat Theme"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
      bottom: DividerBottom(dividerColor: appColors.inferiorColor),
    );
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
          reLoadingBottom: () {
            // If user scrolls below the bottom of conversation refresh
            Client.instance().commands.refetchWrittenText(_chatSessionIndex);
          },
          reLoadingTop: () {
            // If user reaches top of conversation retrieve more messages
            Client.instance().commands.fetchWrittenText(_chatSessionIndex);
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
            icon: Icon(Icons.arrow_back, color: appColors.inferiorColor),
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
                  case MessageContentType.file || MessageContentType.image:
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
                      Client.instance().commands.deleteMessages(_chatSessionIndex, messageIDs);
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          const SizedBox(width: 5),
          SendFilePopupMenu(
            chatSessionIndex: _chatSessionIndex,
            fileCallBack: (String fileName, Uint8List fileContent) {
              Message pendingMessage = Client.instance().sendFileToClient(fileName, fileContent, widget.chatSessionIndex);
              _addMessage(pendingMessage);
            },
            imageCallBack: (String fileName, Uint8List fileContent) {
              Message pendingMessage = Client.instance().sendImageToClient(fileName, fileContent, widget.chatSessionIndex);
              _addMessage(pendingMessage);
            },
          ),
          const SizedBox(width: 15),
          Expanded(
            child: TextField(
              maxLines: null,
              keyboardType: TextInputType.multiline,
              controller: _inputController,
              decoration: InputDecoration(
                hintText: S.current.type_message,
                filled: true,
                fillColor: appColors.secondaryColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              if (_inputController.text.trim().isEmpty) return;
              _sendTextMessage(_inputController.text);
              _inputController.clear();
            },
            icon: Icon(Icons.send, color: appColors.inferiorColor),
          ),
        ],
      ),
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
          onPressed: () => {Navigator.pop(context)},
        ),
        title: Row(
          children: [
            UserAvatar(imageBytes: Uint8List(0), isOnline: false),
            const SizedBox(width: 10),
            Text(S.current.chat_with(widget.chatSession.getMembers[0].username),
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
      default:
        return BoxDecoration(
          color: appColors.secondaryColor,
        );
    }
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final Message? previousMessage;
  final AppColors appColors;

  const MessageBubble({
    super.key,
    required this.message,
    required this.previousMessage,
    required this.appColors,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMessageOwner = message.clientID == Client.instance().clientID;

    const int millisPerSecond = 1000;
    DateTime currentMessageDate = DateTime.fromMillisecondsSinceEpoch(
            message.epochSecond * millisPerSecond /* Convert seconds to millis */,
            isUtc: true)
        .toLocal();

    DateTime previousMessageDate = DateTime.fromMillisecondsSinceEpoch(
            (previousMessage?.epochSecond ?? 0) * millisPerSecond /* Convert seconds to millis */,
            isUtc: true)
        .toLocal();

    bool isNewDay = previousMessageDate.difference(currentMessageDate).inDays != 0;

    return Column(
      children: [
        if (isNewDay)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Center(
                child: !isNewDay
                    ? Text(S.current.today)
                    : Text(
                        CustomDateFormatter.formatDate(currentMessageDate, "yyyy-MM-dd"))),
          ),
        Align(
          alignment: isMessageOwner ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: 250, // Limit max width to prevent overly wide messages
                  minWidth: 100, // Ensure small messages don't shrink too much
                ),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  padding: const EdgeInsets.all(10),
                  constraints:
                      const BoxConstraints(maxWidth: 225, maxHeight: 300),
                  decoration: BoxDecoration(
                    gradient: isMessageOwner
                        ? LinearGradient(
                            colors: [Color.fromARGB(255, 30, 155, 25), Color.fromARGB(255, 68, 136, 66)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isMessageOwner
                        ? null
                        : const Color.fromARGB(255, 50, 50, 50),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(isMessageOwner ? 10 : 2),
                        topRight: Radius.circular(isMessageOwner ? 2 : 10),
                        bottomLeft: const Radius.circular(10),
                        bottomRight: const  Radius.circular(10)),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none, // Enable positioning outside bounds
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildMessageContent(context, message),
                      ),
                      Positioned(
                        bottom: -10,
                        right: -10,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              CustomDateFormatter.formatDate(currentMessageDate, "HH:mm"),
                              style: TextStyle(
                                  color: appColors.inferiorColor, fontSize: 12),
                            ),
                            const SizedBox(width: 3), // Small spacing
                            if (isMessageOwner)
                              _buildDeliveryIcon(message.deliveryStatus),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryIcon(MessageDeliveryStatus status) {
    IconData icon;
    Color color = Colors.white;

    switch (status) {
      case MessageDeliveryStatus.sending:
        return SizedBox(
          height: 12,
          width: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: appColors.inferiorColor,
          ),
        );
      case MessageDeliveryStatus.serverReceived:
        icon = Icons.check; // ✅ Single checkmark
        break;
      case MessageDeliveryStatus.delivered || MessageDeliveryStatus.lateDelivered:
        icon = Icons.done_all; // ✅✅ Double checkmarks
        color = Color(0xFF34B7F1); // Apparently the color used by WhatsApp for read messages (According to ChatGPT)
        break;
      case MessageDeliveryStatus.failed:
        icon = Icons.sms_failed_rounded;
        color = Colors.redAccent;
        break;
      case MessageDeliveryStatus.rejected:
        icon = Icons.block;
        color = Colors.redAccent;
    }

    return Icon(icon, size: 16, color: color);
  }


  Widget _buildMessageContent(BuildContext context, Message message) {
    switch (message.contentType) {
      case MessageContentType.text:
        return Text(
          message.text,
          softWrap: true, // Enable text wrapping
          overflow: TextOverflow.clip,
          maxLines: null,
        );
      case MessageContentType.file:
        return Row(
          // Occupy as little space as possible
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: appColors.secondaryColor.withAlpha(100),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Client.instance().commands.downloadFile(
                                message.messageID, message.chatSessionIndex);
                          },
                          child: const Icon(Icons.download),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                message.fileName,
                                softWrap: true, // Enable text wrapping
                                overflow: TextOverflow.clip,
                                maxLines: null,
                              ),
                              Text(S.current.unknown_size),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    message.fileName,
                    softWrap: true, // Enable text wrapping
                    overflow: TextOverflow.clip,
                    maxLines: null,
                  ),
                ],
              ),
            ),
          ],
        );
      case MessageContentType.image:
        final image = message.imageBytes == null
            ? null
            : Hero(
                tag: '${message.messageID}',
                child: Image.memory(message.imageBytes!),
              );
        bool isDownloading = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onDoubleTap: () {
                if (image == null) {
                  setState(() {
                    isDownloading = true;
                  });
                  Client.instance()
                      .commands
                      .downloadImage(message.messageID, message.chatSessionIndex);
                }
              },
              child: Container(
                color: appColors.secondaryColor,
                child: image == null
                    ? isDownloading
                        ? LinearProgressIndicator()
                        : null
                    : GestureDetector(
                        onTap: () {
                          // Display image fullscreen
                          showImageDialog(context, image);
                        },
                        child: FittedBox(fit: BoxFit.contain, child: image)),
              ),
            );
          }
        );
    }
  }

  void showImageDialog(BuildContext context, Widget image) {
    showHeroDialog(context,
        pageBuilder: (context, Animation<double> _, Animation<double> __) {
      return GestureDetector(
        onTap: Navigator.of(context).pop,
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(
                color: Colors.transparent,
              ),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        saveFileToDownloads(
                            message.fileName, message.imageBytes!);
                      },
                      icon: Icon(Icons.download),
                    ),
                  ],
                ),
              ),
              body: InteractiveViewer(
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: image,
                  ),
                ),
              ),
            ),
          ),
              ],
        ),
      );
    });
  }
}

class BlurredDialog extends StatelessWidget {
  final Widget content;

  const BlurredDialog({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Blurred Background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.transparent,
            ),
          ),
          // Dialog Content
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white
                  .withValues(red: 0.8, alpha: 0.8, blue: 0.8, green: 0.8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: content,
          ),
        ],
      ),
    );
  }
}

class SendFilePopupMenu extends StatefulWidget {
  final int chatSessionIndex;
  final FileCallBack fileCallBack;
  final ImageCallBack imageCallBack;

  const SendFilePopupMenu({
    required this.chatSessionIndex,
    required this.fileCallBack,
    required this.imageCallBack,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => SendFilePopupMenuState();
}

class SendFilePopupMenuState extends State<SendFilePopupMenu> {
  @override
  void initState() {
    super.initState();
  }

  void _sendFile(String fileName, Uint8List fileBytes) {
    widget.fileCallBack(fileName, fileBytes);
  }

  void _sendImageFile(String fileName, Uint8List fileBytes) {
    widget.imageCallBack(fileName, fileBytes);
  }

  Widget _buildPopupOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: appColors.inferiorColor.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: CircleAvatar(
              radius: 27,
              backgroundColor: appColors.tertiaryColor,
              child: Icon(icon, size: 28, color: appColors.primaryColor),
            ),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (BuildContext context) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      S.current.choose_option,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPopupOption(
                          context,
                          icon: Icons.image,
                          label: S.current.gallery,
                          onTap: () async {
                            Navigator.pop(context);
                            attachSingleFile(context, (String fileName, Uint8List fileBytes) {
                              _sendImageFile(fileName, fileBytes);
                            });
                          },
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        _buildPopupOption(
                          context,
                          icon: Icons.camera_alt,
                          label: S.current.camera,
                          onTap: () async {
                            Navigator.pop(context);
                            XFile? file = await MyCamera.capturePhoto();

                            if (file == null) {
                              return;
                            }

                            String fileName = file.name;
                            Uint8List fileBytes = await file.readAsBytes();

                            _sendImageFile(fileName, fileBytes);
                          },
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        _buildPopupOption(
                          context,
                          icon: Icons.insert_drive_file,
                          label: S.current.documents,
                          onTap: () {
                            Navigator.pop(context);
                            attachSingleFile(context,
                                (String fileName, Uint8List fileBytes) {
                              _sendFile(fileName, fileBytes);
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        icon: Icon(Icons.attach_file));
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
