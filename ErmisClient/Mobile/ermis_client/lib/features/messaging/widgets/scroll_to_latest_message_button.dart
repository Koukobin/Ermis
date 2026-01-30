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

import 'package:flutter/material.dart';

class ScrollToLatestMessageButton extends StatefulWidget {
  const ScrollToLatestMessageButton({
    super.key,
    required this.scrollController,
  });

  final ScrollController scrollController;

  @override
  State<ScrollToLatestMessageButton> createState() => _ScrollToLatestMessageButtonState();
}

class _ScrollToLatestMessageButtonState extends State<ScrollToLatestMessageButton> {
  double _lastOffset = 0;
  bool _isFabVisible = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(() {
      if (offsetExceedsThreshold && isScrollingDown) {
        setState(() {
          _isFabVisible = true;
        });
      }
      if (offsetObeysThreshold || !isScrollingDown) {
        setState(() {
          _isFabVisible = false;
        });
      }

      _lastOffset = widget.scrollController.offset;
    });
  }

  bool get offsetExceedsThreshold => widget.scrollController.offset > 100;
  bool get offsetObeysThreshold => widget.scrollController.offset < 100;
  bool get isScrollingDown => widget.scrollController.offset < _lastOffset;

  @override
  Widget build(BuildContext context) {
    return widget.scrollController.hasClients && _isFabVisible
        ? Padding(
            padding: const EdgeInsets.only(bottom: 64.0),
            child: _ActualButton(scrollController: widget.scrollController),
          )
        : const SizedBox.shrink();
  }
}

class _ActualButton extends StatefulWidget {
  const _ActualButton({required this.scrollController});

  final ScrollController scrollController;

  @override
  State<_ActualButton> createState() => _ActualButtonState();
}

class _ActualButtonState extends State<_ActualButton> {
  double _scale = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(milliseconds: 100),
      () => _scale = 1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      scale: _scale,
      child: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          widget.scrollController
              .animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );

          setState(() {
            _scale = 0.0;
          });
        },
        child: const Icon(Icons.arrow_downward),
      ),
    );
  }
}
