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

import 'dart:async';

/// Handles event dispatching to listeners via Dart's [Stream] API. The [EventBus]
/// is designed for decoupled communication between components. It enables objects
/// to interact without needing to explicitly define and manage listeners.
///
/// Only events of general interest should be emitted through the [EventBus].
///
/// Events are regular Dart objects, and listeners can filter events by their class.
class EventBus {
  final StreamController _streamController;

  /// Constructs an [EventBus] instance.
  ///
  /// When [sync] is set to true, events are sent directly to listeners during the
  /// [fire] call. If false (default), events will be sent after the event creation
  /// completes, allowing for a more asynchronous flow.
  EventBus({bool sync = false}) : _streamController = StreamController.broadcast(sync: sync);

  /// Registers a listener for events of type [T] and its subtypes.
  ///
  /// The method is invoked as follows: myEventBus.on&lt;MyType&gt;();
  ///
  /// If the type parameter is omitted, the [Stream] will include all events
  /// from the [EventBus].
  ///
  /// The returned [Stream] is broadcast, so it allows multiple subscriptions.
  ///
  /// Listeners operate independently, and if one is paused, it only affects that listener.
  /// Paused listeners will buffer events internally until resumed or canceled. It is typically
  /// better to cancel and resubscribe to avoid memory leaks.
  ///
  Stream<T> on<T>() {
    if (T == dynamic) {
      return streamController.stream as Stream<T>;
    } else {
      return streamController.stream.where((event) => event is T).cast<T>();
    }
  }

  /// The controller used to manage the event bus stream.
  StreamController get streamController => _streamController;

  /// Sends a new event onto the event bus, broadcasting the specified [event].
  void fire(event) {
    streamController.add(event);
  }

  /// Retrieves the streams satisfying [test], or an empty stream if there are none.
  Stream<T> where<T>(bool Function(dynamic event) test) {
    return _streamController.stream.where(test) as Stream<T>;
  }

  /// Closes the [EventBus].
  void destroy() {
    _streamController.close();
  }
}
