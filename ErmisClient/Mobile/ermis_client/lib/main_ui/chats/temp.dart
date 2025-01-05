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



import 'package:flutter/material.dart';

enum Task {
  normal, loading, editing, searching
}
abstract class TempState<T extends StatefulWidget> extends State<T> {

  Task task;

  TempState(this.task);

  @override
  Widget build(BuildContext context) {
    switch (task) {
      case Task.normal:
        return normalBuild(context);
      case Task.loading:
        return loadingBuild(context);
      case Task.editing:
        return editingBuild(context);
      case Task.searching:
        return searchingBuild(context);
    }
  }

  Widget normalBuild(BuildContext context);
  
  /// By default return normal build
  Widget loadingBuild(BuildContext context) {
    return normalBuild(context);
  }

  /// By default return normal build
  Widget editingBuild(BuildContext context) {
    return normalBuild(context);
  }

  /// By default return normal build
  Widget searchingBuild(BuildContext context) {
    return normalBuild(context);
  }
}