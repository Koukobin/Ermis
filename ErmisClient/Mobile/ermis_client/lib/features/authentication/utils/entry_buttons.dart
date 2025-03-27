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

mixin EntryButtons {

  Widget buildButton({
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 17),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.white30, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      icon: Icon(icon, color: textColor),
      label: Text(
        label,
        style: TextStyle(fontSize: 18, color: textColor),
      ),
    );
  }

  Widget buildTextButton({
    required String label,
    IconData? icon,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 18),
        textStyle: const TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      icon: icon == null ? null : Icon(icon, color: textColor),
      label: Text(
        label,
        style: TextStyle(fontSize: 18, color: textColor),
      ),
    );
  }
}


