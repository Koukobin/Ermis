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

import '../theme/app_theme.dart';

const String applicationTitle = "Ermis";
const String applicationVersion = "0.7.0";
const String appIconPath = 'assets/primary_application_icon.png';
const String parthenonasPath = 'assets/parthenonas.png';
const String sourceCodeURL = "https://github.com/Koukobin/Ermis";
const String licenceURL = "$sourceCodeURL/wiki/License";
const String licencePath = "assets/LICENCE.txt";

const AppColors lightAppColors = AppColors(
    primaryColor: Colors.green,
    secondaryColor: Colors.white,
    tertiaryColor: Color.fromARGB(255, 233, 233, 233),
    quaternaryColor: Color.fromARGB(255, 150, 150, 150),
    inferiorColor: Colors.black);

const AppColors darkAppColors = AppColors(
  primaryColor: Colors.green,
  secondaryColor: Color.fromARGB(255, 17, 17, 17),
  tertiaryColor: Color.fromARGB(221, 30, 30, 30),
  quaternaryColor: Color.fromARGB(255, 46, 46, 46),
  inferiorColor: Colors.white,
);
