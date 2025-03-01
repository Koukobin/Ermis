import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class InfiniteScrollList extends StatefulWidget {
  final Function(int page)? onLoadingStart;
  final bool everythingLoaded;
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

  final VoidCallback reLoading;
  final VoidCallback reLoading2;
  final int itemCount;
  final Widget? Function(BuildContext, int) itemBuilder;
  const InfiniteScrollList({
    super.key,
    this.onLoadingStart,
    this.everythingLoaded = false,
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
    required this.reLoading,
    required this.reLoading2,
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  State<InfiniteScrollList> createState() => _InfiniteScrollListState();
}

class _InfiniteScrollListState extends State<InfiniteScrollList> {
  bool _loading = false;
  bool _loading2 = false;
  
  @override
  void initState() {
    super.initState();
  }

  int v = 0;

  @override
  Widget build(BuildContext context) {
    return widget.itemCount == 0 && _loading
        ? widget.loadingWidget ??
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            )
        : NotificationListener<OverscrollNotification>(
            onNotification: (overscroll) {
              v++;
              Future.delayed(Duration(milliseconds: 100), () => v = 0);
              if (v < 10) {
                return false;
              }
              if (overscroll.overscroll < 0) {
                setState(() {
                  _loading = true;
                });
                widget.reLoading();
                Future.delayed(Duration(seconds: 2), () {
                  setState(() {
                    _loading = false;
                  });
                });
              } else if (overscroll.overscroll > 0) {
                setState(() {
                  _loading2 = true;
                });
                widget.reLoading2();
                Future.delayed(Duration(seconds: 2), () {
                  setState(() {
                    _loading2 = false;
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
                  if (!widget.everythingLoaded || _loading) {
                    return buildLoadingScreen();
                  } else {
                    return const SizedBox.shrink();
                  }
                } else if (index == widget.itemCount + 2 - 1) {
                  if (_loading2) {
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
