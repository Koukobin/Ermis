import 'dart:collection';

/// This is an implementation of the .distinct() method in the Java Stream API in dart
extension IterableDistinct<T> on Iterable<T> {
  ///
  /// Returns a new [Iterable] consisting of the distinct elements 
  /// (according to ==) of this [Iterable].
  ///
  Iterable<T> equalsDistinct() {
    final seen = LinkedHashSet<T>();
    // forEach((m) {
    //   int count = 0;
    //   for (T t in this) {
    //     if (t == m) return count;
    //   }
    // });
    return where((T element) => seen.add(element));
  }

  /// Returns a new [Iterable] consisting of the distinct
  /// elements (according to hashCode method) of this [Iterable].
  ///
  /// Uses [LinkedHashSet] to assure there are not duplicates
  /// while maintaining the ordering of the elements
  Iterable<T> hashCodeDistinct() {
    final seen = LinkedHashSet<T>();
    toSet().toList();
    return where((T element) => seen.add(element));
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