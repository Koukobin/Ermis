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

import 'choose_server_interface.dart';
import '../constants/app_constants.dart';
import '../theme/app_theme.dart';
import '../util/database_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    fetch();
  }

  void fetch() async {
    // Fetch server URLs asynchronously
    Set<ServerInfo> cachedServerUrls = (await ErmisDB.createConnection().getServerUrls()).toSet();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => ChooseServer(cachedServerUrls),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.ease),
            );

            return FadeTransition(opacity: fadeAnimation, child: child);
          },
        ),
      );
    });
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
                  appIconPath,
                  height: 120,
                  width: 120,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
}
