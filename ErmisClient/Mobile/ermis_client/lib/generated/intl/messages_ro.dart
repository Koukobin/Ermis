// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ro locale. All the
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
  String get localeName => 'ro';

  static String m0(deviceInfo) =>
      "Sigur doriți să vă deconectați de la ${deviceInfo}?";

  static String m1(username) => "Conversație cu ${username}";

  static String m2(entropy) => "Entropie: ${entropy} (Estimare aproximativă)";

  static String m3(fileName) => "Fișier primit ${fileName}";

  static String m4(username) => "Mesaj de la ${username}";

  static String m5(minEntropy) => "Entropie minimă: ${minEntropy}";

  static String m6(resultMessage) => "Înregistrare eșuată: ${resultMessage}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "abstract": MessageLookupByLibrary.simpleMessage("Abstract"),
    "accept": MessageLookupByLibrary.simpleMessage("Acceptă"),
    "account": MessageLookupByLibrary.simpleMessage("Cont"),
    "account_add": MessageLookupByLibrary.simpleMessage("Adaugă cont nou"),
    "account_confirm_proceed": MessageLookupByLibrary.simpleMessage(
      "Ești sigur că vrei să continui?",
    ),
    "account_delete": MessageLookupByLibrary.simpleMessage("Șterge contul"),
    "account_delete_bullet1": MessageLookupByLibrary.simpleMessage(
      "Șterge contul tău fără posibilitatea de recuperare",
    ),
    "account_delete_bullet2": MessageLookupByLibrary.simpleMessage(
      "Șterge istoricul mesajelor tale",
    ),
    "account_delete_bullet3": MessageLookupByLibrary.simpleMessage(
      "Șterge toate chat-urile tale",
    ),
    "account_delete_confirmation": MessageLookupByLibrary.simpleMessage(
      "Ștergerea acestui cont va:",
    ),
    "account_delete_error": MessageLookupByLibrary.simpleMessage(
      "A apărut o eroare la încercarea de a șterge contul tău!",
    ),
    "account_delete_my": MessageLookupByLibrary.simpleMessage(
      "Șterge Contul Meu",
    ),
    "account_settings": MessageLookupByLibrary.simpleMessage("Setări cont"),
    "add_user": MessageLookupByLibrary.simpleMessage("Adaugă Utilizator"),
    "address_not_recognized": MessageLookupByLibrary.simpleMessage(
      "Adresa nu este recunoscută!",
    ),
    "app_info": MessageLookupByLibrary.simpleMessage("Informații aplicație"),
    "app_language": MessageLookupByLibrary.simpleMessage("Limba aplicației"),
    "are_you_sure_you_want_to_logout_from": m0,
    "are_you_sure_you_want_to_logout_from_all_devices":
        MessageLookupByLibrary.simpleMessage(
          "Ești sigur că vrei să te deconectezi de pe toate dispozitivele?",
        ),
    "attempting_delete_message": MessageLookupByLibrary.simpleMessage(
      "Se încearcă ștergerea mesajului",
    ),
    "authentication_stage_create_account": MessageLookupByLibrary.simpleMessage(
      "Crează cont",
    ),
    "authentication_stage_credentials_exchange":
        MessageLookupByLibrary.simpleMessage("Schimb de credențiale"),
    "authentication_stage_credentials_validation":
        MessageLookupByLibrary.simpleMessage("Validarea credențialelor"),
    "authentication_stage_login": MessageLookupByLibrary.simpleMessage(
      "Conectare",
    ),
    "backup_verification_code": MessageLookupByLibrary.simpleMessage(
      "Cod de verificare de rezervă",
    ),
    "backup_verification_code_regenerate_error":
        MessageLookupByLibrary.simpleMessage(
          "A apărut o eroare la încercarea de a schimba numele de utilizator!",
        ),
    "backup_verification_code_regenerate_success":
        MessageLookupByLibrary.simpleMessage(
          "Codurile de verificare de rezervă au fost regenerate cu succes!",
        ),
    "camera": MessageLookupByLibrary.simpleMessage("Cameră"),
    "cancel": MessageLookupByLibrary.simpleMessage("Anulează"),
    "change_password_error": MessageLookupByLibrary.simpleMessage(
      "A apărut o eroare la încercarea de a schimba parola!",
    ),
    "change_password_success": MessageLookupByLibrary.simpleMessage(
      "Parola a fost schimbată cu succes!",
    ),
    "change_username_error": MessageLookupByLibrary.simpleMessage(
      "A apărut o eroare la încercarea de a schimba numele de utilizator!",
    ),
    "change_username_invalid": MessageLookupByLibrary.simpleMessage(
      "Cerințele pentru nume de utilizator nu sunt îndeplinite",
    ),
    "change_username_success": MessageLookupByLibrary.simpleMessage(
      "Numele de utilizator a fost schimbat cu succes!",
    ),
    "chat_backdrop": MessageLookupByLibrary.simpleMessage("Fundal chat"),
    "chat_backdrop_choose_image": MessageLookupByLibrary.simpleMessage(
      "Alege imaginea",
    ),
    "chat_backdrop_color_pick": MessageLookupByLibrary.simpleMessage(
      "Alege o culoare!",
    ),
    "chat_backdrop_gradient_end_color": MessageLookupByLibrary.simpleMessage(
      "Culoare de sfârșit",
    ),
    "chat_backdrop_gradient_preview": MessageLookupByLibrary.simpleMessage(
      "Previzualizare gradient",
    ),
    "chat_backdrop_gradient_start_color": MessageLookupByLibrary.simpleMessage(
      "Culoare de început",
    ),
    "chat_backdrop_save_changes": MessageLookupByLibrary.simpleMessage(
      "Salvează modificările",
    ),
    "chat_backdrop_select_gradient": MessageLookupByLibrary.simpleMessage(
      "Selectează culorile gradientului",
    ),
    "chat_backdrop_upload_coming_soon": MessageLookupByLibrary.simpleMessage(
      "Încărcarea imaginii personalizate vine în curând!",
    ),
    "chat_backdrop_upload_custom": MessageLookupByLibrary.simpleMessage(
      "Încarcă imagine personalizată",
    ),
    "chat_request_accept_error": MessageLookupByLibrary.simpleMessage(
      "Ceva a mers prost la încercarea de a accepta cererea de chat!",
    ),
    "chat_request_decline_error": MessageLookupByLibrary.simpleMessage(
      "Ceva a mers prost la încercarea de a refuza cererea de chat!",
    ),
    "chat_session_delete_error": MessageLookupByLibrary.simpleMessage(
      "Ceva a mers prost la încercarea de a șterge sesiunea de chat!",
    ),
    "chat_session_not_found": MessageLookupByLibrary.simpleMessage(
      "Sesiunea de chat selectată nu există. (Poate a fost ștearsă de celălalt utilizator)",
    ),
    "chat_theme": MessageLookupByLibrary.simpleMessage("Temă Chat"),
    "chat_theme_settings": MessageLookupByLibrary.simpleMessage(
      "Setări temă chat",
    ),
    "chat_with": m1,
    "chats": MessageLookupByLibrary.simpleMessage("Chat-uri"),
    "choose_friends": MessageLookupByLibrary.simpleMessage("Alege Prieteni"),
    "choose_option": MessageLookupByLibrary.simpleMessage("Alege o opțiune"),
    "client_id_must_be_a_number": MessageLookupByLibrary.simpleMessage(
      "ID-ul clientului trebuie să fie un număr",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Închide"),
    "command_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Comanda {} nu este implementată!",
    ),
    "command_unknown": MessageLookupByLibrary.simpleMessage(
      "Comanda nu este cunoscută!",
    ),
    "confirm_delete_message": MessageLookupByLibrary.simpleMessage(
      "Sigur doriți să ștergeți definitiv mesajul?",
    ),
    "connect": MessageLookupByLibrary.simpleMessage("Conectează"),
    "connection_refused": MessageLookupByLibrary.simpleMessage(
      "Conexiune Refuzată!",
    ),
    "connection_reset": MessageLookupByLibrary.simpleMessage(
      "Conexiune Resetată!",
    ),
    "content_type_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Tipul de conținut nu este implementat!",
    ),
    "content_type_unknown": MessageLookupByLibrary.simpleMessage(
      "Tipul de conținut nu este cunoscut!",
    ),
    "could_not_verify_server_certificate": MessageLookupByLibrary.simpleMessage(
      "Nu s-a putut verifica certificatul serverului",
    ),
    "create_account": MessageLookupByLibrary.simpleMessage("Creează cont"),
    "create_account_database_full": MessageLookupByLibrary.simpleMessage(
      "Capacitatea maximă a bazei de date a fost atinsă! Din păcate, cererea ta nu a putut fi procesată.",
    ),
    "create_account_email_exists": MessageLookupByLibrary.simpleMessage(
      "Adresa de email este deja folosită!",
    ),
    "create_account_error": MessageLookupByLibrary.simpleMessage(
      "A apărut o eroare la crearea contului tău!",
    ),
    "create_account_success": MessageLookupByLibrary.simpleMessage(
      "Contul a fost creat cu succes!",
    ),
    "credential_validation_client_id_error":
        MessageLookupByLibrary.simpleMessage(
          "Nu se poate genera ID-ul clientului!",
        ),
    "credential_validation_email_exists": MessageLookupByLibrary.simpleMessage(
      "Adresa de email este deja folosită!",
    ),
    "credential_validation_email_invalid": MessageLookupByLibrary.simpleMessage(
      "Adresă de email nevalidă",
    ),
    "credential_validation_password_invalid":
        MessageLookupByLibrary.simpleMessage(
          "Cerințele pentru parolă nu sunt îndeplinite!",
        ),
    "credential_validation_success": MessageLookupByLibrary.simpleMessage(
      "Credențialele au fost schimbate cu succes!",
    ),
    "credential_validation_username_invalid":
        MessageLookupByLibrary.simpleMessage(
          "Cerințele pentru nume de utilizator nu sunt îndeplinite!",
        ),
    "custom": MessageLookupByLibrary.simpleMessage("Personalizat"),
    "decline": MessageLookupByLibrary.simpleMessage("Refuză"),
    "decompression_failed": MessageLookupByLibrary.simpleMessage(
      "Decompresia a eșuat",
    ),
    "default_monotone": MessageLookupByLibrary.simpleMessage(
      "Implicit/Monoton",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Șterge"),
    "delete_chat": MessageLookupByLibrary.simpleMessage("Șterge chat"),
    "delete_this_chat_question": MessageLookupByLibrary.simpleMessage(
      "Ștergeți acest chat?",
    ),
    "deleting_this_chat_will_permanently_delete_all_prior_messages":
        MessageLookupByLibrary.simpleMessage(
          "Ștergerea acestui chat va șterge permanent toate mesajele anterioare",
        ),
    "display_name": MessageLookupByLibrary.simpleMessage("Nume afișat"),
    "display_part_of_messages_in_notifications":
        MessageLookupByLibrary.simpleMessage(
          "Afișează o parte a mesajului în notificări",
        ),
    "donate_to_ermis_project": MessageLookupByLibrary.simpleMessage(
      "Donează Proiectului Ermis",
    ),
    "donate_to_hoster": MessageLookupByLibrary.simpleMessage(
      "Donează către găzduire",
    ),
    "donations": MessageLookupByLibrary.simpleMessage("Donații"),
    "downloaded_file": MessageLookupByLibrary.simpleMessage("Fișier descărcat"),
    "email": MessageLookupByLibrary.simpleMessage("E-mail"),
    "email_address": MessageLookupByLibrary.simpleMessage("Adresă de email"),
    "email_is_empty": MessageLookupByLibrary.simpleMessage(
      "E-mailul este gol!",
    ),
    "email_mismatch": MessageLookupByLibrary.simpleMessage(
      "Emailul introdus nu corespunde cu emailul real!",
    ),
    "enter_client_id": MessageLookupByLibrary.simpleMessage(
      "Introduceți ID-ul clientului",
    ),
    "enter_verification_code": MessageLookupByLibrary.simpleMessage(
      "Introduceți codul de verificare",
    ),
    "enter_verification_code_sent_to_your_email":
        MessageLookupByLibrary.simpleMessage(
          "Introduceți codul de verificare trimis la adresa dvs. de e-mail",
        ),
    "entropy_rough_estimate": m2,
    "error_saving_file": MessageLookupByLibrary.simpleMessage(
      "A apărut o eroare la încercarea de a salva fișierul",
    ),
    "faq_contact_terms_privacy": MessageLookupByLibrary.simpleMessage(
      "Întrebări frecvente, contactează-ne, termeni și politica de confidențialitate",
    ),
    "feature_audio_messages": MessageLookupByLibrary.simpleMessage(
      "Suport pentru mesaje audio",
    ),
    "feature_chat_themes": MessageLookupByLibrary.simpleMessage(
      "Teme noi de chat",
    ),
    "feature_encryption": MessageLookupByLibrary.simpleMessage(
      "Protocoale de criptare îmbunătățite",
    ),
    "feature_languages": MessageLookupByLibrary.simpleMessage(
      "Suport multi-lingvistic!",
    ),
    "feature_voice_calls": MessageLookupByLibrary.simpleMessage(
      "Apeluri vocale (Acces timpuriu)",
    ),
    "file_received": m3,
    "functionality_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Funcționalitatea nu este încă implementată!",
    ),
    "gallery": MessageLookupByLibrary.simpleMessage("Galerie"),
    "got_it_button": MessageLookupByLibrary.simpleMessage("Am înțeles!"),
    "gradient": MessageLookupByLibrary.simpleMessage("Gradient"),
    "help": MessageLookupByLibrary.simpleMessage("Ajutor"),
    "help_settings": MessageLookupByLibrary.simpleMessage("Setări ajutor"),
    "incompatible_server_version_warning": MessageLookupByLibrary.simpleMessage(
      "Versiune server incompatibilă! Unele lucruri ar putea să nu funcționeze conform așteptărilor!",
    ),
    "license_capitalized": MessageLookupByLibrary.simpleMessage("Licență"),
    "license_crux": MessageLookupByLibrary.simpleMessage(
      "Punctul crucial al licenței",
    ),
    "link_new_device": MessageLookupByLibrary.simpleMessage(
      "Conectați un dispozitiv nou",
    ),
    "linked_devices": MessageLookupByLibrary.simpleMessage(
      "Dispozitive conectate",
    ),
    "linked_devices_logout_all": MessageLookupByLibrary.simpleMessage(
      "Deconectare de la toate dispozitivele",
    ),
    "linked_devices_logout_all_confirm": MessageLookupByLibrary.simpleMessage(
      "Ești sigur că vrei să te deconectezi de la toate dispozitivele?",
    ),
    "linked_devices_logout_confirm": MessageLookupByLibrary.simpleMessage(
      "Ești sigur că vrei să te deconectezi de la ",
    ),
    "login": MessageLookupByLibrary.simpleMessage("Conectare"),
    "login_account_not_found": MessageLookupByLibrary.simpleMessage(
      "Contul nu există!",
    ),
    "login_add_device_info": MessageLookupByLibrary.simpleMessage(
      "Adaugă informații despre dispozitiv",
    ),
    "login_backup_code_incorrect": MessageLookupByLibrary.simpleMessage(
      "Cod de verificare de rezervă incorect.",
    ),
    "login_email_incorrect": MessageLookupByLibrary.simpleMessage(
      "Email incorect!",
    ),
    "login_error": MessageLookupByLibrary.simpleMessage(
      "A apărut o eroare la conectarea la contul tău! Te rugăm să contactezi administratorul serverului și să-i spui că serverul lor este defect.",
    ),
    "login_fetch_requirements": MessageLookupByLibrary.simpleMessage(
      "Obține cerințele",
    ),
    "login_password_incorrect": MessageLookupByLibrary.simpleMessage(
      "Parolă incorectă.",
    ),
    "login_success": MessageLookupByLibrary.simpleMessage(
      "Te-ai conectat cu succes la contul tău!",
    ),
    "login_toggle_password": MessageLookupByLibrary.simpleMessage(
      "Comută tipul parolei",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("deconectare"),
    "logout_capitalized": MessageLookupByLibrary.simpleMessage("Deconectare"),
    "logout_confirmation_all_devices": MessageLookupByLibrary.simpleMessage(
      "Sigur doriți să vă deconectați de la \${device.formattedInfo()}?",
    ),
    "logout_confirmation_device": MessageLookupByLibrary.simpleMessage(
      "Sigur doriți să vă deconectați de la \${device.formattedInfo()}?",
    ),
    "logout_from_all_devices": MessageLookupByLibrary.simpleMessage(
      "Deconectare de pe toate dispozitivele",
    ),
    "logout_from_this_device": MessageLookupByLibrary.simpleMessage(
      "Deconectare de pe acest dispozitiv",
    ),
    "manage_storage": MessageLookupByLibrary.simpleMessage(
      "Gestionează stocarea",
    ),
    "message_by": m4,
    "message_copied": MessageLookupByLibrary.simpleMessage(
      "Mesajul a fost copiat în clipboard",
    ),
    "message_deletion_unsuccessful": MessageLookupByLibrary.simpleMessage(
      "Ștergerea mesajului a eșuat",
    ),
    "message_group_call_tones": MessageLookupByLibrary.simpleMessage(
      "Tonuri mesaje, grupuri și apeluri",
    ),
    "message_length_exceeded": MessageLookupByLibrary.simpleMessage(
      "Lungimea mesajului depășește lungimea maximă (%d caractere)",
    ),
    "message_type_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Tipul de mesaj nu este implementat!",
    ),
    "message_type_unknown": MessageLookupByLibrary.simpleMessage(
      "Tipul de mesaj nu este recunoscut!",
    ),
    "min_entropy": m5,
    "name": MessageLookupByLibrary.simpleMessage("Nume"),
    "name_enter": MessageLookupByLibrary.simpleMessage("Introdu numele tău"),
    "network_usage_auto_download": MessageLookupByLibrary.simpleMessage(
      "Utilizare rețea, descărcare automată",
    ),
    "new_chat": MessageLookupByLibrary.simpleMessage("Chat nou"),
    "new_group": MessageLookupByLibrary.simpleMessage("Grup Nou"),
    "new_message": MessageLookupByLibrary.simpleMessage("Mesaj nou!"),
    "no_chat_requests_available": MessageLookupByLibrary.simpleMessage(
      "Nu există cereri de chat în așteptare",
    ),
    "no_chats_available_incompatible_server_version":
        MessageLookupByLibrary.simpleMessage(
          "Nu există chat-uri disponibile, versiunea serverului este incompatibilă",
        ),
    "no_conversations_available": MessageLookupByLibrary.simpleMessage(
      "Nu există conversații disponibile",
    ),
    "no_linked_devices": MessageLookupByLibrary.simpleMessage(
      "Nu există dispozitive conectate",
    ),
    "notification_enable": MessageLookupByLibrary.simpleMessage(
      "Activează notificările",
    ),
    "notification_preview_display_part": MessageLookupByLibrary.simpleMessage(
      "Afișează o parte a mesajului în notificări",
    ),
    "notification_preview_show": MessageLookupByLibrary.simpleMessage(
      "Arată previzualizările mesajelor",
    ),
    "notification_settings": MessageLookupByLibrary.simpleMessage(
      "Setări notificări",
    ),
    "notification_sound": MessageLookupByLibrary.simpleMessage(
      "Sunet notificări",
    ),
    "notification_sound_select": MessageLookupByLibrary.simpleMessage(
      "Selectează sunetul notificărilor",
    ),
    "notifications": MessageLookupByLibrary.simpleMessage("Notificări"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "or": MessageLookupByLibrary.simpleMessage("Sau"),
    "other": MessageLookupByLibrary.simpleMessage("Altele"),
    "other_settings": MessageLookupByLibrary.simpleMessage("Alte setări"),
    "password": MessageLookupByLibrary.simpleMessage("Parola"),
    "password_is_empty": MessageLookupByLibrary.simpleMessage(
      "Parola este goală!",
    ),
    "password_validation_invalid": MessageLookupByLibrary.simpleMessage(
      "Cerințele pentru parolă nu sunt îndeplinite!",
    ),
    "password_validation_success": MessageLookupByLibrary.simpleMessage(
      "Parola a fost validată cu succes!",
    ),
    "please_enter_the_verification_code": MessageLookupByLibrary.simpleMessage(
      "Vă rugăm să introduceți codul de verificare",
    ),
    "privacy": MessageLookupByLibrary.simpleMessage("Confidențialitate"),
    "privacy_security_change_number": MessageLookupByLibrary.simpleMessage(
      "Confidențialitate, securitate, schimbare număr",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("Profil"),
    "profile_about": MessageLookupByLibrary.simpleMessage("Despre"),
    "profile_camera": MessageLookupByLibrary.simpleMessage("Cameră"),
    "profile_change_name_id": MessageLookupByLibrary.simpleMessage(
      "Profil, schimbare nume, ID",
    ),
    "profile_gallery": MessageLookupByLibrary.simpleMessage("Galerie"),
    "profile_hey_there": MessageLookupByLibrary.simpleMessage("Salutare!"),
    "profile_id_copied": MessageLookupByLibrary.simpleMessage(
      "ID-ul a fost copiat în clipboard",
    ),
    "profile_name": MessageLookupByLibrary.simpleMessage("Nume"),
    "profile_name_enter": MessageLookupByLibrary.simpleMessage(
      "Introdu numele tău",
    ),
    "profile_photo": MessageLookupByLibrary.simpleMessage("Fotografie profil"),
    "profile_photo_fetch_error": MessageLookupByLibrary.simpleMessage(
      "A apărut o eroare la încercarea de a prelua fotografia de profil din baza de date!",
    ),
    "profile_settings": MessageLookupByLibrary.simpleMessage("Setări profil"),
    "registration_failed": m6,
    "requests": MessageLookupByLibrary.simpleMessage("Cereri"),
    "resend_code": MessageLookupByLibrary.simpleMessage("Retrimite codul"),
    "save": MessageLookupByLibrary.simpleMessage("Salvează"),
    "search": MessageLookupByLibrary.simpleMessage("Caută..."),
    "select_an_option": MessageLookupByLibrary.simpleMessage(
      "Selectați o opțiune",
    ),
    "send_chat_request": MessageLookupByLibrary.simpleMessage(
      "Trimiteți cerere de chat",
    ),
    "server_add": MessageLookupByLibrary.simpleMessage("Adaugă server"),
    "server_add_success": MessageLookupByLibrary.simpleMessage(
      "Server adăugat cu succes!",
    ),
    "server_certificate_check": MessageLookupByLibrary.simpleMessage(
      "Verifică certificatul",
    ),
    "server_source_code": MessageLookupByLibrary.simpleMessage(
      "Cod sursă server",
    ),
    "server_url_choose": MessageLookupByLibrary.simpleMessage(
      "Alege URL server",
    ),
    "server_url_enter": MessageLookupByLibrary.simpleMessage(
      "Introdu URL server",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Setări"),
    "settings_save": MessageLookupByLibrary.simpleMessage("Salvează setările"),
    "settings_saved": MessageLookupByLibrary.simpleMessage("Setări Salvate"),
    "sign_out": MessageLookupByLibrary.simpleMessage("Deconectare"),
    "source_code": MessageLookupByLibrary.simpleMessage("Cod sursă"),
    "storage_data": MessageLookupByLibrary.simpleMessage("Stocare și date"),
    "submit": MessageLookupByLibrary.simpleMessage("Trimite"),
    "temp_banned": MessageLookupByLibrary.simpleMessage(
      "Calmați-vă caii! Ați fost interzis temporar de la interacțiunea cu serverul pentru un scurt interval de timp.",
    ),
    "theme_dark": MessageLookupByLibrary.simpleMessage("Mod întunecat"),
    "theme_light": MessageLookupByLibrary.simpleMessage("Mod luminos"),
    "theme_mode": MessageLookupByLibrary.simpleMessage("Mod temă"),
    "theme_system_default": MessageLookupByLibrary.simpleMessage(
      "Implicit sistem",
    ),
    "theme_wallpapers_chat_history": MessageLookupByLibrary.simpleMessage(
      "Temă, imagini de fundal, istoric chat",
    ),
    "today": MessageLookupByLibrary.simpleMessage("Astăzi"),
    "type_message": MessageLookupByLibrary.simpleMessage("Scrie un mesaj..."),
    "unknown_size": MessageLookupByLibrary.simpleMessage(
      "Dimensiune necunoscută",
    ),
    "use_backup_verification_code": MessageLookupByLibrary.simpleMessage(
      "Utilizați codul de verificare de rezervă",
    ),
    "use_password": MessageLookupByLibrary.simpleMessage("Utilizați parola"),
    "username_same_as_old": MessageLookupByLibrary.simpleMessage(
      "Numele de utilizator nu poate fi același cu numele de utilizator vechi!",
    ),
    "username_validation_invalid": MessageLookupByLibrary.simpleMessage(
      "Cerințele pentru nume de utilizator nu sunt îndeplinite!",
    ),
    "username_validation_success": MessageLookupByLibrary.simpleMessage(
      "Numele de utilizator a fost validat cu succes!",
    ),
    "verification": MessageLookupByLibrary.simpleMessage("Verificare"),
    "verification_attempts_exhausted": MessageLookupByLibrary.simpleMessage(
      "Numărul de încercări a fost epuizat!",
    ),
    "verification_code_incorrect": MessageLookupByLibrary.simpleMessage(
      "Cod incorect!",
    ),
    "verification_code_must_be_number": MessageLookupByLibrary.simpleMessage(
      "Codul de verificare trebuie să fie un număr",
    ),
    "verification_email_invalid": MessageLookupByLibrary.simpleMessage(
      "Adresă de email nevalidă",
    ),
    "verification_resend_code": MessageLookupByLibrary.simpleMessage(
      "Retrimite codul",
    ),
    "verification_success": MessageLookupByLibrary.simpleMessage(
      "Verificat cu succes!",
    ),
    "version_capitalized": MessageLookupByLibrary.simpleMessage("Versiune"),
    "vibration": MessageLookupByLibrary.simpleMessage("Vibrații"),
    "vibration_unavailable": MessageLookupByLibrary.simpleMessage(
      "Vibrațiile nu sunt disponibile pe acest dispozitiv",
    ),
    "whats_new": MessageLookupByLibrary.simpleMessage("Ce e nou"),
    "whats_new_system_messages": MessageLookupByLibrary.simpleMessage(
      "Mesaje noi de sistem",
    ),
    "whats_new_title": MessageLookupByLibrary.simpleMessage(
      "Funcții noi în Hermis",
    ),
  };
}
