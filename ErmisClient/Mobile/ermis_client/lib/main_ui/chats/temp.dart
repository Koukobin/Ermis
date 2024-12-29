

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