/* Copyright (C) 2026 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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

import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:ermis_mobile/core/data_sources/api_client.dart';
import 'package:ermis_mobile/core/event_bus/app_event_bus.dart';
import 'package:ermis_mobile/core/models/message.dart';
import 'package:ermis_mobile/core/models/message_events.dart';
import 'package:ermis_mobile/core/util/file_utils.dart';
import 'package:ermis_mobile/mixins/event_bus_subscription_mixin.dart';
import 'package:ermis_mobile/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoMessageBubble extends StatefulWidget {
  final Message message;

  const VideoMessageBubble({
    super.key,
    required this.message,
  });

  @override
  State<VideoMessageBubble> createState() => _VideoMessageBubbleState();
}

class _VideoMessageBubbleState extends State<VideoMessageBubble> with EventBusSubscriptionMixin {
  Message get message => widget.message;

  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();

    subscribe(AppEventBus.instance.on<VideoDownloadedEvent>(), (event) {
      if (event.messageID == message.messageID) {
        setupPlayer().whenComplete(() {
          setState(() {
            isDownloading = false;
          });
        });
      }
    });
  }

  Future<void> setupPlayer() async {
    File file = await createTempFile(message.fileBytes!, message.fileName);
    videoPlayerController = VideoPlayerController.file(file);
    await videoPlayerController!.initialize();

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController!,
      autoPlay: true,
      looping: true,
    );
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return GestureDetector(
      onDoubleTap: () {
        if (message.fileBytes == null) {
          setState(() {
            isDownloading = true;
          });
          Client.instance()
              .commands
              ?.downloadVideo(message.messageID, message.chatSessionIndex);
        } else {
          setupPlayer().whenComplete(() => setState(() {}));
        }
      },
      child: Container(
        color: appColors.secondaryColor,
        child: videoPlayerController == null
            ? isDownloading
                ? const LinearProgressIndicator()
                : null
            : videoPlayerController!.value.isInitialized
                ? Chewie(controller: chewieController!)
                : const CircularProgressIndicator(),
      ),
    );
  }

}
