// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Account successfully created!`
  String get create_account_success {
    return Intl.message(
      'Account successfully created!',
      name: 'create_account_success',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred while creating your account!`
  String get create_account_error {
    return Intl.message(
      'An error occurred while creating your account!',
      name: 'create_account_error',
      desc: '',
      args: [],
    );
  }

  /// `Database maximum capacity reached! Unfortunately, your request could not be processed.`
  String get create_account_database_full {
    return Intl.message(
      'Database maximum capacity reached! Unfortunately, your request could not be processed.',
      name: 'create_account_database_full',
      desc: '',
      args: [],
    );
  }

  /// `Email is already used!`
  String get create_account_email_exists {
    return Intl.message(
      'Email is already used!',
      name: 'create_account_email_exists',
      desc: '',
      args: [],
    );
  }

  /// `Successfully exchanged credentials!`
  String get credential_validation_success {
    return Intl.message(
      'Successfully exchanged credentials!',
      name: 'credential_validation_success',
      desc: '',
      args: [],
    );
  }

  /// `Unable to generate client id!`
  String get credential_validation_client_id_error {
    return Intl.message(
      'Unable to generate client id!',
      name: 'credential_validation_client_id_error',
      desc: '',
      args: [],
    );
  }

  /// `Email is already used!`
  String get credential_validation_email_exists {
    return Intl.message(
      'Email is already used!',
      name: 'credential_validation_email_exists',
      desc: '',
      args: [],
    );
  }

  /// `Username requirements not met!`
  String get credential_validation_username_invalid {
    return Intl.message(
      'Username requirements not met!',
      name: 'credential_validation_username_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Password requirements not met!`
  String get credential_validation_password_invalid {
    return Intl.message(
      'Password requirements not met!',
      name: 'credential_validation_password_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email address`
  String get credential_validation_email_invalid {
    return Intl.message(
      'Invalid email address',
      name: 'credential_validation_email_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Add device info`
  String get login_add_device_info {
    return Intl.message(
      'Add device info',
      name: 'login_add_device_info',
      desc: '',
      args: [],
    );
  }

  /// `Fetch requirements`
  String get login_fetch_requirements {
    return Intl.message(
      'Fetch requirements',
      name: 'login_fetch_requirements',
      desc: '',
      args: [],
    );
  }

  /// `Credentials validation`
  String get authentication_stage_credentials_validation {
    return Intl.message(
      'Credentials validation',
      name: 'authentication_stage_credentials_validation',
      desc: '',
      args: [],
    );
  }

  /// `Create account`
  String get authentication_stage_create_account {
    return Intl.message(
      'Create account',
      name: 'authentication_stage_create_account',
      desc: '',
      args: [],
    );
  }

  /// `Successfully logged into your account!`
  String get login_success {
    return Intl.message(
      'Successfully logged into your account!',
      name: 'login_success',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred while logging into your account! Please contact the server administrator and let them know that their server is broken.`
  String get login_error {
    return Intl.message(
      'An error occurred while logging into your account! Please contact the server administrator and let them know that their server is broken.',
      name: 'login_error',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect password.`
  String get login_password_incorrect {
    return Intl.message(
      'Incorrect password.',
      name: 'login_password_incorrect',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect backup verification code.`
  String get login_backup_code_incorrect {
    return Intl.message(
      'Incorrect backup verification code.',
      name: 'login_backup_code_incorrect',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect email!`
  String get login_email_incorrect {
    return Intl.message(
      'Incorrect email!',
      name: 'login_email_incorrect',
      desc: '',
      args: [],
    );
  }

  /// `Account doesn't exist!`
  String get login_account_not_found {
    return Intl.message(
      'Account doesn\'t exist!',
      name: 'login_account_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Toggle password type`
  String get login_toggle_password {
    return Intl.message(
      'Toggle password type',
      name: 'login_toggle_password',
      desc: '',
      args: [],
    );
  }

  /// `Credentials exchange`
  String get authentication_stage_credentials_exchange {
    return Intl.message(
      'Credentials exchange',
      name: 'authentication_stage_credentials_exchange',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get authentication_stage_login {
    return Intl.message(
      'Login',
      name: 'authentication_stage_login',
      desc: '',
      args: [],
    );
  }

  /// `Successfully verified!`
  String get verification_success {
    return Intl.message(
      'Successfully verified!',
      name: 'verification_success',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect code!`
  String get verification_code_incorrect {
    return Intl.message(
      'Incorrect code!',
      name: 'verification_code_incorrect',
      desc: '',
      args: [],
    );
  }

  /// `Run out of attempts!`
  String get verification_attempts_exhausted {
    return Intl.message(
      'Run out of attempts!',
      name: 'verification_attempts_exhausted',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email address`
  String get verification_email_invalid {
    return Intl.message(
      'Invalid email address',
      name: 'verification_email_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Resend code`
  String get verification_resend_code {
    return Intl.message(
      'Resend code',
      name: 'verification_resend_code',
      desc: '',
      args: [],
    );
  }

  /// `Successfully changed password!`
  String get change_password_success {
    return Intl.message(
      'Successfully changed password!',
      name: 'change_password_success',
      desc: '',
      args: [],
    );
  }

  /// `There was an error while trying to change password!`
  String get change_password_error {
    return Intl.message(
      'There was an error while trying to change password!',
      name: 'change_password_error',
      desc: '',
      args: [],
    );
  }

  /// `Successfully changed username!`
  String get change_username_success {
    return Intl.message(
      'Successfully changed username!',
      name: 'change_username_success',
      desc: '',
      args: [],
    );
  }

  /// `There was an error while trying to change username!`
  String get change_username_error {
    return Intl.message(
      'There was an error while trying to change username!',
      name: 'change_username_error',
      desc: '',
      args: [],
    );
  }

  /// `Username requirements not met`
  String get change_username_invalid {
    return Intl.message(
      'Username requirements not met',
      name: 'change_username_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Successfully validated password!`
  String get password_validation_success {
    return Intl.message(
      'Successfully validated password!',
      name: 'password_validation_success',
      desc: '',
      args: [],
    );
  }

  /// `Password requirements not met!`
  String get password_validation_invalid {
    return Intl.message(
      'Password requirements not met!',
      name: 'password_validation_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Successfully validated username!`
  String get username_validation_success {
    return Intl.message(
      'Successfully validated username!',
      name: 'username_validation_success',
      desc: '',
      args: [],
    );
  }

  /// `Username requirements not met!`
  String get username_validation_invalid {
    return Intl.message(
      'Username requirements not met!',
      name: 'username_validation_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Successfully regenerated backup verification codes!`
  String get backup_verification_code_regenerate_success {
    return Intl.message(
      'Successfully regenerated backup verification codes!',
      name: 'backup_verification_code_regenerate_success',
      desc: '',
      args: [],
    );
  }

  /// `There was an error while trying to change username!`
  String get backup_verification_code_regenerate_error {
    return Intl.message(
      'There was an error while trying to change username!',
      name: 'backup_verification_code_regenerate_error',
      desc: '',
      args: [],
    );
  }

  /// `Slow your horses there! You've been temporarily banned from interacting with the server for a short time interval.`
  String get temp_banned {
    return Intl.message(
      'Slow your horses there! You\'ve been temporarily banned from interacting with the server for a short time interval.',
      name: 'temp_banned',
      desc: '',
      args: [],
    );
  }

  /// `Requests`
  String get requests {
    return Intl.message('Requests', name: 'requests', desc: '', args: []);
  }

  /// `Add new account`
  String get account_add {
    return Intl.message(
      'Add new account',
      name: 'account_add',
      desc: '',
      args: [],
    );
  }

  /// `Delete account`
  String get account_delete {
    return Intl.message(
      'Delete account',
      name: 'account_delete',
      desc: '',
      args: [],
    );
  }

  /// `Account Settings`
  String get account_settings {
    return Intl.message(
      'Account Settings',
      name: 'account_settings',
      desc: '',
      args: [],
    );
  }

  /// `Deleting this account will:`
  String get account_delete_confirmation {
    return Intl.message(
      'Deleting this account will:',
      name: 'account_delete_confirmation',
      desc: '',
      args: [],
    );
  }

  /// `Delete your account with no way to recover`
  String get account_delete_bullet1 {
    return Intl.message(
      'Delete your account with no way to recover',
      name: 'account_delete_bullet1',
      desc: '',
      args: [],
    );
  }

  /// `Erase your message history`
  String get account_delete_bullet2 {
    return Intl.message(
      'Erase your message history',
      name: 'account_delete_bullet2',
      desc: '',
      args: [],
    );
  }

  /// `Delete all your chats`
  String get account_delete_bullet3 {
    return Intl.message(
      'Delete all your chats',
      name: 'account_delete_bullet3',
      desc: '',
      args: [],
    );
  }

  /// `Are you certain you want to proceed?`
  String get account_confirm_proceed {
    return Intl.message(
      'Are you certain you want to proceed?',
      name: 'account_confirm_proceed',
      desc: '',
      args: [],
    );
  }

  /// `Email address`
  String get email_address {
    return Intl.message(
      'Email address',
      name: 'email_address',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Delete My Account`
  String get account_delete_my {
    return Intl.message(
      'Delete My Account',
      name: 'account_delete_my',
      desc: '',
      args: [],
    );
  }

  /// `Enter your name`
  String get name_enter {
    return Intl.message(
      'Enter your name',
      name: 'name_enter',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Notification Settings`
  String get notification_settings {
    return Intl.message(
      'Notification Settings',
      name: 'notification_settings',
      desc: '',
      args: [],
    );
  }

  /// `Enable Notifications`
  String get notification_enable {
    return Intl.message(
      'Enable Notifications',
      name: 'notification_enable',
      desc: '',
      args: [],
    );
  }

  /// `Show Message Previews`
  String get notification_preview_show {
    return Intl.message(
      'Show Message Previews',
      name: 'notification_preview_show',
      desc: '',
      args: [],
    );
  }

  /// `Display part of the message in notifications`
  String get notification_preview_display_part {
    return Intl.message(
      'Display part of the message in notifications',
      name: 'notification_preview_display_part',
      desc: '',
      args: [],
    );
  }

  /// `Notification Sound`
  String get notification_sound {
    return Intl.message(
      'Notification Sound',
      name: 'notification_sound',
      desc: '',
      args: [],
    );
  }

  /// `Other Settings`
  String get other_settings {
    return Intl.message(
      'Other Settings',
      name: 'other_settings',
      desc: '',
      args: [],
    );
  }

  /// `Vibration`
  String get vibration {
    return Intl.message('Vibration', name: 'vibration', desc: '', args: []);
  }

  /// `Vibration is not available on this device`
  String get vibration_unavailable {
    return Intl.message(
      'Vibration is not available on this device',
      name: 'vibration_unavailable',
      desc: '',
      args: [],
    );
  }

  /// `Select Notification Sound`
  String get notification_sound_select {
    return Intl.message(
      'Select Notification Sound',
      name: 'notification_sound_select',
      desc: '',
      args: [],
    );
  }

  /// `Display part of the message in notifications`
  String get display_part_of_messages_in_notifications {
    return Intl.message(
      'Display part of the message in notifications',
      name: 'display_part_of_messages_in_notifications',
      desc: '',
      args: [],
    );
  }

  /// `Linked Devices`
  String get linked_devices {
    return Intl.message(
      'Linked Devices',
      name: 'linked_devices',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to logout from `
  String get linked_devices_logout_confirm {
    return Intl.message(
      'Are you sure you want to logout from ',
      name: 'linked_devices_logout_confirm',
      desc: '',
      args: [],
    );
  }

  /// `logout`
  String get logout {
    return Intl.message('logout', name: 'logout', desc: '', args: []);
  }

  /// `Logout`
  String get logout_capitalized {
    return Intl.message(
      'Logout',
      name: 'logout_capitalized',
      desc: '',
      args: [],
    );
  }

  /// `Logout From All Devices`
  String get linked_devices_logout_all {
    return Intl.message(
      'Logout From All Devices',
      name: 'linked_devices_logout_all',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you would like to logout from all devices?`
  String get linked_devices_logout_all_confirm {
    return Intl.message(
      'Are you sure you would like to logout from all devices?',
      name: 'linked_devices_logout_all_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `Account`
  String get account {
    return Intl.message('Account', name: 'account', desc: '', args: []);
  }

  /// `App language`
  String get app_language {
    return Intl.message(
      'App language',
      name: 'app_language',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get version_capitalized {
    return Intl.message(
      'Version',
      name: 'version_capitalized',
      desc: '',
      args: [],
    );
  }

  /// `Licence`
  String get license_capitalized {
    return Intl.message(
      'Licence',
      name: 'license_capitalized',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Profile Settings`
  String get profile_settings {
    return Intl.message(
      'Profile Settings',
      name: 'profile_settings',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get profile_name {
    return Intl.message('Name', name: 'profile_name', desc: '', args: []);
  }

  /// `About`
  String get profile_about {
    return Intl.message('About', name: 'profile_about', desc: '', args: []);
  }

  /// `Hey there!`
  String get profile_hey_there {
    return Intl.message(
      'Hey there!',
      name: 'profile_hey_there',
      desc: '',
      args: [],
    );
  }

  /// `Functionality not implemented yet!`
  String get functionality_not_implemented {
    return Intl.message(
      'Functionality not implemented yet!',
      name: 'functionality_not_implemented',
      desc: '',
      args: [],
    );
  }

  /// `ID copied to clipboard`
  String get profile_id_copied {
    return Intl.message(
      'ID copied to clipboard',
      name: 'profile_id_copied',
      desc: '',
      args: [],
    );
  }

  /// `Profile Photo`
  String get profile_photo {
    return Intl.message(
      'Profile Photo',
      name: 'profile_photo',
      desc: '',
      args: [],
    );
  }

  /// `Gallery`
  String get profile_gallery {
    return Intl.message('Gallery', name: 'profile_gallery', desc: '', args: []);
  }

  /// `Camera`
  String get profile_camera {
    return Intl.message('Camera', name: 'profile_camera', desc: '', args: []);
  }

  /// `Enter you name`
  String get profile_name_enter {
    return Intl.message(
      'Enter you name',
      name: 'profile_name_enter',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Profile, change name, ID`
  String get profile_change_name_id {
    return Intl.message(
      'Profile, change name, ID',
      name: 'profile_change_name_id',
      desc: '',
      args: [],
    );
  }

  /// `Privacy, security, change number`
  String get privacy_security_change_number {
    return Intl.message(
      'Privacy, security, change number',
      name: 'privacy_security_change_number',
      desc: '',
      args: [],
    );
  }

  /// `Chats`
  String get chats {
    return Intl.message('Chats', name: 'chats', desc: '', args: []);
  }

  /// `Theme, wallpapers, chat history`
  String get theme_wallpapers_chat_history {
    return Intl.message(
      'Theme, wallpapers, chat history',
      name: 'theme_wallpapers_chat_history',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Message, group, and call tones`
  String get message_group_call_tones {
    return Intl.message(
      'Message, group, and call tones',
      name: 'message_group_call_tones',
      desc: '',
      args: [],
    );
  }

  /// `Storage and Data`
  String get storage_data {
    return Intl.message(
      'Storage and Data',
      name: 'storage_data',
      desc: '',
      args: [],
    );
  }

  /// `Network usage, auto-download`
  String get network_usage_auto_download {
    return Intl.message(
      'Network usage, auto-download',
      name: 'network_usage_auto_download',
      desc: '',
      args: [],
    );
  }

  /// `Help`
  String get help {
    return Intl.message('Help', name: 'help', desc: '', args: []);
  }

  /// `Help Settings`
  String get help_settings {
    return Intl.message(
      'Help Settings',
      name: 'help_settings',
      desc: '',
      args: [],
    );
  }

  /// `Source Code`
  String get source_code {
    return Intl.message('Source Code', name: 'source_code', desc: '', args: []);
  }

  /// `Server Source Code`
  String get server_source_code {
    return Intl.message(
      'Server Source Code',
      name: 'server_source_code',
      desc: '',
      args: [],
    );
  }

  /// `Donations`
  String get donations {
    return Intl.message('Donations', name: 'donations', desc: '', args: []);
  }

  /// `Donate to Hoster`
  String get donate_to_hoster {
    return Intl.message(
      'Donate to Hoster',
      name: 'donate_to_hoster',
      desc: '',
      args: [],
    );
  }

  /// `Other`
  String get other {
    return Intl.message('Other', name: 'other', desc: '', args: []);
  }

  /// `License crux`
  String get license_crux {
    return Intl.message(
      'License crux',
      name: 'license_crux',
      desc: '',
      args: [],
    );
  }

  /// `App Info`
  String get app_info {
    return Intl.message('App Info', name: 'app_info', desc: '', args: []);
  }

  /// `Donate To The Ermis Project`
  String get donate_to_ermis_project {
    return Intl.message(
      'Donate To The Ermis Project',
      name: 'donate_to_ermis_project',
      desc: '',
      args: [],
    );
  }

  /// `FAQ, contact us, terms and privacy policy`
  String get faq_contact_terms_privacy {
    return Intl.message(
      'FAQ, contact us, terms and privacy policy',
      name: 'faq_contact_terms_privacy',
      desc: '',
      args: [],
    );
  }

  /// `Manage Storage`
  String get manage_storage {
    return Intl.message(
      'Manage Storage',
      name: 'manage_storage',
      desc: '',
      args: [],
    );
  }

  /// `Settings saved`
  String get settings_saved {
    return Intl.message(
      'Settings saved',
      name: 'settings_saved',
      desc: '',
      args: [],
    );
  }

  /// `Save Settings`
  String get settings_save {
    return Intl.message(
      'Save Settings',
      name: 'settings_save',
      desc: '',
      args: [],
    );
  }

  /// `Chat Theme Settings`
  String get chat_theme_settings {
    return Intl.message(
      'Chat Theme Settings',
      name: 'chat_theme_settings',
      desc: '',
      args: [],
    );
  }

  /// `Theme Mode`
  String get theme_mode {
    return Intl.message('Theme Mode', name: 'theme_mode', desc: '', args: []);
  }

  /// `System Default`
  String get theme_system_default {
    return Intl.message(
      'System Default',
      name: 'theme_system_default',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mode`
  String get theme_dark {
    return Intl.message('Dark Mode', name: 'theme_dark', desc: '', args: []);
  }

  /// `Light Mode`
  String get theme_light {
    return Intl.message('Light Mode', name: 'theme_light', desc: '', args: []);
  }

  /// `Chat Backdrop`
  String get chat_backdrop {
    return Intl.message(
      'Chat Backdrop',
      name: 'chat_backdrop',
      desc: '',
      args: [],
    );
  }

  /// `Upload Custom Image`
  String get chat_backdrop_upload_custom {
    return Intl.message(
      'Upload Custom Image',
      name: 'chat_backdrop_upload_custom',
      desc: '',
      args: [],
    );
  }

  /// `Custom image upload coming soon!`
  String get chat_backdrop_upload_coming_soon {
    return Intl.message(
      'Custom image upload coming soon!',
      name: 'chat_backdrop_upload_coming_soon',
      desc: '',
      args: [],
    );
  }

  /// `Choose Image`
  String get chat_backdrop_choose_image {
    return Intl.message(
      'Choose Image',
      name: 'chat_backdrop_choose_image',
      desc: '',
      args: [],
    );
  }

  /// `Select Gradient Colors`
  String get chat_backdrop_select_gradient {
    return Intl.message(
      'Select Gradient Colors',
      name: 'chat_backdrop_select_gradient',
      desc: '',
      args: [],
    );
  }

  /// `Start Color`
  String get chat_backdrop_gradient_start_color {
    return Intl.message(
      'Start Color',
      name: 'chat_backdrop_gradient_start_color',
      desc: '',
      args: [],
    );
  }

  /// `End Color`
  String get chat_backdrop_gradient_end_color {
    return Intl.message(
      'End Color',
      name: 'chat_backdrop_gradient_end_color',
      desc: '',
      args: [],
    );
  }

  /// `Gradient Preview`
  String get chat_backdrop_gradient_preview {
    return Intl.message(
      'Gradient Preview',
      name: 'chat_backdrop_gradient_preview',
      desc: '',
      args: [],
    );
  }

  /// `Save Changes`
  String get chat_backdrop_save_changes {
    return Intl.message(
      'Save Changes',
      name: 'chat_backdrop_save_changes',
      desc: '',
      args: [],
    );
  }

  /// `Pick a color!`
  String get chat_backdrop_color_pick {
    return Intl.message(
      'Pick a color!',
      name: 'chat_backdrop_color_pick',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message('OK', name: 'ok', desc: '', args: []);
  }

  /// `Enter Server URL`
  String get server_url_enter {
    return Intl.message(
      'Enter Server URL',
      name: 'server_url_enter',
      desc: '',
      args: [],
    );
  }

  /// `Server added successfully!`
  String get server_add_success {
    return Intl.message(
      'Server added successfully!',
      name: 'server_add_success',
      desc: '',
      args: [],
    );
  }

  /// `Add Server`
  String get server_add {
    return Intl.message('Add Server', name: 'server_add', desc: '', args: []);
  }

  /// `Check certificate`
  String get server_certificate_check {
    return Intl.message(
      'Check certificate',
      name: 'server_certificate_check',
      desc: '',
      args: [],
    );
  }

  /// `Choose server URL`
  String get server_url_choose {
    return Intl.message(
      'Choose server URL',
      name: 'server_url_choose',
      desc: '',
      args: [],
    );
  }

  /// `Connect`
  String get connect {
    return Intl.message('Connect', name: 'connect', desc: '', args: []);
  }

  /// `Logout from this device`
  String get logout_from_this_device {
    return Intl.message(
      'Logout from this device',
      name: 'logout_from_this_device',
      desc: '',
      args: [],
    );
  }

  /// `Logout From All Devices`
  String get logout_from_all_devices {
    return Intl.message(
      'Logout From All Devices',
      name: 'logout_from_all_devices',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you would like to logout from all devices?`
  String get are_you_sure_you_want_to_logout_from_all_devices {
    return Intl.message(
      'Are you sure you would like to logout from all devices?',
      name: 'are_you_sure_you_want_to_logout_from_all_devices',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong while trying accept chat request!`
  String get chat_request_accept_error {
    return Intl.message(
      'Something went wrong while trying accept chat request!',
      name: 'chat_request_accept_error',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong while trying to decline chat request!`
  String get chat_request_decline_error {
    return Intl.message(
      'Something went wrong while trying to decline chat request!',
      name: 'chat_request_decline_error',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong while trying delete chat session!`
  String get chat_session_delete_error {
    return Intl.message(
      'Something went wrong while trying delete chat session!',
      name: 'chat_session_delete_error',
      desc: '',
      args: [],
    );
  }

  /// `Address not recognized!`
  String get address_not_recognized {
    return Intl.message(
      'Address not recognized!',
      name: 'address_not_recognized',
      desc: '',
      args: [],
    );
  }

  /// `Email entered does not match actual email!`
  String get email_mismatch {
    return Intl.message(
      'Email entered does not match actual email!',
      name: 'email_mismatch',
      desc: '',
      args: [],
    );
  }

  /// `An error occured while trying to delete your account!`
  String get account_delete_error {
    return Intl.message(
      'An error occured while trying to delete your account!',
      name: 'account_delete_error',
      desc: '',
      args: [],
    );
  }

  /// `An error occured while trying to fetch profile photo from database!`
  String get profile_photo_fetch_error {
    return Intl.message(
      'An error occured while trying to fetch profile photo from database!',
      name: 'profile_photo_fetch_error',
      desc: '',
      args: [],
    );
  }

  /// `Command {} not implemented!`
  String get command_not_implemented {
    return Intl.message(
      'Command {} not implemented!',
      name: 'command_not_implemented',
      desc: '',
      args: [],
    );
  }

  /// `Username cannot be the same as old username!`
  String get username_same_as_old {
    return Intl.message(
      'Username cannot be the same as old username!',
      name: 'username_same_as_old',
      desc: '',
      args: [],
    );
  }

  /// `Chat session selected doesn't exist. (May have been deleted by the other user)`
  String get chat_session_not_found {
    return Intl.message(
      'Chat session selected doesn\'t exist. (May have been deleted by the other user)',
      name: 'chat_session_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Message length exceeds maximum length (%d characters)`
  String get message_length_exceeded {
    return Intl.message(
      'Message length exceeds maximum length (%d characters)',
      name: 'message_length_exceeded',
      desc: '',
      args: [],
    );
  }

  /// `Command not known!`
  String get command_unknown {
    return Intl.message(
      'Command not known!',
      name: 'command_unknown',
      desc: '',
      args: [],
    );
  }

  /// `Content type not implemented!`
  String get content_type_not_implemented {
    return Intl.message(
      'Content type not implemented!',
      name: 'content_type_not_implemented',
      desc: '',
      args: [],
    );
  }

  /// `Message type not implemented!`
  String get message_type_not_implemented {
    return Intl.message(
      'Message type not implemented!',
      name: 'message_type_not_implemented',
      desc: '',
      args: [],
    );
  }

  /// `Content type not known!`
  String get content_type_unknown {
    return Intl.message(
      'Content type not known!',
      name: 'content_type_unknown',
      desc: '',
      args: [],
    );
  }

  /// `Message type not recognized!`
  String get message_type_unknown {
    return Intl.message(
      'Message type not recognized!',
      name: 'message_type_unknown',
      desc: '',
      args: [],
    );
  }

  /// `Decompression failed`
  String get decompression_failed {
    return Intl.message(
      'Decompression failed',
      name: 'decompression_failed',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'el'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'grc'),
      Locale.fromSubtags(languageCode: 'it'),
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'la'),
      Locale.fromSubtags(languageCode: 'pt'),
      Locale.fromSubtags(languageCode: 'ro'),
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'tr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
