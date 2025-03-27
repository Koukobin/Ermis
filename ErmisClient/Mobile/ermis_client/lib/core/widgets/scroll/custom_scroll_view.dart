import 'package:flutter/material.dart';

final class ScrollViewFixer {
  const ScrollViewFixer._();

  /// For some odd reason, in Flutter, conventional ScrollViews - whether that
  /// is a [ListView], or a [RefreshIndicator] - mess up with the AppBars' background color.
  /// The accompanying method, manages to resolve this issue by wrapping the [ScrollView] in a
  /// [CustomScrollView] to enable slivers, allowing the [AppBar] to be independent from the body and
  /// preventing the [ScrollView] from interfering with the AppBar's background color.
  /// I do not know why is this the case - but it works.
  static CustomScrollView createScrollViewWithAppBarSafety({
    required Widget scrollView,
    List<Widget> slivers = const [],
  }) {
    // Read method documentation to understand the purpose behind this abomination
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(child: scrollView),
      ],
    );
  }
}
