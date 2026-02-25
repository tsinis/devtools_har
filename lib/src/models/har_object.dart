import '../helpers/har_utils.dart';

/// Base class for all HAR objects that expose `comment` and custom fields.
abstract class HarObject {
  /// Creates a base HAR object with an optional comment and custom fields.
  const HarObject({this.comment, this.custom = const {}});

  /// JSON key for the human-readable comment (`"comment"`).
  static const kComment = 'comment';

  /// Key for vendor-specific custom fields (`"custom"`).
  static const kCustom = 'custom';

  /// Default HTTP version when not specified.
  static const kDefaultHttpVersion = 'HTTP/1.1';

  /// A comment provided by the user or the application.
  final String? comment;

  /// Vendor-specific custom fields (keys starting with `_`).
  final Json custom;

  /// Serialises this object back to a JSON-compatible map.
  Json toJson({bool includeNulls = false});

  /// Shared `toJson` tail for `comment` and custom fields.
  Json commonJson({bool includeNulls = false}) => HarUtils.applyNullPolicy(
    {kComment: comment, ...custom},
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );

  @override
  String toString() =>
      '''HarObject(${[if (comment != null) '$kComment: $comment', if (custom.isNotEmpty) '$kCustom: $custom'].join(', ')})''';
}
