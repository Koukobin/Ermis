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
import 'package:flutter/widgets.dart';
import '../core/event_bus/event_bus.dart';

/// This mixin is designed to facilitate the use of the global [EventBus]
/// by automating the release of subscriptions to it, minimizing risk of
/// potential memory leaks.
mixin EventBusSubscriptionMixin<T extends StatefulWidget> on State<T> {
  final List<StreamSubscription> _subscriptions = [];

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  @protected
  void subscribe<E>(
    Stream<E> stream,
    void Function(E data) onData, {
    void Function()? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    if (!mounted) return;

    _subscriptions.add(stream.listen((event) {
      if (!mounted) return;

      onData(event);
    }));
  }
}
