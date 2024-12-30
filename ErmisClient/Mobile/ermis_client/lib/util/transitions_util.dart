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

import 'package:flutter/material.dart';

enum DirectionYAxis {
  topToBottom,
  bottomToTop;
}

Future<Object?> pushHorizontalTransition(BuildContext context, Widget newPage, [Widget? oldPage]) async {
  return await Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => newPage,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Start position
        const end = Offset.zero; // End position
        const curve = Curves.easeOutQuad;

        final Animatable<Offset> tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final Animation<Offset> offsetAnimation = animation.drive(tween);

        final Animatable<Offset> secondaryTween = Tween(begin: Offset(-0.1, 0.0), end: Offset(0.0, 0.0)).chain(CurveTween(curve: curve));
        final Animation<Offset> secondaryOffsetAnimation = secondaryAnimation.drive(secondaryTween);
        
        return Stack(
          children: [
            SlideTransition(
              position: secondaryOffsetAnimation,
              child: oldPage,
            ),
            SlideTransition(
              position: offsetAnimation,
              child: newPage,
            ),
          ],
        );
      },
    ),
  );
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


PageRouteBuilder buildSlideTransition(DirectionYAxis direction, Widget newPage, [Widget? oldPage]) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => newPage,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnimation = Tween<Offset>(
        begin: Offset(direction == DirectionYAxis.bottomToTop ? 0.5 : -0.5,
            direction == DirectionYAxis.bottomToTop ? 1.0 : -1.0),
        end: Offset.zero,
      ).animate(animation);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}