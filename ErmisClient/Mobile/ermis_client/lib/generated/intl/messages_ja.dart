// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ja locale. All the
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
  String get localeName => 'ja';

  static String m0(deviceInfo) => "${deviceInfo} からログアウトしてもよろしいですか？";

  static String m1(username) => "${username} とのチャット";

  static String m2(entropy) => "エントロピー：${entropy}（概算）";

  static String m3(fileName) => "ファイルを受信しました ${fileName}";

  static String m4(username) => "${username} からのメッセージ";

  static String m5(minEntropy) => "最小エントロピー：${minEntropy}";

  static String m6(resultMessage) => "登録に失敗しました：${resultMessage}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accept": MessageLookupByLibrary.simpleMessage("承諾"),
    "account": MessageLookupByLibrary.simpleMessage("アカウント"),
    "account_add": MessageLookupByLibrary.simpleMessage("新しいアカウントを追加"),
    "account_confirm_proceed": MessageLookupByLibrary.simpleMessage(
      "続行してもよろしいですか？",
    ),
    "account_delete": MessageLookupByLibrary.simpleMessage("アカウントを削除"),
    "account_delete_bullet1": MessageLookupByLibrary.simpleMessage(
      "アカウントが回復不能な状態で削除されます",
    ),
    "account_delete_bullet2": MessageLookupByLibrary.simpleMessage(
      "メッセージ履歴が消去されます",
    ),
    "account_delete_bullet3": MessageLookupByLibrary.simpleMessage(
      "すべてのチャットが削除されます",
    ),
    "account_delete_confirmation": MessageLookupByLibrary.simpleMessage(
      "このアカウントを削除すると：",
    ),
    "account_delete_error": MessageLookupByLibrary.simpleMessage(
      "アカウントの削除中にエラーが発生しました！",
    ),
    "account_delete_my": MessageLookupByLibrary.simpleMessage("マイアカウントを削除"),
    "account_settings": MessageLookupByLibrary.simpleMessage("アカウント設定"),
    "address_not_recognized": MessageLookupByLibrary.simpleMessage(
      "アドレスが認識されません！",
    ),
    "app_info": MessageLookupByLibrary.simpleMessage("アプリ情報"),
    "app_language": MessageLookupByLibrary.simpleMessage("アプリの言語"),
    "are_you_sure_you_want_to_logout_from": m0,
    "are_you_sure_you_want_to_logout_from_all_devices":
        MessageLookupByLibrary.simpleMessage("本当にすべてのデバイスからログアウトしますか？"),
    "attempting_delete_message": MessageLookupByLibrary.simpleMessage(
      "メッセージを削除しようとしています",
    ),
    "authentication_stage_create_account": MessageLookupByLibrary.simpleMessage(
      "アカウントを作成",
    ),
    "authentication_stage_credentials_exchange":
        MessageLookupByLibrary.simpleMessage("認証情報の交換"),
    "authentication_stage_credentials_validation":
        MessageLookupByLibrary.simpleMessage("認証情報の検証"),
    "authentication_stage_login": MessageLookupByLibrary.simpleMessage("ログイン"),
    "backup_verification_code": MessageLookupByLibrary.simpleMessage(
      "バックアップ認証コード",
    ),
    "backup_verification_code_regenerate_error":
        MessageLookupByLibrary.simpleMessage("ユーザー名の変更中にエラーが発生しました！"),
    "backup_verification_code_regenerate_success":
        MessageLookupByLibrary.simpleMessage("バックアップ認証コードが正常に再生成されました！"),
    "camera": MessageLookupByLibrary.simpleMessage("カメラ"),
    "cancel": MessageLookupByLibrary.simpleMessage("キャンセル"),
    "change_password_error": MessageLookupByLibrary.simpleMessage(
      "パスワードの変更中にエラーが発生しました！",
    ),
    "change_password_success": MessageLookupByLibrary.simpleMessage(
      "パスワードが正常に変更されました！",
    ),
    "change_username_error": MessageLookupByLibrary.simpleMessage(
      "ユーザー名の変更中にエラーが発生しました！",
    ),
    "change_username_invalid": MessageLookupByLibrary.simpleMessage(
      "ユーザー名の要件が満たされていません",
    ),
    "change_username_success": MessageLookupByLibrary.simpleMessage(
      "ユーザー名が正常に変更されました！",
    ),
    "chat_backdrop": MessageLookupByLibrary.simpleMessage("チャットの背景"),
    "chat_backdrop_choose_image": MessageLookupByLibrary.simpleMessage("画像を選択"),
    "chat_backdrop_color_pick": MessageLookupByLibrary.simpleMessage("色を選択！"),
    "chat_backdrop_gradient_end_color": MessageLookupByLibrary.simpleMessage(
      "終了色",
    ),
    "chat_backdrop_gradient_preview": MessageLookupByLibrary.simpleMessage(
      "グラデーションプレビュー",
    ),
    "chat_backdrop_gradient_start_color": MessageLookupByLibrary.simpleMessage(
      "開始色",
    ),
    "chat_backdrop_save_changes": MessageLookupByLibrary.simpleMessage("変更を保存"),
    "chat_backdrop_select_gradient": MessageLookupByLibrary.simpleMessage(
      "グラデーションの色を選択",
    ),
    "chat_backdrop_upload_coming_soon": MessageLookupByLibrary.simpleMessage(
      "カスタム画像のアップロードは近日公開！",
    ),
    "chat_backdrop_upload_custom": MessageLookupByLibrary.simpleMessage(
      "カスタム画像をアップロード",
    ),
    "chat_request_accept_error": MessageLookupByLibrary.simpleMessage(
      "チャットリクエストの承認中にエラーが発生しました！",
    ),
    "chat_request_decline_error": MessageLookupByLibrary.simpleMessage(
      "チャットリクエストの拒否中にエラーが発生しました！",
    ),
    "chat_session_delete_error": MessageLookupByLibrary.simpleMessage(
      "チャットセッションの削除中にエラーが発生しました！",
    ),
    "chat_session_not_found": MessageLookupByLibrary.simpleMessage(
      "選択されたチャットセッションは存在しません。（他のユーザーによって削除された可能性があります）",
    ),
    "chat_theme_settings": MessageLookupByLibrary.simpleMessage("チャットテーマ設定"),
    "chat_with": m1,
    "chats": MessageLookupByLibrary.simpleMessage("チャット"),
    "choose_option": MessageLookupByLibrary.simpleMessage("オプションを選択"),
    "client_id_must_be_a_number": MessageLookupByLibrary.simpleMessage(
      "クライアントIDは数字である必要があります",
    ),
    "close": MessageLookupByLibrary.simpleMessage("閉じる"),
    "command_not_implemented": MessageLookupByLibrary.simpleMessage(
      "コマンド{}は実装されていません！",
    ),
    "command_unknown": MessageLookupByLibrary.simpleMessage("コマンドが不明です！"),
    "confirm_delete_message": MessageLookupByLibrary.simpleMessage(
      "メッセージを完全に削除してもよろしいですか？",
    ),
    "connect": MessageLookupByLibrary.simpleMessage("接続"),
    "content_type_not_implemented": MessageLookupByLibrary.simpleMessage(
      "コンテンツタイプが実装されていません！",
    ),
    "content_type_unknown": MessageLookupByLibrary.simpleMessage(
      "コンテンツタイプが不明です！",
    ),
    "create_account": MessageLookupByLibrary.simpleMessage("アカウントを作成"),
    "create_account_database_full": MessageLookupByLibrary.simpleMessage(
      "データベースの最大容量に達しました！残念ながら、リクエストを処理できませんでした。",
    ),
    "create_account_email_exists": MessageLookupByLibrary.simpleMessage(
      "このメールアドレスは既に使用されています！",
    ),
    "create_account_error": MessageLookupByLibrary.simpleMessage(
      "アカウントの作成中にエラーが発生しました！",
    ),
    "create_account_success": MessageLookupByLibrary.simpleMessage(
      "アカウントが正常に作成されました！",
    ),
    "credential_validation_client_id_error":
        MessageLookupByLibrary.simpleMessage("クライアントIDを生成できません！"),
    "credential_validation_email_exists": MessageLookupByLibrary.simpleMessage(
      "このメールアドレスは既に使用されています！",
    ),
    "credential_validation_email_invalid": MessageLookupByLibrary.simpleMessage(
      "無効なメールアドレス",
    ),
    "credential_validation_password_invalid":
        MessageLookupByLibrary.simpleMessage("パスワードの要件が満たされていません！"),
    "credential_validation_success": MessageLookupByLibrary.simpleMessage(
      "認証情報が正常に交換されました！",
    ),
    "credential_validation_username_invalid":
        MessageLookupByLibrary.simpleMessage("ユーザー名の要件が満たされていません！"),
    "decline": MessageLookupByLibrary.simpleMessage("拒否"),
    "decompression_failed": MessageLookupByLibrary.simpleMessage("解凍に失敗しました"),
    "delete": MessageLookupByLibrary.simpleMessage("削除"),
    "delete_chat": MessageLookupByLibrary.simpleMessage("チャットを削除"),
    "delete_this_chat_question": MessageLookupByLibrary.simpleMessage(
      "このチャットを削除しますか？",
    ),
    "deleting_this_chat_will_permanently_delete_all_prior_messages":
        MessageLookupByLibrary.simpleMessage(
          "このチャットを削除すると、以前のすべてのメッセージが永久に削除されます",
        ),
    "display_name": MessageLookupByLibrary.simpleMessage("表示名"),
    "display_part_of_messages_in_notifications":
        MessageLookupByLibrary.simpleMessage("通知にメッセージの一部を表示"),
    "donate_to_ermis_project": MessageLookupByLibrary.simpleMessage(
      "Ermisプロジェクトへの寄付",
    ),
    "donate_to_hoster": MessageLookupByLibrary.simpleMessage("ホストへの寄付"),
    "donations": MessageLookupByLibrary.simpleMessage("寄付"),
    "downloaded_file": MessageLookupByLibrary.simpleMessage("ファイルをダウンロードしました"),
    "email": MessageLookupByLibrary.simpleMessage("メールアドレス"),
    "email_address": MessageLookupByLibrary.simpleMessage("メールアドレス"),
    "email_is_empty": MessageLookupByLibrary.simpleMessage("メールアドレスが空です！"),
    "email_mismatch": MessageLookupByLibrary.simpleMessage(
      "入力されたメールアドレスが実際のメールアドレスと一致しません！",
    ),
    "enter_client_id": MessageLookupByLibrary.simpleMessage(
      "クライアントIDを入力してください",
    ),
    "enter_verification_code": MessageLookupByLibrary.simpleMessage(
      "認証コードを入力してください",
    ),
    "enter_verification_code_sent_to_your_email":
        MessageLookupByLibrary.simpleMessage("メールに送信された認証コードを入力してください"),
    "entropy_rough_estimate": m2,
    "error_saving_file": MessageLookupByLibrary.simpleMessage(
      "ファイルの保存中にエラーが発生しました",
    ),
    "faq_contact_terms_privacy": MessageLookupByLibrary.simpleMessage(
      "FAQ、お問い合わせ、利用規約とプライバシーポリシー",
    ),
    "feature_audio_messages": MessageLookupByLibrary.simpleMessage(
      "音声メッセージのサポート",
    ),
    "feature_chat_themes": MessageLookupByLibrary.simpleMessage("新しいチャットテーマ"),
    "feature_encryption": MessageLookupByLibrary.simpleMessage("強化された暗号化プロトコル"),
    "feature_languages": MessageLookupByLibrary.simpleMessage("多言語サポート！"),
    "feature_voice_calls": MessageLookupByLibrary.simpleMessage(
      "音声通話 (早期アクセス)",
    ),
    "file_received": m3,
    "functionality_not_implemented": MessageLookupByLibrary.simpleMessage(
      "この機能はまだ実装されていません！",
    ),
    "gallery": MessageLookupByLibrary.simpleMessage("ギャラリー"),
    "got_it_button": MessageLookupByLibrary.simpleMessage("了解しました！"),
    "help": MessageLookupByLibrary.simpleMessage("ヘルプ"),
    "help_settings": MessageLookupByLibrary.simpleMessage("ヘルプ設定"),
    "incompatible_server_version_warning": MessageLookupByLibrary.simpleMessage(
      "サーバーバージョンが互換性ありません！一部の機能が期待どおりに動作しない可能性があります！",
    ),
    "license_capitalized": MessageLookupByLibrary.simpleMessage("ライセンス"),
    "license_crux": MessageLookupByLibrary.simpleMessage("ライセンスの要点"),
    "link_new_device": MessageLookupByLibrary.simpleMessage("新しいデバイスをリンク"),
    "linked_devices": MessageLookupByLibrary.simpleMessage("リンクされたデバイス"),
    "linked_devices_logout_all": MessageLookupByLibrary.simpleMessage(
      "すべてのデバイスからログアウト",
    ),
    "linked_devices_logout_all_confirm": MessageLookupByLibrary.simpleMessage(
      "本当にすべてのデバイスからログアウトしますか？",
    ),
    "linked_devices_logout_confirm": MessageLookupByLibrary.simpleMessage(
      "本当にログアウトしますか？",
    ),
    "login": MessageLookupByLibrary.simpleMessage("ログイン"),
    "login_account_not_found": MessageLookupByLibrary.simpleMessage(
      "アカウントが存在しません！",
    ),
    "login_add_device_info": MessageLookupByLibrary.simpleMessage("デバイス情報を追加"),
    "login_backup_code_incorrect": MessageLookupByLibrary.simpleMessage(
      "バックアップ認証コードが間違っています。",
    ),
    "login_email_incorrect": MessageLookupByLibrary.simpleMessage(
      "メールアドレスが間違っています！",
    ),
    "login_error": MessageLookupByLibrary.simpleMessage(
      "アカウントへのログイン中にエラーが発生しました！サーバー管理者に連絡し、サーバーが故障していることを伝えてください。",
    ),
    "login_fetch_requirements": MessageLookupByLibrary.simpleMessage("要件を取得"),
    "login_password_incorrect": MessageLookupByLibrary.simpleMessage(
      "パスワードが間違っています。",
    ),
    "login_success": MessageLookupByLibrary.simpleMessage("アカウントに正常にログインしました！"),
    "login_toggle_password": MessageLookupByLibrary.simpleMessage(
      "パスワードの表示/非表示を切り替え",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("ログアウト"),
    "logout_capitalized": MessageLookupByLibrary.simpleMessage("ログアウト"),
    "logout_confirmation_all_devices": MessageLookupByLibrary.simpleMessage(
      "\${device.formattedInfo()} からログアウトしてもよろしいですか？",
    ),
    "logout_confirmation_device": MessageLookupByLibrary.simpleMessage(
      "\${device.formattedInfo()} からログアウトしてもよろしいですか？",
    ),
    "logout_from_all_devices": MessageLookupByLibrary.simpleMessage(
      "すべてのデバイスからログアウト",
    ),
    "logout_from_this_device": MessageLookupByLibrary.simpleMessage(
      "このデバイスからログアウト",
    ),
    "manage_storage": MessageLookupByLibrary.simpleMessage("ストレージを管理"),
    "message_by": m4,
    "message_copied": MessageLookupByLibrary.simpleMessage(
      "メッセージをクリップボードにコピーしました",
    ),
    "message_deletion_unsuccessful": MessageLookupByLibrary.simpleMessage(
      "メッセージの削除に失敗しました",
    ),
    "message_group_call_tones": MessageLookupByLibrary.simpleMessage(
      "メッセージ、グループ、通話音",
    ),
    "message_length_exceeded": MessageLookupByLibrary.simpleMessage(
      "メッセージの長さが最大長（%d文字）を超えています",
    ),
    "message_type_not_implemented": MessageLookupByLibrary.simpleMessage(
      "メッセージタイプが実装されていません！",
    ),
    "message_type_unknown": MessageLookupByLibrary.simpleMessage(
      "メッセージタイプが認識されません！",
    ),
    "min_entropy": m5,
    "name": MessageLookupByLibrary.simpleMessage("名前"),
    "name_enter": MessageLookupByLibrary.simpleMessage("名前を入力してください"),
    "network_usage_auto_download": MessageLookupByLibrary.simpleMessage(
      "ネットワーク使用量、自動ダウンロード",
    ),
    "new_chat": MessageLookupByLibrary.simpleMessage("「新しいチャット」"),
    "new_message": MessageLookupByLibrary.simpleMessage("新しいメッセージ！"),
    "no_chat_requests_available": MessageLookupByLibrary.simpleMessage(
      "保留中のチャットリクエストはありません",
    ),
    "no_chats_available_incompatible_server_version":
        MessageLookupByLibrary.simpleMessage("チャットは利用できません。サーバーバージョンが互換性ありません"),
    "no_conversations_available": MessageLookupByLibrary.simpleMessage(
      "利用可能な会話はありません",
    ),
    "no_linked_devices": MessageLookupByLibrary.simpleMessage(
      "リンクされたデバイスはありません",
    ),
    "notification_enable": MessageLookupByLibrary.simpleMessage("通知を有効にする"),
    "notification_preview_display_part": MessageLookupByLibrary.simpleMessage(
      "通知にメッセージの一部を表示",
    ),
    "notification_preview_show": MessageLookupByLibrary.simpleMessage(
      "メッセージのプレビューを表示",
    ),
    "notification_settings": MessageLookupByLibrary.simpleMessage("通知設定"),
    "notification_sound": MessageLookupByLibrary.simpleMessage("通知音"),
    "notification_sound_select": MessageLookupByLibrary.simpleMessage("通知音を選択"),
    "notifications": MessageLookupByLibrary.simpleMessage("通知"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "or": MessageLookupByLibrary.simpleMessage("または"),
    "other": MessageLookupByLibrary.simpleMessage("その他"),
    "other_settings": MessageLookupByLibrary.simpleMessage("その他の設定"),
    "password": MessageLookupByLibrary.simpleMessage("パスワード"),
    "password_is_empty": MessageLookupByLibrary.simpleMessage("パスワードが空です！"),
    "password_validation_invalid": MessageLookupByLibrary.simpleMessage(
      "パスワードの要件が満たされていません！",
    ),
    "password_validation_success": MessageLookupByLibrary.simpleMessage(
      "パスワードが正常に検証されました！",
    ),
    "please_enter_the_verification_code": MessageLookupByLibrary.simpleMessage(
      "認証コードを入力してください",
    ),
    "privacy_security_change_number": MessageLookupByLibrary.simpleMessage(
      "プライバシー、セキュリティ、番号変更",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("プロフィール"),
    "profile_about": MessageLookupByLibrary.simpleMessage("自己紹介"),
    "profile_camera": MessageLookupByLibrary.simpleMessage("カメラ"),
    "profile_change_name_id": MessageLookupByLibrary.simpleMessage(
      "プロフィール、名前変更、ID",
    ),
    "profile_gallery": MessageLookupByLibrary.simpleMessage("ギャラリー"),
    "profile_hey_there": MessageLookupByLibrary.simpleMessage("こんにちは！"),
    "profile_id_copied": MessageLookupByLibrary.simpleMessage(
      "IDがクリップボードにコピーされました",
    ),
    "profile_name": MessageLookupByLibrary.simpleMessage("名前"),
    "profile_name_enter": MessageLookupByLibrary.simpleMessage("名前を入力してください"),
    "profile_photo": MessageLookupByLibrary.simpleMessage("プロフィール写真"),
    "profile_photo_fetch_error": MessageLookupByLibrary.simpleMessage(
      "データベースからプロフィール写真を取得中にエラーが発生しました！",
    ),
    "profile_settings": MessageLookupByLibrary.simpleMessage("プロフィール設定"),
    "registration_failed": m6,
    "requests": MessageLookupByLibrary.simpleMessage("リクエスト"),
    "resend_code": MessageLookupByLibrary.simpleMessage("コードを再送信"),
    "save": MessageLookupByLibrary.simpleMessage("保存"),
    "search": MessageLookupByLibrary.simpleMessage("検索..."),
    "select_an_option": MessageLookupByLibrary.simpleMessage("オプションを選択してください"),
    "send_chat_request": MessageLookupByLibrary.simpleMessage("チャットリクエストを送信"),
    "server_add": MessageLookupByLibrary.simpleMessage("サーバーを追加"),
    "server_add_success": MessageLookupByLibrary.simpleMessage(
      "サーバーが正常に追加されました！",
    ),
    "server_certificate_check": MessageLookupByLibrary.simpleMessage("証明書を確認"),
    "server_source_code": MessageLookupByLibrary.simpleMessage("サーバーのソースコード"),
    "server_url_choose": MessageLookupByLibrary.simpleMessage("サーバーのURLを選択"),
    "server_url_enter": MessageLookupByLibrary.simpleMessage("サーバーのURLを入力"),
    "settings": MessageLookupByLibrary.simpleMessage("設定"),
    "settings_save": MessageLookupByLibrary.simpleMessage("設定を保存"),
    "settings_saved": MessageLookupByLibrary.simpleMessage("設定が保存されました"),
    "sign_out": MessageLookupByLibrary.simpleMessage("サインアウト"),
    "source_code": MessageLookupByLibrary.simpleMessage("ソースコード"),
    "storage_data": MessageLookupByLibrary.simpleMessage("ストレージとデータ"),
    "submit": MessageLookupByLibrary.simpleMessage("送信"),
    "temp_banned": MessageLookupByLibrary.simpleMessage(
      "少し落ち着いてください！短時間サーバーとのやり取りを一時的に禁止されています。",
    ),
    "theme_dark": MessageLookupByLibrary.simpleMessage("ダークモード"),
    "theme_light": MessageLookupByLibrary.simpleMessage("ライトモード"),
    "theme_mode": MessageLookupByLibrary.simpleMessage("テーマモード"),
    "theme_system_default": MessageLookupByLibrary.simpleMessage("システムのデフォルト"),
    "theme_wallpapers_chat_history": MessageLookupByLibrary.simpleMessage(
      "テーマ、壁紙、チャット履歴",
    ),
    "today": MessageLookupByLibrary.simpleMessage("今日"),
    "type_message": MessageLookupByLibrary.simpleMessage("メッセージを入力..."),
    "unknown_size": MessageLookupByLibrary.simpleMessage("不明なサイズ"),
    "use_backup_verification_code": MessageLookupByLibrary.simpleMessage(
      "バックアップ認証コードを使用",
    ),
    "use_password": MessageLookupByLibrary.simpleMessage("パスワードを使用"),
    "username_same_as_old": MessageLookupByLibrary.simpleMessage(
      "ユーザー名を以前のユーザー名と同じにすることはできません！",
    ),
    "username_validation_invalid": MessageLookupByLibrary.simpleMessage(
      "ユーザー名の要件が満たされていません！",
    ),
    "username_validation_success": MessageLookupByLibrary.simpleMessage(
      "ユーザー名が正常に検証されました！",
    ),
    "verification": MessageLookupByLibrary.simpleMessage("認証"),
    "verification_attempts_exhausted": MessageLookupByLibrary.simpleMessage(
      "試行回数が上限に達しました！",
    ),
    "verification_code_incorrect": MessageLookupByLibrary.simpleMessage(
      "コードが間違っています！",
    ),
    "verification_code_must_be_number": MessageLookupByLibrary.simpleMessage(
      "認証コードは数字である必要があります",
    ),
    "verification_email_invalid": MessageLookupByLibrary.simpleMessage(
      "無効なメールアドレス",
    ),
    "verification_resend_code": MessageLookupByLibrary.simpleMessage("コードを再送信"),
    "verification_success": MessageLookupByLibrary.simpleMessage("正常に検証されました！"),
    "version_capitalized": MessageLookupByLibrary.simpleMessage("バージョン"),
    "vibration": MessageLookupByLibrary.simpleMessage("バイブレーション"),
    "vibration_unavailable": MessageLookupByLibrary.simpleMessage(
      "このデバイスではバイブレーションは利用できません",
    ),
    "whats_new": MessageLookupByLibrary.simpleMessage("新着情報"),
    "whats_new_system_messages": MessageLookupByLibrary.simpleMessage(
      "新しいシステムメッセージ",
    ),
    "whats_new_title": MessageLookupByLibrary.simpleMessage("Hermisの新機能"),
  };
}
