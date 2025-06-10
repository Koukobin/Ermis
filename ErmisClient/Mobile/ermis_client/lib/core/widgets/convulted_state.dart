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

enum ConvultedTask { normal, loading, editing, searching }

abstract class ConvultedState<T extends StatefulWidget> extends State<T> with AutomaticKeepAliveClientMixin<T> {
  ConvultedTask task;

  ConvultedState(this.task);

  @override
  Widget build(BuildContext context) {
    super.build(context); // Cache state
    switch (task) {
      case ConvultedTask.normal:
        return normalBuild(context);
      case ConvultedTask.loading:
        return loadingBuild(context);
      case ConvultedTask.editing:
        return editingBuild(context);
      case ConvultedTask.searching:
        return searchingBuild(context);
    }
  }

  Widget normalBuild(BuildContext context);

  /// By default returns normal build
  Widget loadingBuild(BuildContext context) {
    return normalBuild(context);
  }

  /// By default returns normal build
  Widget editingBuild(BuildContext context) {
    return normalBuild(context);
  }

  /// By default returns normal build
  Widget searchingBuild(BuildContext context) {
    return normalBuild(context);
  }

  @override
  bool get wantKeepAlive => true;
}
