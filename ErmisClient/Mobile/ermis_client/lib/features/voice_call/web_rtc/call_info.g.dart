// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CallInfo _$CallInfoFromJson(Map<String, dynamic> json) => CallInfo(
      chatSessionID: (json['chatSessionID'] as num).toInt(),
      chatSessionIndex: (json['chatSessionIndex'] as num).toInt(),
      member: Member.fromJson(json['member'] as Map<String, dynamic>),
      isInitiator: json['isInitiator'] as bool,
    );

Map<String, dynamic> _$CallInfoToJson(CallInfo instance) => <String, dynamic>{
      'chatSessionID': instance.chatSessionID,
      'chatSessionIndex': instance.chatSessionIndex,
      'member': instance.member,
      'isInitiator': instance.isInitiator,
    };
