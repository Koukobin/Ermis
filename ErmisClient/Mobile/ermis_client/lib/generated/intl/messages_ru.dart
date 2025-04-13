// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
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
  String get localeName => 'ru';

  static String m0(deviceInfo) =>
      "Вы уверены, что хотите выйти из ${deviceInfo}?";

  static String m1(username) => "Чат с ${username}";

  static String m2(entropy) => "Энтропия: ${entropy} (Приблизительная оценка)";

  static String m3(fileName) => "Файл получен ${fileName}";

  static String m4(username) => "Сообщение от ${username}";

  static String m5(minEntropy) => "Минимальная энтропия: ${minEntropy}";

  static String m6(resultMessage) => "Регистрация не удалась: ${resultMessage}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "abstract": MessageLookupByLibrary.simpleMessage("Абстрактный"),
    "accept": MessageLookupByLibrary.simpleMessage("Принять"),
    "account": MessageLookupByLibrary.simpleMessage("Аккаунт"),
    "account_add": MessageLookupByLibrary.simpleMessage(
      "Добавить новый аккаунт",
    ),
    "account_confirm_proceed": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите продолжить?",
    ),
    "account_delete": MessageLookupByLibrary.simpleMessage("Удалить аккаунт"),
    "account_delete_bullet1": MessageLookupByLibrary.simpleMessage(
      "Полному удалению вашего аккаунта без возможности восстановления",
    ),
    "account_delete_bullet2": MessageLookupByLibrary.simpleMessage(
      "Стиранию вашей истории сообщений",
    ),
    "account_delete_bullet3": MessageLookupByLibrary.simpleMessage(
      "Удалению всех ваших чатов",
    ),
    "account_delete_confirmation": MessageLookupByLibrary.simpleMessage(
      "Удаление этого аккаунта приведет к:",
    ),
    "account_delete_error": MessageLookupByLibrary.simpleMessage(
      "Произошла ошибка при попытке удалить ваш аккаунт!",
    ),
    "account_delete_my": MessageLookupByLibrary.simpleMessage(
      "Удалить мой аккаунт",
    ),
    "account_settings": MessageLookupByLibrary.simpleMessage(
      "Настройки аккаунта",
    ),
    "add_user": MessageLookupByLibrary.simpleMessage("Добавить пользователя"),
    "address_not_recognized": MessageLookupByLibrary.simpleMessage(
      "Адрес не распознан!",
    ),
    "app_info": MessageLookupByLibrary.simpleMessage("Информация о приложении"),
    "app_language": MessageLookupByLibrary.simpleMessage("Язык приложения"),
    "are_you_sure_you_want_to_logout_from": m0,
    "are_you_sure_you_want_to_logout_from_all_devices":
        MessageLookupByLibrary.simpleMessage(
          "Вы уверены, что хотите выйти со всех устройств?",
        ),
    "attempting_delete_message": MessageLookupByLibrary.simpleMessage(
      "Попытка удалить сообщение",
    ),
    "authentication_stage_create_account": MessageLookupByLibrary.simpleMessage(
      "Создание аккаунта",
    ),
    "authentication_stage_credentials_exchange":
        MessageLookupByLibrary.simpleMessage("Обмен учетными данными"),
    "authentication_stage_credentials_validation":
        MessageLookupByLibrary.simpleMessage("Проверка учетных данных"),
    "authentication_stage_login": MessageLookupByLibrary.simpleMessage(
      "Авторизация",
    ),
    "backup_verification_code": MessageLookupByLibrary.simpleMessage(
      "Резервный код верификации",
    ),
    "backup_verification_code_regenerate_error":
        MessageLookupByLibrary.simpleMessage(
          "Произошла ошибка при смене имени пользователя!",
        ),
    "backup_verification_code_regenerate_success":
        MessageLookupByLibrary.simpleMessage(
          "Резервные коды подтверждения успешно сгенерированы заново!",
        ),
    "camera": MessageLookupByLibrary.simpleMessage("Камера"),
    "cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
    "change_password_error": MessageLookupByLibrary.simpleMessage(
      "Произошла ошибка при смене пароля!",
    ),
    "change_password_success": MessageLookupByLibrary.simpleMessage(
      "Пароль успешно изменен!",
    ),
    "change_username_error": MessageLookupByLibrary.simpleMessage(
      "Произошла ошибка при смене имени пользователя!",
    ),
    "change_username_invalid": MessageLookupByLibrary.simpleMessage(
      "Имя пользователя не соответствует требованиям!",
    ),
    "change_username_success": MessageLookupByLibrary.simpleMessage(
      "Имя пользователя успешно изменено!",
    ),
    "chat_backdrop": MessageLookupByLibrary.simpleMessage("Фон чата"),
    "chat_backdrop_choose_image": MessageLookupByLibrary.simpleMessage(
      "Выбрать изображение",
    ),
    "chat_backdrop_color_pick": MessageLookupByLibrary.simpleMessage(
      "Выберите цвет!",
    ),
    "chat_backdrop_gradient_end_color": MessageLookupByLibrary.simpleMessage(
      "Конечный цвет",
    ),
    "chat_backdrop_gradient_preview": MessageLookupByLibrary.simpleMessage(
      "Предпросмотр градиента",
    ),
    "chat_backdrop_gradient_start_color": MessageLookupByLibrary.simpleMessage(
      "Начальный цвет",
    ),
    "chat_backdrop_save_changes": MessageLookupByLibrary.simpleMessage(
      "Сохранить изменения",
    ),
    "chat_backdrop_select_gradient": MessageLookupByLibrary.simpleMessage(
      "Выбрать градиентные цвета",
    ),
    "chat_backdrop_upload_coming_soon": MessageLookupByLibrary.simpleMessage(
      "Загрузка собственного изображения скоро появится!",
    ),
    "chat_backdrop_upload_custom": MessageLookupByLibrary.simpleMessage(
      "Загрузить собственное изображение",
    ),
    "chat_request_accept_error": MessageLookupByLibrary.simpleMessage(
      "Что-то пошло не так при попытке принять запрос на чат!",
    ),
    "chat_request_decline_error": MessageLookupByLibrary.simpleMessage(
      "Что-то пошло не так при попытке отклонить запрос на чат!",
    ),
    "chat_session_delete_error": MessageLookupByLibrary.simpleMessage(
      "Что-то пошло не так при попытке удалить сессию чата!",
    ),
    "chat_session_not_found": MessageLookupByLibrary.simpleMessage(
      "Выбранная сессия чата не существует. (Возможно, удалена другим пользователем)",
    ),
    "chat_theme": MessageLookupByLibrary.simpleMessage("Тема чата"),
    "chat_theme_settings": MessageLookupByLibrary.simpleMessage(
      "Настройки темы чата",
    ),
    "chat_with": m1,
    "chats": MessageLookupByLibrary.simpleMessage("Чаты"),
    "choose_friends": MessageLookupByLibrary.simpleMessage("Выбрать друзей"),
    "choose_option": MessageLookupByLibrary.simpleMessage("Выберите опцию"),
    "client_id_must_be_a_number": MessageLookupByLibrary.simpleMessage(
      "ID клиента должен быть числом",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Закрыть"),
    "command_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Команда {} не реализована!",
    ),
    "command_unknown": MessageLookupByLibrary.simpleMessage(
      "Команда неизвестна!",
    ),
    "confirm_delete_message": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите безвозвратно удалить сообщение?",
    ),
    "connect": MessageLookupByLibrary.simpleMessage("Подключиться"),
    "connection_refused": MessageLookupByLibrary.simpleMessage(
      "Соединение отклонено!",
    ),
    "connection_reset": MessageLookupByLibrary.simpleMessage(
      "Соединение сброшено!",
    ),
    "content_type_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Тип содержимого не реализован!",
    ),
    "content_type_unknown": MessageLookupByLibrary.simpleMessage(
      "Тип содержимого неизвестен!",
    ),
    "could_not_verify_server_certificate": MessageLookupByLibrary.simpleMessage(
      "Не удалось проверить сертификат сервера",
    ),
    "create_account": MessageLookupByLibrary.simpleMessage("Создать аккаунт"),
    "create_account_database_full": MessageLookupByLibrary.simpleMessage(
      "Достигнута максимальная емкость базы данных! К сожалению, ваш запрос не может быть обработан.",
    ),
    "create_account_email_exists": MessageLookupByLibrary.simpleMessage(
      "Эта почта уже используется!",
    ),
    "create_account_error": MessageLookupByLibrary.simpleMessage(
      "Произошла ошибка при создании аккаунта!",
    ),
    "create_account_success": MessageLookupByLibrary.simpleMessage(
      "Аккаунт успешно создан!",
    ),
    "credential_validation_client_id_error":
        MessageLookupByLibrary.simpleMessage(
          "Не удалось сгенерировать идентификатор клиента!",
        ),
    "credential_validation_email_exists": MessageLookupByLibrary.simpleMessage(
      "Эта почта уже используется!",
    ),
    "credential_validation_email_invalid": MessageLookupByLibrary.simpleMessage(
      "Некорректный адрес электронной почты",
    ),
    "credential_validation_password_invalid":
        MessageLookupByLibrary.simpleMessage(
          "Пароль не соответствует требованиям!",
        ),
    "credential_validation_success": MessageLookupByLibrary.simpleMessage(
      "Учетные данные успешно обменяны!",
    ),
    "credential_validation_username_invalid":
        MessageLookupByLibrary.simpleMessage(
          "Имя пользователя не соответствует требованиям!",
        ),
    "custom": MessageLookupByLibrary.simpleMessage("Пользовательский"),
    "decline": MessageLookupByLibrary.simpleMessage("Отклонить"),
    "decompression_failed": MessageLookupByLibrary.simpleMessage(
      "Ошибка распаковки",
    ),
    "default_monotone": MessageLookupByLibrary.simpleMessage(
      "По умолчанию/Монотонный",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Удалить"),
    "delete_chat": MessageLookupByLibrary.simpleMessage("Удалить чат"),
    "delete_this_chat_question": MessageLookupByLibrary.simpleMessage(
      "Удалить этот чат?",
    ),
    "deleting_this_chat_will_permanently_delete_all_prior_messages":
        MessageLookupByLibrary.simpleMessage(
          "Удаление этого чата навсегда удалит все предыдущие сообщения",
        ),
    "display_name": MessageLookupByLibrary.simpleMessage("Отображаемое имя"),
    "display_part_of_messages_in_notifications":
        MessageLookupByLibrary.simpleMessage(
          "Отображать часть сообщения в уведомлениях",
        ),
    "donate_to_ermis_project": MessageLookupByLibrary.simpleMessage(
      "Пожертвовать на проект Ermis",
    ),
    "donate_to_hoster": MessageLookupByLibrary.simpleMessage(
      "Пожертвовать хостеру",
    ),
    "donations": MessageLookupByLibrary.simpleMessage("Пожертвования"),
    "downloaded_file": MessageLookupByLibrary.simpleMessage("Файл загружен"),
    "email": MessageLookupByLibrary.simpleMessage("Электронная почта"),
    "email_address": MessageLookupByLibrary.simpleMessage("Электронная почта"),
    "email_is_empty": MessageLookupByLibrary.simpleMessage(
      "Электронная почта пуста!",
    ),
    "email_mismatch": MessageLookupByLibrary.simpleMessage(
      "Введённый email не совпадает с фактическим!",
    ),
    "enter_client_id": MessageLookupByLibrary.simpleMessage(
      "Введите ID клиента",
    ),
    "enter_verification_code": MessageLookupByLibrary.simpleMessage(
      "Введите код верификации",
    ),
    "enter_verification_code_sent_to_your_email":
        MessageLookupByLibrary.simpleMessage(
          "Введите код верификации, отправленный на вашу электронную почту",
        ),
    "entropy_rough_estimate": m2,
    "error_saving_file": MessageLookupByLibrary.simpleMessage(
      "Произошла ошибка при попытке сохранить файл",
    ),
    "faq_contact_terms_privacy": MessageLookupByLibrary.simpleMessage(
      "FAQ, контакты, условия и политика конфиденциальности",
    ),
    "feature_audio_messages": MessageLookupByLibrary.simpleMessage(
      "Поддержка аудиосообщений",
    ),
    "feature_chat_themes": MessageLookupByLibrary.simpleMessage(
      "Новые темы чата",
    ),
    "feature_encryption": MessageLookupByLibrary.simpleMessage(
      "Улучшенные протоколы шифрования",
    ),
    "feature_languages": MessageLookupByLibrary.simpleMessage(
      "Многоязычная поддержка!",
    ),
    "feature_voice_calls": MessageLookupByLibrary.simpleMessage(
      "Голосовые звонки (Ранний доступ)",
    ),
    "file_received": m3,
    "functionality_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Функция ещё не реализована!",
    ),
    "gallery": MessageLookupByLibrary.simpleMessage("Галерея"),
    "got_it_button": MessageLookupByLibrary.simpleMessage("Понял!"),
    "gradient": MessageLookupByLibrary.simpleMessage("Градиент"),
    "help": MessageLookupByLibrary.simpleMessage("Помощь"),
    "help_settings": MessageLookupByLibrary.simpleMessage("Настройки помощи"),
    "incompatible_server_version_warning": MessageLookupByLibrary.simpleMessage(
      "Несовместимая версия сервера! Некоторые функции могут работать не так, как ожидается!",
    ),
    "license_capitalized": MessageLookupByLibrary.simpleMessage("Лицензия"),
    "license_crux": MessageLookupByLibrary.simpleMessage("Основное о лицензии"),
    "link_new_device": MessageLookupByLibrary.simpleMessage(
      "Связать новое устройство",
    ),
    "linked_devices": MessageLookupByLibrary.simpleMessage(
      "Подключенные устройства",
    ),
    "linked_devices_logout_all": MessageLookupByLibrary.simpleMessage(
      "Выйти со всех устройств",
    ),
    "linked_devices_logout_all_confirm": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите выйти со всех устройств?",
    ),
    "linked_devices_logout_confirm": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите выйти из ",
    ),
    "login": MessageLookupByLibrary.simpleMessage("Войти"),
    "login_account_not_found": MessageLookupByLibrary.simpleMessage(
      "Аккаунт не существует!",
    ),
    "login_add_device_info": MessageLookupByLibrary.simpleMessage(
      "Добавить информацию об устройстве",
    ),
    "login_backup_code_incorrect": MessageLookupByLibrary.simpleMessage(
      "Неверный резервный код подтверждения.",
    ),
    "login_email_incorrect": MessageLookupByLibrary.simpleMessage(
      "Неверный адрес электронной почты!",
    ),
    "login_error": MessageLookupByLibrary.simpleMessage(
      "Произошла ошибка при входе в аккаунт! Пожалуйста, свяжитесь с администратором сервера и сообщите ему о проблеме.",
    ),
    "login_fetch_requirements": MessageLookupByLibrary.simpleMessage(
      "Получить требования",
    ),
    "login_password_incorrect": MessageLookupByLibrary.simpleMessage(
      "Неверный пароль.",
    ),
    "login_success": MessageLookupByLibrary.simpleMessage(
      "Вы успешно вошли в свой аккаунт!",
    ),
    "login_toggle_password": MessageLookupByLibrary.simpleMessage(
      "Показать/скрыть пароль",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("выход"),
    "logout_capitalized": MessageLookupByLibrary.simpleMessage("Выход"),
    "logout_confirmation_all_devices": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите выйти из \${device.formattedInfo()}?",
    ),
    "logout_confirmation_device": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите выйти из \${device.formattedInfo()}?",
    ),
    "logout_from_all_devices": MessageLookupByLibrary.simpleMessage(
      "Выйти со всех устройств",
    ),
    "logout_from_this_device": MessageLookupByLibrary.simpleMessage(
      "Выйти с этого устройства",
    ),
    "manage_storage": MessageLookupByLibrary.simpleMessage(
      "Управление хранилищем",
    ),
    "message_by": m4,
    "message_copied": MessageLookupByLibrary.simpleMessage(
      "Сообщение скопировано в буфер обмена",
    ),
    "message_deletion_unsuccessful": MessageLookupByLibrary.simpleMessage(
      "Не удалось удалить сообщение",
    ),
    "message_group_call_tones": MessageLookupByLibrary.simpleMessage(
      "Тоны сообщений, групп и звонков",
    ),
    "message_length_exceeded": MessageLookupByLibrary.simpleMessage(
      "Длина сообщения превышает максимальную ({%d} символов)",
    ),
    "message_type_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Тип сообщения не реализован!",
    ),
    "message_type_unknown": MessageLookupByLibrary.simpleMessage(
      "Тип сообщения не распознан!",
    ),
    "min_entropy": m5,
    "name": MessageLookupByLibrary.simpleMessage("Имя"),
    "name_enter": MessageLookupByLibrary.simpleMessage("Введите ваше имя"),
    "network_usage_auto_download": MessageLookupByLibrary.simpleMessage(
      "Использование сети, автозагрузка",
    ),
    "new_chat": MessageLookupByLibrary.simpleMessage("Новый чат"),
    "new_group": MessageLookupByLibrary.simpleMessage("Новая группа"),
    "new_message": MessageLookupByLibrary.simpleMessage("Новое сообщение!"),
    "no_chat_requests_available": MessageLookupByLibrary.simpleMessage(
      "Нет ожидающих запросов чата",
    ),
    "no_chats_available_incompatible_server_version":
        MessageLookupByLibrary.simpleMessage(
          "Чаты недоступны, несовместимая версия сервера",
        ),
    "no_conversations_available": MessageLookupByLibrary.simpleMessage(
      "Нет доступных бесед",
    ),
    "no_linked_devices": MessageLookupByLibrary.simpleMessage(
      "Нет связанных устройств",
    ),
    "notification_enable": MessageLookupByLibrary.simpleMessage(
      "Включить уведомления",
    ),
    "notification_preview_display_part": MessageLookupByLibrary.simpleMessage(
      "Отображать часть сообщения в уведомлениях",
    ),
    "notification_preview_show": MessageLookupByLibrary.simpleMessage(
      "Показывать предпросмотр сообщений",
    ),
    "notification_settings": MessageLookupByLibrary.simpleMessage(
      "Настройки уведомлений",
    ),
    "notification_sound": MessageLookupByLibrary.simpleMessage(
      "Звук уведомлений",
    ),
    "notification_sound_select": MessageLookupByLibrary.simpleMessage(
      "Выбрать звук уведомления",
    ),
    "notifications": MessageLookupByLibrary.simpleMessage("Уведомления"),
    "ok": MessageLookupByLibrary.simpleMessage("ОК"),
    "or": MessageLookupByLibrary.simpleMessage("Или"),
    "other": MessageLookupByLibrary.simpleMessage("Другое"),
    "other_settings": MessageLookupByLibrary.simpleMessage("Другие настройки"),
    "password": MessageLookupByLibrary.simpleMessage("Пароль"),
    "password_is_empty": MessageLookupByLibrary.simpleMessage("Пароль пуст!"),
    "password_validation_invalid": MessageLookupByLibrary.simpleMessage(
      "Пароль не соответствует требованиям!",
    ),
    "password_validation_success": MessageLookupByLibrary.simpleMessage(
      "Пароль успешно подтвержден!",
    ),
    "please_enter_the_verification_code": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите код верификации",
    ),
    "privacy": MessageLookupByLibrary.simpleMessage("Конфиденциальность"),
    "privacy_security_change_number": MessageLookupByLibrary.simpleMessage(
      "Конфиденциальность, безопасность, смена номера",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("Профиль"),
    "profile_about": MessageLookupByLibrary.simpleMessage("О себе"),
    "profile_camera": MessageLookupByLibrary.simpleMessage("Камера"),
    "profile_change_name_id": MessageLookupByLibrary.simpleMessage(
      "Профиль, изменение имени, ID",
    ),
    "profile_gallery": MessageLookupByLibrary.simpleMessage("Галерея"),
    "profile_hey_there": MessageLookupByLibrary.simpleMessage("Привет!"),
    "profile_id_copied": MessageLookupByLibrary.simpleMessage(
      "ID скопирован в буфер обмена",
    ),
    "profile_name": MessageLookupByLibrary.simpleMessage("Имя"),
    "profile_name_enter": MessageLookupByLibrary.simpleMessage(
      "Введите ваше имя",
    ),
    "profile_photo": MessageLookupByLibrary.simpleMessage("Фото профиля"),
    "profile_photo_fetch_error": MessageLookupByLibrary.simpleMessage(
      "Произошла ошибка при получении фото профиля из базы данных!",
    ),
    "profile_settings": MessageLookupByLibrary.simpleMessage(
      "Настройки профиля",
    ),
    "registration_failed": m6,
    "requests": MessageLookupByLibrary.simpleMessage("Запросы"),
    "resend_code": MessageLookupByLibrary.simpleMessage(
      "Повторно отправить код",
    ),
    "save": MessageLookupByLibrary.simpleMessage("Сохранить"),
    "search": MessageLookupByLibrary.simpleMessage("Поиск..."),
    "select_an_option": MessageLookupByLibrary.simpleMessage("Выберите опцию"),
    "send_chat_request": MessageLookupByLibrary.simpleMessage(
      "Отправить запрос чата",
    ),
    "server_add": MessageLookupByLibrary.simpleMessage("Добавить сервер"),
    "server_add_success": MessageLookupByLibrary.simpleMessage(
      "Сервер успешно добавлен!",
    ),
    "server_certificate_check": MessageLookupByLibrary.simpleMessage(
      "Проверить сертификат",
    ),
    "server_source_code": MessageLookupByLibrary.simpleMessage(
      "Исходный код сервера",
    ),
    "server_url_choose": MessageLookupByLibrary.simpleMessage(
      "Выберите URL сервера",
    ),
    "server_url_enter": MessageLookupByLibrary.simpleMessage(
      "Введите URL сервера",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Настройки"),
    "settings_save": MessageLookupByLibrary.simpleMessage(
      "Сохранить настройки",
    ),
    "settings_saved": MessageLookupByLibrary.simpleMessage(
      "Настройки сохранены",
    ),
    "sign_out": MessageLookupByLibrary.simpleMessage("Выйти"),
    "source_code": MessageLookupByLibrary.simpleMessage("Исходный код"),
    "storage_data": MessageLookupByLibrary.simpleMessage("Хранилище и данные"),
    "submit": MessageLookupByLibrary.simpleMessage("Отправить"),
    "temp_banned": MessageLookupByLibrary.simpleMessage(
      "Притормози! Ты временно заблокирован от взаимодействия с сервером на короткий промежуток времени.",
    ),
    "theme_dark": MessageLookupByLibrary.simpleMessage("Тёмный режим"),
    "theme_light": MessageLookupByLibrary.simpleMessage("Светлый режим"),
    "theme_mode": MessageLookupByLibrary.simpleMessage("Режим темы"),
    "theme_system_default": MessageLookupByLibrary.simpleMessage(
      "Системный по умолчанию",
    ),
    "theme_wallpapers_chat_history": MessageLookupByLibrary.simpleMessage(
      "Тема, обои, история чатов",
    ),
    "today": MessageLookupByLibrary.simpleMessage("Сегодня"),
    "type_message": MessageLookupByLibrary.simpleMessage(
      "Введите сообщение...",
    ),
    "unknown_size": MessageLookupByLibrary.simpleMessage("Неизвестный размер"),
    "use_backup_verification_code": MessageLookupByLibrary.simpleMessage(
      "Использовать резервный код верификации",
    ),
    "use_password": MessageLookupByLibrary.simpleMessage("Использовать пароль"),
    "username_same_as_old": MessageLookupByLibrary.simpleMessage(
      "Имя пользователя не может совпадать со старым именем!",
    ),
    "username_validation_invalid": MessageLookupByLibrary.simpleMessage(
      "Имя пользователя не соответствует требованиям!",
    ),
    "username_validation_success": MessageLookupByLibrary.simpleMessage(
      "Имя пользователя успешно подтверждено!",
    ),
    "verification": MessageLookupByLibrary.simpleMessage("Верификация"),
    "verification_attempts_exhausted": MessageLookupByLibrary.simpleMessage(
      "Исчерпаны все попытки!",
    ),
    "verification_code_incorrect": MessageLookupByLibrary.simpleMessage(
      "Неверный код!",
    ),
    "verification_code_must_be_number": MessageLookupByLibrary.simpleMessage(
      "Код верификации должен быть числом",
    ),
    "verification_email_invalid": MessageLookupByLibrary.simpleMessage(
      "Некорректный адрес электронной почты",
    ),
    "verification_resend_code": MessageLookupByLibrary.simpleMessage(
      "Отправить код повторно",
    ),
    "verification_success": MessageLookupByLibrary.simpleMessage(
      "Успешно подтверждено!",
    ),
    "version_capitalized": MessageLookupByLibrary.simpleMessage("Версия"),
    "vibration": MessageLookupByLibrary.simpleMessage("Вибрация"),
    "vibration_unavailable": MessageLookupByLibrary.simpleMessage(
      "Вибрация недоступна на этом устройстве",
    ),
    "whats_new": MessageLookupByLibrary.simpleMessage("Что нового"),
    "whats_new_system_messages": MessageLookupByLibrary.simpleMessage(
      "Новые системные сообщения",
    ),
    "whats_new_title": MessageLookupByLibrary.simpleMessage(
      "Новые функции в Hermis",
    ),
  };
}
