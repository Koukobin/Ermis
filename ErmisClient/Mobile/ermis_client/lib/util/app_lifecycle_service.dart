import 'package:flutter/material.dart';

class AppLifecycleService with WidgetsBindingObserver {
  static final AppLifecycleService _instance = AppLifecycleService._internal();

  /// Helper method to initialize class
  static void init() {}

  factory AppLifecycleService() => _instance;

  AppLifecycleState? _appLifecycleState;

  AppLifecycleService._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  AppLifecycleState? get appLifecycleState => _appLifecycleState;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appLifecycleState = state;
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
