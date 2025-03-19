// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a pt locale. All the
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
  String get localeName => 'pt';

  static String m0(deviceInfo) =>
      "Tem certeza de que deseja sair de ${deviceInfo}?";

  static String m1(username) => "Conversa com ${username}";

  static String m2(entropy) => "Entropia: ${entropy} (Estimativa aproximada)";

  static String m3(fileName) => "Arquivo recebido ${fileName}";

  static String m4(username) => "Mensagem de ${username}";

  static String m5(minEntropy) => "Entropia mínima: ${minEntropy}";

  static String m6(resultMessage) => "Registro falhou: ${resultMessage}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accept": MessageLookupByLibrary.simpleMessage("Aceitar"),
    "account": MessageLookupByLibrary.simpleMessage("Conta"),
    "account_add": MessageLookupByLibrary.simpleMessage("Adicionar nova conta"),
    "account_confirm_proceed": MessageLookupByLibrary.simpleMessage(
      "Tem certeza de que deseja prosseguir?",
    ),
    "account_delete": MessageLookupByLibrary.simpleMessage("Excluir conta"),
    "account_delete_bullet1": MessageLookupByLibrary.simpleMessage(
      "Excluir sua conta sem possibilidade de recuperação",
    ),
    "account_delete_bullet2": MessageLookupByLibrary.simpleMessage(
      "Apagar seu histórico de mensagens",
    ),
    "account_delete_bullet3": MessageLookupByLibrary.simpleMessage(
      "Excluir todos os seus chats",
    ),
    "account_delete_confirmation": MessageLookupByLibrary.simpleMessage(
      "Excluir esta conta irá:",
    ),
    "account_delete_error": MessageLookupByLibrary.simpleMessage(
      "Ocorreu um erro ao tentar excluir sua conta!",
    ),
    "account_delete_my": MessageLookupByLibrary.simpleMessage(
      "Excluir minha conta",
    ),
    "account_settings": MessageLookupByLibrary.simpleMessage(
      "Configurações da conta",
    ),
    "address_not_recognized": MessageLookupByLibrary.simpleMessage(
      "Endereço não reconhecido!",
    ),
    "app_info": MessageLookupByLibrary.simpleMessage(
      "Informações do aplicativo",
    ),
    "app_language": MessageLookupByLibrary.simpleMessage(
      "Idioma do aplicativo",
    ),
    "are_you_sure_you_want_to_logout_from": m0,
    "are_you_sure_you_want_to_logout_from_all_devices":
        MessageLookupByLibrary.simpleMessage(
          "Tem certeza de que deseja sair de todos os dispositivos?",
        ),
    "attempting_delete_message": MessageLookupByLibrary.simpleMessage(
      "Tentando excluir a mensagem",
    ),
    "authentication_stage_create_account": MessageLookupByLibrary.simpleMessage(
      "Criar conta",
    ),
    "authentication_stage_credentials_exchange":
        MessageLookupByLibrary.simpleMessage("Troca de credenciais"),
    "authentication_stage_credentials_validation":
        MessageLookupByLibrary.simpleMessage("Validação de credenciais"),
    "authentication_stage_login": MessageLookupByLibrary.simpleMessage("Login"),
    "backup_verification_code": MessageLookupByLibrary.simpleMessage(
      "Código de verificação de backup",
    ),
    "backup_verification_code_regenerate_error":
        MessageLookupByLibrary.simpleMessage(
          "Ocorreu um erro ao tentar alterar o nome de usuário!",
        ),
    "backup_verification_code_regenerate_success":
        MessageLookupByLibrary.simpleMessage(
          "Códigos de verificação de backup regenerados com sucesso!",
        ),
    "camera": MessageLookupByLibrary.simpleMessage("Câmera"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
    "change_password_error": MessageLookupByLibrary.simpleMessage(
      "Ocorreu um erro ao tentar alterar a senha!",
    ),
    "change_password_success": MessageLookupByLibrary.simpleMessage(
      "Senha alterada com sucesso!",
    ),
    "change_username_error": MessageLookupByLibrary.simpleMessage(
      "Ocorreu um erro ao tentar alterar o nome de usuário!",
    ),
    "change_username_invalid": MessageLookupByLibrary.simpleMessage(
      "Requisitos de nome de usuário não atendidos",
    ),
    "change_username_success": MessageLookupByLibrary.simpleMessage(
      "Nome de usuário alterado com sucesso!",
    ),
    "chat_backdrop": MessageLookupByLibrary.simpleMessage("Fundo do chat"),
    "chat_backdrop_choose_image": MessageLookupByLibrary.simpleMessage(
      "Escolher imagem",
    ),
    "chat_backdrop_color_pick": MessageLookupByLibrary.simpleMessage(
      "Escolha uma cor!",
    ),
    "chat_backdrop_gradient_end_color": MessageLookupByLibrary.simpleMessage(
      "Cor final",
    ),
    "chat_backdrop_gradient_preview": MessageLookupByLibrary.simpleMessage(
      "Visualização do gradiente",
    ),
    "chat_backdrop_gradient_start_color": MessageLookupByLibrary.simpleMessage(
      "Cor inicial",
    ),
    "chat_backdrop_save_changes": MessageLookupByLibrary.simpleMessage(
      "Salvar alterações",
    ),
    "chat_backdrop_select_gradient": MessageLookupByLibrary.simpleMessage(
      "Selecionar cores de gradiente",
    ),
    "chat_backdrop_upload_coming_soon": MessageLookupByLibrary.simpleMessage(
      "Carregamento de imagem personalizada em breve!",
    ),
    "chat_backdrop_upload_custom": MessageLookupByLibrary.simpleMessage(
      "Carregar imagem personalizada",
    ),
    "chat_request_accept_error": MessageLookupByLibrary.simpleMessage(
      "Algo deu errado ao tentar aceitar a solicitação de chat!",
    ),
    "chat_request_decline_error": MessageLookupByLibrary.simpleMessage(
      "Algo deu errado ao tentar recusar a solicitação de chat!",
    ),
    "chat_session_delete_error": MessageLookupByLibrary.simpleMessage(
      "Algo deu errado ao tentar excluir a sessão de chat!",
    ),
    "chat_session_not_found": MessageLookupByLibrary.simpleMessage(
      "A sessão de chat selecionada não existe. (Pode ter sido excluída pelo outro usuário)",
    ),
    "chat_theme_settings": MessageLookupByLibrary.simpleMessage(
      "Configurações de tema do chat",
    ),
    "chat_with": m1,
    "chats": MessageLookupByLibrary.simpleMessage("Chats"),
    "choose_option": MessageLookupByLibrary.simpleMessage("Escolha uma opção"),
    "client_id_must_be_a_number": MessageLookupByLibrary.simpleMessage(
      "O ID do cliente deve ser um número",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Fechar"),
    "command_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Comando {} não implementado!",
    ),
    "command_unknown": MessageLookupByLibrary.simpleMessage(
      "Comando desconhecido!",
    ),
    "confirm_delete_message": MessageLookupByLibrary.simpleMessage(
      "Tem certeza de que deseja excluir permanentemente a mensagem?",
    ),
    "connect": MessageLookupByLibrary.simpleMessage("Conectar"),
    "content_type_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Tipo de conteúdo não implementado!",
    ),
    "content_type_unknown": MessageLookupByLibrary.simpleMessage(
      "Tipo de conteúdo desconhecido!",
    ),
    "create_account": MessageLookupByLibrary.simpleMessage("Criar conta"),
    "create_account_database_full": MessageLookupByLibrary.simpleMessage(
      "Capacidade máxima do banco de dados atingida! Infelizmente, sua solicitação não pôde ser processada.",
    ),
    "create_account_email_exists": MessageLookupByLibrary.simpleMessage(
      "O e-mail já está em uso!",
    ),
    "create_account_error": MessageLookupByLibrary.simpleMessage(
      "Ocorreu um erro ao criar sua conta!",
    ),
    "create_account_success": MessageLookupByLibrary.simpleMessage(
      "Conta criada com sucesso!",
    ),
    "credential_validation_client_id_error":
        MessageLookupByLibrary.simpleMessage(
          "Não foi possível gerar o ID do cliente!",
        ),
    "credential_validation_email_exists": MessageLookupByLibrary.simpleMessage(
      "O e-mail já está em uso!",
    ),
    "credential_validation_email_invalid": MessageLookupByLibrary.simpleMessage(
      "Endereço de e-mail inválido",
    ),
    "credential_validation_password_invalid":
        MessageLookupByLibrary.simpleMessage(
          "Requisitos de senha não atendidos!",
        ),
    "credential_validation_success": MessageLookupByLibrary.simpleMessage(
      "Credenciais trocadas com sucesso!",
    ),
    "credential_validation_username_invalid":
        MessageLookupByLibrary.simpleMessage(
          "Requisitos de nome de usuário não atendidos!",
        ),
    "decline": MessageLookupByLibrary.simpleMessage("Recusar"),
    "decompression_failed": MessageLookupByLibrary.simpleMessage(
      "Falha na descompressão",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Excluir"),
    "delete_chat": MessageLookupByLibrary.simpleMessage("Excluir chat"),
    "delete_this_chat_question": MessageLookupByLibrary.simpleMessage(
      "Excluir este chat?",
    ),
    "deleting_this_chat_will_permanently_delete_all_prior_messages":
        MessageLookupByLibrary.simpleMessage(
          "Excluir este chat apagará permanentemente todas as mensagens anteriores",
        ),
    "display_name": MessageLookupByLibrary.simpleMessage("Nome de exibição"),
    "display_part_of_messages_in_notifications":
        MessageLookupByLibrary.simpleMessage(
          "Exibir parte da mensagem nas notificações",
        ),
    "donate_to_ermis_project": MessageLookupByLibrary.simpleMessage(
      "Doar para o Projeto Ermis",
    ),
    "donate_to_hoster": MessageLookupByLibrary.simpleMessage(
      "Doar para o host",
    ),
    "donations": MessageLookupByLibrary.simpleMessage("Doações"),
    "downloaded_file": MessageLookupByLibrary.simpleMessage("Arquivo baixado"),
    "email": MessageLookupByLibrary.simpleMessage("E-mail"),
    "email_address": MessageLookupByLibrary.simpleMessage("Endereço de e-mail"),
    "email_is_empty": MessageLookupByLibrary.simpleMessage(
      "O e-mail está vazio!",
    ),
    "email_mismatch": MessageLookupByLibrary.simpleMessage(
      "O e-mail digitado não corresponde ao e-mail real!",
    ),
    "enter_client_id": MessageLookupByLibrary.simpleMessage(
      "Digite o ID do cliente",
    ),
    "enter_verification_code": MessageLookupByLibrary.simpleMessage(
      "Digite o código de verificação",
    ),
    "enter_verification_code_sent_to_your_email":
        MessageLookupByLibrary.simpleMessage(
          "Digite o código de verificação enviado para seu e-mail",
        ),
    "entropy_rough_estimate": m2,
    "error_saving_file": MessageLookupByLibrary.simpleMessage(
      "Ocorreu um erro ao tentar salvar o arquivo",
    ),
    "faq_contact_terms_privacy": MessageLookupByLibrary.simpleMessage(
      "FAQ, entre em contato conosco, termos e política de privacidade",
    ),
    "feature_audio_messages": MessageLookupByLibrary.simpleMessage(
      "Wsparcie dla wiadomości audio",
    ),
    "feature_chat_themes": MessageLookupByLibrary.simpleMessage(
      "Nowe motywy czatu",
    ),
    "feature_encryption": MessageLookupByLibrary.simpleMessage(
      "Ulepszone protokoły szyfrowania",
    ),
    "feature_languages": MessageLookupByLibrary.simpleMessage(
      "Wielojęzyczne wsparcie!",
    ),
    "feature_voice_calls": MessageLookupByLibrary.simpleMessage(
      "Połączenia głosowe (wczesny dostęp)",
    ),
    "file_received": m3,
    "functionality_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Funcionalidade ainda não implementada!",
    ),
    "gallery": MessageLookupByLibrary.simpleMessage("Galeria"),
    "got_it_button": MessageLookupByLibrary.simpleMessage("Rozumiem!"),
    "help": MessageLookupByLibrary.simpleMessage("Ajuda"),
    "help_settings": MessageLookupByLibrary.simpleMessage(
      "Configurações de ajuda",
    ),
    "incompatible_server_version_warning": MessageLookupByLibrary.simpleMessage(
      "Versão do servidor incompatível! Algumas coisas podem não funcionar como esperado!",
    ),
    "license_capitalized": MessageLookupByLibrary.simpleMessage("Licença"),
    "license_crux": MessageLookupByLibrary.simpleMessage(
      "Ponto crucial da licença",
    ),
    "link_new_device": MessageLookupByLibrary.simpleMessage(
      "Vincular novo dispositivo",
    ),
    "linked_devices": MessageLookupByLibrary.simpleMessage(
      "Dispositivos vinculados",
    ),
    "linked_devices_logout_all": MessageLookupByLibrary.simpleMessage(
      "Sair de todos os dispositivos",
    ),
    "linked_devices_logout_all_confirm": MessageLookupByLibrary.simpleMessage(
      "Tem certeza de que deseja sair de todos os dispositivos?",
    ),
    "linked_devices_logout_confirm": MessageLookupByLibrary.simpleMessage(
      "Tem certeza de que deseja sair de ",
    ),
    "login": MessageLookupByLibrary.simpleMessage("Entrar"),
    "login_account_not_found": MessageLookupByLibrary.simpleMessage(
      "A conta não existe!",
    ),
    "login_add_device_info": MessageLookupByLibrary.simpleMessage(
      "Adicionar informações do dispositivo",
    ),
    "login_backup_code_incorrect": MessageLookupByLibrary.simpleMessage(
      "Código de verificação de backup incorreto.",
    ),
    "login_email_incorrect": MessageLookupByLibrary.simpleMessage(
      "E-mail incorreto!",
    ),
    "login_error": MessageLookupByLibrary.simpleMessage(
      "Ocorreu um erro ao fazer login na sua conta! Entre em contato com o administrador do servidor e informe que o servidor está com problemas.",
    ),
    "login_fetch_requirements": MessageLookupByLibrary.simpleMessage(
      "Buscar requisitos",
    ),
    "login_password_incorrect": MessageLookupByLibrary.simpleMessage(
      "Senha incorreta.",
    ),
    "login_success": MessageLookupByLibrary.simpleMessage(
      "Login efetuado com sucesso na sua conta!",
    ),
    "login_toggle_password": MessageLookupByLibrary.simpleMessage(
      "Alternar tipo de senha",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("sair"),
    "logout_capitalized": MessageLookupByLibrary.simpleMessage("Sair"),
    "logout_confirmation_all_devices": MessageLookupByLibrary.simpleMessage(
      "Tem certeza de que deseja sair de \${device.formattedInfo()}?",
    ),
    "logout_confirmation_device": MessageLookupByLibrary.simpleMessage(
      "Tem certeza de que deseja sair de \${device.formattedInfo()}?",
    ),
    "logout_from_all_devices": MessageLookupByLibrary.simpleMessage(
      "Sair de todos os dispositivos",
    ),
    "logout_from_this_device": MessageLookupByLibrary.simpleMessage(
      "Sair deste dispositivo",
    ),
    "manage_storage": MessageLookupByLibrary.simpleMessage(
      "Gerenciar armazenamento",
    ),
    "message_by": m4,
    "message_copied": MessageLookupByLibrary.simpleMessage(
      "Mensagem copiada para a área de transferência",
    ),
    "message_deletion_unsuccessful": MessageLookupByLibrary.simpleMessage(
      "A exclusão da mensagem falhou",
    ),
    "message_group_call_tones": MessageLookupByLibrary.simpleMessage(
      "Sons de mensagens, grupos e chamadas",
    ),
    "message_length_exceeded": MessageLookupByLibrary.simpleMessage(
      "O comprimento da mensagem excede o comprimento máximo (%d caracteres)",
    ),
    "message_type_not_implemented": MessageLookupByLibrary.simpleMessage(
      "Tipo de mensagem não implementado!",
    ),
    "message_type_unknown": MessageLookupByLibrary.simpleMessage(
      "Tipo de mensagem não reconhecido!",
    ),
    "min_entropy": m5,
    "name": MessageLookupByLibrary.simpleMessage("Nome"),
    "name_enter": MessageLookupByLibrary.simpleMessage("Digite seu nome"),
    "network_usage_auto_download": MessageLookupByLibrary.simpleMessage(
      "Uso de rede, download automático",
    ),
    "new_chat": MessageLookupByLibrary.simpleMessage("\'Novo chat\'"),
    "new_message": MessageLookupByLibrary.simpleMessage("Nova mensagem!"),
    "no_chat_requests_available": MessageLookupByLibrary.simpleMessage(
      "Não há solicitações de chat pendentes",
    ),
    "no_chats_available_incompatible_server_version":
        MessageLookupByLibrary.simpleMessage(
          "Não há chats disponíveis, versão do servidor incompatível",
        ),
    "no_conversations_available": MessageLookupByLibrary.simpleMessage(
      "Não há conversas disponíveis",
    ),
    "no_linked_devices": MessageLookupByLibrary.simpleMessage(
      "Não há dispositivos vinculados",
    ),
    "notification_enable": MessageLookupByLibrary.simpleMessage(
      "Ativar notificações",
    ),
    "notification_preview_display_part": MessageLookupByLibrary.simpleMessage(
      "Exibir parte da mensagem nas notificações",
    ),
    "notification_preview_show": MessageLookupByLibrary.simpleMessage(
      "Mostrar pré-visualizações de mensagens",
    ),
    "notification_settings": MessageLookupByLibrary.simpleMessage(
      "Configurações de notificação",
    ),
    "notification_sound": MessageLookupByLibrary.simpleMessage(
      "Som de notificação",
    ),
    "notification_sound_select": MessageLookupByLibrary.simpleMessage(
      "Selecionar som de notificação",
    ),
    "notifications": MessageLookupByLibrary.simpleMessage("Notificações"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "or": MessageLookupByLibrary.simpleMessage("Ou"),
    "other": MessageLookupByLibrary.simpleMessage("Outros"),
    "other_settings": MessageLookupByLibrary.simpleMessage(
      "Outras configurações",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Senha"),
    "password_is_empty": MessageLookupByLibrary.simpleMessage(
      "A senha está vazia!",
    ),
    "password_validation_invalid": MessageLookupByLibrary.simpleMessage(
      "Requisitos de senha não atendidos!",
    ),
    "password_validation_success": MessageLookupByLibrary.simpleMessage(
      "Senha validada com sucesso!",
    ),
    "please_enter_the_verification_code": MessageLookupByLibrary.simpleMessage(
      "Por favor, digite o código de verificação",
    ),
    "privacy_security_change_number": MessageLookupByLibrary.simpleMessage(
      "Privacidade, segurança, alterar número",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("Perfil"),
    "profile_about": MessageLookupByLibrary.simpleMessage("Sobre"),
    "profile_camera": MessageLookupByLibrary.simpleMessage("Câmera"),
    "profile_change_name_id": MessageLookupByLibrary.simpleMessage(
      "Perfil, alterar nome, ID",
    ),
    "profile_gallery": MessageLookupByLibrary.simpleMessage("Galeria"),
    "profile_hey_there": MessageLookupByLibrary.simpleMessage("Olá!"),
    "profile_id_copied": MessageLookupByLibrary.simpleMessage(
      "ID copiado para a área de transferência",
    ),
    "profile_name": MessageLookupByLibrary.simpleMessage("Nome"),
    "profile_name_enter": MessageLookupByLibrary.simpleMessage(
      "Digite seu nome",
    ),
    "profile_photo": MessageLookupByLibrary.simpleMessage("Foto de perfil"),
    "profile_photo_fetch_error": MessageLookupByLibrary.simpleMessage(
      "Ocorreu um erro ao tentar buscar a foto de perfil do banco de dados!",
    ),
    "profile_settings": MessageLookupByLibrary.simpleMessage(
      "Configurações de perfil",
    ),
    "registration_failed": m6,
    "requests": MessageLookupByLibrary.simpleMessage("Solicitações"),
    "resend_code": MessageLookupByLibrary.simpleMessage("Reenviar código"),
    "save": MessageLookupByLibrary.simpleMessage("Salvar"),
    "search": MessageLookupByLibrary.simpleMessage("Pesquisar..."),
    "select_an_option": MessageLookupByLibrary.simpleMessage(
      "Selecione uma opção",
    ),
    "send_chat_request": MessageLookupByLibrary.simpleMessage(
      "Enviar solicitação de chat",
    ),
    "server_add": MessageLookupByLibrary.simpleMessage("Adicionar servidor"),
    "server_add_success": MessageLookupByLibrary.simpleMessage(
      "Servidor adicionado com sucesso!",
    ),
    "server_certificate_check": MessageLookupByLibrary.simpleMessage(
      "Verificar certificado",
    ),
    "server_source_code": MessageLookupByLibrary.simpleMessage(
      "Código fonte do servidor",
    ),
    "server_url_choose": MessageLookupByLibrary.simpleMessage(
      "Escolher URL do servidor",
    ),
    "server_url_enter": MessageLookupByLibrary.simpleMessage(
      "Digite o URL do servidor",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Configurações"),
    "settings_save": MessageLookupByLibrary.simpleMessage(
      "Salvar configurações",
    ),
    "settings_saved": MessageLookupByLibrary.simpleMessage(
      "Configurações salvas",
    ),
    "sign_out": MessageLookupByLibrary.simpleMessage("Sair"),
    "source_code": MessageLookupByLibrary.simpleMessage("Código fonte"),
    "storage_data": MessageLookupByLibrary.simpleMessage(
      "Armazenamento e dados",
    ),
    "submit": MessageLookupByLibrary.simpleMessage("Enviar"),
    "temp_banned": MessageLookupByLibrary.simpleMessage(
      "Vá com calma! Você foi temporariamente banido de interagir com o servidor por um curto período de tempo.",
    ),
    "theme_dark": MessageLookupByLibrary.simpleMessage("Modo escuro"),
    "theme_light": MessageLookupByLibrary.simpleMessage("Modo claro"),
    "theme_mode": MessageLookupByLibrary.simpleMessage("Modo de tema"),
    "theme_system_default": MessageLookupByLibrary.simpleMessage(
      "Padrão do sistema",
    ),
    "theme_wallpapers_chat_history": MessageLookupByLibrary.simpleMessage(
      "Tema, papéis de parede, histórico de chats",
    ),
    "today": MessageLookupByLibrary.simpleMessage("Hoje"),
    "type_message": MessageLookupByLibrary.simpleMessage(
      "Digite uma mensagem...",
    ),
    "unknown_size": MessageLookupByLibrary.simpleMessage(
      "Tamanho desconhecido",
    ),
    "use_backup_verification_code": MessageLookupByLibrary.simpleMessage(
      "Usar código de verificação de backup",
    ),
    "use_password": MessageLookupByLibrary.simpleMessage("Usar senha"),
    "username_same_as_old": MessageLookupByLibrary.simpleMessage(
      "O nome de usuário não pode ser o mesmo que o nome de usuário antigo!",
    ),
    "username_validation_invalid": MessageLookupByLibrary.simpleMessage(
      "Requisitos de nome de usuário não atendidos!",
    ),
    "username_validation_success": MessageLookupByLibrary.simpleMessage(
      "Nome de usuário validado com sucesso!",
    ),
    "verification": MessageLookupByLibrary.simpleMessage("Verificação"),
    "verification_attempts_exhausted": MessageLookupByLibrary.simpleMessage(
      "Tentativas esgotadas!",
    ),
    "verification_code_incorrect": MessageLookupByLibrary.simpleMessage(
      "Código incorreto!",
    ),
    "verification_code_must_be_number": MessageLookupByLibrary.simpleMessage(
      "O código de verificação deve ser um número",
    ),
    "verification_email_invalid": MessageLookupByLibrary.simpleMessage(
      "Endereço de e-mail inválido",
    ),
    "verification_resend_code": MessageLookupByLibrary.simpleMessage(
      "Reenviar código",
    ),
    "verification_success": MessageLookupByLibrary.simpleMessage(
      "Verificado com sucesso!",
    ),
    "version_capitalized": MessageLookupByLibrary.simpleMessage("Versão"),
    "vibration": MessageLookupByLibrary.simpleMessage("Vibração"),
    "vibration_unavailable": MessageLookupByLibrary.simpleMessage(
      "A vibração não está disponível neste dispositivo",
    ),
    "whats_new": MessageLookupByLibrary.simpleMessage("Co nowego"),
    "whats_new_system_messages": MessageLookupByLibrary.simpleMessage(
      "Nowe wiadomości systemowe",
    ),
    "whats_new_title": MessageLookupByLibrary.simpleMessage(
      "Nowe funkcje w Hermis",
    ),
  };
}
