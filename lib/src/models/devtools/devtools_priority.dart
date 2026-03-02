/// Chrome resource priority levels.
///
/// Maps to the Chrome DevTools Protocol
/// [`ResourcePriority`](https://chromedevtools.github.io/devtools-protocol/1-3/Network/#type-ResourcePriority)
/// enum.
///
/// ```dart
/// const priority = DevToolsPriority.high;
/// print(priority.value); // High
/// print(DevToolsPriority.tryParse('VeryHigh')); // DevToolsPriority.veryHigh
/// ```
enum DevToolsPriority {
  /// Very high priority.
  veryHigh('VeryHigh'),

  /// High priority.
  high('High'),

  /// Medium priority.
  medium('Medium'),

  /// Low priority.
  low('Low'),

  /// Very low priority.
  veryLow('VeryLow');

  const DevToolsPriority(this.value);

  /// The string value as it appears in HAR / CDP JSON.
  final String value;

  /// Resolves a [DevToolsPriority] from its JSON string [value].
  ///
  /// Returns `null` if [value] is `null` or does not match any known
  /// variant (case-insensitive).
  static DevToolsPriority? tryParse(Object? value) {
    if (value == null) return null;

    final lower = value.toString().toLowerCase();
    for (final priority in values) {
      if (priority.value.toLowerCase() == lower) return priority;
    }

    return null;
  }

  /// Serialises as the string value matching the CDP convention.
  String toJson() => value;
}
