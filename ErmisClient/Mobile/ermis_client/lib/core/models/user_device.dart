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



import '../exceptions/EnumNotFoundException.dart';

enum DeviceType {
  mobile(0),
  tablet(1),
  desktop(2),
  unknown(3);

  final int id;

  const DeviceType(this.id);

  String get name {
    switch (this) {
      case DeviceType.mobile:
        return 'Mobile';
      case DeviceType.tablet:
        return 'Tablet';
      case DeviceType.desktop:
        return 'Desktop';
      case DeviceType.unknown:
        return 'Device unspecified';
      }
  }

  // This function mimics the fromId functionality and throws an exception when no match is found.
  static DeviceType fromId(int id) {
    try {
      return DeviceType.values.firstWhere((type) => type.id == id);
    } catch (e) {
      throw EnumNotFoundException('No DeviceType found for id $id');
    }
  }
}


class UserDeviceInfo {
  final String ipAddress;
  final DeviceType deviceType;
  final String osName;

  const UserDeviceInfo(this.ipAddress, this.deviceType, this.osName);

  @override
  int get hashCode => ipAddress.hashCode ^ deviceType.hashCode ^ osName.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UserDeviceInfo) return false;
    return other.ipAddress == ipAddress &&
        other.deviceType == deviceType &&
        other.osName == osName;
  }

  String formattedInfo() {
    return '${deviceType.name} $osName: $ipAddress';
  }

  @override
  String toString() {
    return 'UserDeviceInfo(ipAddress: $ipAddress, deviceType: ${deviceType.name}, osName: $osName)';
  }
}
