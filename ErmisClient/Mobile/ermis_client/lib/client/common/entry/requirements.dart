import 'dart:core';

class Requirements {
	
	final double minEntropy;
	final int maxLength;
  final String invalidCharacters;

  Requirements({this.minEntropy = 0, required this.maxLength, this.invalidCharacters = ""});

  double get getMinEntropy => minEntropy;
  int get getMaxLength => maxLength;
  String get getInvalidCharacters => invalidCharacters;
}
