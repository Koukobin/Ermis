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

import 'dart:convert';
import 'dart:io';

import 'package:ermis_client/main_ui/settings/theme_settings.dart';
import 'package:ermis_client/util/settings_json.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../constants/app_constants.dart';
import 'chat_interface.dart';
import '../../client/client.dart';
import '../../client/common/chat_session.dart';
import '../../client/common/file_heap.dart';
import '../../client/common/message.dart';
import '../../client/common/message_types/content_type.dart';
import '../../theme/app_theme.dart';
import '../../util/dialogs_utils.dart';
import '../../util/file_utils.dart';
import '../../util/notifications_util.dart';
import '../../util/top_app_bar_utils.dart';

class MessagingInterface extends StatefulWidget {
  final int chatSessionIndex;
  final ChatSession chatSession;

  const MessagingInterface(
      {super.key, required this.chatSessionIndex, required this.chatSession});

  @override
  State<MessagingInterface> createState() => MessagingInterfaceState();
}

class MessagingInterfaceState extends LoadingState<MessagingInterface> {
  late final int _chatSessionIndex;
  late final ChatSession _chatSession;

  final List<Message> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isEditingMessage = false;
  late Message _messageBeingEdited;
  final List<Message> pendingMessagesQueue = [];

  @override
  void initState() {
    super.initState();
    _chatSessionIndex = widget.chatSessionIndex;
    _chatSession = widget.chatSession;

    // Fetch cached messages or load from the server
    if (!_chatSession.haveChatMessagesBeenCached) {
      Client.getInstance().commands.fetchWrittenText(_chatSessionIndex);
    } else {
      _updateMessages(_chatSession.getMessages);
      setState(() {
        isLoading = false;
      });
    }

    // Register message listeners
    _setupListeners();
  }

  void _setupListeners() {
    Client.getInstance().whenAlreadyWrittenTextReceived((chatSession) {
      _updateMessages(chatSession.getMessages);
      setState(() {
        isLoading = false;
      });
    });

    Client.getInstance().whenMessageReceived((msg, chatSessionIndex) {
      String body;

      switch (msg.contentType) {
        case ContentType.text:
          body = utf8.decode(msg.text!);
          break;
        case ContentType.file || ContentType.image: 
          body = utf8.decode(msg.fileName!);
          break;
        }

      NotificationService.showInstantNotification(msg.getUsername, body);
      _addMessage(msg);
    });

    Client.getInstance().whenFileDownloaded((file) async {
     
      String? filePath = await saveFileToDownloads(file.fileName, file.fileBytes);

      if (filePath != null) {
        showSnackBarDialog(context: context, content: "Downloaded file");
        return;
      }

      showExceptionDialog(context, "An error occured while trying to save file");
    });

    Client.getInstance().whenImageDownloaded((file, messageID) async {
      _updateImageMessage(file, messageID);
    });

    Client.getInstance().whenMessageDeleted((session, messageID) {
      for (var i = 0; i < session.getMessages.length; i++) {
        if (session.getMessages[i].messageID == messageID) {
          _chatSession.getMessages.removeAt(i);

          if (session.chatSessionID == _chatSession.chatSessionID) {
            setState(() {
              _messages.removeAt(i);
            });
          }

          break;
        }
      }
    });

    Client.getInstance().whenSuccesfullySentMessageReceived((session, messageID) {
      session.getMessages.add(pendingMessagesQueue.last..setIsSent(true)..setMessageID(messageID));
      if (session.chatSessionID == _chatSession.chatSessionID) {
        Future.delayed(Duration(milliseconds: 100), () {
          setState(() {
            _messages.last.setIsSent(true);
          });
        });
      }
      pendingMessagesQueue.removeLast();
    });

    Client.getInstance().whenVoiceCallIncoming((member) {
      return true;
    });
  }

  void _updateMessages(List<Message> messages) {
    setState(() {
      _messages.clear();
      _messages.addAll(messages);
    });
  }

  void _addMessage(Message msg) {
    setState(() {
      _messages.add(msg);
    });
  }

  void _updateImageMessage(LoadedInMemoryFile file, int messageID) {
    for (final message in _messages) {
      if (message.messageID == messageID) {
        setState(() {
          message.fileName = Uint8List.fromList(utf8.encode(file.fileName));
          message.imageBytes = file.fileBytes;
        });
        break;
      }
    }
  }

  void createPendingMessage(
      {Uint8List? text,
      Uint8List? fileName,
      required ContentType contentType,
      required int chatSessionID,
      required int chatSessionIndex}) {
      
    Message pendingMessage = Message(
        text: text,
        fileName: fileName,
        username: Client.getInstance().displayName!,
        clientID: Client.getInstance().clientID,
        messageID: -1,
        chatSessionID: chatSessionID,
        chatSessionIndex: chatSessionIndex,
        timeWritten: DateTime.now().millisecondsSinceEpoch,
        contentType: contentType,
        isSent: false);

    pendingMessagesQueue.add(pendingMessage);
    _addMessage(pendingMessage);
  }

  void _sendTextMessage() {
    if (_inputController.text.trim().isEmpty) return;

    Client.getInstance().sendMessageToClient(_inputController.text, _chatSessionIndex);

    createPendingMessage(
        text: Uint8List.fromList(utf8.encode(_inputController.text)),
        contentType: ContentType.text,
        chatSessionID: _chatSession.chatSessionID,
        chatSessionIndex: _chatSessionIndex);

    _inputController.clear();
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
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: appColors.inferiorColor),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              UserAvatar(
                imageBytes: _chatSession.getMembers[0].getIcon,
                isOnline: _chatSession.getMembers[0].isActive,
              ),
              const SizedBox(width: 10),
              Text(
                "Chat with ${widget.chatSession.getMembers[0].username}",
                style: TextStyle(color: appColors.inferiorColor),
              ),
            ],
          ),
          Flexible(
            child: IconButton(
                onPressed: () async {
                  final address = InternetAddress("192.168.10.103");
                  final port = 8081;
            
                  final socket = UDPSocket();
                  print("initializing");
                  await socket.initialize(address, port);
                  print("sending");
                  socket.send("message");
                },
                icon: Icon(Icons.phone)),
          )
        ],
      ),
      bottom: DividerBottom(dividerColor: appColors.inferiorColor),
    );
  }

  Widget _buildMessageList(AppColors appColors) {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          // If user reaches top of conversation retrieve more messages
          Client.getInstance().commands.fetchWrittenText(_chatSessionIndex);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListView.builder(
            controller: _scrollController,
            reverse: true,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final Message message = _messages[_messages.length - index - 1];
              return GestureDetector(
                  onLongPress: () {
                    setState(() {
                      _isEditingMessage = true;
                      _messageBeingEdited = message;
                    });
                  },
                  child: Container(
                      decoration: _isEditingMessage &&
                              message == _messageBeingEdited
                          ? BoxDecoration(
                              color: appColors.secondaryColor.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white, width: 1.5),
                            )
                          : null,
                      child: MessageBubble(message: message, appColors: appColors)));
            },
          ),
        ),
      ),
    );
  }

  AppBar _buildEditMessageAppBar(AppColors appColors) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: appColors.inferiorColor),
        onPressed: () {
          setState(() {
            _isEditingMessage = false;
          });
        },
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
              onPressed: () {
                Uint8List? data;
                switch (_messageBeingEdited.contentType) {
                  case ContentType.text:
                    data = _messageBeingEdited.text;
                    break;
                  case ContentType.file || ContentType.image:
                    data = _messageBeingEdited.fileName;
                    break;
                }
                if (data == null) {
                  showSnackBarDialog(
                      context: context,
                      content:
                          "An error occured while trying to copy message to clipboard");
                  return;
                }

                Clipboard.setData(ClipboardData(text: utf8.decode(data)));
                showSnackBarDialog(context: context, content: "Message copied to clipboard");
                setState(() {
                  _isEditingMessage = false;
                });
              },
              icon: Icon(Icons.copy)),
          IconButton(
              onPressed: () {
                Client.getInstance().commands.deleteMessage(
                    _chatSessionIndex, _messageBeingEdited.messageID);
                showSnackBarDialog(
                    context: context, content: "Message deleted");
                setState(() {
                  _isEditingMessage = false;
                });
              },
              icon: Icon(Icons.delete_outline)),
        ],
      ),
      bottom: DividerBottom(dividerColor: appColors.inferiorColor),
    );
  }

  Widget _buildInputField(AppColors appColors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          SizedBox(width: 5),
          SendFilePopupMenu(
            chatSessionIndex: _chatSessionIndex,
            fileCallBack: (String fileName, Uint8List fileContent) {
              createPendingMessage(
                  fileName: Uint8List.fromList(utf8.encode(fileName)),
                  contentType: ContentType.file,
                  chatSessionID: _chatSession.chatSessionID,
                  chatSessionIndex: _chatSessionIndex);
            },
          ),
          SizedBox(width: 15),
          Expanded(
            child: TextField(
              maxLines: null,
              keyboardType: TextInputType.multiline,
              controller: _inputController,
              decoration: InputDecoration(
                hintText: "Type a message...",
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
            onPressed: _sendTextMessage,
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
          icon: Icon(Icons.arrow_back,
              color: appColors.inferiorColor), // Back arrow icon
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            UserAvatar(imageBytes: Uint8List(0), isOnline: false),
            const SizedBox(width: 10),
            Text("Chat with ${widget.chatSession.getMembers[0].username}",
                style: TextStyle(color: appColors.inferiorColor)),
          ],
        ),
        bottom: DividerBottom(dividerColor: appColors.inferiorColor),
      ),
      body: Center(child: CircularProgressIndicator()),
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
            image: AssetImage(parthenonasPath),
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

class ErmisDoodlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2) // Subtle doodle color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw Circles
    for (double x = 0; x < size.width; x += 50) {
      for (double y = 0; y < size.height; y += 50) {
        canvas.drawCircle(Offset(x, y), 15, paint);
      }
    }

    // Draw Wavy Lines
    for (double y = 20; y < size.height; y += 100) {
      final path = Path();
      path.moveTo(0, y);
      for (double x = 0; x < size.width; x += 50) {
        path.quadraticBezierTo(x + 25, y + 20, x + 50, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // Redraw only if necessary
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final AppColors appColors;
  static DateTime lastMessageDate = DateTime.fromMicrosecondsSinceEpoch(500000);

  const MessageBubble(
      {required this.message, required this.appColors, super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMessageOwner = message.clientID == Client.getInstance().clientID;
    final formattedTime = DateFormat("HH:mm").format(
      DateTime.fromMillisecondsSinceEpoch(message.getTimeWritten, isUtc: true)
          .toLocal(),
    );

    DateTime currentMessageDate =
        DateTime.fromMillisecondsSinceEpoch(message.getTimeWritten, isUtc: true)
            .toLocal();
    DateTime now = DateTime.now();

    bool isNewDay = lastMessageDate.day != currentMessageDate.day;
    lastMessageDate = currentMessageDate;

    return Column(
      children: [
        if (isNewDay)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Center(
                child: currentMessageDate.day == now.day
                    ? Text("Today")
                    : Text(
                        DateFormat("yyyy-MM-dd").format(currentMessageDate))),
          ),
        Stack(
          children: [
            Align(
              alignment:
                  isMessageOwner ? Alignment.centerRight : Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isMessageOwner)
                    Text(formattedTime,
                        style: TextStyle(color: appColors.inferiorColor)),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    constraints: BoxConstraints(maxWidth: 225, maxHeight: 300),
                    decoration: BoxDecoration(
                      color: isMessageOwner
                          ? appColors.primaryColor
                          : const Color.fromARGB(100, 100, 100, 100),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _buildMessageContent(context, message),
                  ),
                  if (isMessageOwner)
                    Text(formattedTime,
                        style: TextStyle(color: appColors.inferiorColor)),
                ],
              ),
            ),
            if (!message.isSent)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3), // Semi-transparent overlay
                  child: Center(
                    child: CircularProgressIndicator(
                      color: appColors.inferiorColor,
                      strokeWidth: 2.0,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessageContent(BuildContext context, Message message) {
    switch (message.contentType) {
      case ContentType.text:
        return Text(
          utf8.decode(message.getText!.toList()),
          softWrap: true, // Enable text wrapping
          overflow: TextOverflow.clip, // Add ellipsis for overflow
          maxLines: null,
        );
      case ContentType.file:
        return Row(
          // Occupy as little space as possible
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                utf8.decode(message.getFileName!.toList()),
              ),
            ),
            GestureDetector(
              onTap: () {
                Client.getInstance().commands.downloadFile(message.getMessageID, message.chatSessionIndex);
              },
              child: Icon(Icons.download,
                  size: 20, color: appColors.inferiorColor),
            ),
          ],
        );
      case ContentType.image:
        final image = message.imageBytes != null
            ? Image.memory(message.imageBytes!)
            : null;
        return GestureDetector(
          onDoubleTap: () {
            if (image == null) {
              Client.getInstance().commands.downloadImage(
                  message.getMessageID, message.chatSessionIndex);
            }
          },
          child: Container(
            color: appColors.secondaryColor,
            child: image != null
                ? Stack(
                    children: [
                      GestureDetector(
                          onTap: () {
                            // Display fullscreen image
                            showDialog(
                              context: context,
                              builder: (context) => GestureDetector(
                                onTap: () {
                                  // Close the fullscreen view on tap
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  color: Colors.black,
                                  child: Center(
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: image,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: FittedBox(
                              fit: BoxFit.contain, child: image)),
                      IconButton(
                          onPressed: () {
                            saveFileToDownloads(utf8.decode(message.fileName!), message.imageBytes!);
                          },
                          icon: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Manually add black outline
                              Icon(
                                Icons.download,
                                color: Colors.black,
                                size: 37,
                              ),
                              Icon(
                                Icons.download,
                                color: Colors.white,
                                size: 30,
                              )
                            ],
                          )),
                    ],
                  )
                : null,
          ),
        );
      default:
        return const Text("Unsupported message type");
    }
  }
}

class SendFilePopupMenu extends StatefulWidget {
  final int chatSessionIndex;
  final FileCallBack fileCallBack;
  const SendFilePopupMenu({required this.fileCallBack, required this.chatSessionIndex, super.key});

  @override
  State<StatefulWidget> createState() => SendFilePopupMenuState();
}

class SendFilePopupMenuState extends State<SendFilePopupMenu> {
  @override
  void initState() {
    super.initState();
  }

  void _sendFile(String fileName, Uint8List fileBytes) async {
    Client.getInstance().sendFileToClient(fileName, fileBytes, widget.chatSessionIndex);
    widget.fileCallBack(fileName, fileBytes);
  }

  void _sendImageFile(String fileName, Uint8List fileBytes) async {
    Client.getInstance().sendImageToClient(fileName, fileBytes, widget.chatSessionIndex);
    widget.fileCallBack(fileName, fileBytes);
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
                      "Choose an option",
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
                          label: "Gallery",
                          onTap: () async {
                            Navigator.pop(context);
                            attachSingleFile(context,
                                (String fileName, Uint8List fileBytes) {
                              _sendImageFile(fileName, fileBytes);
                            });
                          },
                        ),
                        SizedBox(width: 5,),
                        _buildPopupOption(
                          context,
                          icon: Icons.camera_alt,
                          label: "Camera",
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
                        SizedBox(width: 5,),
                        _buildPopupOption(
                          context,
                          icon: Icons.insert_drive_file,
                          label: "Documents",
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
    // return PopupMenuButton<void Function()>(
    //     color: appColors.secondaryColor,
    //     onSelected: (value) {
    //       value(); // Run the given function
    //     },
    //     itemBuilder: (context) => [
    //           PopupMenuItem<void Function()>(
    //             value: () async => await attachSingleFile(context,
    //                 (String fileName, Uint8List fileBytes) {
    //               _sendFile(fileName, fileBytes);
    //             }),
    //             child: Row(
    //               children: [
    //                 Icon(
    //                   Icons.file_copy,
    //                   color: appColors.primaryColor,
    //                 ),
    //                 const SizedBox(width: 10),
    //                 Text(
    //                   "Attach file",
    //                   style: TextStyle(
    //                     color: appColors.primaryColor,
    //                     fontSize: 16,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //           PopupMenuItem<void Function()>(
    //             value: () {
    //               attachSingleFile(context,
    //                   (String fileName, Uint8List fileBytes) {
    //                 _sendImageFile(fileName, fileBytes);
    //               });
    //             },
    //             child: Row(
    //               children: [
    //                 Icon(
    //                   Icons.image_outlined,
    //                   color: appColors
    //                       .primaryColor, // Consistent color with other items
    //                 ),
    //                 const SizedBox(width: 10),
    //                 Text(
    //                   "Attach image",
    //                   style: TextStyle(
    //                     color: appColors.primaryColor, // Consistent color
    //                     fontSize: 16, // Readable font size
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //           PopupMenuItem<void Function()>(
    //             value: () async {
    //               XFile? file = await MyCamera.capturePhoto();

    //               if (file == null) {
    //                 return;
    //               }

    //               String fileName = file.name;
    //               Uint8List fileBytes = await file.readAsBytes();

    //               _sendImageFile(fileName, fileBytes);
    //             },
    //             child: Row(
    //               children: [
    //                 Icon(
    //                   Icons.camera_alt_outlined,
    //                   color: appColors
    //                       .primaryColor, // Consistent color with other items
    //                 ),
    //                 const SizedBox(width: 10),
    //                 Text(
    //                   "Take photo",
    //                   style: TextStyle(
    //                     color: appColors.primaryColor, // Consistent color
    //                     fontSize: 16, // Readable font size
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ],
    //     position: PopupMenuPosition.under,
    //     child: Icon(Icons.attach_file));
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
