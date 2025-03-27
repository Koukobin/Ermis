// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(deviceInfo) =>
      "Are you sure you want to logout from ${deviceInfo}?";

  static String m1(username) => "Chat with ${username}";

  static String m2(entropy) => "Entropy: ${entropy} (Rough estimate)";

  static String m3(fileName) => "File received ${fileName}";

  static String m4(username) => "Message by ${username}";

  static String m5(minEntropy) => "Min Entropy: ${minEntropy}";

  static String m6(resultMessage) => "Registration failed: ${resultMessage}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accept": MessageLookupByLibrary.simpleMessage("Accept"),
    "account": MessageLookupByLibrary.simpleMessage("Account"),
    "account_add": MessageLookupByLibrary.simpleMessage("Add new account"),
    "account_confirm_proceed": MessageLookupByLibrary.simpleMessage(
      "Are you certain you want to proceed?",
    ),
    "account_delete": MessageLookupByLibrary.simpleMessage("Delete account"),
    "account_delete_bullet1": MessageLookupByLibrary.simpleMessage(
      "Delete your account with no way to recover",
    ),
    "account_delete_bullet2": MessageLookupByLibrary.simpleMessage(
      "Erase your message history",
    ),
    "account_delete_bullet3": MessageLookupByLibrary.simpleMessage(
      "Delete all your chats",
    ),
    "account_delete_confirmation": MessageLookupByLibrary.simpleMessage(
      "Deleting this account will:",
    ),
    "account_delete_error": MessageLookupByLibrary.simpleMessage(
      "An error occured while trying to delete your account!",
    ),
    "account_delete_my": MessageLookupByLibrary.simpleMessage(
      "Delete My Account",
    ),
    "account_settings": MessageLookupByLibrary.simpleMessage(
      "Account Settings",
    ),
    "address_not_recognized": MessageLookupByLibrary.simpleMessage(
      "Address not recognized!",
    ),
    "app_info": MessageLookupByLibrary.simpleMessage("App Info"),
    "app_language": MessageLookupByLibrary.simpleMessage("App language"),
    "are_you_sure_you_want_to_logout_from": m0,
    "are_you_sure_you_want_to_logout_from_all_devices":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you would like to logout from all devices?",
        ),
    "attempting_delete_message": MessageLookupByLibrary.simpleMessage(
      "Attempting to delete message",
    ),
    "authentication_stage_create_account": MessageLookupByLibrary.simpleMessage(
      "Create account",
    ),
    "authentication_stage_credentials_exchange":
        MessageLookupByLibrary.simpleMessage("Credentials exchange"),
    "authentication_stage_credentials_validation":
        MessageLookupByLibrary.simpleMessage("Credentials validation"),
    "authentication_stage_login": MessageLookupByLibrary.simpleMessage("Login"),
    "backup_verification_code": MessageLookupByLibrary.simpleMessage(
      "Backup-Verification Code",
    ),
    "backup_verification_code_regenerate_error":
        MessageLookupByLibrary.simpleMessage(
          "There was an error while trying to change username!",
        ),
    "backup_verification_code_regenerate_success":
        MessageLookupByLibrary.simpleMessage(
          "Successfully regenerated backup verification codes!",
        ),
    "camera": MessageLookupByLibrary.simpleMessage("Camera"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "change_password_error": MessageLookupByLibrary.simpleMessage(
      "There was an error while trying to change password!",
    ),
    "change_password_success": MessageLookupByLibrary.simpleMessage(
      "Successfully changed password!",
    ),
    "change_username_error": MessageLookupByLibrary.simpleMessage(
      "There was an error while trying to change username!",
    ),
    "change_username_invalid": MessageLookupByLibrary.simpleMessage(
      "Username requirements not met",
    ),
    "change_username_success": MessageLookupByLibrary.simpleMessage(
      "Successfully changed username!",
    ),
    "chat_backdrop": MessageLookupByLibrary.simpleMessage("Chat Backdrop"),
    "chat_backdrop_choose_image": MessageLookupByLibrary.simpleMessage(
      "Choose Image",
    ),
    "chat_backdrop_color_pick": MessageLookupByLibrary.simpleMessage(
      "Pick a color!",
    ),
    "chat_backdrop_gradient_end_color": MessageLookupByLibrary.simpleMessage(
      "End Color",
    ),
    "chat_backdrop_gradient_preview": MessageLookupByLibrary.simpleMessage(
      "Gradient Preview",
    ),
    "chat_backdrop_gradient_start_color": MessageLookupByLibrary.simpleMessage(
      "Start Color",
    ),
    "chat_backdrop_save_changes": MessageLookupByLibrary.simpleMessage(
      "Save Changes",
    ),
    "chat_backdrop_select_gradient": MessageLookupByLibrary.simpleMessage(
      "Select Gradient Colors",
    ),
    "chat_backdrop_upload_coming_soon": MessageLookupByLibrary.simpleMessage(
      "Custom image upload coming soon!",
    ),
    "chat_backdrop_upload_custom": MessageLookupByLibrary.simpleMessage(
      "Upload Custom Image",
    ),
    "chat_request_accept_error": MessageLookupByLibrary.simpleMessage(
      "Something went wrong while trying accept chat request!",
    ),
    "chat_request_decline_error": MessageLookupByLibrary.simpleMessage(
      "Something went wrong while trying to decline chat request!",
    ),
    "chat_session_delete_error": MessageLookupByLibrary.simpleMessage(
      "Something went wrong while trying delete chat session!",
    ),
    "chat_session_not_found": MessageLookupByLibrary.simpleMessage(
      "Chat session selected doesn\'t exist. (May have been deleted by the other user)",
    ),
    "chat_theme_settings": MessageLookupByLibrary.simpleMessage(
      "Chat Theme Settings",
    ),
    "chat_with": m1,
    "chats": MessageLookupByLibrary.simpleMessage("Chats"),
    "choose_option": MessageLookupByLibrary.simpleMessage("Choose an option"),
    "client_id_must_be_a_number": MessageLookupByLibrary.simpleMessage(
      "Client id must be a number",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "command_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Command {} not implemented!",
    ),
    "command_not_recognized": MessageLookupByLibrary.simpleMessage(
      "The command you entered was not recognized by the server.",
    ),
    "command_unknown": MessageLookupByLibrary.simpleMessage(
      "Command not known!",
    ),
    "confirm_delete_message": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to permanently delete message?",
    ),
    "connect": MessageLookupByLibrary.simpleMessage("Connect"),
    "content_type_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Content type not implemented!",
    ),
    "content_type_unknown": MessageLookupByLibrary.simpleMessage(
      "Content type not known!",
    ),
    "create_account": MessageLookupByLibrary.simpleMessage("Create Account"),
    "create_account_database_full": MessageLookupByLibrary.simpleMessage(
      "Database maximum capacity reached! Unfortunately, your request could not be processed.",
    ),
    "create_account_email_exists": MessageLookupByLibrary.simpleMessage(
      "Email is already used!",
    ),
    "create_account_error": MessageLookupByLibrary.simpleMessage(
      "An error occurred while creating your account!",
    ),
    "create_account_success": MessageLookupByLibrary.simpleMessage(
      "Account successfully created!",
    ),
    "credential_validation_client_id_error":
        MessageLookupByLibrary.simpleMessage("Unable to generate client id!"),
    "credential_validation_email_exists": MessageLookupByLibrary.simpleMessage(
      "Email is already used!",
    ),
    "credential_validation_email_invalid": MessageLookupByLibrary.simpleMessage(
      "Invalid email address",
    ),
    "credential_validation_password_invalid":
        MessageLookupByLibrary.simpleMessage("Password requirements not met!"),
    "credential_validation_success": MessageLookupByLibrary.simpleMessage(
      "Successfully exchanged credentials!",
    ),
    "credential_validation_username_invalid":
        MessageLookupByLibrary.simpleMessage("Username requirements not met!"),
    "decline": MessageLookupByLibrary.simpleMessage("Decline"),
    "decompression_failed": MessageLookupByLibrary.simpleMessage(
      "Decompression failed",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "delete_chat": MessageLookupByLibrary.simpleMessage("Delete chat"),
    "delete_this_chat_question": MessageLookupByLibrary.simpleMessage(
      "Delete this chat?",
    ),
    "deleting_this_chat_will_permanently_delete_all_prior_messages":
        MessageLookupByLibrary.simpleMessage(
          "Deleting this chat will permanently delete all prior messages",
        ),
    "display_name": MessageLookupByLibrary.simpleMessage("Display Name"),
    "display_part_of_messages_in_notifications":
        MessageLookupByLibrary.simpleMessage(
          "Display part of the message in notifications",
        ),
    "documents": MessageLookupByLibrary.simpleMessage("Documents"),
    "donate_to_ermis_project": MessageLookupByLibrary.simpleMessage(
      "Donate To The Ermis Project",
    ),
    "donate_to_hoster": MessageLookupByLibrary.simpleMessage(
      "Donate to Hoster",
    ),
    "donations": MessageLookupByLibrary.simpleMessage("Donations"),
    "downloaded_file": MessageLookupByLibrary.simpleMessage("Downloaded file"),
    "email": MessageLookupByLibrary.simpleMessage("Email"),
    "email_address": MessageLookupByLibrary.simpleMessage("Email address"),
    "email_is_empty": MessageLookupByLibrary.simpleMessage("Email is empty!"),
    "email_mismatch": MessageLookupByLibrary.simpleMessage(
      "Email entered does not match actual email!",
    ),
    "enter_client_id": MessageLookupByLibrary.simpleMessage("Enter client id"),
    "enter_verification_code": MessageLookupByLibrary.simpleMessage(
      "Enter Verification Code",
    ),
    "enter_verification_code_sent_to_your_email":
        MessageLookupByLibrary.simpleMessage(
          "Enter verification code sent to your email",
        ),
    "entropy_rough_estimate": m2,
    "error_occurred_while_trying_to_fetch_file_from_database":
        MessageLookupByLibrary.simpleMessage(
          "An error occurred while attempting to retrieve the file from the database.",
        ),
    "error_occurred_while_trying_to_send_chat_request":
        MessageLookupByLibrary.simpleMessage(
          "An error occurred while attempting to send the chat request.",
        ),
    "error_saving_file": MessageLookupByLibrary.simpleMessage(
      "An error occurred while trying to save the file",
    ),
    "faq_contact_terms_privacy": MessageLookupByLibrary.simpleMessage(
      "FAQ, contact us, terms and privacy policy",
    ),
    "feature_audio_messages": MessageLookupByLibrary.simpleMessage(
      "Audio message support",
    ),
    "feature_chat_themes": MessageLookupByLibrary.simpleMessage(
      "New chat themes",
    ),
    "feature_encryption": MessageLookupByLibrary.simpleMessage(
      "Enhanced encryption protocols",
    ),
    "feature_languages": MessageLookupByLibrary.simpleMessage(
      "Multi-language support!",
    ),
    "feature_voice_calls": MessageLookupByLibrary.simpleMessage(
      "Voice calls (Early Access)",
    ),
    "file_received": m3,
    "functionality_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Functionality not implemented yet!",
    ),
    "gallery": MessageLookupByLibrary.simpleMessage("Gallery"),
    "got_it_button": MessageLookupByLibrary.simpleMessage("Got it!"),
    "help": MessageLookupByLibrary.simpleMessage("Help"),
    "help_settings": MessageLookupByLibrary.simpleMessage("Help Settings"),
    "incompatible_server_version_warning": MessageLookupByLibrary.simpleMessage(
      "Incompatible server version! Some things many not work as expected!",
    ),
    "license_capitalized": MessageLookupByLibrary.simpleMessage("Licence"),
    "license_crux": MessageLookupByLibrary.simpleMessage("License crux"),
    "link_new_device": MessageLookupByLibrary.simpleMessage("Link new device"),
    "linked_devices": MessageLookupByLibrary.simpleMessage("Linked Devices"),
    "linked_devices_logout_all": MessageLookupByLibrary.simpleMessage(
      "Logout From All Devices",
    ),
    "linked_devices_logout_all_confirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you would like to logout from all devices?",
    ),
    "linked_devices_logout_confirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to logout from ",
    ),
    "login": MessageLookupByLibrary.simpleMessage("Login"),
    "login_account_not_found": MessageLookupByLibrary.simpleMessage(
      "Account doesn\'t exist!",
    ),
    "login_add_device_info": MessageLookupByLibrary.simpleMessage(
      "Add device info",
    ),
    "login_backup_code_incorrect": MessageLookupByLibrary.simpleMessage(
      "Incorrect backup verification code.",
    ),
    "login_email_incorrect": MessageLookupByLibrary.simpleMessage(
      "Incorrect email!",
    ),
    "login_error": MessageLookupByLibrary.simpleMessage(
      "An error occurred while logging into your account! Please contact the server administrator and let them know that their server is broken.",
    ),
    "login_fetch_requirements": MessageLookupByLibrary.simpleMessage(
      "Fetch requirements",
    ),
    "login_password_incorrect": MessageLookupByLibrary.simpleMessage(
      "Incorrect password.",
    ),
    "login_success": MessageLookupByLibrary.simpleMessage(
      "Successfully logged into your account!",
    ),
    "login_toggle_password": MessageLookupByLibrary.simpleMessage(
      "Toggle password type",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("logout"),
    "logout_capitalized": MessageLookupByLibrary.simpleMessage("Logout"),
    "logout_confirmation_all_devices": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to logout from \${device.formattedInfo()}?",
    ),
    "logout_confirmation_device": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to logout from \${device.formattedInfo()}?",
    ),
    "logout_from_all_devices": MessageLookupByLibrary.simpleMessage(
      "Logout From All Devices",
    ),
    "logout_from_this_device": MessageLookupByLibrary.simpleMessage(
      "Logout from this device",
    ),
    "manage_storage": MessageLookupByLibrary.simpleMessage("Manage Storage"),
    "message_by": m4,
    "message_copied": MessageLookupByLibrary.simpleMessage(
      "Message copied to clipboard",
    ),
    "message_deletion_unsuccessful": MessageLookupByLibrary.simpleMessage(
      "Message deletion was unsuccessful",
    ),
    "message_group_call_tones": MessageLookupByLibrary.simpleMessage(
      "Message, group, and call tones",
    ),
    "message_length_exceeded": MessageLookupByLibrary.simpleMessage(
      "Message length exceeds maximum length {|characters}",
    ),
    "message_type_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Message type not implemented!",
    ),
    "message_type_not_recognized": MessageLookupByLibrary.simpleMessage(
      "The message type received was not recognized.",
    ),
    "message_type_unknown": MessageLookupByLibrary.simpleMessage(
      "Message type not recognized!",
    ),
    "min_entropy": m5,
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "name_enter": MessageLookupByLibrary.simpleMessage("Enter your name"),
    "network_usage_auto_download": MessageLookupByLibrary.simpleMessage(
      "Network usage, auto-download",
    ),
    "new_chat": MessageLookupByLibrary.simpleMessage("\'New chat\'"),
    "new_message": MessageLookupByLibrary.simpleMessage("New message!"),
    "no_chat_requests_available": MessageLookupByLibrary.simpleMessage(
      "No pending chat requests",
    ),
    "no_chats_available_incompatible_server_version":
        MessageLookupByLibrary.simpleMessage(
          "No chats available, incompatible server version",
        ),
    "no_conversations_available": MessageLookupByLibrary.simpleMessage(
      "No conversations available",
    ),
    "no_linked_devices": MessageLookupByLibrary.simpleMessage(
      "No linked devices",
    ),
    "notification_enable": MessageLookupByLibrary.simpleMessage(
      "Enable Notifications",
    ),
    "notification_preview_display_part": MessageLookupByLibrary.simpleMessage(
      "Display part of the message in notifications",
    ),
    "notification_preview_show": MessageLookupByLibrary.simpleMessage(
      "Show Message Previews",
    ),
    "notification_settings": MessageLookupByLibrary.simpleMessage(
      "Notification Settings",
    ),
    "notification_sound": MessageLookupByLibrary.simpleMessage(
      "Notification Sound",
    ),
    "notification_sound_select": MessageLookupByLibrary.simpleMessage(
      "Select Notification Sound",
    ),
    "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "or": MessageLookupByLibrary.simpleMessage("OR"),
    "other": MessageLookupByLibrary.simpleMessage("Other"),
    "other_settings": MessageLookupByLibrary.simpleMessage("Other Settings"),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "password_is_empty": MessageLookupByLibrary.simpleMessage(
      "Password is empty!",
    ),
    "password_validation_invalid": MessageLookupByLibrary.simpleMessage(
      "Password requirements not met!",
    ),
    "password_validation_success": MessageLookupByLibrary.simpleMessage(
      "Successfully validated password!",
    ),
    "please_enter_the_verification_code": MessageLookupByLibrary.simpleMessage(
      "Please enter the verification code",
    ),
    "privacy_security_change_number": MessageLookupByLibrary.simpleMessage(
      "Privacy, security, change number",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "profile_about": MessageLookupByLibrary.simpleMessage("About"),
    "profile_camera": MessageLookupByLibrary.simpleMessage("Camera"),
    "profile_change_name_id": MessageLookupByLibrary.simpleMessage(
      "Profile, change name, ID",
    ),
    "profile_gallery": MessageLookupByLibrary.simpleMessage("Gallery"),
    "profile_hey_there": MessageLookupByLibrary.simpleMessage("Hey there!"),
    "profile_id_copied": MessageLookupByLibrary.simpleMessage(
      "ID copied to clipboard",
    ),
    "profile_name": MessageLookupByLibrary.simpleMessage("Name"),
    "profile_name_enter": MessageLookupByLibrary.simpleMessage(
      "Enter you name",
    ),
    "profile_photo": MessageLookupByLibrary.simpleMessage("Profile Photo"),
    "profile_photo_fetch_error": MessageLookupByLibrary.simpleMessage(
      "An error occured while trying to fetch profile photo from database!",
    ),
    "profile_settings": MessageLookupByLibrary.simpleMessage(
      "Profile Settings",
    ),
    "registration_failed": m6,
    "requests": MessageLookupByLibrary.simpleMessage("Requests"),
    "resend_code": MessageLookupByLibrary.simpleMessage("Resend Code"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "search": MessageLookupByLibrary.simpleMessage("Search..."),
    "select_an_option": MessageLookupByLibrary.simpleMessage(
      "Select an option",
    ),
    "send_chat_request": MessageLookupByLibrary.simpleMessage(
      "Send Chat Request",
    ),
    "server_add": MessageLookupByLibrary.simpleMessage("Add Server"),
    "server_add_success": MessageLookupByLibrary.simpleMessage(
      "Server added successfully!",
    ),
    "server_certificate_check": MessageLookupByLibrary.simpleMessage(
      "Check certificate",
    ),
    "server_source_code": MessageLookupByLibrary.simpleMessage(
      "Server Source Code",
    ),
    "server_url_choose": MessageLookupByLibrary.simpleMessage(
      "Choose server URL",
    ),
    "server_url_enter": MessageLookupByLibrary.simpleMessage(
      "Enter Server URL",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "settings_save": MessageLookupByLibrary.simpleMessage("Save Settings"),
    "settings_saved": MessageLookupByLibrary.simpleMessage("Settings saved"),
    "sign_out": MessageLookupByLibrary.simpleMessage("Sign out"),
    "source_code": MessageLookupByLibrary.simpleMessage("Source Code"),
    "storage_data": MessageLookupByLibrary.simpleMessage("Storage and Data"),
    "submit": MessageLookupByLibrary.simpleMessage("Submit"),
    "temp_banned": MessageLookupByLibrary.simpleMessage(
      "Slow your horses there! You\'ve been temporarily banned from interacting with the server for a short time interval.",
    ),
    "theme_dark": MessageLookupByLibrary.simpleMessage("Dark Mode"),
    "theme_light": MessageLookupByLibrary.simpleMessage("Light Mode"),
    "theme_mode": MessageLookupByLibrary.simpleMessage("Theme Mode"),
    "theme_system_default": MessageLookupByLibrary.simpleMessage(
      "System Default",
    ),
    "theme_wallpapers_chat_history": MessageLookupByLibrary.simpleMessage(
      "Theme, wallpapers, chat history",
    ),
    "today": MessageLookupByLibrary.simpleMessage("Today"),
    "too_many_requests_made": MessageLookupByLibrary.simpleMessage(
      "Slow your horses. You have been temporarily banned.",
    ),
    "type_message": MessageLookupByLibrary.simpleMessage("Type a message..."),
    "unknown_size": MessageLookupByLibrary.simpleMessage("Unknown size"),
    "use_backup_verification_code": MessageLookupByLibrary.simpleMessage(
      "Use Backup-Verification Code",
    ),
    "use_password": MessageLookupByLibrary.simpleMessage("Use Password"),
    "username_same_as_old": MessageLookupByLibrary.simpleMessage(
      "Username cannot be the same as old username!",
    ),
    "username_validation_invalid": MessageLookupByLibrary.simpleMessage(
      "Username requirements not met!",
    ),
    "username_validation_success": MessageLookupByLibrary.simpleMessage(
      "Successfully validated username!",
    ),
    "verification": MessageLookupByLibrary.simpleMessage("Verification"),
    "verification_attempts_exhausted": MessageLookupByLibrary.simpleMessage(
      "Run out of attempts!",
    ),
    "verification_code_incorrect": MessageLookupByLibrary.simpleMessage(
      "Incorrect code!",
    ),
    "verification_code_must_be_number": MessageLookupByLibrary.simpleMessage(
      "Verification code must be number",
    ),
    "verification_email_invalid": MessageLookupByLibrary.simpleMessage(
      "Invalid email address",
    ),
    "verification_resend_code": MessageLookupByLibrary.simpleMessage(
      "Resend code",
    ),
    "verification_success": MessageLookupByLibrary.simpleMessage(
      "Successfully verified!",
    ),
    "version_capitalized": MessageLookupByLibrary.simpleMessage("Version"),
    "vibration": MessageLookupByLibrary.simpleMessage("Vibration"),
    "vibration_unavailable": MessageLookupByLibrary.simpleMessage(
      "Vibration is not available on this device",
    ),
    "whats_new": MessageLookupByLibrary.simpleMessage("What\'s New"),
    "whats_new_system_messages": MessageLookupByLibrary.simpleMessage(
      "New System Messages",
    ),
    "whats_new_title": MessageLookupByLibrary.simpleMessage(
      "New Features in Hermis",
    ),
  };
}
