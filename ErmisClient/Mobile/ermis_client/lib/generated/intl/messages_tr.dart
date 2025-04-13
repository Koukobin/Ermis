// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a tr locale. All the
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
  String get localeName => 'tr';

  static String m0(deviceInfo) =>
      "${deviceInfo} cihazından çıkış yapmak istediğinize emin misiniz?";

  static String m1(username) => "${username} ile sohbet";

  static String m2(entropy) => "Entropi: ${entropy} (Kaba tahmin)";

  static String m3(fileName) => "Dosya alındı ${fileName}";

  static String m4(username) => "${username} tarafından mesaj";

  static String m5(minEntropy) => "Minimum entropi: ${minEntropy}";

  static String m6(resultMessage) => "Kayıt başarısız oldu: ${resultMessage}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "abstract": MessageLookupByLibrary.simpleMessage("Soyut"),
    "accept": MessageLookupByLibrary.simpleMessage("Kabul et"),
    "account": MessageLookupByLibrary.simpleMessage("Hesap"),
    "account_add": MessageLookupByLibrary.simpleMessage("Yeni hesap ekle"),
    "account_confirm_proceed": MessageLookupByLibrary.simpleMessage(
      "Devam etmek istediğinizden emin misiniz?",
    ),
    "account_delete": MessageLookupByLibrary.simpleMessage("Hesabı sil"),
    "account_delete_bullet1": MessageLookupByLibrary.simpleMessage(
      "Hesabınızı kurtarılamayacak şekilde silin",
    ),
    "account_delete_bullet2": MessageLookupByLibrary.simpleMessage(
      "Mesaj geçmişinizi silin",
    ),
    "account_delete_bullet3": MessageLookupByLibrary.simpleMessage(
      "Tüm sohbetlerinizi silin",
    ),
    "account_delete_confirmation": MessageLookupByLibrary.simpleMessage(
      "Bu hesabı silmek şunları yapacak:",
    ),
    "account_delete_error": MessageLookupByLibrary.simpleMessage(
      "Hesabınızı silmeye çalışırken bir hata oluştu!",
    ),
    "account_delete_my": MessageLookupByLibrary.simpleMessage("Hesabımı Sil"),
    "account_settings": MessageLookupByLibrary.simpleMessage("Hesap Ayarları"),
    "add_user": MessageLookupByLibrary.simpleMessage("Kullanıcı Ekle"),
    "address_not_recognized": MessageLookupByLibrary.simpleMessage(
      "Adres tanınmadı!",
    ),
    "app_info": MessageLookupByLibrary.simpleMessage("Uygulama Bilgisi"),
    "app_language": MessageLookupByLibrary.simpleMessage("Uygulama dili"),
    "are_you_sure_you_want_to_logout_from": m0,
    "are_you_sure_you_want_to_logout_from_all_devices":
        MessageLookupByLibrary.simpleMessage(
          "Tüm cihazlardan çıkış yapmak istediğinizden emin misiniz?",
        ),
    "attempting_delete_message": MessageLookupByLibrary.simpleMessage(
      "Mesaj silinmeye çalışılıyor",
    ),
    "authentication_stage_create_account": MessageLookupByLibrary.simpleMessage(
      "Hesap oluştur",
    ),
    "authentication_stage_credentials_exchange":
        MessageLookupByLibrary.simpleMessage("Kimlik bilgisi değişimi"),
    "authentication_stage_credentials_validation":
        MessageLookupByLibrary.simpleMessage("Kimlik bilgisi doğrulama"),
    "authentication_stage_login": MessageLookupByLibrary.simpleMessage(
      "Giriş yap",
    ),
    "backup_verification_code": MessageLookupByLibrary.simpleMessage(
      "Yedek doğrulama kodu",
    ),
    "backup_verification_code_regenerate_error":
        MessageLookupByLibrary.simpleMessage(
          "Kullanıcı adını değiştirmeye çalışırken bir hata oluştu!",
        ),
    "backup_verification_code_regenerate_success":
        MessageLookupByLibrary.simpleMessage(
          "Yedek doğrulama kodları başarıyla yeniden oluşturuldu!",
        ),
    "camera": MessageLookupByLibrary.simpleMessage("Kamera"),
    "cancel": MessageLookupByLibrary.simpleMessage("İptal"),
    "change_password_error": MessageLookupByLibrary.simpleMessage(
      "Şifreyi değiştirmeye çalışırken bir hata oluştu!",
    ),
    "change_password_success": MessageLookupByLibrary.simpleMessage(
      "Şifre başarıyla değiştirildi!",
    ),
    "change_username_error": MessageLookupByLibrary.simpleMessage(
      "Kullanıcı adını değiştirmeye çalışırken bir hata oluştu!",
    ),
    "change_username_invalid": MessageLookupByLibrary.simpleMessage(
      "Kullanıcı adı gereksinimleri karşılanmadı",
    ),
    "change_username_success": MessageLookupByLibrary.simpleMessage(
      "Kullanıcı adı başarıyla değiştirildi!",
    ),
    "chat_backdrop": MessageLookupByLibrary.simpleMessage("Sohbet Arka Planı"),
    "chat_backdrop_choose_image": MessageLookupByLibrary.simpleMessage(
      "Resim Seç",
    ),
    "chat_backdrop_color_pick": MessageLookupByLibrary.simpleMessage(
      "Bir renk seç!",
    ),
    "chat_backdrop_gradient_end_color": MessageLookupByLibrary.simpleMessage(
      "Bitiş Rengi",
    ),
    "chat_backdrop_gradient_preview": MessageLookupByLibrary.simpleMessage(
      "Gradyan Önizleme",
    ),
    "chat_backdrop_gradient_start_color": MessageLookupByLibrary.simpleMessage(
      "Başlangıç Rengi",
    ),
    "chat_backdrop_save_changes": MessageLookupByLibrary.simpleMessage(
      "Değişiklikleri Kaydet",
    ),
    "chat_backdrop_select_gradient": MessageLookupByLibrary.simpleMessage(
      "Gradyan Renkleri Seç",
    ),
    "chat_backdrop_upload_coming_soon": MessageLookupByLibrary.simpleMessage(
      "Özel resim yükleme yakında geliyor!",
    ),
    "chat_backdrop_upload_custom": MessageLookupByLibrary.simpleMessage(
      "Özel Resim Yükle",
    ),
    "chat_request_accept_error": MessageLookupByLibrary.simpleMessage(
      "Sohbet isteğini kabul etmeye çalışırken bir hata oluştu!",
    ),
    "chat_request_decline_error": MessageLookupByLibrary.simpleMessage(
      "Sohbet isteğini reddetmeye çalışırken bir hata oluştu!",
    ),
    "chat_session_delete_error": MessageLookupByLibrary.simpleMessage(
      "Sohbet oturumunu silmeye çalışırken bir hata oluştu!",
    ),
    "chat_session_not_found": MessageLookupByLibrary.simpleMessage(
      "Seçilen sohbet oturumu mevcut değil. (Diğer kullanıcı tarafından silinmiş olabilir)",
    ),
    "chat_theme": MessageLookupByLibrary.simpleMessage("Sohbet Teması"),
    "chat_theme_settings": MessageLookupByLibrary.simpleMessage(
      "Sohbet Tema Ayarları",
    ),
    "chat_with": m1,
    "chats": MessageLookupByLibrary.simpleMessage("Sohbetler"),
    "choose_friends": MessageLookupByLibrary.simpleMessage("Arkadaşları Seç"),
    "choose_option": MessageLookupByLibrary.simpleMessage("Bir seçenek seçin"),
    "client_id_must_be_a_number": MessageLookupByLibrary.simpleMessage(
      "Müşteri kimliği bir sayı olmalıdır",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Kapat"),
    "command_not_implemented": MessageLookupByLibrary.simpleMessage(
      "{} komutu uygulanmadı!",
    ),
    "command_unknown": MessageLookupByLibrary.simpleMessage(
      "Komut bilinmiyor!",
    ),
    "confirm_delete_message": MessageLookupByLibrary.simpleMessage(
      "Mesajı kalıcı olarak silmek istediğinizden emin misiniz?",
    ),
    "connect": MessageLookupByLibrary.simpleMessage("Bağlan"),
    "connection_refused": MessageLookupByLibrary.simpleMessage(
      "Bağlantı Reddedildi!",
    ),
    "connection_reset": MessageLookupByLibrary.simpleMessage(
      "Bağlantı Sıfırlandı!",
    ),
    "content_type_not_implemented": MessageLookupByLibrary.simpleMessage(
      "İçerik türü uygulanmadı!",
    ),
    "content_type_unknown": MessageLookupByLibrary.simpleMessage(
      "İçerik türü bilinmiyor!",
    ),
    "could_not_verify_server_certificate": MessageLookupByLibrary.simpleMessage(
      "Sunucu sertifikası doğrulanamadı",
    ),
    "create_account": MessageLookupByLibrary.simpleMessage("Hesap oluştur"),
    "create_account_database_full": MessageLookupByLibrary.simpleMessage(
      "Veritabanı maksimum kapasitesine ulaştı! Maalesef isteğiniz işlenemedi.",
    ),
    "create_account_email_exists": MessageLookupByLibrary.simpleMessage(
      "E-posta zaten kullanılıyor!",
    ),
    "create_account_error": MessageLookupByLibrary.simpleMessage(
      "Hesabınız oluşturulurken bir hata oluştu!",
    ),
    "create_account_success": MessageLookupByLibrary.simpleMessage(
      "Hesap başarıyla oluşturuldu!",
    ),
    "credential_validation_client_id_error":
        MessageLookupByLibrary.simpleMessage(
          "İstemci kimliği oluşturulamıyor!",
        ),
    "credential_validation_email_exists": MessageLookupByLibrary.simpleMessage(
      "E-posta zaten kullanılıyor!",
    ),
    "credential_validation_email_invalid": MessageLookupByLibrary.simpleMessage(
      "Geçersiz e-posta adresi",
    ),
    "credential_validation_password_invalid":
        MessageLookupByLibrary.simpleMessage(
          "Şifre gereksinimleri karşılanmadı!",
        ),
    "credential_validation_success": MessageLookupByLibrary.simpleMessage(
      "Kimlik bilgileri başarıyla değiştirildi!",
    ),
    "credential_validation_username_invalid":
        MessageLookupByLibrary.simpleMessage(
          "Kullanıcı adı gereksinimleri karşılanmadı!",
        ),
    "custom": MessageLookupByLibrary.simpleMessage("Özel"),
    "decline": MessageLookupByLibrary.simpleMessage("Reddet"),
    "decompression_failed": MessageLookupByLibrary.simpleMessage(
      "Sıkıştırma açma başarısız oldu",
    ),
    "default_monotone": MessageLookupByLibrary.simpleMessage(
      "Varsayılan/Tek Renkli",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Sil"),
    "delete_chat": MessageLookupByLibrary.simpleMessage("Sohbeti sil"),
    "delete_this_chat_question": MessageLookupByLibrary.simpleMessage(
      "Bu sohbeti silinsin mi?",
    ),
    "deleting_this_chat_will_permanently_delete_all_prior_messages":
        MessageLookupByLibrary.simpleMessage(
          "Bu sohbeti silmek, önceki tüm mesajları kalıcı olarak silecektir",
        ),
    "display_name": MessageLookupByLibrary.simpleMessage("Görünen ad"),
    "display_part_of_messages_in_notifications":
        MessageLookupByLibrary.simpleMessage(
          "Bildirimlerde mesajın bir kısmını göster",
        ),
    "donate_to_ermis_project": MessageLookupByLibrary.simpleMessage(
      "Ermis Projesine Bağış Yap",
    ),
    "donate_to_hoster": MessageLookupByLibrary.simpleMessage(
      "Barındırıcıya Bağış Yap",
    ),
    "donations": MessageLookupByLibrary.simpleMessage("Bağışlar"),
    "downloaded_file": MessageLookupByLibrary.simpleMessage("Dosya indirildi"),
    "email": MessageLookupByLibrary.simpleMessage("E-posta"),
    "email_address": MessageLookupByLibrary.simpleMessage("E-posta adresi"),
    "email_is_empty": MessageLookupByLibrary.simpleMessage("E-posta boş!"),
    "email_mismatch": MessageLookupByLibrary.simpleMessage(
      "Girilen e-posta gerçek e-posta ile eşleşmiyor!",
    ),
    "enter_client_id": MessageLookupByLibrary.simpleMessage(
      "Müşteri kimliğini girin",
    ),
    "enter_verification_code": MessageLookupByLibrary.simpleMessage(
      "Doğrulama kodunu girin",
    ),
    "enter_verification_code_sent_to_your_email":
        MessageLookupByLibrary.simpleMessage(
          "E-postanıza gönderilen doğrulama kodunu girin",
        ),
    "entropy_rough_estimate": m2,
    "error_saving_file": MessageLookupByLibrary.simpleMessage(
      "Dosya kaydedilirken bir hata oluştu",
    ),
    "faq_contact_terms_privacy": MessageLookupByLibrary.simpleMessage(
      "SSS, bize ulaşın, şartlar ve gizlilik politikası",
    ),
    "feature_audio_messages": MessageLookupByLibrary.simpleMessage(
      "Sesli mesaj desteği",
    ),
    "feature_chat_themes": MessageLookupByLibrary.simpleMessage(
      "Yeni sohbet temaları",
    ),
    "feature_encryption": MessageLookupByLibrary.simpleMessage(
      "Geliştirilmiş şifreleme protokolleri",
    ),
    "feature_languages": MessageLookupByLibrary.simpleMessage(
      "Çoklu dil desteği!",
    ),
    "feature_voice_calls": MessageLookupByLibrary.simpleMessage(
      "Sesli aramalar (Erken Erişim)",
    ),
    "file_received": m3,
    "functionality_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Bu işlev henüz uygulanmadı!",
    ),
    "gallery": MessageLookupByLibrary.simpleMessage("Galeri"),
    "got_it_button": MessageLookupByLibrary.simpleMessage("Anladım!"),
    "gradient": MessageLookupByLibrary.simpleMessage("Gradyan"),
    "help": MessageLookupByLibrary.simpleMessage("Yardım"),
    "help_settings": MessageLookupByLibrary.simpleMessage("Yardım Ayarları"),
    "incompatible_server_version_warning": MessageLookupByLibrary.simpleMessage(
      "Uyumsuz sunucu sürümü! Bazı şeyler beklendiği gibi çalışmayabilir!",
    ),
    "license_capitalized": MessageLookupByLibrary.simpleMessage("Lisans"),
    "license_crux": MessageLookupByLibrary.simpleMessage("Lisans özü"),
    "link_new_device": MessageLookupByLibrary.simpleMessage("Yeni cihaz bağla"),
    "linked_devices": MessageLookupByLibrary.simpleMessage("Bağlı Cihazlar"),
    "linked_devices_logout_all": MessageLookupByLibrary.simpleMessage(
      "Tüm Cihazlardan Çıkış Yap",
    ),
    "linked_devices_logout_all_confirm": MessageLookupByLibrary.simpleMessage(
      "Tüm cihazlardan çıkış yapmak istediğinizden emin misiniz?",
    ),
    "linked_devices_logout_confirm": MessageLookupByLibrary.simpleMessage(
      "Şuradan çıkış yapmak istediğinizden emin misiniz: ",
    ),
    "login": MessageLookupByLibrary.simpleMessage("Giriş yap"),
    "login_account_not_found": MessageLookupByLibrary.simpleMessage(
      "Hesap mevcut değil!",
    ),
    "login_add_device_info": MessageLookupByLibrary.simpleMessage(
      "Cihaz bilgisini ekle",
    ),
    "login_backup_code_incorrect": MessageLookupByLibrary.simpleMessage(
      "Yanlış yedek doğrulama kodu.",
    ),
    "login_email_incorrect": MessageLookupByLibrary.simpleMessage(
      "Yanlış e-posta!",
    ),
    "login_error": MessageLookupByLibrary.simpleMessage(
      "Hesabınıza giriş yaparken bir hata oluştu! Lütfen sunucu yöneticisiyle iletişime geçin ve sunucularının bozuk olduğunu bildirin.",
    ),
    "login_fetch_requirements": MessageLookupByLibrary.simpleMessage(
      "Gereksinimleri getir",
    ),
    "login_password_incorrect": MessageLookupByLibrary.simpleMessage(
      "Yanlış şifre.",
    ),
    "login_success": MessageLookupByLibrary.simpleMessage(
      "Hesabınıza başarıyla giriş yapıldı!",
    ),
    "login_toggle_password": MessageLookupByLibrary.simpleMessage(
      "Şifre türünü değiştir",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("çıkış yap"),
    "logout_capitalized": MessageLookupByLibrary.simpleMessage("Çıkış Yap"),
    "logout_confirmation_all_devices": MessageLookupByLibrary.simpleMessage(
      "\${device.formattedInfo()} cihazından çıkış yapmak istediğinize emin misiniz?",
    ),
    "logout_confirmation_device": MessageLookupByLibrary.simpleMessage(
      "\${device.formattedInfo()} cihazından çıkış yapmak istediğinize emin misiniz?",
    ),
    "logout_from_all_devices": MessageLookupByLibrary.simpleMessage(
      "Tüm Cihazlardan Çıkış Yap",
    ),
    "logout_from_this_device": MessageLookupByLibrary.simpleMessage(
      "Bu cihazdan çıkış yap",
    ),
    "manage_storage": MessageLookupByLibrary.simpleMessage("Depolamayı Yönet"),
    "message_by": m4,
    "message_copied": MessageLookupByLibrary.simpleMessage(
      "Mesaj panoya kopyalandı",
    ),
    "message_deletion_unsuccessful": MessageLookupByLibrary.simpleMessage(
      "Mesaj silme başarısız oldu",
    ),
    "message_group_call_tones": MessageLookupByLibrary.simpleMessage(
      "Mesaj, grup ve çağrı tonları",
    ),
    "message_length_exceeded": MessageLookupByLibrary.simpleMessage(
      "Mesaj uzunluğu maksimum uzunluğu aşıyor (%d karakter)",
    ),
    "message_type_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Mesaj türü uygulanmadı!",
    ),
    "message_type_unknown": MessageLookupByLibrary.simpleMessage(
      "Mesaj türü tanınmadı!",
    ),
    "min_entropy": m5,
    "name": MessageLookupByLibrary.simpleMessage("İsim"),
    "name_enter": MessageLookupByLibrary.simpleMessage("Adınızı girin"),
    "network_usage_auto_download": MessageLookupByLibrary.simpleMessage(
      "Ağ kullanımı, otomatik indirme",
    ),
    "new_chat": MessageLookupByLibrary.simpleMessage("Yeni sohbet"),
    "new_group": MessageLookupByLibrary.simpleMessage("Yeni Grup"),
    "new_message": MessageLookupByLibrary.simpleMessage("Yeni mesaj!"),
    "no_chat_requests_available": MessageLookupByLibrary.simpleMessage(
      "Bekleyen sohbet isteği yok",
    ),
    "no_chats_available_incompatible_server_version":
        MessageLookupByLibrary.simpleMessage(
          "Sohbetler mevcut değil, sunucu sürümü uyumsuz",
        ),
    "no_conversations_available": MessageLookupByLibrary.simpleMessage(
      "Mevcut konuşma yok",
    ),
    "no_linked_devices": MessageLookupByLibrary.simpleMessage(
      "Bağlı cihaz yok",
    ),
    "notification_enable": MessageLookupByLibrary.simpleMessage(
      "Bildirimleri Etkinleştir",
    ),
    "notification_preview_display_part": MessageLookupByLibrary.simpleMessage(
      "Bildirimlerde mesajın bir kısmını göster",
    ),
    "notification_preview_show": MessageLookupByLibrary.simpleMessage(
      "Mesaj Önizlemelerini Göster",
    ),
    "notification_settings": MessageLookupByLibrary.simpleMessage(
      "Bildirim Ayarları",
    ),
    "notification_sound": MessageLookupByLibrary.simpleMessage("Bildirim Sesi"),
    "notification_sound_select": MessageLookupByLibrary.simpleMessage(
      "Bildirim Sesi Seç",
    ),
    "notifications": MessageLookupByLibrary.simpleMessage("Bildirimler"),
    "ok": MessageLookupByLibrary.simpleMessage("Tamam"),
    "or": MessageLookupByLibrary.simpleMessage("Veya"),
    "other": MessageLookupByLibrary.simpleMessage("Diğer"),
    "other_settings": MessageLookupByLibrary.simpleMessage("Diğer Ayarlar"),
    "password": MessageLookupByLibrary.simpleMessage("Şifre"),
    "password_is_empty": MessageLookupByLibrary.simpleMessage("Şifre boş!"),
    "password_validation_invalid": MessageLookupByLibrary.simpleMessage(
      "Şifre gereksinimleri karşılanmadı!",
    ),
    "password_validation_success": MessageLookupByLibrary.simpleMessage(
      "Şifre başarıyla doğrulandı!",
    ),
    "please_enter_the_verification_code": MessageLookupByLibrary.simpleMessage(
      "Lütfen doğrulama kodunu girin",
    ),
    "privacy": MessageLookupByLibrary.simpleMessage("Gizlilik"),
    "privacy_security_change_number": MessageLookupByLibrary.simpleMessage(
      "Gizlilik, güvenlik, numara değiştir",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("Profil"),
    "profile_about": MessageLookupByLibrary.simpleMessage("Hakkında"),
    "profile_camera": MessageLookupByLibrary.simpleMessage("Kamera"),
    "profile_change_name_id": MessageLookupByLibrary.simpleMessage(
      "Profil, isim değiştir, ID",
    ),
    "profile_gallery": MessageLookupByLibrary.simpleMessage("Galeri"),
    "profile_hey_there": MessageLookupByLibrary.simpleMessage("Merhaba!"),
    "profile_id_copied": MessageLookupByLibrary.simpleMessage(
      "ID panoya kopyalandı",
    ),
    "profile_name": MessageLookupByLibrary.simpleMessage("İsim"),
    "profile_name_enter": MessageLookupByLibrary.simpleMessage("Adınızı girin"),
    "profile_photo": MessageLookupByLibrary.simpleMessage("Profil Fotoğrafı"),
    "profile_photo_fetch_error": MessageLookupByLibrary.simpleMessage(
      "Veritabanından profil fotoğrafı almaya çalışırken bir hata oluştu!",
    ),
    "profile_settings": MessageLookupByLibrary.simpleMessage("Profil Ayarları"),
    "registration_failed": m6,
    "requests": MessageLookupByLibrary.simpleMessage("İstekler"),
    "resend_code": MessageLookupByLibrary.simpleMessage("Kodu yeniden gönder"),
    "save": MessageLookupByLibrary.simpleMessage("Kaydet"),
    "search": MessageLookupByLibrary.simpleMessage("Ara..."),
    "select_an_option": MessageLookupByLibrary.simpleMessage(
      "Bir seçenek seçin",
    ),
    "send_chat_request": MessageLookupByLibrary.simpleMessage(
      "Sohbet isteği gönder",
    ),
    "server_add": MessageLookupByLibrary.simpleMessage("Sunucu Ekle"),
    "server_add_success": MessageLookupByLibrary.simpleMessage(
      "Sunucu başarıyla eklendi!",
    ),
    "server_certificate_check": MessageLookupByLibrary.simpleMessage(
      "Sertifikayı kontrol et",
    ),
    "server_source_code": MessageLookupByLibrary.simpleMessage(
      "Sunucu Kaynak Kodu",
    ),
    "server_url_choose": MessageLookupByLibrary.simpleMessage(
      "Sunucu URLsini seçin",
    ),
    "server_url_enter": MessageLookupByLibrary.simpleMessage(
      "Sunucu URLsini Girin",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Ayarlar"),
    "settings_save": MessageLookupByLibrary.simpleMessage("Ayarları Kaydet"),
    "settings_saved": MessageLookupByLibrary.simpleMessage(
      "Ayarlar Kaydedildi",
    ),
    "sign_out": MessageLookupByLibrary.simpleMessage("Çıkış yap"),
    "source_code": MessageLookupByLibrary.simpleMessage("Kaynak Kodu"),
    "storage_data": MessageLookupByLibrary.simpleMessage("Depolama ve Veri"),
    "submit": MessageLookupByLibrary.simpleMessage("Gönder"),
    "temp_banned": MessageLookupByLibrary.simpleMessage(
      "Biraz yavaşlayın! Kısa bir süre için sunucuyla etkileşim kurmanız geçici olarak yasaklandı.",
    ),
    "theme_dark": MessageLookupByLibrary.simpleMessage("Karanlık Mod"),
    "theme_light": MessageLookupByLibrary.simpleMessage("Aydınlık Mod"),
    "theme_mode": MessageLookupByLibrary.simpleMessage("Tema Modu"),
    "theme_system_default": MessageLookupByLibrary.simpleMessage(
      "Sistem Varsayılanı",
    ),
    "theme_wallpapers_chat_history": MessageLookupByLibrary.simpleMessage(
      "Tema, duvar kağıtları, sohbet geçmişi",
    ),
    "today": MessageLookupByLibrary.simpleMessage("Bugün"),
    "type_message": MessageLookupByLibrary.simpleMessage("Bir mesaj yazın..."),
    "unknown_size": MessageLookupByLibrary.simpleMessage("Bilinmeyen boyut"),
    "use_backup_verification_code": MessageLookupByLibrary.simpleMessage(
      "Yedek doğrulama kodunu kullan",
    ),
    "use_password": MessageLookupByLibrary.simpleMessage("Şifreyi kullan"),
    "username_same_as_old": MessageLookupByLibrary.simpleMessage(
      "Kullanıcı adı eski kullanıcı adı ile aynı olamaz!",
    ),
    "username_validation_invalid": MessageLookupByLibrary.simpleMessage(
      "Kullanıcı adı gereksinimleri karşılanmadı!",
    ),
    "username_validation_success": MessageLookupByLibrary.simpleMessage(
      "Kullanıcı adı başarıyla doğrulandı!",
    ),
    "verification": MessageLookupByLibrary.simpleMessage("Doğrulama"),
    "verification_attempts_exhausted": MessageLookupByLibrary.simpleMessage(
      "Deneme hakkı tükendi!",
    ),
    "verification_code_incorrect": MessageLookupByLibrary.simpleMessage(
      "Yanlış kod!",
    ),
    "verification_code_must_be_number": MessageLookupByLibrary.simpleMessage(
      "Doğrulama kodu bir sayı olmalıdır",
    ),
    "verification_email_invalid": MessageLookupByLibrary.simpleMessage(
      "Geçersiz e-posta adresi",
    ),
    "verification_resend_code": MessageLookupByLibrary.simpleMessage(
      "Kodu yeniden gönder",
    ),
    "verification_success": MessageLookupByLibrary.simpleMessage(
      "Başarıyla doğrulandı!",
    ),
    "version_capitalized": MessageLookupByLibrary.simpleMessage("Versiyon"),
    "vibration": MessageLookupByLibrary.simpleMessage("Titreşim"),
    "vibration_unavailable": MessageLookupByLibrary.simpleMessage(
      "Bu cihazda titreşim kullanılamıyor",
    ),
    "whats_new": MessageLookupByLibrary.simpleMessage("Ne var ne yok"),
    "whats_new_system_messages": MessageLookupByLibrary.simpleMessage(
      "Yeni sistem mesajları",
    ),
    "whats_new_title": MessageLookupByLibrary.simpleMessage(
      "Hermisteki Yeni Özellikler",
    ),
  };
}
