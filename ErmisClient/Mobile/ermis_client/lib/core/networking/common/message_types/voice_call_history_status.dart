import '../../../exceptions/EnumNotFoundException.dart';

enum VoiceCallHistoryStatus {
  created(0),
  accepted(1),
  ignored(2);

  final int id;

  const VoiceCallHistoryStatus(this.id);

  static final Map<int, VoiceCallHistoryStatus> _valuesById = {
    for (var status in VoiceCallHistoryStatus.values) status.id: status,
  };

  static VoiceCallHistoryStatus fromId(int id) {
    final s = _valuesById[id];

    if (s == null) {
      throw EnumNotFoundException('No $VoiceCallHistoryStatus found for id $id');
    }
    
    return s;
  }
}
