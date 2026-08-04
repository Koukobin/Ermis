/* Copyright (C) 2026 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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
import 'dart:convert';
import 'dart:typed_data';

import '../../../data/models/network/byte_buf.dart';
import '../../../event_bus/app_event_bus.dart';
import '../../../models/message_events.dart';

final AppEventBus _eventBus = AppEventBus.instance;

mixin UnrelatedCommands {
  void fetchSignallingPortUrl(ByteBuf msg) {
    int signallingServerPort = msg.readInt32();
    _eventBus.fire(SignallingServerPortEvent(signallingServerPort));
  }

  void getSourceCodePageURL(ByteBuf msg) {
    Uint8List sourceCodePageURL = msg.readBytes(msg.readableBytes);
    _eventBus.fire(SourceCodePageEvent(utf8.decode(sourceCodePageURL)));
  }

  void getDonationPageURL(ByteBuf msg) {
    Uint8List donationPageURL = msg.readBytes(msg.readableBytes);
    _eventBus.fire(DonationPageEvent(utf8.decode(donationPageURL)));
  }
}