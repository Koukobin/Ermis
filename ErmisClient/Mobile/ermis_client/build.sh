#!/bin/bash

flutter pub get
dart run flutter_launcher_icons

# Running "dart run flutter_launcher_icons" generates a folder named 
# "mipmap-anydpi-v26" in android/app/src/main/res/. In order to ensure the app icon 
# is correctly displayed in the application launcher, the aforementioned folder must be deleted.
# I have no idea why, but it works.
rm -r android/app/src/main/res/mipmap-anydpi-v26