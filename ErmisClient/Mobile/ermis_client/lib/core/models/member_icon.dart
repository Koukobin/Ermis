
import 'dart:typed_data';

class MemberIcon {
  final Uint8List profilePhoto;
  final int lastUpdatedAtEpochSecond;
  const MemberIcon(this.profilePhoto, this.lastUpdatedAtEpochSecond);

  /// This hashCode is not ideal nor is it optimal but it is 
  /// good enough and sufficient for virtually all cases
  @override
  int get hashCode => profilePhoto.length * lastUpdatedAtEpochSecond.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MemberIcon) return false;
    
    return profilePhoto == other.profilePhoto &&
        lastUpdatedAtEpochSecond == other.lastUpdatedAtEpochSecond;
  }
}