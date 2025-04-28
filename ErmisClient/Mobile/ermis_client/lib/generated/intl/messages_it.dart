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
// This is a library that provides messages for a it locale. All the
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
  String get localeName => 'it';

  static String m0(deviceInfo) =>
      "Sei sicuro di voler disconnetterti da ${deviceInfo}?";

  static String m1(username) => "Chat con ${username}";

  static String m2(entropy) => "Entropia: ${entropy} (Stima approssimativa)";

  static String m3(fileName) => "File ricevuto ${fileName}";

  static String m4(username) => "Messaggio da ${username}";

  static String m5(minEntropy) => "Entropia minima: ${minEntropy}";

  static String m6(resultMessage) => "Registrazione fallita: ${resultMessage}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "abstract": MessageLookupByLibrary.simpleMessage("抽象"),
    "accept": MessageLookupByLibrary.simpleMessage("Accetta"),
    "account": MessageLookupByLibrary.simpleMessage("Account"),
    "account_add": MessageLookupByLibrary.simpleMessage(
      "Aggiungi nuovo account",
    ),
    "account_confirm_proceed": MessageLookupByLibrary.simpleMessage(
      "Sei sicuro di voler procedere?",
    ),
    "account_delete": MessageLookupByLibrary.simpleMessage("Elimina account"),
    "account_delete_bullet1": MessageLookupByLibrary.simpleMessage(
      "Laccount verrà eliminato definitivamente senza possibilità di recupero",
    ),
    "account_delete_bullet2": MessageLookupByLibrary.simpleMessage(
      "La cronologia dei messaggi verrà cancellata",
    ),
    "account_delete_bullet3": MessageLookupByLibrary.simpleMessage(
      "Tutte le chat verranno eliminate",
    ),
    "account_delete_confirmation": MessageLookupByLibrary.simpleMessage(
      "Eliminando questo account:",
    ),
    "account_delete_error": MessageLookupByLibrary.simpleMessage(
      "Si è verificato un errore durante leliminazione dellaccount!",
    ),
    "account_delete_my": MessageLookupByLibrary.simpleMessage(
      "Elimina il mio account",
    ),
    "account_settings": MessageLookupByLibrary.simpleMessage(
      "Impostazioni account",
    ),
    "add_user": MessageLookupByLibrary.simpleMessage("ユーザーを追加"),
    "address_not_recognized": MessageLookupByLibrary.simpleMessage(
      "Indirizzo non riconosciuto!",
    ),
    "app_info": MessageLookupByLibrary.simpleMessage("Informazioni sullapp"),
    "app_language": MessageLookupByLibrary.simpleMessage("Lingua dellapp"),
    "are_you_sure_you_want_to_logout_from": m0,
    "are_you_sure_you_want_to_logout_from_all_devices":
        MessageLookupByLibrary.simpleMessage(
          "Sei sicuro di voler uscire da tutti i dispositivi?",
        ),
    "attempting_delete_message": MessageLookupByLibrary.simpleMessage(
      "Tentativo di eliminazione del messaggio",
    ),
    "authentication_stage_create_account": MessageLookupByLibrary.simpleMessage(
      "Creazione account",
    ),
    "authentication_stage_credentials_exchange":
        MessageLookupByLibrary.simpleMessage("Scambio credenziali"),
    "authentication_stage_credentials_validation":
        MessageLookupByLibrary.simpleMessage("Validazione delle credenziali"),
    "authentication_stage_login": MessageLookupByLibrary.simpleMessage(
      "Accesso",
    ),
    "backup_verification_code": MessageLookupByLibrary.simpleMessage(
      "Codice di verifica di backup",
    ),
    "backup_verification_code_regenerate_error":
        MessageLookupByLibrary.simpleMessage(
          "Si è verificato un errore durante il cambio del nome utente!",
        ),
    "backup_verification_code_regenerate_success":
        MessageLookupByLibrary.simpleMessage(
          "Codici di verifica di backup rigenerati con successo!",
        ),
    "camera": MessageLookupByLibrary.simpleMessage("Fotocamera"),
    "cancel": MessageLookupByLibrary.simpleMessage("Annulla"),
    "change_password_error": MessageLookupByLibrary.simpleMessage(
      "Si è verificato un errore durante il cambio della password!",
    ),
    "change_password_success": MessageLookupByLibrary.simpleMessage(
      "Password cambiata con successo!",
    ),
    "change_username_error": MessageLookupByLibrary.simpleMessage(
      "Si è verificato un errore durante il cambio del nome utente!",
    ),
    "change_username_invalid": MessageLookupByLibrary.simpleMessage(
      "I requisiti del nome utente non sono soddisfatti",
    ),
    "change_username_success": MessageLookupByLibrary.simpleMessage(
      "Nome utente cambiato con successo!",
    ),
    "chat_backdrop": MessageLookupByLibrary.simpleMessage("Sfondo chat"),
    "chat_backdrop_choose_image": MessageLookupByLibrary.simpleMessage(
      "Scegli immagine",
    ),
    "chat_backdrop_color_pick": MessageLookupByLibrary.simpleMessage(
      "Scegli un colore!",
    ),
    "chat_backdrop_gradient_end_color": MessageLookupByLibrary.simpleMessage(
      "Colore finale",
    ),
    "chat_backdrop_gradient_preview": MessageLookupByLibrary.simpleMessage(
      "Anteprima gradiente",
    ),
    "chat_backdrop_gradient_start_color": MessageLookupByLibrary.simpleMessage(
      "Colore iniziale",
    ),
    "chat_backdrop_save_changes": MessageLookupByLibrary.simpleMessage(
      "Salva modifiche",
    ),
    "chat_backdrop_select_gradient": MessageLookupByLibrary.simpleMessage(
      "Seleziona colori gradiente",
    ),
    "chat_backdrop_upload_coming_soon": MessageLookupByLibrary.simpleMessage(
      "Caricamento immagine personalizzata in arrivo!",
    ),
    "chat_backdrop_upload_custom": MessageLookupByLibrary.simpleMessage(
      "Carica immagine personalizzata",
    ),
    "chat_request_accept_error": MessageLookupByLibrary.simpleMessage(
      "Si è verificato un errore durante laccettazione della richiesta di chat!",
    ),
    "chat_request_decline_error": MessageLookupByLibrary.simpleMessage(
      "Si è verificato un errore durante il rifiuto della richiesta di chat!",
    ),
    "chat_session_delete_error": MessageLookupByLibrary.simpleMessage(
      "Si è verificato un errore durante leliminazione della sessione di chat!",
    ),
    "chat_session_not_found": MessageLookupByLibrary.simpleMessage(
      "La sessione di chat selezionata non esiste. (Potrebbe essere stata eliminata dallaltro utente)",
    ),
    "chat_theme": MessageLookupByLibrary.simpleMessage("チャットテーマ"),
    "chat_theme_settings": MessageLookupByLibrary.simpleMessage(
      "Impostazioni tema chat",
    ),
    "chat_with": m1,
    "chats": MessageLookupByLibrary.simpleMessage("Chat"),
    "choose_friends": MessageLookupByLibrary.simpleMessage("友達を選択"),
    "choose_option": MessageLookupByLibrary.simpleMessage("Scegli unopzione"),
    "client_id_must_be_a_number": MessageLookupByLibrary.simpleMessage(
      "LID cliente deve essere un numero",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Chiudi"),
    "command_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Comando {} non implementato!",
    ),
    "command_unknown": MessageLookupByLibrary.simpleMessage(
      "Comando sconosciuto!",
    ),
    "confirm_delete_message": MessageLookupByLibrary.simpleMessage(
      "Sei sicuro di voler eliminare definitivamente il messaggio?",
    ),
    "connect": MessageLookupByLibrary.simpleMessage("Connetti"),
    "connection_refused": MessageLookupByLibrary.simpleMessage("接続が拒否されました！"),
    "connection_reset": MessageLookupByLibrary.simpleMessage("接続がリセットされました！"),
    "content_type_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Tipo di contenuto non implementato!",
    ),
    "content_type_unknown": MessageLookupByLibrary.simpleMessage(
      "Tipo di contenuto sconosciuto!",
    ),
    "could_not_verify_server_certificate": MessageLookupByLibrary.simpleMessage(
      "サーバー証明書を検証できませんでした",
    ),
    "create_account": MessageLookupByLibrary.simpleMessage("Crea account"),
    "create_account_database_full": MessageLookupByLibrary.simpleMessage(
      "Capacità massima del database raggiunta! Purtroppo la tua richiesta non può essere elaborata.",
    ),
    "create_account_email_exists": MessageLookupByLibrary.simpleMessage(
      "Lemail è già in uso!",
    ),
    "create_account_error": MessageLookupByLibrary.simpleMessage(
      "Si è verificato un errore durante la creazione dellaccount!",
    ),
    "create_account_success": MessageLookupByLibrary.simpleMessage(
      "Account creato con successo!",
    ),
    "credential_validation_client_id_error":
        MessageLookupByLibrary.simpleMessage(
          "Impossibile generare lID client!",
        ),
    "credential_validation_email_exists": MessageLookupByLibrary.simpleMessage(
      "Lemail è già in uso!",
    ),
    "credential_validation_email_invalid": MessageLookupByLibrary.simpleMessage(
      "Indirizzo email non valido",
    ),
    "credential_validation_password_invalid":
        MessageLookupByLibrary.simpleMessage(
          "I requisiti della password non sono soddisfatti!",
        ),
    "credential_validation_success": MessageLookupByLibrary.simpleMessage(
      "Credenziali scambiate con successo!",
    ),
    "credential_validation_username_invalid":
        MessageLookupByLibrary.simpleMessage(
          "I requisiti del nome utente non sono soddisfatti!",
        ),
    "custom": MessageLookupByLibrary.simpleMessage("カスタム"),
    "decline": MessageLookupByLibrary.simpleMessage("Rifiuta"),
    "decompression_failed": MessageLookupByLibrary.simpleMessage(
      "Decompressione fallita",
    ),
    "default_monotone": MessageLookupByLibrary.simpleMessage("デフォルト/モノトーン"),
    "delete": MessageLookupByLibrary.simpleMessage("Elimina"),
    "delete_chat": MessageLookupByLibrary.simpleMessage("Elimina chat"),
    "delete_this_chat_question": MessageLookupByLibrary.simpleMessage(
      "Eliminare questa chat?",
    ),
    "deleting_this_chat_will_permanently_delete_all_prior_messages":
        MessageLookupByLibrary.simpleMessage(
          "Leliminazione di questa chat cancellerà permanentemente tutti i messaggi precedenti",
        ),
    "display_name": MessageLookupByLibrary.simpleMessage("Nome visualizzato"),
    "display_part_of_messages_in_notifications":
        MessageLookupByLibrary.simpleMessage(
          "Mostra parte del messaggio nelle notifiche",
        ),
    "donate_to_ermis_project": MessageLookupByLibrary.simpleMessage(
      "Dona al progetto Ermis",
    ),
    "donate_to_hoster": MessageLookupByLibrary.simpleMessage("Dona allhost"),
    "donations": MessageLookupByLibrary.simpleMessage("Donazioni"),
    "downloaded_file": MessageLookupByLibrary.simpleMessage("File scaricato"),
    "email": MessageLookupByLibrary.simpleMessage("Email"),
    "email_address": MessageLookupByLibrary.simpleMessage("Indirizzo email"),
    "email_is_empty": MessageLookupByLibrary.simpleMessage("Lemail è vuota!"),
    "email_mismatch": MessageLookupByLibrary.simpleMessage(
      "Lemail inserita non corrisponde allemail effettiva!",
    ),
    "enter_client_id": MessageLookupByLibrary.simpleMessage(
      "Inserisci lID cliente",
    ),
    "enter_verification_code": MessageLookupByLibrary.simpleMessage(
      "Inserisci il codice di verifica",
    ),
    "enter_verification_code_sent_to_your_email":
        MessageLookupByLibrary.simpleMessage(
          "Inserisci il codice di verifica inviato alla tua email",
        ),
    "entropy_rough_estimate": m2,
    "error_saving_file": MessageLookupByLibrary.simpleMessage(
      "Si è verificato un errore durante il salvataggio del file",
    ),
    "faq_contact_terms_privacy": MessageLookupByLibrary.simpleMessage(
      "FAQ, contattaci, termini e privacy",
    ),
    "feature_audio_messages": MessageLookupByLibrary.simpleMessage(
      "Supporto per i messaggi audio",
    ),
    "feature_chat_themes": MessageLookupByLibrary.simpleMessage(
      "Nuovi temi di chat",
    ),
    "feature_encryption": MessageLookupByLibrary.simpleMessage(
      "Protocolli di crittografia migliorati",
    ),
    "feature_languages": MessageLookupByLibrary.simpleMessage(
      "Supporto multilingue!",
    ),
    "feature_voice_calls": MessageLookupByLibrary.simpleMessage(
      "Chiamate vocali (Accesso anticipato)",
    ),
    "file_received": m3,
    "functionality_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Funzionalità non ancora implementata!",
    ),
    "gallery": MessageLookupByLibrary.simpleMessage("Galleria"),
    "got_it_button": MessageLookupByLibrary.simpleMessage("Capito!"),
    "gradient": MessageLookupByLibrary.simpleMessage("グラデーション"),
    "help": MessageLookupByLibrary.simpleMessage("Aiuto"),
    "help_settings": MessageLookupByLibrary.simpleMessage(
      "Impostazioni di aiuto",
    ),
    "incompatible_server_version_warning": MessageLookupByLibrary.simpleMessage(
      "Versione del server incompatibile! Alcune funzionalità potrebbero non funzionare come previsto!",
    ),
    "license_capitalized": MessageLookupByLibrary.simpleMessage("Licenza"),
    "license_crux": MessageLookupByLibrary.simpleMessage("Licenza crux"),
    "link_new_device": MessageLookupByLibrary.simpleMessage(
      "Collega nuovo dispositivo",
    ),
    "linked_devices": MessageLookupByLibrary.simpleMessage(
      "Dispositivi collegati",
    ),
    "linked_devices_logout_all": MessageLookupByLibrary.simpleMessage(
      "Disconnetti da tutti i dispositivi",
    ),
    "linked_devices_logout_all_confirm": MessageLookupByLibrary.simpleMessage(
      "Sei sicuro di voler disconnetterti da tutti i dispositivi?",
    ),
    "linked_devices_logout_confirm": MessageLookupByLibrary.simpleMessage(
      "Sei sicuro di voler disconnetterti da ",
    ),
    "login": MessageLookupByLibrary.simpleMessage("Accedi"),
    "login_account_not_found": MessageLookupByLibrary.simpleMessage(
      "Laccount non esiste!",
    ),
    "login_add_device_info": MessageLookupByLibrary.simpleMessage(
      "Aggiungi informazioni sul dispositivo",
    ),
    "login_backup_code_incorrect": MessageLookupByLibrary.simpleMessage(
      "Codice di verifica di backup errato.",
    ),
    "login_email_incorrect": MessageLookupByLibrary.simpleMessage(
      "Email errata!",
    ),
    "login_error": MessageLookupByLibrary.simpleMessage(
      "Si è verificato un errore durante laccesso! Contatta lamministratore del server e informalo che il server non funziona.",
    ),
    "login_fetch_requirements": MessageLookupByLibrary.simpleMessage(
      "Recupera requisiti",
    ),
    "login_password_incorrect": MessageLookupByLibrary.simpleMessage(
      "Password errata.",
    ),
    "login_success": MessageLookupByLibrary.simpleMessage(
      "Accesso effettuato con successo!",
    ),
    "login_toggle_password": MessageLookupByLibrary.simpleMessage(
      "Mostra/nascondi password",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("disconnetti"),
    "logout_capitalized": MessageLookupByLibrary.simpleMessage("Disconnetti"),
    "logout_confirmation_all_devices": MessageLookupByLibrary.simpleMessage(
      "Sei sicuro di voler disconnetterti da \${device.formattedInfo()}?",
    ),
    "logout_confirmation_device": MessageLookupByLibrary.simpleMessage(
      "Sei sicuro di voler disconnetterti da \${device.formattedInfo()}?",
    ),
    "logout_from_all_devices": MessageLookupByLibrary.simpleMessage(
      "Esci da tutti i dispositivi",
    ),
    "logout_from_this_device": MessageLookupByLibrary.simpleMessage(
      "Esci da questo dispositivo",
    ),
    "manage_storage": MessageLookupByLibrary.simpleMessage(
      "Gestisci archiviazione",
    ),
    "message_by": m4,
    "message_copied": MessageLookupByLibrary.simpleMessage(
      "Messaggio copiato negli appunti",
    ),
    "message_deletion_unsuccessful": MessageLookupByLibrary.simpleMessage(
      "Eliminazione del messaggio non riuscita",
    ),
    "message_group_call_tones": MessageLookupByLibrary.simpleMessage(
      "Messaggi, gruppi e suonerie chiamate",
    ),
    "message_length_exceeded": MessageLookupByLibrary.simpleMessage(
      "La lunghezza del messaggio supera il limite massimo di %d caratteri",
    ),
    "message_type_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Tipo di messaggio non implementato!",
    ),
    "message_type_unknown": MessageLookupByLibrary.simpleMessage(
      "Tipo di messaggio non riconosciuto!",
    ),
    "min_entropy": m5,
    "name": MessageLookupByLibrary.simpleMessage("Nome"),
    "name_enter": MessageLookupByLibrary.simpleMessage("Inserisci il tuo nome"),
    "network_usage_auto_download": MessageLookupByLibrary.simpleMessage(
      "Utilizzo rete, download automatico",
    ),
    "new_chat": MessageLookupByLibrary.simpleMessage("Nuova chat"),
    "new_group": MessageLookupByLibrary.simpleMessage("新しいグループ"),
    "new_message": MessageLookupByLibrary.simpleMessage("Nuovo messaggio!"),
    "no_chat_requests_available": MessageLookupByLibrary.simpleMessage(
      "Nessuna richiesta di chat pendente",
    ),
    "no_chats_available_incompatible_server_version":
        MessageLookupByLibrary.simpleMessage(
          "Nessuna chat disponibile, versione del server incompatibile",
        ),
    "no_conversations_available": MessageLookupByLibrary.simpleMessage(
      "Nessuna conversazione disponibile",
    ),
    "no_linked_devices": MessageLookupByLibrary.simpleMessage(
      "Nessun dispositivo collegato",
    ),
    "notification_enable": MessageLookupByLibrary.simpleMessage(
      "Abilita notifiche",
    ),
    "notification_preview_display_part": MessageLookupByLibrary.simpleMessage(
      "Mostra parte del messaggio nelle notifiche",
    ),
    "notification_preview_show": MessageLookupByLibrary.simpleMessage(
      "Mostra anteprima messaggi",
    ),
    "notification_settings": MessageLookupByLibrary.simpleMessage(
      "Impostazioni notifiche",
    ),
    "notification_sound": MessageLookupByLibrary.simpleMessage(
      "Suono notifica",
    ),
    "notification_sound_select": MessageLookupByLibrary.simpleMessage(
      "Seleziona suono di notifica",
    ),
    "notifications": MessageLookupByLibrary.simpleMessage("Notifiche"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "or": MessageLookupByLibrary.simpleMessage("O"),
    "other": MessageLookupByLibrary.simpleMessage("Altro"),
    "other_settings": MessageLookupByLibrary.simpleMessage(
      "Altre impostazioni",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "password_is_empty": MessageLookupByLibrary.simpleMessage(
      "La password è vuota!",
    ),
    "password_validation_invalid": MessageLookupByLibrary.simpleMessage(
      "I requisiti della password non sono soddisfatti!",
    ),
    "password_validation_success": MessageLookupByLibrary.simpleMessage(
      "Password convalidata con successo!",
    ),
    "please_enter_the_verification_code": MessageLookupByLibrary.simpleMessage(
      "Inserisci il codice di verifica",
    ),
    "privacy": MessageLookupByLibrary.simpleMessage("プライバシー"),
    "privacy_security_change_number": MessageLookupByLibrary.simpleMessage(
      "Privacy, sicurezza, cambia numero",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("Profilo"),
    "profile_about": MessageLookupByLibrary.simpleMessage("Informazioni"),
    "profile_camera": MessageLookupByLibrary.simpleMessage("Fotocamera"),
    "profile_change_name_id": MessageLookupByLibrary.simpleMessage(
      "Profilo, cambia nome, ID",
    ),
    "profile_gallery": MessageLookupByLibrary.simpleMessage("Galleria"),
    "profile_hey_there": MessageLookupByLibrary.simpleMessage("Ciao!"),
    "profile_id_copied": MessageLookupByLibrary.simpleMessage(
      "ID copiato negli appunti",
    ),
    "profile_name": MessageLookupByLibrary.simpleMessage("Nome"),
    "profile_name_enter": MessageLookupByLibrary.simpleMessage(
      "Inserisci il tuo nome",
    ),
    "profile_photo": MessageLookupByLibrary.simpleMessage("Foto profilo"),
    "profile_photo_fetch_error": MessageLookupByLibrary.simpleMessage(
      "Si è verificato un errore durante il recupero della foto profilo dal database!",
    ),
    "profile_settings": MessageLookupByLibrary.simpleMessage(
      "Impostazioni profilo",
    ),
    "registration_failed": m6,
    "requests": MessageLookupByLibrary.simpleMessage("Richieste"),
    "resend_code": MessageLookupByLibrary.simpleMessage("Reinvia codice"),
    "save": MessageLookupByLibrary.simpleMessage("Salva"),
    "search": MessageLookupByLibrary.simpleMessage("Cerca..."),
    "select_an_option": MessageLookupByLibrary.simpleMessage(
      "Seleziona unopzione",
    ),
    "send_chat_request": MessageLookupByLibrary.simpleMessage(
      "Invia richiesta di chat",
    ),
    "server_add": MessageLookupByLibrary.simpleMessage("Aggiungi server"),
    "server_add_success": MessageLookupByLibrary.simpleMessage(
      "Server aggiunto con successo!",
    ),
    "server_certificate_check": MessageLookupByLibrary.simpleMessage(
      "Verifica certificato",
    ),
    "server_source_code": MessageLookupByLibrary.simpleMessage(
      "Codice sorgente del server",
    ),
    "server_url_choose": MessageLookupByLibrary.simpleMessage(
      "Scegli URL del server",
    ),
    "server_url_enter": MessageLookupByLibrary.simpleMessage(
      "Inserisci URL del server",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Impostazioni"),
    "settings_save": MessageLookupByLibrary.simpleMessage("Salva impostazioni"),
    "settings_saved": MessageLookupByLibrary.simpleMessage("設定を保存しました"),
    "sign_out": MessageLookupByLibrary.simpleMessage("Disconnetti"),
    "source_code": MessageLookupByLibrary.simpleMessage("Codice sorgente"),
    "storage_data": MessageLookupByLibrary.simpleMessage(
      "Archiviazione e dati",
    ),
    "submit": MessageLookupByLibrary.simpleMessage("Invia"),
    "temp_banned": MessageLookupByLibrary.simpleMessage(
      "Rallenta un po! Sei stato temporaneamente bannato dallinterazione con il server per un breve intervallo di tempo.",
    ),
    "theme_dark": MessageLookupByLibrary.simpleMessage("Modalità scura"),
    "theme_light": MessageLookupByLibrary.simpleMessage("Modalità chiara"),
    "theme_mode": MessageLookupByLibrary.simpleMessage("Modalità tema"),
    "theme_system_default": MessageLookupByLibrary.simpleMessage(
      "Predefinito di sistema",
    ),
    "theme_wallpapers_chat_history": MessageLookupByLibrary.simpleMessage(
      "Tema, sfondi, cronologia chat",
    ),
    "today": MessageLookupByLibrary.simpleMessage("Oggi"),
    "type_message": MessageLookupByLibrary.simpleMessage(
      "Scrivi un messaggio...",
    ),
    "unknown_size": MessageLookupByLibrary.simpleMessage(
      "Dimensione sconosciuta",
    ),
    "use_backup_verification_code": MessageLookupByLibrary.simpleMessage(
      "Usa il codice di verifica di backup",
    ),
    "use_password": MessageLookupByLibrary.simpleMessage("Usa la password"),
    "username_same_as_old": MessageLookupByLibrary.simpleMessage(
      "Il nome utente non può essere lo stesso di quello vecchio!",
    ),
    "username_validation_invalid": MessageLookupByLibrary.simpleMessage(
      "I requisiti del nome utente non sono soddisfatti!",
    ),
    "username_validation_success": MessageLookupByLibrary.simpleMessage(
      "Nome utente convalidato con successo!",
    ),
    "verification": MessageLookupByLibrary.simpleMessage("Verifica"),
    "verification_attempts_exhausted": MessageLookupByLibrary.simpleMessage(
      "Numero massimo di tentativi esaurito!",
    ),
    "verification_code_incorrect": MessageLookupByLibrary.simpleMessage(
      "Codice errato!",
    ),
    "verification_code_must_be_number": MessageLookupByLibrary.simpleMessage(
      "Il codice di verifica deve essere un numero",
    ),
    "verification_email_invalid": MessageLookupByLibrary.simpleMessage(
      "Indirizzo email non valido",
    ),
    "verification_resend_code": MessageLookupByLibrary.simpleMessage(
      "Reinvia codice",
    ),
    "verification_success": MessageLookupByLibrary.simpleMessage(
      "Verifica completata con successo!",
    ),
    "version_capitalized": MessageLookupByLibrary.simpleMessage("Versione"),
    "vibration": MessageLookupByLibrary.simpleMessage("Vibrazione"),
    "vibration_unavailable": MessageLookupByLibrary.simpleMessage(
      "La vibrazione non è disponibile su questo dispositivo",
    ),
    "whats_new": MessageLookupByLibrary.simpleMessage("Cosa cè di nuovo"),
    "whats_new_system_messages": MessageLookupByLibrary.simpleMessage(
      "Nuovi messaggi di sistema",
    ),
    "whats_new_title": MessageLookupByLibrary.simpleMessage(
      "Nuove funzionalità in Hermis",
    ),
  };
}
