#!/bin/bash

flutter clean
flutter pub get
dart run flutter_launcher_icons
dart run intl_utils:generate
dart run build_runner build --delete-conflicting-outputs
