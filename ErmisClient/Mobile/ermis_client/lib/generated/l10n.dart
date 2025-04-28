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

  /// `Account doesnt exist!`
  String get login_account_not_found {
    return Intl.message(
      'Account doesnt exist!',
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

  /// `Slow your horses there! Youve been temporarily banned from interacting with the server for a short time interval.`
  String get temp_banned {
    return Intl.message(
      'Slow your horses there! Youve been temporarily banned from interacting with the server for a short time interval.',
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

  /// `Chat session selected doesnt exist. (May have been deleted by the other user)`
  String get chat_session_not_found {
    return Intl.message(
      'Chat session selected doesnt exist. (May have been deleted by the other user)',
      name: 'chat_session_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Message length exceeds maximum length {|characters}`
  String get message_length_exceeded {
    return Intl.message(
      'Message length exceeds maximum length {|characters}',
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

  /// `Slow your horses. You have been temporarily banned.`
  String get too_many_requests_made {
    return Intl.message(
      'Slow your horses. You have been temporarily banned.',
      name: 'too_many_requests_made',
      desc: '',
      args: [],
    );
  }

  /// `The command you entered was not recognized by the server.`
  String get command_not_recognized {
    return Intl.message(
      'The command you entered was not recognized by the server.',
      name: 'command_not_recognized',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred while attempting to send the chat request.`
  String get error_occurred_while_trying_to_send_chat_request {
    return Intl.message(
      'An error occurred while attempting to send the chat request.',
      name: 'error_occurred_while_trying_to_send_chat_request',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred while attempting to retrieve the file from the database.`
  String get error_occurred_while_trying_to_fetch_file_from_database {
    return Intl.message(
      'An error occurred while attempting to retrieve the file from the database.',
      name: 'error_occurred_while_trying_to_fetch_file_from_database',
      desc: '',
      args: [],
    );
  }

  /// `The message type received was not recognized.`
  String get message_type_not_recognized {
    return Intl.message(
      'The message type received was not recognized.',
      name: 'message_type_not_recognized',
      desc: '',
      args: [],
    );
  }

  /// `New message!`
  String get new_message {
    return Intl.message(
      'New message!',
      name: 'new_message',
      desc: '',
      args: [],
    );
  }

  /// `File received {fileName}`
  String file_received(Object fileName) {
    return Intl.message(
      'File received $fileName',
      name: 'file_received',
      desc: '',
      args: [fileName],
    );
  }

  /// `Message by {username}`
  String message_by(Object username) {
    return Intl.message(
      'Message by $username',
      name: 'message_by',
      desc: '',
      args: [username],
    );
  }

  /// `Downloaded file`
  String get downloaded_file {
    return Intl.message(
      'Downloaded file',
      name: 'downloaded_file',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred while trying to save the file`
  String get error_saving_file {
    return Intl.message(
      'An error occurred while trying to save the file',
      name: 'error_saving_file',
      desc: '',
      args: [],
    );
  }

  /// `Message deletion was unsuccessful`
  String get message_deletion_unsuccessful {
    return Intl.message(
      'Message deletion was unsuccessful',
      name: 'message_deletion_unsuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Chat with {username}`
  String chat_with(Object username) {
    return Intl.message(
      'Chat with $username',
      name: 'chat_with',
      desc: '',
      args: [username],
    );
  }

  /// `Message copied to clipboard`
  String get message_copied {
    return Intl.message(
      'Message copied to clipboard',
      name: 'message_copied',
      desc: '',
      args: [],
    );
  }

  /// `Attempting to delete message`
  String get attempting_delete_message {
    return Intl.message(
      'Attempting to delete message',
      name: 'attempting_delete_message',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to permanently delete message?`
  String get confirm_delete_message {
    return Intl.message(
      'Are you sure you want to permanently delete message?',
      name: 'confirm_delete_message',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Type a message...`
  String get type_message {
    return Intl.message(
      'Type a message...',
      name: 'type_message',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get today {
    return Intl.message('Today', name: 'today', desc: '', args: []);
  }

  /// `Choose an option`
  String get choose_option {
    return Intl.message(
      'Choose an option',
      name: 'choose_option',
      desc: '',
      args: [],
    );
  }

  /// `Gallery`
  String get gallery {
    return Intl.message('Gallery', name: 'gallery', desc: '', args: []);
  }

  /// `Camera`
  String get camera {
    return Intl.message('Camera', name: 'camera', desc: '', args: []);
  }

  /// `Documents`
  String get documents {
    return Intl.message('Documents', name: 'documents', desc: '', args: []);
  }

  /// `Whats New`
  String get whats_new {
    return Intl.message('Whats New', name: 'whats_new', desc: '', args: []);
  }

  /// `New Features in Hermis`
  String get whats_new_title {
    return Intl.message(
      'New Features in Hermis',
      name: 'whats_new_title',
      desc: '',
      args: [],
    );
  }

  /// `Enhanced encryption protocols`
  String get feature_encryption {
    return Intl.message(
      'Enhanced encryption protocols',
      name: 'feature_encryption',
      desc: '',
      args: [],
    );
  }

  /// `Multi-language support!`
  String get feature_languages {
    return Intl.message(
      'Multi-language support!',
      name: 'feature_languages',
      desc: '',
      args: [],
    );
  }

  /// `Voice calls (Early Access)`
  String get feature_voice_calls {
    return Intl.message(
      'Voice calls (Early Access)',
      name: 'feature_voice_calls',
      desc: '',
      args: [],
    );
  }

  /// `New chat themes`
  String get feature_chat_themes {
    return Intl.message(
      'New chat themes',
      name: 'feature_chat_themes',
      desc: '',
      args: [],
    );
  }

  /// `Audio message support`
  String get feature_audio_messages {
    return Intl.message(
      'Audio message support',
      name: 'feature_audio_messages',
      desc: '',
      args: [],
    );
  }

  /// `New System Messages`
  String get whats_new_system_messages {
    return Intl.message(
      'New System Messages',
      name: 'whats_new_system_messages',
      desc: '',
      args: [],
    );
  }

  /// `Got it!`
  String get got_it_button {
    return Intl.message('Got it!', name: 'got_it_button', desc: '', args: []);
  }

  /// `Are you sure you want to logout from {deviceInfo}?`
  String are_you_sure_you_want_to_logout_from(Object deviceInfo) {
    return Intl.message(
      'Are you sure you want to logout from $deviceInfo?',
      name: 'are_you_sure_you_want_to_logout_from',
      desc: '',
      args: [deviceInfo],
    );
  }

  /// `No pending chat requests`
  String get no_chat_requests_available {
    return Intl.message(
      'No pending chat requests',
      name: 'no_chat_requests_available',
      desc: '',
      args: [],
    );
  }

  /// `Ermis has no friends...`
  String get no_conversations_available {
    return Intl.message(
      'Ermis has no friends...',
      name: 'no_conversations_available',
      desc: '',
      args: [],
    );
  }

  /// `No chats available, incompatible server version`
  String get no_chats_available_incompatible_server_version {
    return Intl.message(
      'No chats available, incompatible server version',
      name: 'no_chats_available_incompatible_server_version',
      desc: '',
      args: [],
    );
  }

  /// `Accept`
  String get accept {
    return Intl.message('Accept', name: 'accept', desc: '', args: []);
  }

  /// `Decline`
  String get decline {
    return Intl.message('Decline', name: 'decline', desc: '', args: []);
  }

  /// `Client id must be a number`
  String get client_id_must_be_a_number {
    return Intl.message(
      'Client id must be a number',
      name: 'client_id_must_be_a_number',
      desc: '',
      args: [],
    );
  }

  /// `Enter client id`
  String get enter_client_id {
    return Intl.message(
      'Enter client id',
      name: 'enter_client_id',
      desc: '',
      args: [],
    );
  }

  /// `Send Chat Request`
  String get send_chat_request {
    return Intl.message(
      'Send Chat Request',
      name: 'send_chat_request',
      desc: '',
      args: [],
    );
  }

  /// `Search...`
  String get search {
    return Intl.message('Search...', name: 'search', desc: '', args: []);
  }

  /// `Select an option`
  String get select_an_option {
    return Intl.message(
      'Select an option',
      name: 'select_an_option',
      desc: '',
      args: [],
    );
  }

  /// `Delete chat`
  String get delete_chat {
    return Intl.message('Delete chat', name: 'delete_chat', desc: '', args: []);
  }

  /// `Deleting this chat will permanently delete all prior messages`
  String get deleting_this_chat_will_permanently_delete_all_prior_messages {
    return Intl.message(
      'Deleting this chat will permanently delete all prior messages',
      name: 'deleting_this_chat_will_permanently_delete_all_prior_messages',
      desc: '',
      args: [],
    );
  }

  /// `Delete this chat?`
  String get delete_this_chat_question {
    return Intl.message(
      'Delete this chat?',
      name: 'delete_this_chat_question',
      desc: '',
      args: [],
    );
  }

  /// `New chat`
  String get new_chat {
    return Intl.message('New chat', name: 'new_chat', desc: '', args: []);
  }

  /// `Incompatible server version! Some things many not work as expected!`
  String get incompatible_server_version_warning {
    return Intl.message(
      'Incompatible server version! Some things many not work as expected!',
      name: 'incompatible_server_version_warning',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submit {
    return Intl.message('Submit', name: 'submit', desc: '', args: []);
  }

  /// `Verification`
  String get verification {
    return Intl.message(
      'Verification',
      name: 'verification',
      desc: '',
      args: [],
    );
  }

  /// `Enter verification code sent to your email`
  String get enter_verification_code_sent_to_your_email {
    return Intl.message(
      'Enter verification code sent to your email',
      name: 'enter_verification_code_sent_to_your_email',
      desc: '',
      args: [],
    );
  }

  /// `Verification code must be number`
  String get verification_code_must_be_number {
    return Intl.message(
      'Verification code must be number',
      name: 'verification_code_must_be_number',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the verification code`
  String get please_enter_the_verification_code {
    return Intl.message(
      'Please enter the verification code',
      name: 'please_enter_the_verification_code',
      desc: '',
      args: [],
    );
  }

  /// `Resend Code`
  String get resend_code {
    return Intl.message('Resend Code', name: 'resend_code', desc: '', args: []);
  }

  /// `Enter Verification Code`
  String get enter_verification_code {
    return Intl.message(
      'Enter Verification Code',
      name: 'enter_verification_code',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get create_account {
    return Intl.message(
      'Create Account',
      name: 'create_account',
      desc: '',
      args: [],
    );
  }

  /// `Use Backup-Verification Code`
  String get use_backup_verification_code {
    return Intl.message(
      'Use Backup-Verification Code',
      name: 'use_backup_verification_code',
      desc: '',
      args: [],
    );
  }

  /// `Use Password`
  String get use_password {
    return Intl.message(
      'Use Password',
      name: 'use_password',
      desc: '',
      args: [],
    );
  }

  /// `OR`
  String get or {
    return Intl.message('OR', name: 'or', desc: '', args: []);
  }

  /// `Registration failed: {resultMessage}`
  String registration_failed(Object resultMessage) {
    return Intl.message(
      'Registration failed: $resultMessage',
      name: 'registration_failed',
      desc: '',
      args: [resultMessage],
    );
  }

  /// `Password is empty!`
  String get password_is_empty {
    return Intl.message(
      'Password is empty!',
      name: 'password_is_empty',
      desc: '',
      args: [],
    );
  }

  /// `Email is empty!`
  String get email_is_empty {
    return Intl.message(
      'Email is empty!',
      name: 'email_is_empty',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Backup-Verification Code`
  String get backup_verification_code {
    return Intl.message(
      'Backup-Verification Code',
      name: 'backup_verification_code',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Min Entropy: {minEntropy}`
  String min_entropy(Object minEntropy) {
    return Intl.message(
      'Min Entropy: $minEntropy',
      name: 'min_entropy',
      desc: '',
      args: [minEntropy],
    );
  }

  /// `Entropy: {entropy} (Rough estimate)`
  String entropy_rough_estimate(Object entropy) {
    return Intl.message(
      'Entropy: $entropy (Rough estimate)',
      name: 'entropy_rough_estimate',
      desc: '',
      args: [entropy],
    );
  }

  /// `Display Name`
  String get display_name {
    return Intl.message(
      'Display Name',
      name: 'display_name',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to logout from ${device.formattedInfo()}?`
  String get logout_confirmation_device {
    return Intl.message(
      'Are you sure you want to logout from \${device.formattedInfo()}?',
      name: 'logout_confirmation_device',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to logout from ${device.formattedInfo()}?`
  String get logout_confirmation_all_devices {
    return Intl.message(
      'Are you sure you want to logout from \${device.formattedInfo()}?',
      name: 'logout_confirmation_all_devices',
      desc: '',
      args: [],
    );
  }

  /// `Unknown size`
  String get unknown_size {
    return Intl.message(
      'Unknown size',
      name: 'unknown_size',
      desc: '',
      args: [],
    );
  }

  /// `Sign out`
  String get sign_out {
    return Intl.message('Sign out', name: 'sign_out', desc: '', args: []);
  }

  /// `No linked devices`
  String get no_linked_devices {
    return Intl.message(
      'No linked devices',
      name: 'no_linked_devices',
      desc: '',
      args: [],
    );
  }

  /// `Link new device`
  String get link_new_device {
    return Intl.message(
      'Link new device',
      name: 'link_new_device',
      desc: '',
      args: [],
    );
  }

  /// `Many bug fixes!`
  String get many_bug_fixes {
    return Intl.message(
      'Many bug fixes!',
      name: 'many_bug_fixes',
      desc: '',
      args: [],
    );
  }

  /// `Ability to form group chats!`
  String get ability_to_form_group_chats {
    return Intl.message(
      'Ability to form group chats!',
      name: 'ability_to_form_group_chats',
      desc: '',
      args: [],
    );
  }

  /// `Significant optimizations regarding data usage!`
  String get optimizations_on_data_usage {
    return Intl.message(
      'Significant optimizations regarding data usage!',
      name: 'optimizations_on_data_usage',
      desc: '',
      args: [],
    );
  }

  /// `Custom`
  String get custom {
    return Intl.message('Custom', name: 'custom', desc: '', args: []);
  }

  /// `Gradient`
  String get gradient {
    return Intl.message('Gradient', name: 'gradient', desc: '', args: []);
  }

  /// `Abstract`
  String get abstract {
    return Intl.message('Abstract', name: 'abstract', desc: '', args: []);
  }

  /// `Default/Monotone`
  String get default_monotone {
    return Intl.message(
      'Default/Monotone',
      name: 'default_monotone',
      desc: '',
      args: [],
    );
  }

  /// `Connection Refused!`
  String get connection_refused {
    return Intl.message(
      'Connection Refused!',
      name: 'connection_refused',
      desc: '',
      args: [],
    );
  }

  /// `Connection Reset!`
  String get connection_reset {
    return Intl.message(
      'Connection Reset!',
      name: 'connection_reset',
      desc: '',
      args: [],
    );
  }

  /// `Could not verify server certificate`
  String get could_not_verify_server_certificate {
    return Intl.message(
      'Could not verify server certificate',
      name: 'could_not_verify_server_certificate',
      desc: '',
      args: [],
    );
  }

  /// `Privacy`
  String get privacy {
    return Intl.message('Privacy', name: 'privacy', desc: '', args: []);
  }

  /// `New Group`
  String get new_group {
    return Intl.message('New Group', name: 'new_group', desc: '', args: []);
  }

  /// `Add User`
  String get add_user {
    return Intl.message('Add User', name: 'add_user', desc: '', args: []);
  }

  /// `Choose Friends`
  String get choose_friends {
    return Intl.message(
      'Choose Friends',
      name: 'choose_friends',
      desc: '',
      args: [],
    );
  }

  /// `Chat Theme`
  String get chat_theme {
    return Intl.message('Chat Theme', name: 'chat_theme', desc: '', args: []);
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
