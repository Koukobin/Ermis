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

import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

@immutable
class GoldStyle extends ThemeExtension<GoldStyle> {
  final List<Color> colors;
  final List<double> stops;
  final List<Shadow> textShadows;
  final List<Shadow> iconShadows;
  final FontWeight textWeight;

  const GoldStyle({
    required this.colors,
    required this.stops,
    required this.textShadows,
    required this.iconShadows,
    required this.textWeight,
  });

  static const dark = GoldStyle(
    colors: [
      Color(0xFFFFF6BA),
      Color(0xFFFFBD3C),
      Color(0xFFB8860B),
      Color(0xFFFFBD3C),
    ],
    stops: [0.0, 0.4, 0.7, 1.0],
    textShadows: [
      Shadow(blurRadius: 15.0, color: Color(0xFFFFBD3C)),
      Shadow(blurRadius: 10.0, color: Color(0xFFFFF6BA)),
    ],
    iconShadows: [
      Shadow(blurRadius: 20.0, color: Color(0xFFFFBD3C)),
      Shadow(blurRadius: 8.0, color: Color(0xFFFFF6BA)),
    ],
    textWeight: FontWeight.w500,
  );

  static const light = GoldStyle(
    colors: [
      Color(0xFFEECE1A),
      Color(0xFFCA952B),
      Color(0xFF714C00),
      Color(0xFFFFBD3C),
    ],
    stops: [0.0, 0.4, 0.7, 1.0],
    textShadows: [
      Shadow(blurRadius: 12.5, color: Color(0xFFFFFAD7)),
    ],
    iconShadows: [
      Shadow(blurRadius: 10, color: Color(0xFFFDECC9)),
      Shadow(blurRadius: 6.0, color: Color(0xFFFFF6BA)),
    ],
    textWeight: FontWeight.w600,
  );

  LinearGradient gradient({
    AlignmentGeometry begin = Alignment.centerLeft,
    AlignmentGeometry end = Alignment.centerRight,
  }) =>
      LinearGradient(begin: begin, end: end, colors: colors, stops: stops);

  @override
  GoldStyle copyWith({
    List<Color>? colors,
    List<double>? stops,
    List<Shadow>? textShadows,
    List<Shadow>? iconShadows,
    FontWeight? textWeight,
  }) =>
      GoldStyle(
        colors: colors ?? this.colors,
        stops: stops ?? this.stops,
        textShadows: textShadows ?? this.textShadows,
        iconShadows: iconShadows ?? this.iconShadows,
        textWeight: textWeight ?? this.textWeight,
      );

  @override
  GoldStyle lerp(ThemeExtension<GoldStyle>? other, double t) {
    if (other is! GoldStyle) return this;
    // Palettes have the same length here; fall back to a hard switch otherwise.
    final sameShape = colors.length == other.colors.length &&
        stops.length == other.stops.length;
    return GoldStyle(
      colors: sameShape
          ? [
              for (var i = 0; i < colors.length; i++)
                Color.lerp(colors[i], other.colors[i], t)!,
            ]
          : (t < 0.5 ? colors : other.colors),
      stops: sameShape
          ? [
              for (var i = 0; i < stops.length; i++)
                lerpDouble(stops[i], other.stops[i], t)!,
            ]
          : (t < 0.5 ? stops : other.stops),
      textShadows: Shadow.lerpList(textShadows, other.textShadows, t) ?? const [],
      iconShadows: Shadow.lerpList(iconShadows, other.iconShadows, t) ?? const [],
      textWeight: FontWeight.lerp(textWeight, other.textWeight, t)!,
    );
  }
}

extension GoldStyleContext on BuildContext {
  GoldStyle get goldStyleExtension =>
      Theme.of(this).extension<GoldStyle>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? GoldStyle.dark
          : GoldStyle.light);
}