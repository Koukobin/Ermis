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
    ServerInfoMessage.tooManyRequestsMade => S.current.tooManyRequestsMadeError,
    ServerInfoMessage.commandNotRecognized => S.current.commandNotRecognized,
    ServerInfoMessage.errorOccurredWhileTryingToFetchProfilePhoto => S.current.profilePhotoFetchError,
    ServerInfoMessage.inetAddressNotRecognized => S.current.addressNotRecognized,
    ServerInfoMessage.messageLengthExceedsLimit => S.current.messageLengthExceeded,
    ServerInfoMessage.chatSessionDoesNotExist => S.current.chatSessionNotFound,
    ServerInfoMessage.errorOccurredWhileTryingToDeleteChatSession => S.current.chatSessionDeleteError,
    ServerInfoMessage.errorOccurredWhileTryingToDeclineChatRequest => S.current.chatRequestDeclineError,
    ServerInfoMessage.errorOccurredWhileTryingToAcceptChatRequest => S.current.chatRequestAcceptError,
    ServerInfoMessage.errorOccurredWhileTryingToSendChatRequest => S.current.errorOccurredWhileTryingToSendChatRequest,
    ServerInfoMessage.errorOccurredWhileTryingToFetchFileFromDatabase => S.current.errorOccurredFetchingFileFromDatabase,
    ServerInfoMessage.decompressionFailed => S.current.decompressionFailed,
    ServerInfoMessage.messageTypeNotRecognized => S.current.messageTypeNotRecognized,
    ServerInfoMessage.contentTypeNotKnown => S.current.messageTypeUnknown,
    ServerInfoMessage.messageTypeNotImplemented => S.current.messageTypeNotImplemented,
    ServerInfoMessage.contentTypeNotImplemented => S.current.contentTypeNotImplemented,
    ServerInfoMessage.commandNotKnown => S.current.commandUnknown,
  };

  static ServerInfoMessage? fromId(int id) {
    return ServerInfoMessage.values.firstWhere(
      (element) => element.id == id,
      orElse: () => throw ArgumentError('Invalid value: $id'),
    );
  }
}
