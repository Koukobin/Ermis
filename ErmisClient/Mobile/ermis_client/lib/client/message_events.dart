
/// This File contains all the callbacks to call in certain responses of the server -
/// e.g receiving the username.
library;

import 'dart:typed_data';

import 'package:ermis_client/client/common/chat_request.dart';
import 'package:ermis_client/client/common/message.dart';
import 'package:ermis_client/client/common/user_device.dart';

import 'common/account.dart';
import 'common/chat_session.dart';
import 'common/file_heap.dart';
import 'common/html_page.dart';

class UsernameReceivedEvent {
  final String displayName;
  UsernameReceivedEvent(this.displayName);
}

class MessageReceivedEvent {
  final Message message;
  final ChatSession chatSession;
  MessageReceivedEvent(this.message, this.chatSession);
}

class MessageSentEvent {
  final ChatSession session;
  final int messageID;
  MessageSentEvent(this.session, this.messageID);
}

class WrittenTextEvent {
  final ChatSession chatSession;
  WrittenTextEvent(this.chatSession);
}

class ServerMessageEvent {
  final String message;
  ServerMessageEvent(this.message);
}

class FileDownloadedEvent {
  final LoadedInMemoryFile file;
  FileDownloadedEvent(this.file);
}

class ImageDownloadedEvent {
  final LoadedInMemoryFile file;
  final int messageID;
  ImageDownloadedEvent(this.file, this.messageID);
}

class DonationPageEvent {
  final DonationHtmlPage page;
  DonationPageEvent(this.page);
}

class ServerSourceCodeEvent {
  final String sourceCodeUrl;
  ServerSourceCodeEvent(this.sourceCodeUrl);
}

class ClientIdEvent {
  final int clientId;
  ClientIdEvent(this.clientId);
}

class ChatRequestsEvent {
  final List<ChatRequest> requests;
  ChatRequestsEvent(this.requests);
}

class ChatSessionsEvent {
  final List<ChatSession> sessions;
  ChatSessionsEvent(this.sessions);
}

class OtherAccountsEvent {
  final List<Account> accounts;
  OtherAccountsEvent(this.accounts);
}

class VoiceCallIncomingEvent {
  final Member member;
  VoiceCallIncomingEvent(this.member);
}

class MessageDeletedEvent {
  final ChatSession chatSession;
  final int messageId;
  MessageDeletedEvent(this.chatSession, this.messageId);
}

class ProfilePhotoEvent {
  final Uint8List photoBytes;
  ProfilePhotoEvent(this.photoBytes);
}

class AddProfilePhotoResultEvent {
  final bool success;
  AddProfilePhotoResultEvent(this.success);
}

class UserDevicesEvent {
  final List<UserDeviceInfo> devices;
  UserDevicesEvent(this.devices);
}


