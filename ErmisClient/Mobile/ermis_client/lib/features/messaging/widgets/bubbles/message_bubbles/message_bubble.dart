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

import 'package:ermis_mobile/core/data_sources/api_client.dart';
import 'package:ermis_mobile/core/networking/common/message_types/content_type.dart';
import 'package:ermis_mobile/core/networking/common/message_types/message_delivery_status.dart';
import 'package:ermis_mobile/core/models/message.dart';
import 'package:ermis_mobile/core/util/custom_date_formatter.dart';
import 'package:ermis_mobile/features/messaging/widgets/bubbles/abstract_bubble.dart';
import 'package:ermis_mobile/features/messaging/widgets/bubbles/message_bubbles/file_message_bubble.dart';
import 'package:ermis_mobile/features/messaging/widgets/bubbles/message_bubbles/image_message_bubble.dart';
import 'package:ermis_mobile/features/messaging/widgets/bubbles/message_bubbles/voice_message_bubble.dart';
import 'package:ermis_mobile/theme/app_colors.dart';
import 'package:flutter/material.dart';

class MessageBubble extends Bubble {
  final Message message;
  final int? previousMessageEpochSecond;
  final int? previousMessageClientID;
  final AppColors appColors;

  const MessageBubble({
    super.key,
    required this.message,
    required this.previousMessageEpochSecond,
    required this.previousMessageClientID,
    required super.chatSession,
    required this.appColors,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMessageOwner = message.clientID == Client.instance().clientID;

    const int millisPerSecond = 1000;
    final DateTime currentMessageDate = DateTime.fromMillisecondsSinceEpoch(
            message.epochSecond * millisPerSecond /* Convert seconds to millis */,
            isUtc: true)
        .toLocal();

    final DateTime previousMessageDate = DateTime.fromMillisecondsSinceEpoch(
            (previousMessageEpochSecond ?? 0) * millisPerSecond /* Convert seconds to millis */,
            isUtc: true)
        .toLocal();

    return Column(
      children: [
        buildNewDayLabel(
          previousMessageDate: previousMessageDate,
          currentMessageDate: currentMessageDate,
        ),
        buildUserProfile(
          currentMessageClientID: message.clientID,
          previousMessageClientID: previousMessageClientID,
          isMessageOwner: isMessageOwner,
        ),
        Align(
          alignment:
              isMessageOwner ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: const BoxConstraints(
                  maxWidth: 250, // Limit max width to prevent overly wide messages
                  minWidth: 100, // Ensure small messages don't shrink too much
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  padding: const EdgeInsets.all(10),
                  constraints: const BoxConstraints(
                    maxWidth: 225,
                    maxHeight: 300,
                  ),
                  decoration: BoxDecoration(
                    gradient: isMessageOwner
                        ? const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 30, 155, 25),
                              Color.fromARGB(255, 68, 136, 66),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isMessageOwner
                        ? null
                        : MediaQuery.of(context).platformBrightness == Brightness.dark
                            ? const Color.fromARGB(255, 50, 50, 50)
                            : const Color.fromARGB(255, 150, 150, 150),
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
                                color: appColors.inferiorColor,
                                fontSize: 12,
                              ),
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
        color = const Color(0xFF34B7F1); // Apparently the color used by WhatsApp for read messages (According to ChatGPT)
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
        return FileMessageBubble(
          appColors: appColors,
          message: message,
        );
      case MessageContentType.image:
        return ImageMessageBubble(
          message: message,
          appColors: appColors,
        );
      case MessageContentType.voice:
        return VoiceMessage(
          key: Key("${message.messageID}") /* CRITICAL FOR SOME REASON DO NOT REMOVE */,
          message: message,
        );
      case MessageContentType.gif:
        return _GifPage(gifUrl: message.text);
    }
  }

}

class _GifPage extends StatelessWidget {
  final String gifUrl;
  const _GifPage({required this.gifUrl});

  @override
  Widget build(BuildContext context) => Image.network(gifUrl);
}
