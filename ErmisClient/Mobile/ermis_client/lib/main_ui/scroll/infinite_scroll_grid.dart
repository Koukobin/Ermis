import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class InfiniteScrollGrid extends StatefulWidget {
  final List<Widget> children;
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
  final Axis scrollDirection;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;

  const InfiniteScrollGrid({
    Key? key,
    required this.children,
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
    this.scrollDirection = Axis.vertical,
    required this.crossAxisCount,
    this.crossAxisSpacing = 0.0,
    this.mainAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
  }) : super(key: key);

  @override
  State<InfiniteScrollGrid> createState() => _InfiniteScrollGridState();
}

class _InfiniteScrollGridState extends State<InfiniteScrollGrid> {
  final ScrollController _sc = ScrollController();
  bool _loading = true;
  int page = 1;
  @override
  void initState() {
    super.initState();
    _removeLoader();
    _sc.addListener(() async {
      if (_sc.position.atEdge && _sc.offset > 0) {
        if (!widget.everythingLoaded) {
          setState(() {
            _loading = true;
          });

          await widget.onLoadingStart?.call(page++);
        }
      }
    });
  }

  Future<void> _removeLoader() async {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (widget.children.isNotEmpty &&
          mounted &&
          _sc.position.maxScrollExtent == 0) {
        setState(() {
          _loading = false;
        });
        timer.cancel();
      }
    });
  }

  List<Widget> get getChildrens {
    List<Widget> childrens = [];
    for (Widget child in widget.children) {
      childrens.add(child);
    }
    if (!widget.everythingLoaded) {
      childrens.add(
        widget.loadingWidget ??
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
      );
    }

    return childrens;
  }

  @override
  Widget build(BuildContext context) {
    return widget.children.isEmpty && _loading
        ? widget.loadingWidget ??
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            )
        : GridView.count(
            crossAxisSpacing: widget.crossAxisSpacing,
            mainAxisSpacing: widget.mainAxisSpacing,
            childAspectRatio: widget.childAspectRatio,
            physics: widget.physics,
            reverse: widget.reverse,
            primary: widget.primary,
            scrollDirection: widget.scrollDirection,
            cacheExtent: widget.cacheExtent,
            semanticChildCount: widget.semanticChildCount,
            restorationId: widget.restorationId,
            addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
            addRepaintBoundaries: widget.addRepaintBoundaries,
            addSemanticIndexes: widget.addSemanticIndexes,
            dragStartBehavior: widget.dragStartBehavior,
            keyboardDismissBehavior: widget.keyboardDismissBehavior,
            clipBehavior: widget.clipBehavior,
            controller: _sc,
            padding: widget.padding,
            shrinkWrap: widget.shrinkWrap,
            crossAxisCount: widget.crossAxisCount,
            // children: widget.children,
            children: getChildrens,
          );
  }
}
