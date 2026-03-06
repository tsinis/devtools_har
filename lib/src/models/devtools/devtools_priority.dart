import '../../helpers/extensions/enum_iterable_parsing.dart';

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
  /// High priority.
  high('High'),

  /// Low priority.
  low('Low'),

  /// Medium priority.
  medium('Medium'),

  /// Very high priority.
  veryHigh('VeryHigh'),

  /// Very low priority.
  veryLow('VeryLow');

  const DevToolsPriority(this.value);

  /// The string value as it appears in HAR / CDP JSON.
  final String value;

  /// Resolves a [DevToolsPriority] from its JSON string [value].
  ///
  /// Returns `null` if [value] is `null` or does not match any known
  /// variant (case-insensitive).
  static DevToolsPriority? tryParse(Object? value) =>
      values.tryParse(value, valueOf: (prio) => prio.name.toLowerCase());

  /// Serialises as the string value matching the CDP convention.
  String toJson() => value;
}
