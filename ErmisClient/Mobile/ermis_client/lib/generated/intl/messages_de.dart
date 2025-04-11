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

// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
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
  String get localeName => 'de';

  static String m0(deviceInfo) =>
      "Sind Sie sicher, dass Sie sich von ${deviceInfo} abmelden möchten?";

  static String m1(username) => "Chat mit ${username}";

  static String m2(entropy) => "Entropie: ${entropy} (Grobe Schätzung)";

  static String m3(fileName) => "Datei empfangen ${fileName}";

  static String m4(username) => "Nachricht von ${username}";

  static String m5(minEntropy) => "Minimale Entropie: ${minEntropy}";

  static String m6(resultMessage) =>
      "Registrierung fehlgeschlagen: ${resultMessage}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accept": MessageLookupByLibrary.simpleMessage("Akzeptieren"),
    "account": MessageLookupByLibrary.simpleMessage("Konto"),
    "account_add": MessageLookupByLibrary.simpleMessage(
      "Neues Konto hinzufügen",
    ),
    "account_confirm_proceed": MessageLookupByLibrary.simpleMessage(
      "Sind Sie sicher, dass Sie fortfahren möchten?",
    ),
    "account_delete": MessageLookupByLibrary.simpleMessage("Konto löschen"),
    "account_delete_bullet1": MessageLookupByLibrary.simpleMessage(
      "Ihr Konto wird dauerhaft gelöscht und kann nicht wiederhergestellt werden.",
    ),
    "account_delete_bullet2": MessageLookupByLibrary.simpleMessage(
      "Ihr Nachrichtenverlauf wird gelöscht.",
    ),
    "account_delete_bullet3": MessageLookupByLibrary.simpleMessage(
      "Alle Ihre Chats werden gelöscht.",
    ),
    "account_delete_confirmation": MessageLookupByLibrary.simpleMessage(
      "Das Löschen dieses Kontos wird Folgendes bewirken:",
    ),
    "account_delete_error": MessageLookupByLibrary.simpleMessage(
      "Fehler beim Löschen Ihres Kontos!",
    ),
    "account_delete_my": MessageLookupByLibrary.simpleMessage(
      "Mein Konto löschen",
    ),
    "account_settings": MessageLookupByLibrary.simpleMessage(
      "Kontoeinstellungen",
    ),
    "address_not_recognized": MessageLookupByLibrary.simpleMessage(
      "Adresse nicht erkannt!",
    ),
    "app_info": MessageLookupByLibrary.simpleMessage("App-Info"),
    "app_language": MessageLookupByLibrary.simpleMessage("App-Sprache"),
    "are_you_sure_you_want_to_logout_from": m0,
    "are_you_sure_you_want_to_logout_from_all_devices":
        MessageLookupByLibrary.simpleMessage(
          "Sind Sie sicher, dass Sie sich von allen Geräten abmelden möchten?",
        ),
    "attempting_delete_message": MessageLookupByLibrary.simpleMessage(
      "Versuche, Nachricht zu löschen",
    ),
    "authentication_stage_create_account": MessageLookupByLibrary.simpleMessage(
      "Konto erstellen",
    ),
    "authentication_stage_credentials_exchange":
        MessageLookupByLibrary.simpleMessage(
          "Austausch der Anmeldeinformationen",
        ),
    "authentication_stage_credentials_validation":
        MessageLookupByLibrary.simpleMessage(
          "Validierung der Anmeldeinformationen",
        ),
    "authentication_stage_login": MessageLookupByLibrary.simpleMessage(
      "Anmeldung",
    ),
    "backup_verification_code": MessageLookupByLibrary.simpleMessage(
      "Backup-Verifizierungscode",
    ),
    "backup_verification_code_regenerate_error":
        MessageLookupByLibrary.simpleMessage(
          "Beim Neugenerieren der Backup-Codes ist ein Fehler aufgetreten!",
        ),
    "backup_verification_code_regenerate_success":
        MessageLookupByLibrary.simpleMessage(
          "Backup-Verifizierungscodes erfolgreich neu generiert!",
        ),
    "camera": MessageLookupByLibrary.simpleMessage("Kamera"),
    "cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "change_password_error": MessageLookupByLibrary.simpleMessage(
      "Beim Ändern des Passworts ist ein Fehler aufgetreten!",
    ),
    "change_password_success": MessageLookupByLibrary.simpleMessage(
      "Passwort erfolgreich geändert!",
    ),
    "change_username_error": MessageLookupByLibrary.simpleMessage(
      "Beim Ändern des Benutzernamens ist ein Fehler aufgetreten!",
    ),
    "change_username_invalid": MessageLookupByLibrary.simpleMessage(
      "Die Anforderungen an den Benutzernamen sind nicht erfüllt!",
    ),
    "change_username_success": MessageLookupByLibrary.simpleMessage(
      "Benutzername erfolgreich geändert!",
    ),
    "chat_backdrop": MessageLookupByLibrary.simpleMessage("Chat-Hintergrund"),
    "chat_backdrop_choose_image": MessageLookupByLibrary.simpleMessage(
      "Bild auswählen",
    ),
    "chat_backdrop_color_pick": MessageLookupByLibrary.simpleMessage(
      "Wählen Sie eine Farbe!",
    ),
    "chat_backdrop_gradient_end_color": MessageLookupByLibrary.simpleMessage(
      "Endfarbe",
    ),
    "chat_backdrop_gradient_preview": MessageLookupByLibrary.simpleMessage(
      "Farbverlauf-Vorschau",
    ),
    "chat_backdrop_gradient_start_color": MessageLookupByLibrary.simpleMessage(
      "Startfarbe",
    ),
    "chat_backdrop_save_changes": MessageLookupByLibrary.simpleMessage(
      "Änderungen speichern",
    ),
    "chat_backdrop_select_gradient": MessageLookupByLibrary.simpleMessage(
      "Farbverlauf auswählen",
    ),
    "chat_backdrop_upload_coming_soon": MessageLookupByLibrary.simpleMessage(
      "Hochladen eigener Bilder kommt bald!",
    ),
    "chat_backdrop_upload_custom": MessageLookupByLibrary.simpleMessage(
      "Eigenes Bild hochladen",
    ),
    "chat_request_accept_error": MessageLookupByLibrary.simpleMessage(
      "Fehler beim Akzeptieren der Chat-Anfrage!",
    ),
    "chat_request_decline_error": MessageLookupByLibrary.simpleMessage(
      "Fehler beim Ablehnen der Chat-Anfrage!",
    ),
    "chat_session_delete_error": MessageLookupByLibrary.simpleMessage(
      "Fehler beim Löschen der Chat-Sitzung!",
    ),
    "chat_session_not_found": MessageLookupByLibrary.simpleMessage(
      "Die ausgewählte Chat-Sitzung existiert nicht. (Möglicherweise wurde sie vom anderen Nutzer gelöscht)",
    ),
    "chat_theme_settings": MessageLookupByLibrary.simpleMessage(
      "Chat-Design-Einstellungen",
    ),
    "chat_with": m1,
    "chats": MessageLookupByLibrary.simpleMessage("Chats"),
    "choose_option": MessageLookupByLibrary.simpleMessage("Wähle eine Option"),
    "client_id_must_be_a_number": MessageLookupByLibrary.simpleMessage(
      "Die Client-ID muss eine Zahl sein",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Schließen"),
    "command_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Befehl {} nicht implementiert!",
    ),
    "command_unknown": MessageLookupByLibrary.simpleMessage(
      "Befehl nicht bekannt!",
    ),
    "confirm_delete_message": MessageLookupByLibrary.simpleMessage(
      "Möchten Sie die Nachricht wirklich dauerhaft löschen?",
    ),
    "connect": MessageLookupByLibrary.simpleMessage("Verbinden"),
    "content_type_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Inhaltstyp nicht implementiert!",
    ),
    "content_type_unknown": MessageLookupByLibrary.simpleMessage(
      "Inhaltstyp nicht bekannt!",
    ),
    "create_account": MessageLookupByLibrary.simpleMessage("Konto erstellen"),
    "create_account_database_full": MessageLookupByLibrary.simpleMessage(
      "Maximale Datenbankkapazität erreicht! Leider konnte Ihre Anfrage nicht bearbeitet werden.",
    ),
    "create_account_email_exists": MessageLookupByLibrary.simpleMessage(
      "Die E-Mail wird bereits verwendet!",
    ),
    "create_account_error": MessageLookupByLibrary.simpleMessage(
      "Beim Erstellen Ihres Kontos ist ein Fehler aufgetreten!",
    ),
    "create_account_success": MessageLookupByLibrary.simpleMessage(
      "Konto erfolgreich erstellt!",
    ),
    "credential_validation_client_id_error":
        MessageLookupByLibrary.simpleMessage(
          "Konnte die Client-ID nicht generieren!",
        ),
    "credential_validation_email_exists": MessageLookupByLibrary.simpleMessage(
      "Die E-Mail wird bereits verwendet!",
    ),
    "credential_validation_email_invalid": MessageLookupByLibrary.simpleMessage(
      "Ungültige E-Mail-Adresse",
    ),
    "credential_validation_password_invalid":
        MessageLookupByLibrary.simpleMessage(
          "Die Anforderungen an das Passwort sind nicht erfüllt!",
        ),
    "credential_validation_success": MessageLookupByLibrary.simpleMessage(
      "Anmeldeinformationen erfolgreich ausgetauscht!",
    ),
    "credential_validation_username_invalid":
        MessageLookupByLibrary.simpleMessage(
          "Die Anforderungen an den Benutzernamen sind nicht erfüllt!",
        ),
    "decline": MessageLookupByLibrary.simpleMessage("Ablehnen"),
    "decompression_failed": MessageLookupByLibrary.simpleMessage(
      "Dekomprimierung fehlgeschlagen",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Löschen"),
    "delete_chat": MessageLookupByLibrary.simpleMessage("Chat löschen"),
    "delete_this_chat_question": MessageLookupByLibrary.simpleMessage(
      "Diesen Chat löschen?",
    ),
    "deleting_this_chat_will_permanently_delete_all_prior_messages":
        MessageLookupByLibrary.simpleMessage(
          "Das Löschen dieses Chats löscht dauerhaft alle vorherigen Nachrichten",
        ),
    "display_name": MessageLookupByLibrary.simpleMessage("Anzeigename"),
    "display_part_of_messages_in_notifications":
        MessageLookupByLibrary.simpleMessage(
          "Einen Teil der Nachricht in Benachrichtigungen anzeigen",
        ),
    "donate_to_ermis_project": MessageLookupByLibrary.simpleMessage(
      "Für das Ermis-Projekt spenden",
    ),
    "donate_to_hoster": MessageLookupByLibrary.simpleMessage(
      "An den Hoster spenden",
    ),
    "donations": MessageLookupByLibrary.simpleMessage("Spenden"),
    "downloaded_file": MessageLookupByLibrary.simpleMessage(
      "Datei heruntergeladen",
    ),
    "email": MessageLookupByLibrary.simpleMessage("E-Mail"),
    "email_address": MessageLookupByLibrary.simpleMessage("E-Mail-Adresse"),
    "email_is_empty": MessageLookupByLibrary.simpleMessage("E-Mail ist leer!"),
    "email_mismatch": MessageLookupByLibrary.simpleMessage(
      "Eingegebene E-Mail stimmt nicht mit der tatsächlichen E-Mail überein!",
    ),
    "enter_client_id": MessageLookupByLibrary.simpleMessage(
      "Client-ID eingeben",
    ),
    "enter_verification_code": MessageLookupByLibrary.simpleMessage(
      "Verifizierungscode eingeben",
    ),
    "enter_verification_code_sent_to_your_email":
        MessageLookupByLibrary.simpleMessage(
          "Verifizierungscode eingeben, der an Ihre E-Mail gesendet wurde",
        ),
    "entropy_rough_estimate": m2,
    "error_saving_file": MessageLookupByLibrary.simpleMessage(
      "Ein Fehler ist beim Speichern der Datei aufgetreten",
    ),
    "faq_contact_terms_privacy": MessageLookupByLibrary.simpleMessage(
      "FAQ, Kontakt, Nutzungsbedingungen und Datenschutzrichtlinie",
    ),
    "feature_audio_messages": MessageLookupByLibrary.simpleMessage(
      "Unterstützung für Sprachnachrichten",
    ),
    "feature_chat_themes": MessageLookupByLibrary.simpleMessage(
      "Neue Chat-Designs",
    ),
    "feature_encryption": MessageLookupByLibrary.simpleMessage(
      "Verbesserte Verschlüsselungsprotokolle",
    ),
    "feature_languages": MessageLookupByLibrary.simpleMessage(
      "Mehrsprachige Unterstützung!",
    ),
    "feature_voice_calls": MessageLookupByLibrary.simpleMessage(
      "Sprachanrufe (Früher Zugriff)",
    ),
    "file_received": m3,
    "functionality_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Funktionalität noch nicht implementiert!",
    ),
    "gallery": MessageLookupByLibrary.simpleMessage("Galerie"),
    "got_it_button": MessageLookupByLibrary.simpleMessage("Verstanden!"),
    "help": MessageLookupByLibrary.simpleMessage("Hilfe"),
    "help_settings": MessageLookupByLibrary.simpleMessage(
      "Hilfe-Einstellungen",
    ),
    "incompatible_server_version_warning": MessageLookupByLibrary.simpleMessage(
      "Inkompatible Serverversion! Einige Dinge funktionieren möglicherweise nicht wie erwartet!",
    ),
    "license_capitalized": MessageLookupByLibrary.simpleMessage("Lizenz"),
    "license_crux": MessageLookupByLibrary.simpleMessage("Lizenz-Kern"),
    "link_new_device": MessageLookupByLibrary.simpleMessage(
      "Neues Gerät verknüpfen",
    ),
    "linked_devices": MessageLookupByLibrary.simpleMessage("Verknüpfte Geräte"),
    "linked_devices_logout_all": MessageLookupByLibrary.simpleMessage(
      "Von allen Geräten abmelden",
    ),
    "linked_devices_logout_all_confirm": MessageLookupByLibrary.simpleMessage(
      "Sind Sie sicher, dass Sie sich von allen Geräten abmelden möchten?",
    ),
    "linked_devices_logout_confirm": MessageLookupByLibrary.simpleMessage(
      "Sind Sie sicher, dass Sie sich von ",
    ),
    "login": MessageLookupByLibrary.simpleMessage("Anmelden"),
    "login_account_not_found": MessageLookupByLibrary.simpleMessage(
      "Das Konto existiert nicht!",
    ),
    "login_add_device_info": MessageLookupByLibrary.simpleMessage(
      "Geräteinformationen hinzufügen",
    ),
    "login_backup_code_incorrect": MessageLookupByLibrary.simpleMessage(
      "Falscher Backup-Code.",
    ),
    "login_email_incorrect": MessageLookupByLibrary.simpleMessage(
      "Falsche E-Mail!",
    ),
    "login_error": MessageLookupByLibrary.simpleMessage(
      "Beim Anmelden ist ein Fehler aufgetreten! Bitte kontaktieren Sie den Serveradministrator und informieren Sie ihn darüber, dass sein Server ausgefallen ist.",
    ),
    "login_fetch_requirements": MessageLookupByLibrary.simpleMessage(
      "Anforderungen abrufen",
    ),
    "login_password_incorrect": MessageLookupByLibrary.simpleMessage(
      "Falsches Passwort.",
    ),
    "login_success": MessageLookupByLibrary.simpleMessage(
      "Erfolgreich bei Ihrem Konto angemeldet!",
    ),
    "login_toggle_password": MessageLookupByLibrary.simpleMessage(
      "Passworttyp umschalten",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("abmelden"),
    "logout_capitalized": MessageLookupByLibrary.simpleMessage("Abmelden"),
    "logout_confirmation_all_devices": MessageLookupByLibrary.simpleMessage(
      "Sind Sie sicher, dass Sie sich von \${device.formattedInfo()} abmelden möchten?",
    ),
    "logout_confirmation_device": MessageLookupByLibrary.simpleMessage(
      "Sind Sie sicher, dass Sie sich von \${device.formattedInfo()} abmelden möchten?",
    ),
    "logout_from_all_devices": MessageLookupByLibrary.simpleMessage(
      "Von allen Geräten abmelden",
    ),
    "logout_from_this_device": MessageLookupByLibrary.simpleMessage(
      "Von diesem Gerät abmelden",
    ),
    "manage_storage": MessageLookupByLibrary.simpleMessage(
      "Speicher verwalten",
    ),
    "message_by": m4,
    "message_copied": MessageLookupByLibrary.simpleMessage(
      "Nachricht in die Zwischenablage kopiert",
    ),
    "message_deletion_unsuccessful": MessageLookupByLibrary.simpleMessage(
      "Nachricht löschen fehlgeschlagen",
    ),
    "message_group_call_tones": MessageLookupByLibrary.simpleMessage(
      "Nachrichten-, Gruppen- und Anruf-Töne",
    ),
    "message_length_exceeded": MessageLookupByLibrary.simpleMessage(
      "Nachrichtenlänge überschreitet die maximale Länge (%d Zeichen)",
    ),
    "message_type_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Nachrichtentyp nicht implementiert!",
    ),
    "message_type_unknown": MessageLookupByLibrary.simpleMessage(
      "Nachrichtentyp nicht erkannt!",
    ),
    "min_entropy": m5,
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "name_enter": MessageLookupByLibrary.simpleMessage(
      "Geben Sie Ihren Namen ein",
    ),
    "network_usage_auto_download": MessageLookupByLibrary.simpleMessage(
      "Netzwerknutzung, automatischer Download",
    ),
    "new_chat": MessageLookupByLibrary.simpleMessage("\'Neuer Chat\'"),
    "new_message": MessageLookupByLibrary.simpleMessage("Neue Nachricht!"),
    "no_chat_requests_available": MessageLookupByLibrary.simpleMessage(
      "Keine ausstehenden Chat-Anfragen",
    ),
    "no_chats_available_incompatible_server_version":
        MessageLookupByLibrary.simpleMessage(
          "Keine Chats verfügbar, inkompatible Serverversion",
        ),
    "no_conversations_available": MessageLookupByLibrary.simpleMessage(
      "Keine Konversationen verfügbar",
    ),
    "no_linked_devices": MessageLookupByLibrary.simpleMessage(
      "Keine verknüpften Geräte",
    ),
    "notification_enable": MessageLookupByLibrary.simpleMessage(
      "Benachrichtigungen aktivieren",
    ),
    "notification_preview_display_part": MessageLookupByLibrary.simpleMessage(
      "Einen Teil der Nachricht in Benachrichtigungen anzeigen",
    ),
    "notification_preview_show": MessageLookupByLibrary.simpleMessage(
      "Nachrichtenvorschau anzeigen",
    ),
    "notification_settings": MessageLookupByLibrary.simpleMessage(
      "Benachrichtigungseinstellungen",
    ),
    "notification_sound": MessageLookupByLibrary.simpleMessage(
      "Benachrichtigungston",
    ),
    "notification_sound_select": MessageLookupByLibrary.simpleMessage(
      "Benachrichtigungston auswählen",
    ),
    "notifications": MessageLookupByLibrary.simpleMessage("Benachrichtigungen"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "or": MessageLookupByLibrary.simpleMessage("ODER"),
    "other": MessageLookupByLibrary.simpleMessage("Sonstiges"),
    "other_settings": MessageLookupByLibrary.simpleMessage(
      "Weitere Einstellungen",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Passwort"),
    "password_is_empty": MessageLookupByLibrary.simpleMessage(
      "Passwort ist leer!",
    ),
    "password_validation_invalid": MessageLookupByLibrary.simpleMessage(
      "Die Anforderungen an das Passwort sind nicht erfüllt!",
    ),
    "password_validation_success": MessageLookupByLibrary.simpleMessage(
      "Passwort erfolgreich validiert!",
    ),
    "please_enter_the_verification_code": MessageLookupByLibrary.simpleMessage(
      "Bitte geben Sie den Verifizierungscode ein",
    ),
    "privacy_security_change_number": MessageLookupByLibrary.simpleMessage(
      "Datenschutz, Sicherheit, Nummer ändern",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("Profil"),
    "profile_about": MessageLookupByLibrary.simpleMessage("Über"),
    "profile_camera": MessageLookupByLibrary.simpleMessage("Kamera"),
    "profile_change_name_id": MessageLookupByLibrary.simpleMessage(
      "Profil, Name ändern, ID",
    ),
    "profile_gallery": MessageLookupByLibrary.simpleMessage("Galerie"),
    "profile_hey_there": MessageLookupByLibrary.simpleMessage("Hallo!"),
    "profile_id_copied": MessageLookupByLibrary.simpleMessage(
      "ID in die Zwischenablage kopiert",
    ),
    "profile_name": MessageLookupByLibrary.simpleMessage("Name"),
    "profile_name_enter": MessageLookupByLibrary.simpleMessage(
      "Geben Sie Ihren Namen ein",
    ),
    "profile_photo": MessageLookupByLibrary.simpleMessage("Profilbild"),
    "profile_photo_fetch_error": MessageLookupByLibrary.simpleMessage(
      "Fehler beim Abrufen des Profilbilds aus der Datenbank!",
    ),
    "profile_settings": MessageLookupByLibrary.simpleMessage(
      "Profileinstellungen",
    ),
    "registration_failed": m6,
    "requests": MessageLookupByLibrary.simpleMessage("Anfragen"),
    "resend_code": MessageLookupByLibrary.simpleMessage("Code erneut senden"),
    "save": MessageLookupByLibrary.simpleMessage("Speichern"),
    "search": MessageLookupByLibrary.simpleMessage("Suchen..."),
    "select_an_option": MessageLookupByLibrary.simpleMessage(
      "Option auswählen",
    ),
    "send_chat_request": MessageLookupByLibrary.simpleMessage(
      "Chat-Anfrage senden",
    ),
    "server_add": MessageLookupByLibrary.simpleMessage("Server hinzufügen"),
    "server_add_success": MessageLookupByLibrary.simpleMessage(
      "Server erfolgreich hinzugefügt!",
    ),
    "server_certificate_check": MessageLookupByLibrary.simpleMessage(
      "Zertifikat überprüfen",
    ),
    "server_source_code": MessageLookupByLibrary.simpleMessage(
      "Server-Quellcode",
    ),
    "server_url_choose": MessageLookupByLibrary.simpleMessage(
      "Server-URL auswählen",
    ),
    "server_url_enter": MessageLookupByLibrary.simpleMessage(
      "Server-URL eingeben",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Einstellungen"),
    "settings_save": MessageLookupByLibrary.simpleMessage(
      "Einstellungen speichern",
    ),
    "settings_saved": MessageLookupByLibrary.simpleMessage(
      "Einstellungen gespeichert",
    ),
    "sign_out": MessageLookupByLibrary.simpleMessage("Abmelden"),
    "source_code": MessageLookupByLibrary.simpleMessage("Quellcode"),
    "storage_data": MessageLookupByLibrary.simpleMessage("Speicher und Daten"),
    "submit": MessageLookupByLibrary.simpleMessage("Senden"),
    "temp_banned": MessageLookupByLibrary.simpleMessage(
      "Ruhe bewahren! Sie wurden vorübergehend für eine kurze Zeit vom Server ausgeschlossen.",
    ),
    "theme_dark": MessageLookupByLibrary.simpleMessage("Dunkelmodus"),
    "theme_light": MessageLookupByLibrary.simpleMessage("Hellmodus"),
    "theme_mode": MessageLookupByLibrary.simpleMessage("Designmodus"),
    "theme_system_default": MessageLookupByLibrary.simpleMessage(
      "Systemstandard",
    ),
    "theme_wallpapers_chat_history": MessageLookupByLibrary.simpleMessage(
      "Thema, Hintergrundbilder, Chatverlauf",
    ),
    "today": MessageLookupByLibrary.simpleMessage("Heute"),
    "type_message": MessageLookupByLibrary.simpleMessage(
      "Schreibe eine Nachricht...",
    ),
    "unknown_size": MessageLookupByLibrary.simpleMessage("Unbekannte Größe"),
    "use_backup_verification_code": MessageLookupByLibrary.simpleMessage(
      "Backup-Verifizierungscode verwenden",
    ),
    "use_password": MessageLookupByLibrary.simpleMessage("Passwort verwenden"),
    "username_same_as_old": MessageLookupByLibrary.simpleMessage(
      "Der Benutzername darf nicht mit dem alten Benutzernamen übereinstimmen!",
    ),
    "username_validation_invalid": MessageLookupByLibrary.simpleMessage(
      "Die Anforderungen an den Benutzernamen sind nicht erfüllt!",
    ),
    "username_validation_success": MessageLookupByLibrary.simpleMessage(
      "Benutzername erfolgreich validiert!",
    ),
    "verification": MessageLookupByLibrary.simpleMessage("Verifizierung"),
    "verification_attempts_exhausted": MessageLookupByLibrary.simpleMessage(
      "Anzahl der Versuche erschöpft!",
    ),
    "verification_code_incorrect": MessageLookupByLibrary.simpleMessage(
      "Falscher Code!",
    ),
    "verification_code_must_be_number": MessageLookupByLibrary.simpleMessage(
      "Der Verifizierungscode muss eine Zahl sein",
    ),
    "verification_email_invalid": MessageLookupByLibrary.simpleMessage(
      "Ungültige E-Mail-Adresse",
    ),
    "verification_resend_code": MessageLookupByLibrary.simpleMessage(
      "Code erneut senden",
    ),
    "verification_success": MessageLookupByLibrary.simpleMessage(
      "Verifizierung erfolgreich!",
    ),
    "version_capitalized": MessageLookupByLibrary.simpleMessage("Version"),
    "vibration": MessageLookupByLibrary.simpleMessage("Vibration"),
    "vibration_unavailable": MessageLookupByLibrary.simpleMessage(
      "Vibration ist auf diesem Gerät nicht verfügbar",
    ),
    "whats_new": MessageLookupByLibrary.simpleMessage("Was ist neu"),
    "whats_new_system_messages": MessageLookupByLibrary.simpleMessage(
      "Neue Systemnachrichten",
    ),
    "whats_new_title": MessageLookupByLibrary.simpleMessage(
      "Neue Funktionen in Hermis",
    ),
  };
}
