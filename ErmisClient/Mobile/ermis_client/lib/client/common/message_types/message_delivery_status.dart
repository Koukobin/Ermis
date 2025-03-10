import '../exceptions/EnumNotFoundException.dart';

enum MessageDeliveryStatus {
  lateDelivered(0),
  delivered(1),
  serverReceived(2),
  failed(3),
  rejected(4),
  sending(5);

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
