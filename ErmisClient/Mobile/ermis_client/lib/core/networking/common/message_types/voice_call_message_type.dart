

import '../../../exceptions/EnumNotFoundException.dart';

enum VoiceCallMessageType {
	incomingVoiceCall(0),
	userJoinedVoiceCall(1);

  final int id;
  const VoiceCallMessageType(this.id);

  // Mimics the `fromId` functionality, throwing an exception if no match is found.
  static VoiceCallMessageType fromId(int id) {
    try {
      return VoiceCallMessageType.values.firstWhere((type) => type.id == id);
    } catch (e) {
      throw EnumNotFoundException('No $VoiceCallMessageType found for id $id');
    }
  }
}