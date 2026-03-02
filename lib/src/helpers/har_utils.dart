import 'extensions/map_null_pruning_extension.dart';

/// Convenience alias for a decoded JSON map.
typedef Json = Map<String, dynamic>;

/// Utility functions for HAR JSON processing.
///
/// ```dart
/// final json = <String, dynamic>{'key': 'value', 'other': null};
/// final pruned = HarUtils.applyNullPolicy(json);
/// print(pruned); // {key: value}
/// ```
sealed class HarUtils {
  /// Apply null filtering based on [includeNulls].
  static Json applyNullPolicy(Json json, {bool includeNulls = false}) =>
      includeNulls ? json : json.withoutNullValues;

  /// Preserve integer types when a numeric value is whole.
  static num? normalizeNumber(num? numb) {
    if (numb == null) return null;
    if (numb is int) return numb;

    return numb is double && numb.isFinite && numb == numb.truncateToDouble()
        ? numb.toInt()
        : numb;
  }

  /// Collect every key that starts with `_` into a custom-fields map.
  ///
  /// [excludeKeys] omits known DevTools fields that are parsed explicitly.
  static Json collectCustom(Json json, [Set<String> excludeKeys = const {}]) =>
      Json.fromEntries(
        json.entries.where(
          (entr) => entr.key.startsWith('_') && !excludeKeys.contains(entr.key),
        ),
      );

  /// Safely parse a nullable [DateTime] from a nullable JSON string.
  static DateTime? optionalDateTime(Object? value) =>
      value == null ? null : DateTime.tryParse(value.toString());
}
