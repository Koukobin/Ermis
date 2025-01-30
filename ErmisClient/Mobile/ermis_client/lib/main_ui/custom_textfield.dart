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

import 'package:ermis_client/util/string_validator.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final String illegalCharacters;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.illegalCharacters = "",
    this.obscureText = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  String? _errorMessage;
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: widget.controller,
            onChanged: (String input) {
              if (!StringValidator.validate(input, widget.illegalCharacters)) {
                setState(() => _errorMessage = "Invalid character entered!");
                return;
              }
              setState(() => _errorMessage = null);
            },
            obscureText: _obscureText,
            decoration: InputDecoration(
              hintText: widget.hint,
              errorText: _errorMessage,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: appColors.inferiorColor,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Colors.black54,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
            ),
            style: TextStyle(color: appColors.secondaryColor),
          ),
        ),
      ],
    );
  }
}
