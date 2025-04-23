import 'package:flutter/widgets.dart';

/// Service which keeps global [BuildContext] of App, so 
/// I don't to have to constantly pass around the context
class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext get currentContext => navigatorKey.currentContext!;
}
