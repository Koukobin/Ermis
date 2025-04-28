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
// This is a library that provides messages for a el locale. All the
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
  String get localeName => 'el';

  static String m0(deviceInfo) =>
      "Είστε σίγουροι ότι θέλετε να αποσυνδεθείτε από το ${deviceInfo}?";

  static String m1(username) => "Συνομιλία με ${username}";

  static String m2(entropy) =>
      "Εντροπία: ${entropy} (Κατά προσέγγιση εκτίμηση)";

  static String m3(fileName) => "Λήψη αρχείου ${fileName}";

  static String m4(username) => "Μήνυμα από ${username}";

  static String m5(minEntropy) => "Ελάχιστη εντροπία: ${minEntropy}";

  static String m6(resultMessage) => "Η εγγραφή απέτυχε: ${resultMessage}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "ability_to_form_group_chats": MessageLookupByLibrary.simpleMessage(
      "Δυνατότητα δημιουργίας ομαδικών συνομιλιών!",
    ),
    "abstract": MessageLookupByLibrary.simpleMessage("Αφηρημένο"),
    "accept": MessageLookupByLibrary.simpleMessage("Αποδοχή"),
    "account": MessageLookupByLibrary.simpleMessage("Λογαριασμός"),
    "account_add": MessageLookupByLibrary.simpleMessage(
      "Προσθήκη νέου λογαριασμού",
    ),
    "account_confirm_proceed": MessageLookupByLibrary.simpleMessage(
      "Είστε βέβαιοι ότι θέλετε να συνεχίσετε;",
    ),
    "account_delete": MessageLookupByLibrary.simpleMessage(
      "Διαγραφή λογαριασμού",
    ),
    "account_delete_bullet1": MessageLookupByLibrary.simpleMessage(
      "Διαγράψει οριστικά τον λογαριασμό σας χωρίς δυνατότητα ανάκτησης",
    ),
    "account_delete_bullet2": MessageLookupByLibrary.simpleMessage(
      "Διαγράψει το ιστορικό μηνυμάτων σας",
    ),
    "account_delete_bullet3": MessageLookupByLibrary.simpleMessage(
      "Διαγράψει όλες τις συνομιλίες σας",
    ),
    "account_delete_confirmation": MessageLookupByLibrary.simpleMessage(
      "Η διαγραφή αυτού του λογαριασμού θα:",
    ),
    "account_delete_error": MessageLookupByLibrary.simpleMessage(
      "Προέκυψε σφάλμα κατά τη διαγραφή του λογαριασμού σας!",
    ),
    "account_delete_my": MessageLookupByLibrary.simpleMessage(
      "Διαγραφή του λογαριασμού μου",
    ),
    "account_settings": MessageLookupByLibrary.simpleMessage(
      "Ρυθμίσεις λογαριασμού",
    ),
    "add_user": MessageLookupByLibrary.simpleMessage("Προσθήκη Χρήστη"),
    "address_not_recognized": MessageLookupByLibrary.simpleMessage(
      "Η διεύθυνση δεν αναγνωρίστηκε!",
    ),
    "app_info": MessageLookupByLibrary.simpleMessage("Πληροφορίες εφαρμογής"),
    "app_language": MessageLookupByLibrary.simpleMessage("Γλώσσα Εφαρμογής"),
    "are_you_sure_you_want_to_logout_from": m0,
    "are_you_sure_you_want_to_logout_from_all_devices":
        MessageLookupByLibrary.simpleMessage(
          "Είστε σίγουροι ότι θέλετε να αποσυνδεθείτε από όλες τις συσκευές;",
        ),
    "attempting_delete_message": MessageLookupByLibrary.simpleMessage(
      "Προσπάθεια διαγραφής μηνύματος",
    ),
    "authentication_stage_create_account": MessageLookupByLibrary.simpleMessage(
      "Δημιουργία λογαριασμού",
    ),
    "authentication_stage_credentials_exchange":
        MessageLookupByLibrary.simpleMessage("Ανταλλαγή διαπιστευτηρίων"),
    "authentication_stage_credentials_validation":
        MessageLookupByLibrary.simpleMessage("Επικύρωση διαπιστευτηρίων"),
    "authentication_stage_login": MessageLookupByLibrary.simpleMessage("Login"),
    "backup_verification_code": MessageLookupByLibrary.simpleMessage(
      "Κωδικός επαλήθευσης αντιγράφου ασφαλείας",
    ),
    "backup_verification_code_regenerate_error":
        MessageLookupByLibrary.simpleMessage(
          "Προέκυψε σφάλμα κατά την αλλαγή του ονόματος χρήστη!",
        ),
    "backup_verification_code_regenerate_success":
        MessageLookupByLibrary.simpleMessage(
          "Οι εφεδρικοί κωδικοί επαλήθευσης αναδημιουργήθηκαν με επιτυχία!",
        ),
    "camera": MessageLookupByLibrary.simpleMessage("Κάμερα"),
    "cancel": MessageLookupByLibrary.simpleMessage("Ακύρωση"),
    "change_password_error": MessageLookupByLibrary.simpleMessage(
      "Υπήρξε σφάλμα κατά την προσπάθεια αλλαγής του κωδικού πρόσβασης!",
    ),
    "change_password_success": MessageLookupByLibrary.simpleMessage(
      "Επιτυχής αλλαγή κωδικού πρόσβασης!",
    ),
    "change_username_error": MessageLookupByLibrary.simpleMessage(
      "Προέκυψε σφάλμα κατά την αλλαγή του ονόματος χρήστη!",
    ),
    "change_username_invalid": MessageLookupByLibrary.simpleMessage(
      "Οι απαιτήσεις για το όνομα χρήστη δεν πληρούνται",
    ),
    "change_username_success": MessageLookupByLibrary.simpleMessage(
      "Επιτυχής αλλαγή ονόματος χρήστη!",
    ),
    "chat_backdrop": MessageLookupByLibrary.simpleMessage("Φόντο συνομιλίας"),
    "chat_backdrop_choose_image": MessageLookupByLibrary.simpleMessage(
      "Επιλογή εικόνας",
    ),
    "chat_backdrop_color_pick": MessageLookupByLibrary.simpleMessage(
      "Επιλέξτε ένα χρώμα!",
    ),
    "chat_backdrop_gradient_end_color": MessageLookupByLibrary.simpleMessage(
      "Χρώμα λήξης",
    ),
    "chat_backdrop_gradient_preview": MessageLookupByLibrary.simpleMessage(
      "Προεπισκόπηση διαβάθμισης",
    ),
    "chat_backdrop_gradient_start_color": MessageLookupByLibrary.simpleMessage(
      "Χρώμα έναρξης",
    ),
    "chat_backdrop_save_changes": MessageLookupByLibrary.simpleMessage(
      "Αποθήκευση αλλαγών",
    ),
    "chat_backdrop_select_gradient": MessageLookupByLibrary.simpleMessage(
      "Επιλογή χρωματικής διαβάθμισης",
    ),
    "chat_backdrop_upload_coming_soon": MessageLookupByLibrary.simpleMessage(
      "Η δυνατότητα αποστολής προσαρμοσμένης εικόνας έρχεται σύντομα!",
    ),
    "chat_backdrop_upload_custom": MessageLookupByLibrary.simpleMessage(
      "Ανέβασμα προσαρμοσμένης εικόνας",
    ),
    "chat_request_accept_error": MessageLookupByLibrary.simpleMessage(
      "Προέκυψε σφάλμα κατά την αποδοχή της αίτησης συνομιλίας!",
    ),
    "chat_request_decline_error": MessageLookupByLibrary.simpleMessage(
      "Προέκυψε σφάλμα κατά την απόρριψη της αίτησης συνομιλίας!",
    ),
    "chat_session_delete_error": MessageLookupByLibrary.simpleMessage(
      "Προέκυψε σφάλμα κατά τη διαγραφή της συνεδρίας συνομιλίας!",
    ),
    "chat_session_not_found": MessageLookupByLibrary.simpleMessage(
      "Η επιλεγμένη συνεδρία συνομιλίας δεν υπάρχει. (Μπορεί να έχει διαγραφεί από τον άλλο χρήστη)",
    ),
    "chat_theme": MessageLookupByLibrary.simpleMessage("Θέμα Συνομιλίας"),
    "chat_theme_settings": MessageLookupByLibrary.simpleMessage(
      "Ρυθμίσεις θέματος συνομιλίας",
    ),
    "chat_with": m1,
    "chats": MessageLookupByLibrary.simpleMessage("Συνομιλίες"),
    "choose_friends": MessageLookupByLibrary.simpleMessage("Επιλογή Φίλων"),
    "choose_option": MessageLookupByLibrary.simpleMessage(
      "Επιλέξτε μια επιλογή",
    ),
    "client_id_must_be_a_number": MessageLookupByLibrary.simpleMessage(
      "Το ID πελάτη πρέπει να είναι αριθμός",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Κλείσιμο"),
    "command_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Η εντολή {} δεν έχει υλοποιηθεί!",
    ),
    "command_unknown": MessageLookupByLibrary.simpleMessage("Άγνωστη εντολή!"),
    "confirm_delete_message": MessageLookupByLibrary.simpleMessage(
      "Είστε βέβαιοι ότι θέλετε να διαγράψετε οριστικά το μήνυμα;",
    ),
    "connect": MessageLookupByLibrary.simpleMessage("Σύνδεση"),
    "connection_refused": MessageLookupByLibrary.simpleMessage(
      "Η σύνδεση απέτυχε!",
    ),
    "connection_reset": MessageLookupByLibrary.simpleMessage(
      "Η σύνδεση διακόπηκε!",
    ),
    "content_type_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Ο τύπος περιεχομένου δεν έχει υλοποιηθεί!",
    ),
    "content_type_unknown": MessageLookupByLibrary.simpleMessage(
      "Άγνωστος τύπος περιεχομένου!",
    ),
    "could_not_verify_server_certificate": MessageLookupByLibrary.simpleMessage(
      "Δεν ήταν δυνατή η επαλήθευση του πιστοποιητικού διακομιστή",
    ),
    "create_account": MessageLookupByLibrary.simpleMessage(
      "Δημιουργία λογαριασμού",
    ),
    "create_account_database_full": MessageLookupByLibrary.simpleMessage(
      "Η βάση δεδομένων έφτασε τη μέγιστη χωρητικότητα! Συνεπώς, το αίτημά σας δεν μπορεί να διεκπεραιωθεί.",
    ),
    "create_account_email_exists": MessageLookupByLibrary.simpleMessage(
      "Email is already used!",
    ),
    "create_account_error": MessageLookupByLibrary.simpleMessage(
      "Ένα σφάλμα εμφανίστηκε κατά τη δημιουργία του λογαριασμού σας!",
    ),
    "create_account_success": MessageLookupByLibrary.simpleMessage(
      "Λογαριασμός δημιουργήθηκε με επιτυχία!",
    ),
    "credential_validation_client_id_error":
        MessageLookupByLibrary.simpleMessage(
          "Ένα σφάλμα εμφανίστηκε κατά την δημιουργία ενός ID!",
        ),
    "credential_validation_email_exists": MessageLookupByLibrary.simpleMessage(
      "Το email σας χρησιμοποιείται ήδη!",
    ),
    "credential_validation_email_invalid": MessageLookupByLibrary.simpleMessage(
      "Μη έγκυρη διεύθυνση email",
    ),
    "credential_validation_password_invalid":
        MessageLookupByLibrary.simpleMessage(
          "Οι προϋποθέσεις για το κωδικό χρήστη δεν πληρούνται!",
        ),
    "credential_validation_success": MessageLookupByLibrary.simpleMessage(
      "Επιτυχής ανταλλαγή διαπιστευτηρίων!",
    ),
    "credential_validation_username_invalid":
        MessageLookupByLibrary.simpleMessage(
          "Οι προϋποθέσεις για το όνομα χρήστη δεν πληρούνται!",
        ),
    "custom": MessageLookupByLibrary.simpleMessage("Προσαρμοσμένο"),
    "decline": MessageLookupByLibrary.simpleMessage("Απόρριψη"),
    "decompression_failed": MessageLookupByLibrary.simpleMessage(
      "Η αποσυμπίεση απέτυχε",
    ),
    "default_monotone": MessageLookupByLibrary.simpleMessage(
      "Προεπιλογή/Μονότονο",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Διαγραφή"),
    "delete_chat": MessageLookupByLibrary.simpleMessage("Διαγραφή συνομιλίας"),
    "delete_this_chat_question": MessageLookupByLibrary.simpleMessage(
      "Να διαγραφεί αυτή η συνομιλία;",
    ),
    "deleting_this_chat_will_permanently_delete_all_prior_messages":
        MessageLookupByLibrary.simpleMessage(
          "Η διαγραφή αυτής της συνομιλίας θα διαγράψει μόνιμα όλα τα προηγούμενα μηνύματα",
        ),
    "display_name": MessageLookupByLibrary.simpleMessage("Εμφανιζόμενο όνομα"),
    "display_part_of_messages_in_notifications":
        MessageLookupByLibrary.simpleMessage(
          "Εμφάνιση μέρους του μηνύματος στις ειδοποιήσεις",
        ),
    "donate_to_ermis_project": MessageLookupByLibrary.simpleMessage(
      "Δωρεά στο έργο Ermis",
    ),
    "donate_to_hoster": MessageLookupByLibrary.simpleMessage(
      "Δωρεά στον πάροχο",
    ),
    "donations": MessageLookupByLibrary.simpleMessage("Δωρεές"),
    "downloaded_file": MessageLookupByLibrary.simpleMessage(
      "Το αρχείο κατέβηκε",
    ),
    "email": MessageLookupByLibrary.simpleMessage("Email"),
    "email_address": MessageLookupByLibrary.simpleMessage("Διεύθυνση email"),
    "email_is_empty": MessageLookupByLibrary.simpleMessage(
      "Το email είναι κενό!",
    ),
    "email_mismatch": MessageLookupByLibrary.simpleMessage(
      "Το email που εισαγάγατε δεν ταιριάζει με το πραγματικό email!",
    ),
    "enter_client_id": MessageLookupByLibrary.simpleMessage(
      "Εισαγάγετε το ID πελάτη",
    ),
    "enter_verification_code": MessageLookupByLibrary.simpleMessage(
      "Εισαγάγετε τον κωδικό επαλήθευσης",
    ),
    "enter_verification_code_sent_to_your_email":
        MessageLookupByLibrary.simpleMessage(
          "Εισαγάγετε τον κωδικό επαλήθευσης που στάλθηκε στο email σας",
        ),
    "entropy_rough_estimate": m2,
    "error_saving_file": MessageLookupByLibrary.simpleMessage(
      "Παρουσιάστηκε σφάλμα κατά την αποθήκευση του αρχείου",
    ),
    "faq_contact_terms_privacy": MessageLookupByLibrary.simpleMessage(
      "Συχνές ερωτήσεις, επικοινωνία, όροι και πολιτική απορρήτου",
    ),
    "feature_audio_messages": MessageLookupByLibrary.simpleMessage(
      "Υποστήριξη ηχητικών μηνυμάτων",
    ),
    "feature_chat_themes": MessageLookupByLibrary.simpleMessage(
      "Νέα θέματα συνομιλίας",
    ),
    "feature_encryption": MessageLookupByLibrary.simpleMessage(
      "Βελτιωμένα πρωτόκολλα κρυπτογράφησης",
    ),
    "feature_languages": MessageLookupByLibrary.simpleMessage(
      "Υποστήριξη πολλαπλών γλωσσών!",
    ),
    "feature_voice_calls": MessageLookupByLibrary.simpleMessage(
      "Φωνητικές κλήσεις",
    ),
    "file_received": m3,
    "functionality_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Η λειτουργία δεν έχει υλοποιηθεί ακόμα!",
    ),
    "gallery": MessageLookupByLibrary.simpleMessage("Γκαλερί"),
    "got_it_button": MessageLookupByLibrary.simpleMessage("Το κατάλαβα!"),
    "gradient": MessageLookupByLibrary.simpleMessage("Διαβάθμιση"),
    "help": MessageLookupByLibrary.simpleMessage("Βοήθεια"),
    "help_settings": MessageLookupByLibrary.simpleMessage("Ρυθμίσεις βοήθειας"),
    "incompatible_server_version_warning": MessageLookupByLibrary.simpleMessage(
      "Ασύμβατη έκδοση διακομιστή! Ορισμένα πράγματα ενδέχεται να μην λειτουργούν όπως αναμένεται!",
    ),
    "license_capitalized": MessageLookupByLibrary.simpleMessage("Άδεια"),
    "license_crux": MessageLookupByLibrary.simpleMessage("Ουσία άδειας"),
    "link_new_device": MessageLookupByLibrary.simpleMessage(
      "Σύνδεση νέας συσκευής",
    ),
    "linked_devices": MessageLookupByLibrary.simpleMessage(
      "Συνδεδεμένες συσκευές",
    ),
    "linked_devices_logout_all": MessageLookupByLibrary.simpleMessage(
      "Αποσύνδεση από όλες τις συσκευές",
    ),
    "linked_devices_logout_all_confirm": MessageLookupByLibrary.simpleMessage(
      "Είστε βέβαιοι ότι θέλετε να αποσυνδεθείτε από όλες τις συσκευές;",
    ),
    "linked_devices_logout_confirm": MessageLookupByLibrary.simpleMessage(
      "Είστε βέβαιοι ότι θέλετε να αποσυνδεθείτε από ",
    ),
    "login": MessageLookupByLibrary.simpleMessage("Σύνδεση"),
    "login_account_not_found": MessageLookupByLibrary.simpleMessage(
      "το καταχωρημένο email δεν υφίσταται!",
    ),
    "login_add_device_info": MessageLookupByLibrary.simpleMessage(
      "Προσθήκη πληροφοριών συσκευής",
    ),
    "login_backup_code_incorrect": MessageLookupByLibrary.simpleMessage(
      "Λανθασμένος κωδικός επαλήθευσης αντιγράφων ασφαλείας.",
    ),
    "login_email_incorrect": MessageLookupByLibrary.simpleMessage(
      "Λανθασμένο email!",
    ),
    "login_error": MessageLookupByLibrary.simpleMessage(
      "Προέκυψε σφάλμα κατά τη σύνδεση στο λογαριασμό σας!",
    ),
    "login_fetch_requirements": MessageLookupByLibrary.simpleMessage(
      "Φέρτε απαιτήσεις",
    ),
    "login_password_incorrect": MessageLookupByLibrary.simpleMessage(
      "Λανθασμένος κωδικός πρόσβασης.",
    ),
    "login_success": MessageLookupByLibrary.simpleMessage(
      "Συνδεθήκατε επιτυχώς στο λογαριασμό!",
    ),
    "login_toggle_password": MessageLookupByLibrary.simpleMessage(
      "Εναλλαγή τύπου κωδικού πρόσβασης",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("αποσύνδεση"),
    "logout_capitalized": MessageLookupByLibrary.simpleMessage("Αποσύνδεση"),
    "logout_confirmation_all_devices": MessageLookupByLibrary.simpleMessage(
      "Είστε σίγουροι ότι θέλετε να αποσυνδεθείτε από το \${device.formattedInfo()}?",
    ),
    "logout_confirmation_device": MessageLookupByLibrary.simpleMessage(
      "Είστε σίγουροι ότι θέλετε να αποσυνδεθείτε από το \${device.formattedInfo()}?",
    ),
    "logout_from_all_devices": MessageLookupByLibrary.simpleMessage(
      "Αποσύνδεση από όλες τις συσκευές",
    ),
    "logout_from_this_device": MessageLookupByLibrary.simpleMessage(
      "Αποσύνδεση από αυτή τη συσκευή",
    ),
    "manage_storage": MessageLookupByLibrary.simpleMessage(
      "Διαχείριση αποθήκευσης",
    ),
    "many_bug_fixes": MessageLookupByLibrary.simpleMessage(
      "Πολλές διορθώσεις σφαλμάτων!",
    ),
    "message_by": m4,
    "message_copied": MessageLookupByLibrary.simpleMessage(
      "Το μήνυμα αντιγράφηκε στο πρόχειρο",
    ),
    "message_deletion_unsuccessful": MessageLookupByLibrary.simpleMessage(
      "Η διαγραφή του μηνύματος απέτυχε",
    ),
    "message_group_call_tones": MessageLookupByLibrary.simpleMessage(
      "Ήχοι μηνυμάτων, ομάδων και κλήσεων",
    ),
    "message_length_exceeded": MessageLookupByLibrary.simpleMessage(
      "Το μήκος του μηνύματος υπερβαίνει το μέγιστο μήκος (%d χαρακτήρες)",
    ),
    "message_type_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Ο τύπος μηνύματος δεν έχει υλοποιηθεί!",
    ),
    "message_type_unknown": MessageLookupByLibrary.simpleMessage(
      "Άγνωστος τύπος μηνύματος!",
    ),
    "min_entropy": m5,
    "name": MessageLookupByLibrary.simpleMessage("Όνομα"),
    "name_enter": MessageLookupByLibrary.simpleMessage("Εισάγετε το όνομά σας"),
    "network_usage_auto_download": MessageLookupByLibrary.simpleMessage(
      "Χρήση δικτύου, αυτόματη λήψη",
    ),
    "new_chat": MessageLookupByLibrary.simpleMessage("Νέα συνομιλία"),
    "new_group": MessageLookupByLibrary.simpleMessage("Νέα Ομάδα"),
    "new_message": MessageLookupByLibrary.simpleMessage("Νέο μήνυμα!"),
    "no_chat_requests_available": MessageLookupByLibrary.simpleMessage(
      "Δεν υπάρχουν εκκρεμείς αιτήσεις συνομιλίας",
    ),
    "no_chats_available_incompatible_server_version":
        MessageLookupByLibrary.simpleMessage(
          "Δεν υπάρχουν συνομιλίες διαθέσιμες, ασύμβατη έκδοση διακομιστή",
        ),
    "no_conversations_available": MessageLookupByLibrary.simpleMessage(
      "Δεν υπάρχουν διαθέσιμες συνομιλίες",
    ),
    "no_linked_devices": MessageLookupByLibrary.simpleMessage(
      "Δεν υπάρχουν συνδεδεμένες συσκευές",
    ),
    "notification_enable": MessageLookupByLibrary.simpleMessage(
      "Ενεργοποίηση ειδοποιήσεων",
    ),
    "notification_preview_display_part": MessageLookupByLibrary.simpleMessage(
      "Εμφάνιση μέρους του μηνύματος στις ειδοποιήσεις",
    ),
    "notification_preview_show": MessageLookupByLibrary.simpleMessage(
      "Εμφάνιση προεπισκοπήσεων μηνυμάτων",
    ),
    "notification_settings": MessageLookupByLibrary.simpleMessage(
      "Ρυθμίσεις ειδοποιήσεων",
    ),
    "notification_sound": MessageLookupByLibrary.simpleMessage(
      "Ήχος ειδοποίησης",
    ),
    "notification_sound_select": MessageLookupByLibrary.simpleMessage(
      "Επιλογή ήχου ειδοποίησης",
    ),
    "notifications": MessageLookupByLibrary.simpleMessage("Ειδοποιήσεις"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "optimizations_on_data_usage": MessageLookupByLibrary.simpleMessage(
      "Σημαντικές βελτιστοποιήσεις στη χρήση δεδομένων!",
    ),
    "or": MessageLookupByLibrary.simpleMessage("Ή"),
    "other": MessageLookupByLibrary.simpleMessage("Άλλα"),
    "other_settings": MessageLookupByLibrary.simpleMessage("Άλλες ρυθμίσεις"),
    "password": MessageLookupByLibrary.simpleMessage("Κωδικός πρόσβασης"),
    "password_is_empty": MessageLookupByLibrary.simpleMessage(
      "Ο κωδικός πρόσβασης είναι κενός!",
    ),
    "password_validation_invalid": MessageLookupByLibrary.simpleMessage(
      "Οι απαιτήσεις για τον κωδικό δεν πληρούνται!",
    ),
    "password_validation_success": MessageLookupByLibrary.simpleMessage(
      "Ο κωδικός επιβεβαιώθηκε με επιτυχία!",
    ),
    "please_enter_the_verification_code": MessageLookupByLibrary.simpleMessage(
      "Παρακαλώ εισαγάγετε τον κωδικό επαλήθευσης",
    ),
    "privacy": MessageLookupByLibrary.simpleMessage("Απόρρητο"),
    "privacy_security_change_number": MessageLookupByLibrary.simpleMessage(
      "Απόρρητο, ασφάλεια, αλλαγή αριθμού",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("Προφίλ"),
    "profile_about": MessageLookupByLibrary.simpleMessage("Σχετικά"),
    "profile_camera": MessageLookupByLibrary.simpleMessage("Κάμερα"),
    "profile_change_name_id": MessageLookupByLibrary.simpleMessage(
      "Προφίλ, αλλαγή ονόματος, ID",
    ),
    "profile_gallery": MessageLookupByLibrary.simpleMessage("Συλλογή"),
    "profile_hey_there": MessageLookupByLibrary.simpleMessage("Γεια σου!"),
    "profile_id_copied": MessageLookupByLibrary.simpleMessage(
      "Το ID αντιγράφηκε στο πρόχειρο",
    ),
    "profile_name": MessageLookupByLibrary.simpleMessage("Όνομα"),
    "profile_name_enter": MessageLookupByLibrary.simpleMessage(
      "Εισάγετε το όνομά σας",
    ),
    "profile_photo": MessageLookupByLibrary.simpleMessage("Φωτογραφία προφίλ"),
    "profile_photo_fetch_error": MessageLookupByLibrary.simpleMessage(
      "Προέκυψε σφάλμα κατά την ανάκτηση της φωτογραφίας προφίλ από τη βάση δεδομένων!",
    ),
    "profile_settings": MessageLookupByLibrary.simpleMessage(
      "Ρυθμίσεις προφίλ",
    ),
    "registration_failed": m6,
    "requests": MessageLookupByLibrary.simpleMessage("Αιτήματα"),
    "resend_code": MessageLookupByLibrary.simpleMessage("Επαναποστολή κωδικού"),
    "save": MessageLookupByLibrary.simpleMessage("Αποθήκευση"),
    "search": MessageLookupByLibrary.simpleMessage("Αναζήτηση..."),
    "select_an_option": MessageLookupByLibrary.simpleMessage(
      "Επιλέξτε μια επιλογή",
    ),
    "send_chat_request": MessageLookupByLibrary.simpleMessage(
      "Αποστολή αιτήματος συνομιλίας",
    ),
    "server_add": MessageLookupByLibrary.simpleMessage("Προσθήκη διακομιστή"),
    "server_add_success": MessageLookupByLibrary.simpleMessage(
      "Ο διακομιστής προστέθηκε με επιτυχία!",
    ),
    "server_certificate_check": MessageLookupByLibrary.simpleMessage(
      "Έλεγχος πιστοποιητικού",
    ),
    "server_source_code": MessageLookupByLibrary.simpleMessage(
      "Πηγαίος κώδικας διακομιστή",
    ),
    "server_url_choose": MessageLookupByLibrary.simpleMessage(
      "Επιλέξτε διεύθυνση URL διακομιστή",
    ),
    "server_url_enter": MessageLookupByLibrary.simpleMessage(
      "Εισάγετε τη διεύθυνση URL του διακομιστή",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Ρυθμίσεις"),
    "settings_save": MessageLookupByLibrary.simpleMessage(
      "Αποθήκευση ρυθμίσεων",
    ),
    "settings_saved": MessageLookupByLibrary.simpleMessage(
      "Οι ρυθμίσεις αποθηκεύτηκαν",
    ),
    "sign_out": MessageLookupByLibrary.simpleMessage("Αποσύνδεση"),
    "source_code": MessageLookupByLibrary.simpleMessage("Πηγαίος κώδικας"),
    "storage_data": MessageLookupByLibrary.simpleMessage(
      "Αποθήκευση και δεδομένα",
    ),
    "submit": MessageLookupByLibrary.simpleMessage("Υποβολή"),
    "temp_banned": MessageLookupByLibrary.simpleMessage(
      "Χαλαρώστε λίγο! Έχετε αποκλειστεί προσωρινά από την αλληλεπίδραση με τον διακομιστή για μικρό χρονικό διάστημα.",
    ),
    "theme_dark": MessageLookupByLibrary.simpleMessage("Σκούρο θέμα"),
    "theme_light": MessageLookupByLibrary.simpleMessage("Φωτεινό θέμα"),
    "theme_mode": MessageLookupByLibrary.simpleMessage("Λειτουργία θέματος"),
    "theme_system_default": MessageLookupByLibrary.simpleMessage(
      "Προεπιλογή συστήματος",
    ),
    "theme_wallpapers_chat_history": MessageLookupByLibrary.simpleMessage(
      "Θέμα, ταπετσαρίες, ιστορικό συνομιλιών",
    ),
    "today": MessageLookupByLibrary.simpleMessage("Σήμερα"),
    "type_message": MessageLookupByLibrary.simpleMessage(
      "Γράψτε ένα μήνυμα...",
    ),
    "unknown_size": MessageLookupByLibrary.simpleMessage("Άγνωστο μέγεθος"),
    "use_backup_verification_code": MessageLookupByLibrary.simpleMessage(
      "Χρήση κωδικού επαλήθευσης αντιγράφου ασφαλείας",
    ),
    "use_password": MessageLookupByLibrary.simpleMessage(
      "Χρήση κωδικού πρόσβασης",
    ),
    "username_same_as_old": MessageLookupByLibrary.simpleMessage(
      "Το όνομα χρήστη δεν μπορεί να είναι το ίδιο με το παλιό όνομα χρήστη!",
    ),
    "username_validation_invalid": MessageLookupByLibrary.simpleMessage(
      "Οι απαιτήσεις για το όνομα χρήστη δεν πληρούνται!",
    ),
    "username_validation_success": MessageLookupByLibrary.simpleMessage(
      "Το όνομα χρήστη επιβεβαιώθηκε με επιτυχία!",
    ),
    "verification": MessageLookupByLibrary.simpleMessage("Επαλήθευση"),
    "verification_attempts_exhausted": MessageLookupByLibrary.simpleMessage(
      "Ξεμείνατε από προσπάθειες!",
    ),
    "verification_code_incorrect": MessageLookupByLibrary.simpleMessage(
      "Λανθασμένος κωδικός επαλήθευσης!",
    ),
    "verification_code_must_be_number": MessageLookupByLibrary.simpleMessage(
      "Ο κωδικός επαλήθευσης πρέπει να είναι αριθμός",
    ),
    "verification_email_invalid": MessageLookupByLibrary.simpleMessage(
      "Μη έγκυρη διεύθυνση email",
    ),
    "verification_resend_code": MessageLookupByLibrary.simpleMessage(
      "Επαναποστολή κωδικού",
    ),
    "verification_success": MessageLookupByLibrary.simpleMessage(
      "Επιτυχής επικύρωση!",
    ),
    "version_capitalized": MessageLookupByLibrary.simpleMessage("Έκδοση"),
    "vibration": MessageLookupByLibrary.simpleMessage("Δόνηση"),
    "vibration_unavailable": MessageLookupByLibrary.simpleMessage(
      "Η δόνηση δεν είναι διαθέσιμη σε αυτήν τη συσκευή",
    ),
    "whats_new": MessageLookupByLibrary.simpleMessage("Νέα"),
    "whats_new_system_messages": MessageLookupByLibrary.simpleMessage(
      "Νέα μηνύματα συστήματος",
    ),
    "whats_new_title": MessageLookupByLibrary.simpleMessage(
      "Νέες λειτουργίες στο Hermis",
    ),
  };
}
