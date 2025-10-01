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
import 'package:ermis_mobile/core/data_sources/api_client.dart';
import 'package:ermis_mobile/core/event_bus/app_event_bus.dart';
import 'package:ermis_mobile/core/models/message.dart';
import 'package:ermis_mobile/core/models/message_events.dart';
import 'package:ermis_mobile/core/util/dialogs_utils.dart';
import 'package:ermis_mobile/core/util/file_utils.dart';
import 'package:ermis_mobile/mixins/event_bus_subscription_mixin.dart';
import 'package:flutter/material.dart';

import '../../../../../theme/app_colors.dart';

class ImageMessageBubble extends StatefulWidget {
  final AppColors appColors;
  final Message message;

  const ImageMessageBubble({
    super.key,
    required this.appColors,
    required this.message,
  });

  @override
  State<ImageMessageBubble> createState() => _ImageMessageBubbleState();
}

class _ImageMessageBubbleState extends State<ImageMessageBubble> with EventBusSubscriptionMixin {
  Message get message => widget.message;

  Hero? imageHero;
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();

    subscribe(AppEventBus.instance.on<ImageDownloadedEvent>(), (event) {
      if (event.messageID == message.messageID) {
        setState(() {
          isDownloading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    imageHero = message.fileBytes == null
        ? null
        : Hero(
            tag: '${message.messageID}',
            child: Image.memory(message.fileBytes!),
          );

    return GestureDetector(
      onDoubleTap: () {
        if (imageHero == null) {
          setState(() {
            isDownloading = true;
          });
          Client.instance()
              .commands
              ?.downloadImage(message.messageID, message.chatSessionIndex);
        }
      },
      child: Container(
        color: widget.appColors.secondaryColor,
        child: imageHero == null
            ? isDownloading
                ? const LinearProgressIndicator()
                : null
            : GestureDetector(
                onTap: () {
                  // Display image fullscreen
                  showImageDialog(context, imageHero);
                },
                child: FittedBox(fit: BoxFit.contain, child: imageHero)),
      ),
    );
  }

  void showImageDialog(BuildContext context, Hero? image) {
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
                            message.fileName, message.fileBytes!);
                      },
                      icon: const Icon(Icons.download),
                    ),
                  ],
                ),
              ),
              body: InteractiveViewer(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
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
