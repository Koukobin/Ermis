// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a es locale. All the
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
  String get localeName => 'es';

  static String m0(deviceInfo) =>
      "¿Está seguro de que desea cerrar sesión de ${deviceInfo}?";

  static String m1(username) => "Chat con ${username}";

  static String m2(entropy) => "Entropía: ${entropy} (Estimación aproximada)";

  static String m3(fileName) => "Archivo recibido ${fileName}";

  static String m4(username) => "Mensaje de ${username}";

  static String m5(minEntropy) => "Entropía mínima: ${minEntropy}";

  static String m6(resultMessage) => "Registro fallido: ${resultMessage}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "abstract": MessageLookupByLibrary.simpleMessage("Abstracto"),
    "accept": MessageLookupByLibrary.simpleMessage("Aceptar"),
    "account": MessageLookupByLibrary.simpleMessage("Cuenta"),
    "account_add": MessageLookupByLibrary.simpleMessage("Agregar nueva cuenta"),
    "account_confirm_proceed": MessageLookupByLibrary.simpleMessage(
      "¿Estás seguro de que deseas continuar?",
    ),
    "account_delete": MessageLookupByLibrary.simpleMessage("Eliminar cuenta"),
    "account_delete_bullet1": MessageLookupByLibrary.simpleMessage(
      "Eliminará tu cuenta sin posibilidad de recuperación",
    ),
    "account_delete_bullet2": MessageLookupByLibrary.simpleMessage(
      "Borrará tu historial de mensajes",
    ),
    "account_delete_bullet3": MessageLookupByLibrary.simpleMessage(
      "Eliminará todos tus chats",
    ),
    "account_delete_confirmation": MessageLookupByLibrary.simpleMessage(
      "Eliminar esta cuenta:",
    ),
    "account_delete_error": MessageLookupByLibrary.simpleMessage(
      "¡Ocurrió un error al intentar eliminar tu cuenta!",
    ),
    "account_delete_my": MessageLookupByLibrary.simpleMessage(
      "Eliminar mi cuenta",
    ),
    "account_settings": MessageLookupByLibrary.simpleMessage(
      "Configuración de la cuenta",
    ),
    "add_user": MessageLookupByLibrary.simpleMessage("Añadir usuario"),
    "address_not_recognized": MessageLookupByLibrary.simpleMessage(
      "¡Dirección no reconocida!",
    ),
    "app_info": MessageLookupByLibrary.simpleMessage(
      "Información de la aplicación",
    ),
    "app_language": MessageLookupByLibrary.simpleMessage("Idioma"),
    "are_you_sure_you_want_to_logout_from": m0,
    "are_you_sure_you_want_to_logout_from_all_devices":
        MessageLookupByLibrary.simpleMessage(
          "¿Estás seguro de que deseas cerrar sesión en todos los dispositivos?",
        ),
    "attempting_delete_message": MessageLookupByLibrary.simpleMessage(
      "Intentando eliminar el mensaje",
    ),
    "authentication_stage_create_account": MessageLookupByLibrary.simpleMessage(
      "Crear cuenta",
    ),
    "authentication_stage_credentials_exchange":
        MessageLookupByLibrary.simpleMessage("Intercambio de credenciales"),
    "authentication_stage_credentials_validation":
        MessageLookupByLibrary.simpleMessage("Validación de credenciales"),
    "authentication_stage_login": MessageLookupByLibrary.simpleMessage(
      "Iniciar sesión",
    ),
    "backup_verification_code": MessageLookupByLibrary.simpleMessage(
      "Código de verificación de respaldo",
    ),
    "backup_verification_code_regenerate_error":
        MessageLookupByLibrary.simpleMessage(
          "¡Ocurrió un error al intentar cambiar el nombre de usuario!",
        ),
    "backup_verification_code_regenerate_success":
        MessageLookupByLibrary.simpleMessage(
          "¡Códigos de verificación de respaldo regenerados con éxito!",
        ),
    "camera": MessageLookupByLibrary.simpleMessage("Cámara"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
    "change_password_error": MessageLookupByLibrary.simpleMessage(
      "¡Ocurrió un error al intentar cambiar la contraseña!",
    ),
    "change_password_success": MessageLookupByLibrary.simpleMessage(
      "¡Contraseña cambiada con éxito!",
    ),
    "change_username_error": MessageLookupByLibrary.simpleMessage(
      "¡Ocurrió un error al intentar cambiar el nombre de usuario!",
    ),
    "change_username_invalid": MessageLookupByLibrary.simpleMessage(
      "No se cumplen los requisitos del nombre de usuario",
    ),
    "change_username_success": MessageLookupByLibrary.simpleMessage(
      "¡Nombre de usuario cambiado con éxito!",
    ),
    "chat_backdrop": MessageLookupByLibrary.simpleMessage("Fondo del chat"),
    "chat_backdrop_choose_image": MessageLookupByLibrary.simpleMessage(
      "Elegir imagen",
    ),
    "chat_backdrop_color_pick": MessageLookupByLibrary.simpleMessage(
      "¡Elige un color!",
    ),
    "chat_backdrop_gradient_end_color": MessageLookupByLibrary.simpleMessage(
      "Color final",
    ),
    "chat_backdrop_gradient_preview": MessageLookupByLibrary.simpleMessage(
      "Vista previa del degradado",
    ),
    "chat_backdrop_gradient_start_color": MessageLookupByLibrary.simpleMessage(
      "Color de inicio",
    ),
    "chat_backdrop_save_changes": MessageLookupByLibrary.simpleMessage(
      "Guardar cambios",
    ),
    "chat_backdrop_select_gradient": MessageLookupByLibrary.simpleMessage(
      "Seleccionar colores de degradado",
    ),
    "chat_backdrop_upload_coming_soon": MessageLookupByLibrary.simpleMessage(
      "¡Subida de imágenes personalizadas disponible próximamente!",
    ),
    "chat_backdrop_upload_custom": MessageLookupByLibrary.simpleMessage(
      "Subir imagen personalizada",
    ),
    "chat_request_accept_error": MessageLookupByLibrary.simpleMessage(
      "¡Algo salió mal al aceptar la solicitud de chat!",
    ),
    "chat_request_decline_error": MessageLookupByLibrary.simpleMessage(
      "¡Algo salió mal al rechazar la solicitud de chat!",
    ),
    "chat_session_delete_error": MessageLookupByLibrary.simpleMessage(
      "¡Algo salió mal al intentar eliminar la sesión de chat!",
    ),
    "chat_session_not_found": MessageLookupByLibrary.simpleMessage(
      "La sesión de chat seleccionada no existe. (Puede haber sido eliminada por el otro usuario)",
    ),
    "chat_theme": MessageLookupByLibrary.simpleMessage("Tema del chat"),
    "chat_theme_settings": MessageLookupByLibrary.simpleMessage(
      "Configuración del tema del chat",
    ),
    "chat_with": m1,
    "chats": MessageLookupByLibrary.simpleMessage("Chats"),
    "choose_friends": MessageLookupByLibrary.simpleMessage("Elegir amigos"),
    "choose_option": MessageLookupByLibrary.simpleMessage("Elige una opción"),
    "client_id_must_be_a_number": MessageLookupByLibrary.simpleMessage(
      "El ID del cliente debe ser un número",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Cerrar"),
    "command_not_implemented": MessageLookupByLibrary.simpleMessage(
      "¡Comando {} no implementado!",
    ),
    "command_unknown": MessageLookupByLibrary.simpleMessage(
      "¡Comando desconocido!",
    ),
    "confirm_delete_message": MessageLookupByLibrary.simpleMessage(
      "¿Está seguro de que desea eliminar permanentemente el mensaje?",
    ),
    "connect": MessageLookupByLibrary.simpleMessage("Conectar"),
    "connection_refused": MessageLookupByLibrary.simpleMessage(
      "¡Conexión rechazada!",
    ),
    "connection_reset": MessageLookupByLibrary.simpleMessage(
      "¡Conexión reiniciada!",
    ),
    "content_type_not_implemented": MessageLookupByLibrary.simpleMessage(
      "¡Tipo de contenido no implementado!",
    ),
    "content_type_unknown": MessageLookupByLibrary.simpleMessage(
      "¡Tipo de contenido desconocido!",
    ),
    "could_not_verify_server_certificate": MessageLookupByLibrary.simpleMessage(
      "No se pudo verificar el certificado del servidor",
    ),
    "create_account": MessageLookupByLibrary.simpleMessage("Crear cuenta"),
    "create_account_database_full": MessageLookupByLibrary.simpleMessage(
      "¡Capacidad máxima de la base de datos alcanzada! Desafortunadamente, no se pudo procesar tu solicitud.",
    ),
    "create_account_email_exists": MessageLookupByLibrary.simpleMessage(
      "¡El correo electrónico ya está en uso!",
    ),
    "create_account_error": MessageLookupByLibrary.simpleMessage(
      "¡Ocurrió un error al crear tu cuenta!",
    ),
    "create_account_success": MessageLookupByLibrary.simpleMessage(
      "¡Cuenta creada con éxito!",
    ),
    "credential_validation_client_id_error":
        MessageLookupByLibrary.simpleMessage(
          "¡No se pudo generar el ID de cliente!",
        ),
    "credential_validation_email_exists": MessageLookupByLibrary.simpleMessage(
      "¡El correo electrónico ya está en uso!",
    ),
    "credential_validation_email_invalid": MessageLookupByLibrary.simpleMessage(
      "Dirección de correo electrónico no válida",
    ),
    "credential_validation_password_invalid":
        MessageLookupByLibrary.simpleMessage(
          "¡Los requisitos de la contraseña no se cumplen!",
        ),
    "credential_validation_success": MessageLookupByLibrary.simpleMessage(
      "¡Credenciales intercambiadas con éxito!",
    ),
    "credential_validation_username_invalid":
        MessageLookupByLibrary.simpleMessage(
          "¡Los requisitos del nombre de usuario no se cumplen!",
        ),
    "custom": MessageLookupByLibrary.simpleMessage("Personalizado"),
    "decline": MessageLookupByLibrary.simpleMessage("Rechazar"),
    "decompression_failed": MessageLookupByLibrary.simpleMessage(
      "¡Descompresión fallida!",
    ),
    "default_monotone": MessageLookupByLibrary.simpleMessage(
      "Predeterminado/Monótono",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Eliminar"),
    "delete_chat": MessageLookupByLibrary.simpleMessage("Eliminar chat"),
    "delete_this_chat_question": MessageLookupByLibrary.simpleMessage(
      "¿Eliminar este chat?",
    ),
    "deleting_this_chat_will_permanently_delete_all_prior_messages":
        MessageLookupByLibrary.simpleMessage(
          "Eliminar este chat borrará permanentemente todos los mensajes anteriores",
        ),
    "display_name": MessageLookupByLibrary.simpleMessage("Nombre para mostrar"),
    "display_part_of_messages_in_notifications":
        MessageLookupByLibrary.simpleMessage(
          "Mostrar parte del mensaje en las notificaciones",
        ),
    "donate_to_ermis_project": MessageLookupByLibrary.simpleMessage(
      "Donar al proyecto Ermis",
    ),
    "donate_to_hoster": MessageLookupByLibrary.simpleMessage(
      "Donar al hospedador",
    ),
    "donations": MessageLookupByLibrary.simpleMessage("Donaciones"),
    "downloaded_file": MessageLookupByLibrary.simpleMessage(
      "Archivo descargado",
    ),
    "email": MessageLookupByLibrary.simpleMessage("Correo electrónico"),
    "email_address": MessageLookupByLibrary.simpleMessage(
      "Dirección de correo electrónico",
    ),
    "email_is_empty": MessageLookupByLibrary.simpleMessage(
      "¡El correo electrónico está vacío!",
    ),
    "email_mismatch": MessageLookupByLibrary.simpleMessage(
      "¡El correo ingresado no coincide con el correo real!",
    ),
    "enter_client_id": MessageLookupByLibrary.simpleMessage(
      "Introduzca el ID del cliente",
    ),
    "enter_verification_code": MessageLookupByLibrary.simpleMessage(
      "Introduzca el código de verificación",
    ),
    "enter_verification_code_sent_to_your_email":
        MessageLookupByLibrary.simpleMessage(
          "Introduzca el código de verificación enviado a su correo electrónico",
        ),
    "entropy_rough_estimate": m2,
    "error_saving_file": MessageLookupByLibrary.simpleMessage(
      "Ocurrió un error al intentar guardar el archivo",
    ),
    "faq_contact_terms_privacy": MessageLookupByLibrary.simpleMessage(
      "Preguntas frecuentes, contáctanos, términos y política de privacidad",
    ),
    "feature_audio_messages": MessageLookupByLibrary.simpleMessage(
      "Soporte para mensajes de audio",
    ),
    "feature_chat_themes": MessageLookupByLibrary.simpleMessage(
      "Nuevos temas de chat",
    ),
    "feature_encryption": MessageLookupByLibrary.simpleMessage(
      "Protocolos de cifrado mejorados",
    ),
    "feature_languages": MessageLookupByLibrary.simpleMessage(
      "¡Soporte multilingüe!",
    ),
    "feature_voice_calls": MessageLookupByLibrary.simpleMessage(
      "Llamadas de voz (Acceso anticipado)",
    ),
    "file_received": m3,
    "functionality_not_implemented": MessageLookupByLibrary.simpleMessage(
      "¡Funcionalidad aún no implementada!",
    ),
    "gallery": MessageLookupByLibrary.simpleMessage("Galería"),
    "got_it_button": MessageLookupByLibrary.simpleMessage("¡Entendido!"),
    "gradient": MessageLookupByLibrary.simpleMessage("Gradiente"),
    "help": MessageLookupByLibrary.simpleMessage("Ayuda"),
    "help_settings": MessageLookupByLibrary.simpleMessage(
      "Configuración de ayuda",
    ),
    "incompatible_server_version_warning": MessageLookupByLibrary.simpleMessage(
      "¡Versión del servidor incompatible! ¡Algunas cosas podrían no funcionar como se espera!",
    ),
    "license_capitalized": MessageLookupByLibrary.simpleMessage("Licence"),
    "license_crux": MessageLookupByLibrary.simpleMessage("Licencia crux"),
    "link_new_device": MessageLookupByLibrary.simpleMessage(
      "Vincular nuevo dispositivo",
    ),
    "linked_devices": MessageLookupByLibrary.simpleMessage(
      "Dispositivos vinculados",
    ),
    "linked_devices_logout_all": MessageLookupByLibrary.simpleMessage(
      "Cerrar sesión en todos los dispositivos",
    ),
    "linked_devices_logout_all_confirm": MessageLookupByLibrary.simpleMessage(
      "¿Estás seguro de que deseas cerrar sesión en todos los dispositivos?",
    ),
    "linked_devices_logout_confirm": MessageLookupByLibrary.simpleMessage(
      "¿Estás seguro de que deseas cerrar sesión en ",
    ),
    "login": MessageLookupByLibrary.simpleMessage("Iniciar sesión"),
    "login_account_not_found": MessageLookupByLibrary.simpleMessage(
      "¡La cuenta no existe!",
    ),
    "login_add_device_info": MessageLookupByLibrary.simpleMessage(
      "Agregar información del dispositivo",
    ),
    "login_backup_code_incorrect": MessageLookupByLibrary.simpleMessage(
      "Código de verificación de respaldo incorrecto.",
    ),
    "login_email_incorrect": MessageLookupByLibrary.simpleMessage(
      "¡Correo electrónico incorrecto!",
    ),
    "login_error": MessageLookupByLibrary.simpleMessage(
      "¡Ocurrió un error al iniciar sesión! Contacta al administrador del servidor e infórmale que su servidor está roto.",
    ),
    "login_fetch_requirements": MessageLookupByLibrary.simpleMessage(
      "Obtener requisitos",
    ),
    "login_password_incorrect": MessageLookupByLibrary.simpleMessage(
      "Contraseña incorrecta.",
    ),
    "login_success": MessageLookupByLibrary.simpleMessage(
      "¡Has iniciado sesión con éxito!",
    ),
    "login_toggle_password": MessageLookupByLibrary.simpleMessage(
      "Alternar tipo de contraseña",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("cerrar sesión"),
    "logout_capitalized": MessageLookupByLibrary.simpleMessage("Cerrar sesión"),
    "logout_confirmation_all_devices": MessageLookupByLibrary.simpleMessage(
      "¿Está seguro de que desea cerrar sesión de \${device.formattedInfo()}?",
    ),
    "logout_confirmation_device": MessageLookupByLibrary.simpleMessage(
      "¿Está seguro de que desea cerrar sesión de \${device.formattedInfo()}?",
    ),
    "logout_from_all_devices": MessageLookupByLibrary.simpleMessage(
      "Cerrar sesión en todos los dispositivos",
    ),
    "logout_from_this_device": MessageLookupByLibrary.simpleMessage(
      "Cerrar sesión en este dispositivo",
    ),
    "manage_storage": MessageLookupByLibrary.simpleMessage(
      "Administrar almacenamiento",
    ),
    "message_by": m4,
    "message_copied": MessageLookupByLibrary.simpleMessage(
      "Mensaje copiado al portapapeles",
    ),
    "message_deletion_unsuccessful": MessageLookupByLibrary.simpleMessage(
      "La eliminación del mensaje no tuvo éxito",
    ),
    "message_group_call_tones": MessageLookupByLibrary.simpleMessage(
      "Tonos de mensajes, grupos y llamadas",
    ),
    "message_length_exceeded": MessageLookupByLibrary.simpleMessage(
      "La longitud del mensaje supera el máximo permitido (%d caracteres)",
    ),
    "message_type_not_implemented": MessageLookupByLibrary.simpleMessage(
      "¡Tipo de mensaje no implementado!",
    ),
    "message_type_unknown": MessageLookupByLibrary.simpleMessage(
      "¡Tipo de mensaje no reconocido!",
    ),
    "min_entropy": m5,
    "name": MessageLookupByLibrary.simpleMessage("Nombre"),
    "name_enter": MessageLookupByLibrary.simpleMessage("Ingresa tu nombre"),
    "network_usage_auto_download": MessageLookupByLibrary.simpleMessage(
      "Uso de red, descarga automática",
    ),
    "new_chat": MessageLookupByLibrary.simpleMessage("Nuevo chat"),
    "new_group": MessageLookupByLibrary.simpleMessage("Nuevo grupo"),
    "new_message": MessageLookupByLibrary.simpleMessage("¡Nuevo mensaje!"),
    "no_chat_requests_available": MessageLookupByLibrary.simpleMessage(
      "No hay solicitudes de chat pendientes",
    ),
    "no_chats_available_incompatible_server_version":
        MessageLookupByLibrary.simpleMessage(
          "No hay chats disponibles, versión del servidor incompatible",
        ),
    "no_conversations_available": MessageLookupByLibrary.simpleMessage(
      "No hay conversaciones disponibles",
    ),
    "no_linked_devices": MessageLookupByLibrary.simpleMessage(
      "No hay dispositivos vinculados",
    ),
    "notification_enable": MessageLookupByLibrary.simpleMessage(
      "Habilitar notificaciones",
    ),
    "notification_preview_display_part": MessageLookupByLibrary.simpleMessage(
      "Mostrar parte del mensaje en las notificaciones",
    ),
    "notification_preview_show": MessageLookupByLibrary.simpleMessage(
      "Mostrar vistas previas de mensajes",
    ),
    "notification_settings": MessageLookupByLibrary.simpleMessage(
      "Configuración de notificaciones",
    ),
    "notification_sound": MessageLookupByLibrary.simpleMessage(
      "Sonido de notificación",
    ),
    "notification_sound_select": MessageLookupByLibrary.simpleMessage(
      "Seleccionar sonido de notificación",
    ),
    "notifications": MessageLookupByLibrary.simpleMessage("Notificaciones"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "or": MessageLookupByLibrary.simpleMessage("O"),
    "other": MessageLookupByLibrary.simpleMessage("Otros"),
    "other_settings": MessageLookupByLibrary.simpleMessage(
      "Otras configuraciones",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Contraseña"),
    "password_is_empty": MessageLookupByLibrary.simpleMessage(
      "¡La contraseña está vacía!",
    ),
    "password_validation_invalid": MessageLookupByLibrary.simpleMessage(
      "¡No se cumplen los requisitos de la contraseña!",
    ),
    "password_validation_success": MessageLookupByLibrary.simpleMessage(
      "¡Contraseña validada con éxito!",
    ),
    "please_enter_the_verification_code": MessageLookupByLibrary.simpleMessage(
      "Por favor, introduzca el código de verificación",
    ),
    "privacy": MessageLookupByLibrary.simpleMessage("Privacidad"),
    "privacy_security_change_number": MessageLookupByLibrary.simpleMessage(
      "Privacidad, seguridad, cambiar número",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("Perfil"),
    "profile_about": MessageLookupByLibrary.simpleMessage("Acerca de"),
    "profile_camera": MessageLookupByLibrary.simpleMessage("Cámara"),
    "profile_change_name_id": MessageLookupByLibrary.simpleMessage(
      "Perfil, cambiar nombre, ID",
    ),
    "profile_gallery": MessageLookupByLibrary.simpleMessage("Galería"),
    "profile_hey_there": MessageLookupByLibrary.simpleMessage("¡Hola!"),
    "profile_id_copied": MessageLookupByLibrary.simpleMessage(
      "ID copiado al portapapeles",
    ),
    "profile_name": MessageLookupByLibrary.simpleMessage("Nombre"),
    "profile_name_enter": MessageLookupByLibrary.simpleMessage(
      "Introduce tu nombre",
    ),
    "profile_photo": MessageLookupByLibrary.simpleMessage("Foto de perfil"),
    "profile_photo_fetch_error": MessageLookupByLibrary.simpleMessage(
      "¡Ocurrió un error al intentar obtener la foto de perfil de la base de datos!",
    ),
    "profile_settings": MessageLookupByLibrary.simpleMessage(
      "Configuración del perfil",
    ),
    "registration_failed": m6,
    "resend_code": MessageLookupByLibrary.simpleMessage("Reenviar código"),
    "save": MessageLookupByLibrary.simpleMessage("Guardar"),
    "search": MessageLookupByLibrary.simpleMessage("Buscar..."),
    "select_an_option": MessageLookupByLibrary.simpleMessage(
      "Seleccione una opción",
    ),
    "send_chat_request": MessageLookupByLibrary.simpleMessage(
      "Enviar solicitud de chat",
    ),
    "server_add": MessageLookupByLibrary.simpleMessage("Añadir servidor"),
    "server_add_success": MessageLookupByLibrary.simpleMessage(
      "¡Servidor añadido con éxito!",
    ),
    "server_certificate_check": MessageLookupByLibrary.simpleMessage(
      "Verificar certificado",
    ),
    "server_source_code": MessageLookupByLibrary.simpleMessage(
      "Código fuente del servidor",
    ),
    "server_url_choose": MessageLookupByLibrary.simpleMessage(
      "Elegir URL del servidor",
    ),
    "server_url_enter": MessageLookupByLibrary.simpleMessage(
      "Introduce la URL del servidor",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Configuración"),
    "settings_save": MessageLookupByLibrary.simpleMessage(
      "Guardar configuración",
    ),
    "settings_saved": MessageLookupByLibrary.simpleMessage("Ajustes guardados"),
    "sign_out": MessageLookupByLibrary.simpleMessage("Cerrar sesión"),
    "source_code": MessageLookupByLibrary.simpleMessage("Código fuente"),
    "storage_data": MessageLookupByLibrary.simpleMessage(
      "Almacenamiento y datos",
    ),
    "submit": MessageLookupByLibrary.simpleMessage("Enviar"),
    "temp_banned": MessageLookupByLibrary.simpleMessage(
      "¡Tranquilo! Has sido bloqueado temporalmente de interactuar con el servidor por un corto período de tiempo.",
    ),
    "theme_dark": MessageLookupByLibrary.simpleMessage("Modo oscuro"),
    "theme_light": MessageLookupByLibrary.simpleMessage("Modo claro"),
    "theme_mode": MessageLookupByLibrary.simpleMessage("Modo de tema"),
    "theme_system_default": MessageLookupByLibrary.simpleMessage(
      "Predeterminado del sistema",
    ),
    "theme_wallpapers_chat_history": MessageLookupByLibrary.simpleMessage(
      "Tema, fondos de pantalla, historial de chats",
    ),
    "today": MessageLookupByLibrary.simpleMessage("Hoy"),
    "type_message": MessageLookupByLibrary.simpleMessage(
      "Escribe un mensaje...",
    ),
    "unknown_size": MessageLookupByLibrary.simpleMessage("Tamaño desconocido"),
    "use_backup_verification_code": MessageLookupByLibrary.simpleMessage(
      "Usar código de verificación de respaldo",
    ),
    "use_password": MessageLookupByLibrary.simpleMessage("Usar contraseña"),
    "username_same_as_old": MessageLookupByLibrary.simpleMessage(
      "¡El nombre de usuario no puede ser el mismo que el anterior!",
    ),
    "username_validation_invalid": MessageLookupByLibrary.simpleMessage(
      "¡No se cumplen los requisitos del nombre de usuario!",
    ),
    "username_validation_success": MessageLookupByLibrary.simpleMessage(
      "¡Nombre de usuario validado con éxito!",
    ),
    "verification": MessageLookupByLibrary.simpleMessage("Verificación"),
    "verification_attempts_exhausted": MessageLookupByLibrary.simpleMessage(
      "¡Se han agotado los intentos!",
    ),
    "verification_code_incorrect": MessageLookupByLibrary.simpleMessage(
      "¡Código incorrecto!",
    ),
    "verification_code_must_be_number": MessageLookupByLibrary.simpleMessage(
      "El código de verificación debe ser un número",
    ),
    "verification_email_invalid": MessageLookupByLibrary.simpleMessage(
      "Dirección de correo electrónico no válida",
    ),
    "verification_resend_code": MessageLookupByLibrary.simpleMessage(
      "Reenviar código",
    ),
    "verification_success": MessageLookupByLibrary.simpleMessage(
      "¡Verificado con éxito!",
    ),
    "version_capitalized": MessageLookupByLibrary.simpleMessage("Version"),
    "vibration": MessageLookupByLibrary.simpleMessage("Vibración"),
    "vibration_unavailable": MessageLookupByLibrary.simpleMessage(
      "La vibración no está disponible en este dispositivo",
    ),
    "whats_new": MessageLookupByLibrary.simpleMessage("Novedades"),
    "whats_new_system_messages": MessageLookupByLibrary.simpleMessage(
      "Nuevos mensajes del sistema",
    ),
    "whats_new_title": MessageLookupByLibrary.simpleMessage(
      "Nuevas funciones en Hermis",
    ),
  };
}
