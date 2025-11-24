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

import 'event_bus.dart';

class AppEventBus {
  EventBus _eventBus = EventBus();

  static final AppEventBus _appEventBus = AppEventBus._();
  static AppEventBus get instance => _appEventBus;

  /// Prevent instantiation
  AppEventBus._();

  Stream<T> on<T>() => _eventBus.on<T>();
  void fire<T>(T event) => _eventBus.fire(event);

  void destroyInstance() => _eventBus.destroy();
  void restoreInstance() => _eventBus = EventBus();
}