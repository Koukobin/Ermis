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

import 'dart:math';

import 'package:ermis_mobile/core/services/database/extensions/servers_extension.dart';
import 'package:ermis_mobile/core/services/database/models/server_info.dart';
import 'package:ermis_mobile/core/util/dialogs_utils.dart';
import 'package:ermis_mobile/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../../core/util/ermis_loading_messages.dart';
import '../choose_server_screen/choose_server_screen.dart';
import '../../constants/app_constants.dart';
import '../../core/services/database/database_service.dart';
import '../../core/widgets/animated_text/animated_text.dart';
import '../../core/widgets/animated_text/scramble.dart';
import '../../core/widgets/animated_text/typewriter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _fetchServerUrls();
  }

  /// Fetch server URLs asynchronously
  void _fetchServerUrls() async {
    Set<ServerInfo> cachedServerUrls;
    try {
      cachedServerUrls = (await ErmisDB.getConnection().getServerUrls()).toSet();
    } catch (e) {
      showToastDialog(e.toString());
      return;
    }

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => ChooseServerScreen(cachedServerUrls),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.ease),
            );

            return FadeTransition(opacity: fadeAnimation, child: child);
          },
        ),
      );
    });
  }

  /// Builds an Ermis-tailored loading text widget with
  /// slight variations because I could not decide which
  /// one I preferred best.
  Widget buildErmisLoadingText() {
    final random = Random();

    if (random.nextBool()) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: AnimatedTextKit(
          totalRepeatCount: 1,
          animatedTexts: [
            TypewriterAnimatedText(
              ErmisLoadingMessages.randomMessage(),
              textAlign: TextAlign.center,
              textStyle: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (random.nextBool()) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: AnimatedTextKit(
          totalRepeatCount: 1,
          animatedTexts: [
            ScrambleAnimatedText(
              ErmisLoadingMessages.randomMessage(),
              textAlign: TextAlign.center,
              textStyle: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
              speed: const Duration(milliseconds: 25),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        ErmisLoadingMessages.randomMessage(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: appColors.secondaryColor,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(seconds: 1),
                child: Image.asset(
                  AppConstants.appIconPath,
                  height: 120,
                  width: 120,
                ),
              ),
              buildErmisLoadingText(),
            ],
          ),
        ),
      ),
    );
  }
}
