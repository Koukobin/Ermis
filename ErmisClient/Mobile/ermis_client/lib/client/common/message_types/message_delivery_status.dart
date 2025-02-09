import '../exceptions/EnumNotFoundException.dart';

enum MessageDeliveryStatus {
  delivered(0),
  serverReceived(1),
  failed(2),
  rejected(3),
  sending(4);

  final int id;
  const MessageDeliveryStatus(this.id);

  // Mimics the `fromId` functionality, throwing an exception if no match is found.
  static MessageDeliveryStatus fromId(int id) {
    try {
      return MessageDeliveryStatus.values.firstWhere((type) => type.id == id);
    } catch (e) {
      throw EnumNotFoundException('No ServerMessageType found for id $id');
    }
  }
}
