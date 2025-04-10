import 'dart:collection';

/// This is an implementation of the .distinct() method in the Java Stream API in dart
extension IterableDistinct<T> on Iterable<T> {
  ///
  /// Returns a new [Iterable] consisting of the distinct elements
  /// (according to both == and hashCode) of this [Iterable].
  ///
  Iterable<T> shittyDistinct() {
    // ignore: prefer_collection_literals, for clarity, I decided to explicitly initialize the Set instead of using {}
    final seen = LinkedHashSet<T>();
    return where((T element) => seen.add(element));
  }

  /// Returns a new [Iterable] consisting of the distinct
  /// elements (according to hashCode method) of this [Iterable].
  ///
  /// Uses [LinkedHashSet] to assure there are not duplicates
  /// while maintaining the ordering of the elements
  Iterable<T> hashCodeDistinct() {
    return toHashOnlySet();
  }
}

extension FirstWhereExt<T> on Iterable<T> {
  /// The first element satisfying [test], or `null` if there are none.
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

extension ToHashOnlySet<T> on Iterable<T> {
  /// Apparently, in Dart, the Set uses both hashCode and == (equality operator) 
  /// to determine uniqueness of values. So even if multiple elements have the same 
  /// hash code, they will all be added to the set unless they are also considered 
  /// equal via ==.
  /// 
  /// This is truly a horrible design choice. Why? I love Dart - but this is a very 
  /// questionable choice. Nevertheless, I am sure they had their reasons.
  Iterable<T> toHashOnlySet() {
    return HashSet(equals: (p0, p1) => true)..addAll(this);
  }
}
