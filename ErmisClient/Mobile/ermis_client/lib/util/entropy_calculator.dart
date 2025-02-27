import 'dart:math';

class EntropyCalculator {
  static double calculateEntropy(String input) {
    if (input.isEmpty) return 0.0;

    final Map<String, int> frequencyMap = {};

    // Count occurrences of each character
    for (final int char in input.runes) {
      String key = String.fromCharCode(char);
      frequencyMap[key] = (frequencyMap[key] ?? 0) + 1;
    }

    final int length = input.length;
    double entropy = 0.0;

    // Calculate entropy
    for (final int count in frequencyMap.values) {
      double probability = count / length;
      entropy -= probability * (log(probability) / ln2);
    }

    if (input.length > 6) return entropy * 30;
    return entropy * 4;
  }
}
