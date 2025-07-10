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

import 'package:ermis_mobile/generated/l10n.dart';

enum ServerInfoMessage {
  tooManyRequestsMade(0),
  commandNotRecognized(1),
  errorOccurredWhileTryingToFetchProfilePhoto(2),
  inetAddressNotRecognized(3),
  messageLengthExceedsLimit(4),
  chatSessionDoesNotExist(5),
  errorOccurredWhileTryingToDeleteChatSession(6),
  errorOccurredWhileTryingToDeclineChatRequest(7),
  errorOccurredWhileTryingToAcceptChatRequest(8),
  errorOccurredWhileTryingToSendChatRequest(9),
  errorOccurredWhileTryingToFetchFileFromDatabase(10),
  decompressionFailed(11),
  messageTypeNotRecognized(12),
  contentTypeNotKnown(13),
  messageTypeNotImplemented(14),
  contentTypeNotImplemented(15),
  commandNotKnown(16);

  final int id;

  const ServerInfoMessage(this.id);

  String get stringMessage => switch (this) {
    ServerInfoMessage.tooManyRequestsMade => S.current.too_many_requests_made,
    ServerInfoMessage.commandNotRecognized => S.current.command_not_recognized,
    ServerInfoMessage.errorOccurredWhileTryingToFetchProfilePhoto => S.current.profile_photo_fetch_error,
    ServerInfoMessage.inetAddressNotRecognized => S.current.address_not_recognized,
    ServerInfoMessage.messageLengthExceedsLimit => S.current.message_length_exceeded,
    ServerInfoMessage.chatSessionDoesNotExist => S.current.chat_session_not_found,
    ServerInfoMessage.errorOccurredWhileTryingToDeleteChatSession => S.current.chat_session_delete_error,
    ServerInfoMessage.errorOccurredWhileTryingToDeclineChatRequest => S.current.chat_request_decline_error,
    ServerInfoMessage.errorOccurredWhileTryingToAcceptChatRequest => S.current.chat_request_accept_error,
    ServerInfoMessage.errorOccurredWhileTryingToSendChatRequest => S.current.error_occurred_while_trying_to_send_chat_request,
    ServerInfoMessage.errorOccurredWhileTryingToFetchFileFromDatabase => S.current.error_occurred_while_trying_to_fetch_file_from_database,
    ServerInfoMessage.decompressionFailed => S.current.decompression_failed,
    ServerInfoMessage.messageTypeNotRecognized => S.current.message_type_not_recognized,
    ServerInfoMessage.contentTypeNotKnown => S.current.message_type_unknown,
    ServerInfoMessage.messageTypeNotImplemented => S.current.message_type_not_implemented,
    ServerInfoMessage.contentTypeNotImplemented => S.current.content_type_not_implemented,
    ServerInfoMessage.commandNotKnown => S.current.command_unknown,
  };

  static ServerInfoMessage? fromId(int id) {
    return ServerInfoMessage.values.firstWhere(
      (element) => element.id == id,
      orElse: () => throw ArgumentError('Invalid value: $id'),
    );
  }
}
