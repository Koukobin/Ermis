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
import 'package:flutter/material.dart';

class TimeElapsedWidget extends StatefulWidget {
  final ValueNotifier<int> elapsedTime;
  const TimeElapsedWidget({super.key, required this.elapsedTime});

  @override
  State<TimeElapsedWidget> createState() => _TimeElapsedWidgetState();
}

class _TimeElapsedWidgetState extends State<TimeElapsedWidget> {

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      widget.elapsedTime.value++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: widget.elapsedTime,
        builder: (context, int value, Widget? child) {
          return Text(
            "${(value / 60).floor()}:${(value % 60).toString().padLeft(2, '0')}",
          );
        });
  }
}
