

class EpochDateTime {
  static DateTime fromSecondsSinceEpoch(int secondsSinceEpoch, {bool isUtc = false}) =>
      DateTime.fromMillisecondsSinceEpoch(secondsSinceEpoch * 1000,
              isUtc: isUtc)
          .toLocal();
}
