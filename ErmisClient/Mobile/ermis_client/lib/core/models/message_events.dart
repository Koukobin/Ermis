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

import 'package:ermis_client/core/models/chat_request.dart';
import 'package:ermis_client/core/models/inet_socket_address.dart';
import 'package:ermis_client/core/models/member.dart';
import 'package:ermis_client/core/models/message.dart';
import 'package:ermis_client/core/networking/common/message_types/message_delivery_status.dart';
import 'package:ermis_client/core/models/user_device.dart';
import 'package:ermis_client/core/data/models/network/byte_buf.dart';
import 'package:ermis_client/core/networking/common/message_types/client_status.dart';

import 'account.dart';
import 'chat_session.dart';
import 'file_heap.dart';

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

class VoiceDownloadedEvent {
  final LoadedInMemoryFile file;
  final int messageID;
  const VoiceDownloadedEvent(this.file, this.messageID);
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
  const SignallingServerPortEvent(this.port);
}

class ClientIdReceivedEvent {
  final int clientId;
  const ClientIdReceivedEvent(this.clientId);
}

class AccountStatusEvent {
  final ClientStatus status;
  const AccountStatusEvent(this.status);
}

class ChatRequestsEvent {
  final List<ChatRequest> requests;
  const ChatRequestsEvent(this.requests);
}

class ChatSessionsIndicesReceivedEvent {
  final List<ChatSession> sessions;
  const ChatSessionsIndicesReceivedEvent(this.sessions);
}

class ChatSessionsEvent {
  final List<ChatSession> sessions;
  const ChatSessionsEvent(this.sessions);
}

class ChatSessionsStatusesEvent {
  final List<ChatSession> sessions;
  const ChatSessionsStatusesEvent(this.sessions);
}

class OtherAccountsEvent {
  final List<Account> accounts;
  const OtherAccountsEvent(this.accounts);
}

class VoiceCallIncomingEvent {
  final int chatSessionID;
  final int chatSessionIndex;
  final Uint8List aesKey;
  final Member member;
  final int signallingPort;
  const VoiceCallIncomingEvent({
    required this.chatSessionID,
    required this.chatSessionIndex,
    required this.aesKey,
    required this.member,
    required this.signallingPort,
  });
}

class MemberAddedToVoiceCalll {
  final int chatSessionID;
  final int clientID;
  final JavaInetSocketAddress socket;
  const MemberAddedToVoiceCalll({
    required this.chatSessionID,
    required this.clientID,
    required this.socket,
  });
}

class StartVoiceCallResultEvent {
  final Uint8List aesKey;
  final int udpServerPort;
  const StartVoiceCallResultEvent(this.aesKey, this.udpServerPort);
}

class MessageDeletionUnsuccessfulEvent {
  const MessageDeletionUnsuccessfulEvent();
}

class MessageDeletedEvent {
  final ChatSession chatSession;
  final int messageId;
  const MessageDeletedEvent(this.chatSession, this.messageId);
}

class ProfilePhotoReceivedEvent {
  final Uint8List photoBytes;
  const ProfilePhotoReceivedEvent(this.photoBytes);
}

class AddProfilePhotoResultEvent {
  final bool success;
  const AddProfilePhotoResultEvent(this.success);
}

class UserDevicesEvent {
  final List<UserDeviceInfo> devices;
  const UserDevicesEvent(this.devices);
}

class ConnectionResetEvent {
  const ConnectionResetEvent();
}
