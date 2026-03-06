/// Extension on [Iterable] of [Enum] values providing a generic [tryParse]
/// utility for matching enum entries by a string representation.
///
/// Typical usage pattern — call this on an enum's `.values` list:
///
/// ```dart
/// final priority = DevToolsPriority.values.tryParse(input);
/// ```
extension EnumIterableParsing<T extends Enum> on Iterable<T> {
  /// Attempts to find an enum entry whose [valueOf] result lowercase-trimmed
  /// string matches [value].toString().toLowerCase().trim(). Default [valueOf]
  /// is the enum entry's `name` property.
  ///
  /// Returns `null` if [value] is `null` or no match is found.
  ///
  /// Example:
  /// ```dart
  /// final result = DevToolsPriority.values.tryParse(someInput);
  /// ```
  // ignore: avoid-similar-names, prefer-explicit-parameter-names, user defined.
  T? tryParse(Object? value, {String Function(T)? valueOf}) {
    if (value == null) return null;
    final lowerTrimmed = value.toString().toLowerCase().trim();
    final stringOf = valueOf ?? (enumValue) => enumValue.name;

    for (final entry in this) {
      if (stringOf(entry).toLowerCase().trim() == lowerTrimmed) return entry;
    }

    return null;
  }
}
