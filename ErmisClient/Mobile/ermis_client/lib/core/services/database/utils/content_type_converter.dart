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


import 'dart:collection';

import 'package:ermis_mobile/core/networking/common/message_types/content_type.dart';
import 'package:ermis_mobile/core/networking/common/message_types/message_delivery_status.dart';

class ContentTypeConverter {
  static const int text = 117; // WARNING: DO NOT CHANGE TO ENSURE COMPATIBILITY WITH LOCAL SQLITE DATABASE
	static const int file = 64; // WARNING: DO NOT CHANGE TO ENSURE COMPATIBILITY WITH LOCAL SQLITE DATABASE
	static const int image = 343; // WARNING: DO NOT CHANGE TO ENSURE COMPATIBILITY WITH LOCAL SQLITE DATABASE
	static const int voice = 2008; // WARNING: DO NOT CHANGE TO ENSURE COMPATIBILITY WITH LOCAL SQLITE DATABASE
	static const int gif = 2320; // WARNING: DO NOT CHANGE TO ENSURE COMPATIBILITY WITH LOCAL SQLITE DATABASE

  static final Map<MessageContentType, int> contentTypesToDatabaseInts = UnmodifiableMapView(const {
    MessageContentType.text: text,
    MessageContentType.file: file,
    MessageContentType.image: image,
    MessageContentType.voice: voice,
    MessageContentType.gif: gif,
  });

  static final Map<int, MessageContentType> databaseIntsToContentTypes = UnmodifiableMapView(const {
    text: MessageContentType.text,
    file: MessageContentType.file,
    image: MessageContentType.image,
    voice: MessageContentType.voice,
    gif: MessageContentType.gif,
  });
}

class DeliveryStatusConverter {
  static const int delivered = 116; // WARNING: DO NOT CHANGE TO ENSURE COMPATIBILITY WITH LOCAL SQLITE DATABASE
  static const int failed = 117; // WARNING: DO NOT CHANGE TO ENSURE COMPATIBILITY WITH LOCAL SQLITE DATABASE
  static const int lateDelivered = 118; // WARNING: DO NOT CHANGE TO ENSURE COMPATIBILITY WITH LOCAL SQLITE DATABASE
	static const int rejected = 64; // WARNING: DO NOT CHANGE TO ENSURE COMPATIBILITY WITH LOCAL SQLITE DATABASE
	static const int sending = 343; // WARNING: DO NOT CHANGE TO ENSURE COMPATIBILITY WITH LOCAL SQLITE DATABASE
	static const int serverReceived = 2008; // WARNING: DO NOT CHANGE TO ENSURE COMPATIBILITY WITH LOCAL SQLITE DATABASE

  static final Map<MessageDeliveryStatus, int> deliveryStatusToDatabaseInts = UnmodifiableMapView(const {
    MessageDeliveryStatus.delivered: delivered,
    MessageDeliveryStatus.failed: failed,
    MessageDeliveryStatus.lateDelivered: lateDelivered,
    MessageDeliveryStatus.rejected: rejected,
    MessageDeliveryStatus.sending: sending,
    MessageDeliveryStatus.serverReceived: serverReceived,
  });

  static final Map<int, MessageDeliveryStatus> databaseIntsToDeliveryStatus = UnmodifiableMapView(const {
    delivered: MessageDeliveryStatus.delivered,
    failed: MessageDeliveryStatus.failed,
    lateDelivered: MessageDeliveryStatus.lateDelivered,
    rejected: MessageDeliveryStatus.rejected,
    sending: MessageDeliveryStatus.sending,
    serverReceived: MessageDeliveryStatus.serverReceived,
  });
}
