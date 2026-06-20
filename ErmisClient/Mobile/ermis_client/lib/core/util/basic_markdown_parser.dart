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
import 'package:flutter/widgets.dart';

Widget parseMessage(
  String text, {
  required Text Function(String text) plainBuilder,
  required RichText Function(TextSpan spans) formattedBuilder,
}) {
  TextSpan? spans = formatMessage(text);

  if (spans == null) {
    return plainBuilder(text);
  }

  return formattedBuilder(spans);
}

TextSpan? formatMessage(String text) {
  final List<InlineSpan> spans = [];

  final regex = RegExp(
    r'(?<!\*)\*([^*]+)\*(?!\*)|(?<!_)_([^_]+)_(?!_)|(?<!~)~([^~]+)~(?!~)|(?<!`)`([^`]+)`(?!`)',
  );

  int last = 0;

  for (final match in regex.allMatches(text)) {
    if (match.start > last) {
      spans.add(TextSpan(text: text.substring(last, match.start)));
    }

    final token = match.group(0)!;

    if ((token.startsWith('*_') && token.endsWith('_*')) ||
        (token.startsWith('_*') && token.endsWith('*_'))) { // BOLD + ITALIC
      spans.add(TextSpan(
        text: token.substring(2, token.length - 2),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      ));
    } else if (token.startsWith('*')) { // BOLD
      spans.add(TextSpan(
        text: token.substring(1, token.length - 1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
    } else if (token.startsWith('_')) { // ITALIIC
      spans.add(TextSpan(
        text: token.substring(1, token.length - 1),
        style: const TextStyle(fontStyle: FontStyle.italic),
      ));
    } else if (token.startsWith('~')) { // STRIKETHROUGH
      spans.add(TextSpan(
        text: token.substring(1, token.length - 1),
        style: const TextStyle(
          decoration: TextDecoration.lineThrough,
        ),
      ));
    } else if (token.startsWith('`')) { // INLINE CODE
      spans.add(WidgetSpan(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            color: const Color.fromARGB(225, 42, 42, 45),
          ),
          child: Text(
            token.substring(1, token.length - 1),
            style: const TextStyle(
              color: Color.fromARGB(255, 181, 182, 182),
            ),
          ),
        ),
      ));
    }

    last = match.end;
  }

  if (spans.isEmpty) return null;

  spans.add(TextSpan(text: text.substring(last)));
  return TextSpan(children: spans);
}
