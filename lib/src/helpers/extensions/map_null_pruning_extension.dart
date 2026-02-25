import 'dart:collection' show LinkedHashMap;

/// Extension on [Map] that provides null-value filtering utilities.
extension MapNullPruningExtension<K, V> on Map<K, V?> {
  /// Returns a new [Map] with all entries whose value is `null` removed.
  ///
  /// The returned map is of type `Map<K, V>` — the compiler-visible nullable
  /// value type is narrowed to its non-nullable counterpart, giving full
  /// static type safety downstream without any unsafe casts.
  ///
  /// This method is **non-mutating**: the original map is never modified.
  /// A fresh [LinkedHashMap] is allocated, preserving insertion order.
  ///
  /// **Complexity**: O(n) time, O(n) space.
  ///
  /// **Type parameters**
  /// - [K] — the key type (unrestricted).
  /// - [V] — the non-nullable value type after pruning.
  ///
  /// **Example**
  /// ```dart
  /// final raw = <String, int?>{
  ///   'a': 1,
  ///   'b': null,
  ///   'c': 3,
  /// };
  ///
  /// final clean = raw.withoutNullValues;
  /// // clean == {'a': 1, 'c': 3}
  /// // clean is Map<String, int>  ✓
  /// ```
  ///
  /// See also:
  /// - [removeNullValues], the in-place mutating variant.
  Map<K, V> get withoutNullValues {
    final result = <K, V>{};
    for (final entry in entries) {
      final value = entry.value;
      if (value != null) result[entry.key] = value; // Smart-cast: V? → V.
    }

    return result;
  }

  /// Removes all entries whose value is `null` from this map **in place**,
  /// then returns `this` for optional chaining.
  ///
  /// Unlike [withoutNullValues], no new map is allocated.
  /// Prefer this variant when you own the map and want to avoid the
  /// extra allocation (e.g. a freshly-built builder map).
  ///
  /// **Complexity**: O(n) time, O(1) extra space.
  ///
  /// **Returns** `this` (still typed as `Map<K, V?>`) to allow chaining.
  ///
  /// > **Warning**: mutates the receiver. Do not use on unmodifiable maps.
  ///
  /// **Example**
  /// ```dart
  /// final map = <String, int?>{
  ///   'x': 10,
  ///   'y': null,
  ///   'z': 30,
  /// };
  ///
  /// map.removeNullValues();
  /// // map == {'x': 10, 'z': 30}
  /// ```
  ///
  /// See also:
  /// - [withoutNullValues], the non-mutating variant that returns `Map<K, V>`.
  // ignore: avoid-collection-mutating-methods, prefer-getter-over-method, that's the point of this method...
  Map<K, V?> removeNullValues() => this..removeWhere((_, v) => v == null);
}
