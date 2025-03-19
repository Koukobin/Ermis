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


/// This File contains all the callbacks to call in certain responses of the server -
/// e.g receiving the username.
library;

import 'dart:typed_data';

import 'package:ermis_client/client/common/chat_request.dart';
import 'package:ermis_client/client/common/message.dart';
import 'package:ermis_client/client/common/message_types/message_delivery_status.dart';
import 'package:ermis_client/client/common/user_device.dart';
import 'package:ermis_client/client/io/byte_buf.dart';

import 'common/account.dart';
import 'common/chat_session.dart';
import 'common/file_heap.dart';

class EntryMessage {
  final ByteBuf buffer;
  const EntryMessage(this.buffer);
}

class UsernameReceivedEvent {
  final String displayName;
  const UsernameReceivedEvent(this.displayName);
}

class MessageReceivedEvent {
  final Message message;
  final ChatSession chatSession;
  const MessageReceivedEvent(this.message, this.chatSession);
}

class MessageDeliveryStatusEvent {
  final MessageDeliveryStatus deliveryStatus;
  final Message message;
  const MessageDeliveryStatusEvent({
    required this.deliveryStatus,
    required this.message,
  });
}

class WrittenTextEvent {
  final ChatSession chatSession;
  const WrittenTextEvent(this.chatSession);
}

class ServerMessageInfoEvent {
  final String message;
  const ServerMessageInfoEvent(this.message);
}

class FileDownloadedEvent {
  final LoadedInMemoryFile file;
  const FileDownloadedEvent(this.file);
}

class ImageDownloadedEvent {
  final LoadedInMemoryFile file;
  final int messageID;
  const ImageDownloadedEvent(this.file, this.messageID);
}

class DonationPageEvent {
  final String donationPageURL;
  const DonationPageEvent(this.donationPageURL);
}

class SourceCodePageEvent {
  final String sourceCodePageURL;
  const SourceCodePageEvent(this.sourceCodePageURL);
}

class ServerSourceCodeEvent {
  final String sourceCodeUrl;
  const ServerSourceCodeEvent(this.sourceCodeUrl);
}

class SignallingServerPortEvent {
  final int port;
  final Uint8List aesKey;
  const SignallingServerPortEvent(this.port, this.aesKey);
}

class ClientIdEvent {
  final int clientId;
  const ClientIdEvent(this.clientId);
}

class ChatRequestsEvent {
  final List<ChatRequest> requests;
  const ChatRequestsEvent(this.requests);
}

class ChatSessionsEvent {
  final List<ChatSession> sessions;
  const ChatSessionsEvent(this.sessions);
}

class OtherAccountsEvent {
  final List<Account> accounts;
  const OtherAccountsEvent(this.accounts);
}

class VoiceCallIncomingEvent {
  final int chatSessionID;
  final int chatSessionIndex;
  final Uint8List aesKey;
  final int mansPort;
  final Member member;
  const VoiceCallIncomingEvent({
    required this.chatSessionID,
    required this.chatSessionIndex,
    required this.aesKey,
    required this.member,
    required this.mansPort,
  });
}

class StartVoiceCallResultEvent {
  final int key;
  final int udpServerPort;
  const StartVoiceCallResultEvent(this.key, this.udpServerPort);
}

class MessageDeletionUnsuccessfulEvent {
  const MessageDeletionUnsuccessfulEvent();
}

class MessageDeletedEvent {
  final ChatSession chatSession;
  final int messageId;
  const MessageDeletedEvent(this.chatSession, this.messageId);
}

class ProfilePhotoEvent {
  final Uint8List photoBytes;
  const ProfilePhotoEvent(this.photoBytes);
}

class AddProfilePhotoResultEvent {
  final bool success;
  const AddProfilePhotoResultEvent(this.success);
}

class UserDevicesEvent {
  final List<UserDeviceInfo> devices;
  const UserDevicesEvent(this.devices);
}


