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

import 'dart:math';

import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../core/util/url_launcher.dart';
import '../../generated/l10n.dart';

class ConfigureOwnServerButton extends StatefulWidget {
  final bool shouldPulse;
  const ConfigureOwnServerButton({
    super.key,
    required this.shouldPulse,
  });

  @override
  State<ConfigureOwnServerButton> createState() => _ConfigureOwnServerButtonState();
}

class _ConfigureOwnServerButtonState extends State<ConfigureOwnServerButton> {
  final ValueNotifier<double> _opacityNotifier = ValueNotifier(1.0);

  @override
  void initState() {
    super.initState();
    if (widget.shouldPulse) _startPulsing();
  }

  void _startPulsing() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        _opacityNotifier.value = 0.5 + 0.5 * sin(DateTime.now().millisecondsSinceEpoch / 500);
        _startPulsing();
      }
    });
  }

  @override
  void dispose() {
    _opacityNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _opacityNotifier,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Padding(
            padding: const EdgeInsets.only(top: 25),
            child: Column(
              children: [
                IconButton.outlined(
                  onPressed: () {
                    UrlLauncher.launchURL(
                      context,
                      AppConstants.configureServerURL,
                    );
                  },
                  icon: const Icon(Icons.question_mark),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Text(
                    S().howToConfigureYourOwnServer,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}