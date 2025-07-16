# Ermis M (Mobile)

[ilias.koukovinis@gmail.com]: https://mail.google.com/mail/u/0/?tab=rm&ogbl#search/ilias.koukovinis%40gmail.com

## Overview

**Ermis M** is an open-source, Flutter client application designed for secure and seamless communication with the Ermis server. Ermis M offers a fast and secure platform for connecting with others. Since the dedicated app is built with Flutter, it runs seamlessly on both Android and iOS, while maintaining an almost identical experience across all devices.

You can install the app on the Play Store here: [Ermis M]()https://play.google.com/store/apps/details?id=io.github.koukobin.ermis.ermismobile). 

## Key Features

- **Real-time Messaging**: Chat with friends and family instantly.
- **Media Sharing**: Easily share images, videos, and documents within your chats.
- **Video/Voice Calls**: Communicate with friends and family in real-time as if you are in person.
- **Secure Connections**: Integrated with TLS in order to ensure privacy and security.

## Requirements

- **Supported Platforms**:
    - **Android**: Tested on API level 33
    - **iOS**: Not tested yet due to Apple's protectionist and closed-platform policies

## Set up Project Locally For Development

For a meticulous step-by-step guide for setting up the mobile client codebase locally, refer to the [wiki](https://github.com/Koukobin/Ermis/wiki/MobileClientSetupGuide)

# Building

Before building an installer for a specific platform such as:
   * ```flutter build apk --release```
   * ```flutter build ios --release```

First, execute ```./build.sh``` to ensure built is updated correctly.

## Releasing (Android)

To build a release APK or AAB for publishing on the Play Store, you first have to [sign your app](https://developer.android.com/studio/publish/app-signing#releasemode).

Prima facie, you have to generate a keystore file:
```bash
keytool -genkeypair -v -keystore my-release-key.keystore -alias my_alias -keyalg RSA -keysize 4096 -validity 10000 # Minimum number of days needed to publish on the Google Play Store
```

Once you have generated the prerequisite key to sign your app, add the following to `~/.gradle/gradle.properties` (if doesn't exist first run `touch ~/.gradle/gradle.properties` on your terminal). Thereafter, place the following into `gradle.properties` with the necessary modifications:
```bash
RELEASE_STORE_FILE=your-release-key-path.keystore
RELEASE_STORE_PASSWORD=your_store_password
RELEASE_KEY_ALIAS=your_key_alias
RELEASE_KEY_PASSWORD=your_key_password
```

These variables will be automatically referenced by `android/app/build.gradle`.

> [!TIP]
> **Optionally:**
> - You can change app package name using this command:
> ```bash
> flutter pub run change_app_package_name:main your_desired_package_name
> ```
> - You can change app name in pubspec.yaml with the ensuing command:
> ```bash
> find . -type f -name "*.dart" -exec sed -i 's/package:current_app_name\//package:desired_app_name\//g' {} +
> ```

Denique, you can execute `flutter build apk --release` or `flutter build aab --release` and successfully build your signed package/bundle.

## Contributing

For contribution guidelines, please refer to the main Ermis `README` file.

## Authors

* Ilias Koukovinis (2024) [ilias.koukovinis@gmail.com]

## License

Ermis-Client is distributed under the GNU Affero General Public License Version 3.0 which can be found in the `LICENSE` file.

By using this software, you agree to the terms outlined in the license agreement.
