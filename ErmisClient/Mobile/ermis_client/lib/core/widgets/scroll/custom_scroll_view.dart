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
