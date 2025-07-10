/* Copyright (C) 2025 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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

import 'package:ermis_mobile/theme/app_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class InfiniteScrollList extends StatefulWidget {
  final Function(int page)? onLoadingStart;
  final bool isLoaded;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final bool reverse;
  final bool? primary;
  final double? itemExtent;
  final Widget? prototypeItem;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;
  final Widget? loadingWidget;

  final VoidCallback reLoadingBottom;
  final VoidCallback reLoadingTop;
  final int itemCount;
  final Widget? Function(BuildContext, int) itemBuilder;
  const InfiniteScrollList({
    super.key,
    this.onLoadingStart,
    this.isLoaded = false,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.reverse = false,
    this.primary,
    this.itemExtent,
    this.prototypeItem,
    this.cacheExtent,
    this.semanticChildCount,
    this.restorationId,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.clipBehavior = Clip.hardEdge,
    this.loadingWidget,
    required this.reLoadingBottom,
    required this.reLoadingTop,
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  State<InfiniteScrollList> createState() => _InfiniteScrollListState();
}

class _InfiniteScrollListState extends State<InfiniteScrollList> {
  bool _isLoadingTop = false;
  bool _isLoadingBottom = false;
  int _overscrollCount = 0;
  DateTime _dateTime = DateTime.now();
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.itemCount == 0 && _isLoadingTop
        ? widget.loadingWidget ??
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            )
        : NotificationListener<OverscrollNotification>(
            onNotification: (OverscrollNotification overscroll) {
              _overscrollCount++;

              // Reset count after delay to prevent triggering too quickly
              Future.delayed(const Duration(milliseconds: 100), () => _overscrollCount = 0);
              if (_overscrollCount < 10) {
                return false;
              }

              if (DateTime.now().difference(_dateTime).inSeconds < 3) {
                return false;
              }

              _dateTime = DateTime.now();

              if (overscroll.overscroll < 0) {
                setState(() {
                  _isLoadingTop = true;
                });
                widget.reLoadingBottom();
                Future.delayed(Duration(seconds: 2), () {
                  setState(() {
                    _isLoadingTop = false;
                  });
                });
              } else if (overscroll.overscroll > 0) {
                setState(() {
                  _isLoadingBottom = true;
                });
                widget.reLoadingTop();
                Future.delayed(Duration(seconds: 2), () {
                  setState(() {
                    _isLoadingBottom = false;
                  });
                });
              }

              return false;
            },
            child: ListView.builder(
              physics: widget.physics,
              reverse: widget.reverse,
              primary: widget.primary,
              itemExtent: widget.itemExtent,
              prototypeItem: widget.prototypeItem,
              cacheExtent: widget.cacheExtent,
              semanticChildCount: widget.semanticChildCount,
              restorationId: widget.restorationId,
              addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
              addRepaintBoundaries: widget.addRepaintBoundaries,
              addSemanticIndexes: widget.addSemanticIndexes,
              dragStartBehavior: widget.dragStartBehavior,
              keyboardDismissBehavior: widget.keyboardDismissBehavior,
              clipBehavior: widget.clipBehavior,
              padding: widget.padding,
              shrinkWrap: widget.shrinkWrap,
              itemCount: widget.itemCount + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  if (!widget.isLoaded || _isLoadingTop) {
                    return buildLoadingScreen();
                  } else {
                    return const SizedBox.shrink();
                  }
                } else if (index == widget.itemCount + 2 - 1) {
                  if (_isLoadingBottom) {
                    return buildLoadingScreen();
                  } else {
                    return const SizedBox.shrink();
                  }
                }

                return widget.itemBuilder(context, index - 1);
              },
            ),
        );
  }

  Widget buildLoadingScreen() {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return widget.loadingWidget ??
        Card(
          color: appColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6, // Adds a subtle shadow effect
          child: const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            ),
          ),
        );
  }
}
