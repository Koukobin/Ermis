// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Member _$MemberFromJson(Map<String, dynamic> json) => Member(
      json['username'] as String,
      (json['clientID'] as num).toInt(),
      MemberIcon.fromJson(json['icon'] as Map<String, dynamic>),
      $enumDecode(_$ClientStatusEnumMap, json['status']),
      (json['lastUpdatedAtEpochSecond'] as num).toInt(),
    );

Map<String, dynamic> _$MemberToJson(Member instance) => <String, dynamic>{
      'username': instance.username,
      'clientID': instance.clientID,
      'icon': instance.icon,
      'status': _$ClientStatusEnumMap[instance.status]!,
      'lastUpdatedAtEpochSecond': instance.lastUpdatedAtEpochSecond,
    };

const _$ClientStatusEnumMap = {
  ClientStatus.online: 'online',
  ClientStatus.offline: 'offline',
  ClientStatus.doNotDisturb: 'doNotDisturb',
  ClientStatus.invisible: 'invisible',
};
