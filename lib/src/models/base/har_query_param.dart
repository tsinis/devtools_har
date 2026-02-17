import '../har_object.dart';
import '../har_utils.dart';

/// A single query-string parameter from a request URL.
///
/// Reference: http://www.softwareishard.com/blog/har-12-spec/#queryString
class HarQueryParam extends HarObject {
  /// Creates a [HarQueryParam] with the given field values.
  ///
  /// [name] and [value] are required by the HAR 1.2 spec.
  const HarQueryParam({
    required this.name,
    required this.value,
    super.comment,
    super.custom,
  });

  /// Deserialises a [HarQueryParam] from a decoded JSON map.
  ///
  /// Both [name] and [value] are required by the spec. When either
  /// is missing an assertion fires (in debug mode) and the field
  /// falls back to an empty string so that parsing does not throw
  /// in production.
  factory HarQueryParam.fromJson(Json json) => _fromJson(json);

  static HarQueryParam _fromJson(Json json) {
    final nameRaw = json[kName];
    assert(nameRaw != null, 'HarQueryParam: "$kName" is required');
    final valueRaw = json[kValue];
    assert(valueRaw != null, 'HarQueryParam: "$kValue" is required');

    return HarQueryParam(
      name: nameRaw?.toString() ?? '',
      value: valueRaw?.toString() ?? '',
      comment: json[HarObject.kComment]?.toString(),
      custom: HarUtils.collectCustom(json),
    );
  }

  /// JSON key for the parameter name (`"name"`).
  static const kName = 'name';

  /// JSON key for the parameter value (`"value"`).
  static const kValue = 'value';

  /// The name of the query-string parameter.
  ///
  /// Required by the HAR 1.2 spec.
  final String name;

  /// The value of the query-string parameter.
  ///
  /// Required by the HAR 1.2 spec.
  final String value;

  /// Serialises this query parameter back to a JSON-compatible map.
  ///
  /// Optional fields that are `null` are omitted from the output.
  @override
  Json toJson({bool includeNulls = false}) => HarUtils.applyNullPolicy(
    {kName: name, kValue: value, ...commonJson()},
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );
}
