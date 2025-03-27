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

import 'dart:ui';
import 'package:ermis_client/core/data_sources/api_client.dart';
import 'package:ermis_client/client/common/message_types/content_type.dart';
import 'package:ermis_client/client/common/message_types/message_delivery_status.dart';
import 'package:ermis_client/core/models/message.dart';
import 'package:ermis_client/core/util/custom_date_formatter.dart';
import 'package:ermis_client/core/util/dialogs_utils.dart';
import 'package:ermis_client/core/util/file_utils.dart';
import 'package:ermis_client/languages/generated/l10n.dart';
import 'package:ermis_client/theme/app_colors.dart';
import 'package:flutter/material.dart';

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
            padding: const EdgeInsets.symmetric(vertical: 10),
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
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  padding: const EdgeInsets.all(10),
                  constraints: const BoxConstraints(maxWidth: 225, maxHeight: 300),
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
