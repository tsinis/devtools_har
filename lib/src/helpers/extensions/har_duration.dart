import '../har_utils.dart';

/// Extension methods for converting between HAR millisecond durations and
/// Dart [Duration]s.
extension HarDuration<T extends Duration> on T? {
  // ignore: avoid-explicit-type-declaration, it's clearer to have the type here.
  static const int _perMillisecond = Duration.microsecondsPerMillisecond;

  /// HAR spec uses `-1` to mean "does not apply to the current request".
  /// This is semantically distinct from `null` (field absent), so we map it to
  /// a specific [Duration] value that can be round-tripped without loss
  /// of information.
  static const minusOne = Duration(milliseconds: -1);

  /// Converts a millisecond [maybeMilliseconds] to [Duration].
  ///
  /// Maps `-1` to `Duration(milliseconds: -1)` per HAR spec.
  /// Returns `null` for `null` input.
  static Duration? tryParse(String? maybeMilliseconds) {
    final milliseconds = num.tryParse(maybeMilliseconds ?? '');

    return milliseconds == null
        ? null
        : Duration(
            microseconds: (milliseconds.toDouble() * _perMillisecond).round(),
          );
  }

  /// Converts a [Duration] back to a millisecond [num].
  ///
  /// Preserves integer types when a numeric value is whole.
  num? get inNormalizedMilliseconds {
    final duration = this;

    return duration == null
        ? null
        : HarUtils.normalizeNumber(duration.inMicroseconds / _perMillisecond);
  }
}
