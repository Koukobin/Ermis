/* Copyright (C) 2024 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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

import 'package:ermis_client/features/authentication/domain/entities/resultable.dart';

import '../../../features/authentication/domain/entities/added_info.dart';

class EntryResult<T extends Resultable> {
  final T resultHolder;
	final Map<AddedInfo, String> addedInfo;

  const EntryResult(this.resultHolder, this.addedInfo);

  T get isSuccessful => resultHolder;
}