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

import 'package:ermis_mobile/features/authentication/domain/entities/resultable.dart';
import 'package:ermis_mobile/generated/l10n.dart';

import '../../../exceptions/enum_not_found_exception.dart';

enum ChangePasswordResult implements Resultable {
  successfullyChangedPassword(
    id: 0,
    success: true,
  ),
  errorWhileChangingPassword(
    id: 1,
    success: false,
  );

  final int id;
  final bool success;

  const ChangePasswordResult({
    required this.id,
    required this.success,
  });

  @override
  bool get isSuccessful => success;
  
  @override
  String get message => switch(ChangePasswordResult.fromId(id)) {
    ChangePasswordResult.successfullyChangedPassword => S.current.change_password_success,
    ChangePasswordResult.errorWhileChangingPassword => S.current.change_password_error
  };

  static ChangePasswordResult fromId(int id) {
    try {
      return ChangePasswordResult.values.firstWhere((type) => type.id == id);
    } catch (e) {
      throw EnumNotFoundException('No $ChangePasswordResult found for id $id');
    }
  }
}
