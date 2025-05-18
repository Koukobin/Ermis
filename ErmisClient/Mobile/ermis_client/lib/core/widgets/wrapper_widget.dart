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

import 'package:flutter/widgets.dart';

/// This [Widget]'s sole purpose it to wrap another [Widget]
/// and add a [Key] to it. This class can be useful in cases
/// when a [Widget] has already been initialized, yet you
/// somehow want to add a [Key] to it afterwards
class WrapperWidget extends StatelessWidget {
  final Widget child;
  const WrapperWidget({required super.key, required this.child});

  @override
  Widget build(BuildContext context) => child;
}
