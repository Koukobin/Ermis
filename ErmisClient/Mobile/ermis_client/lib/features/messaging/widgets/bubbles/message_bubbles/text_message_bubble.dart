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

import 'package:flutter/widgets.dart';

import '../../../../../core/models/message.dart';
import '../../../../../core/util/basic_markdown_parser.dart';
import '../../../../../theme/app_colors.dart';

class TextMessageBubble extends StatelessWidget {
  final AppColors appColors;
  final Message message;

  const TextMessageBubble({
    super.key,
    required this.appColors,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    TextSpan? formattedMessage = formatMessage(message.text);

    if (formattedMessage == null) {
      return Text(
        message.text,
        softWrap: true, // Enable text wrapping
        overflow: TextOverflow.clip,
        maxLines: null,
      );
    }

    return RichText(
      text: formattedMessage,
      softWrap: true, // Enable text wrapping
      overflow: TextOverflow.clip,
      maxLines: null,
    );
  }
}
