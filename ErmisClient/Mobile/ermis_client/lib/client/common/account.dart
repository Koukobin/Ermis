import 'dart:typed_data';
import 'dart:convert';

class Account {
  final Uint8List profilePhoto;
  final String displayName;
  final String email;
  final int clientID;

  Account({
    required this.profilePhoto,
    required this.displayName,
    required this.email,
    required this.clientID,
  });

  @override
  int get hashCode {
    const prime = 31;
    var result = 1;
    result = prime * result + profilePhoto.hashCode;
    result = prime * result + displayName.hashCode;
    result = prime * result + email.hashCode;
    result = prime * result + clientID.hashCode;
    return result;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Account) {
      return false;
    }
    return clientID == other.clientID &&
        profilePhoto == other.profilePhoto &&
        email == other.email &&
        displayName == other.displayName;
  }

  String name() {
    return "$displayName@$clientID";
  }

  @override
  String toString() {
    return 'Account [icon=${base64Encode(profilePhoto)}, username=$displayName, email=$email, clientID=$clientID]';
  }
}
