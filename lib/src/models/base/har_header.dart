import '../har_object.dart';
import '../har_utils.dart';

/// A single HTTP header name-value pair.
///
/// Models the headers object defined in the HAR 1.2 specification.
///
/// Used in both `<request>` and `<response>` objects to represent
/// individual HTTP headers.
///
/// Reference: http://www.softwareishard.com/blog/har-12-spec/#headers
class HarHeader extends HarObject {
  /// Creates a [HarHeader] with the given field values.
  ///
  /// [name] and [value] are required by the HAR 1.2 spec.
  const HarHeader({
    required this.name,
    required this.value,
    super.comment,
    super.custom,
  });

  /// Deserialises a [HarHeader] from a decoded JSON map.
  ///
  /// Required fields ([name], [value]) are guarded by [assert]s
  /// that fire in debug mode. In release builds, missing keys
  /// fall back to empty strings.
  factory HarHeader.fromJson(Json json) => _fromJson(json);

  static HarHeader _fromJson(Json json) {
    assert(json[kName] != null, 'HarHeader: "$kName" is required');
    assert(json[kValue] != null, 'HarHeader: "$kValue" is required');

    return HarHeader(
      name: json[kName]?.toString() ?? '',
      value: json[kValue]?.toString() ?? '',
      comment: json[HarObject.kComment]?.toString(),
      custom: HarUtils.collectCustom(json),
    );
  }

  /// JSON key for the header name (`"name"`).
  static const kName = 'name';

  /// JSON key for the header value (`"value"`).
  static const kValue = 'value';

  /// The name of the HTTP header (e.g. `"Content-Type"`).
  ///
  /// Required by the HAR 1.2 spec.
  final String name;

  /// The value of the HTTP header.
  ///
  /// Required by the HAR 1.2 spec.
  final String value;

  /// Serialises this header back to a JSON-compatible map.
  ///
  /// Optional fields that are `null` are omitted from the output.
  @override
  Json toJson({bool includeNulls = false}) => HarUtils.applyNullPolicy(
    {kName: name, kValue: value, ...commonJson(includeNulls: includeNulls)},
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );

  @override
  String toString() => 'HarHeader(${[
    'name: $name',
    'value: $value',
    if (comment != null) 'comment: $comment',
    if (custom.isNotEmpty) 'custom: $custom',
  ].join(', ')})';
}
