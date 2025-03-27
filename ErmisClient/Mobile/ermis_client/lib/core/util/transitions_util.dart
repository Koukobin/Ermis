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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<T> pushMaterialTransition<T>(BuildContext context, Widget newPage) async {
  return await Navigator.push(context, MaterialPageRoute(
    builder: (context) => newPage,
  ));
}

Future<T> pushSlideTransition<T>(BuildContext context, Widget newPage) async {
  // CupertinoPageRoute adds a very nice slide transition between pages
  return await Navigator.push(context, CupertinoPageRoute(
    builder: (context) => newPage,
  ));
}

void navigateWithFade(BuildContext context, Widget newScreen) {
  Navigator.of(context).push(PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => newScreen,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  ));
}

enum DirectionYAxis {
  topToBottom,
  bottomToTop;
}

Route createVerticalTransition(Widget newPage, DirectionYAxis direction) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => newPage,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final double startX = 0;
      final double startY = direction == DirectionYAxis.bottomToTop ? 1.0 : -1.0;
      final begin = Offset(startX, startY); // Start position: off-screen at the bottom
      const end = Offset.zero; // End position: on-screen
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

PageRouteBuilder buildSlideTransition(DirectionYAxis direction, Widget newPage, [Widget? oldPage]) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => newPage,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final double beginX = direction == DirectionYAxis.bottomToTop ? 0.5 : -0.5;
      final double beginY = direction == DirectionYAxis.bottomToTop ? 1.0 : -1.0;

      final begin = Offset(beginX, beginY);
      const end = Offset.zero; // End position
      const curve = Curves.easeOutQuad;

      final Animatable<Offset> tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      final Animation<Offset> offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}