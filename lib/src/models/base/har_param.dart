import '../../helpers/har_utils.dart';
import '../har_object.dart';
import 'har_post_data.dart';

/// A single posted parameter (embedded in a [HarPostData] object).
///
/// Models one entry in the `params` array defined in the HAR 1.2
/// specification.
///
/// For `multipart/form-data` uploads the [fileName] and [contentType]
/// fields describe the uploaded file.
///
/// ```dart
/// const param = HarParam(name: 'username', value: 'admin');
/// print(param.toJson()); // {name: username, value: admin}
/// ```
// Reference: http://www.softwareishard.com/blog/har-12-spec/#params.
class HarParam extends HarObject {
  /// Creates a [HarParam] with the given field values.
  ///
  /// [name] is required by the HAR 1.2 spec.
  const HarParam({
    required this.name,
    this.value,
    this.fileName,
    this.contentType,
    super.comment,
    super.custom,
  });

  /// Deserialises a [HarParam] from a decoded JSON map.
  ///
  /// [name] is required by the spec. When missing, an assertion
  /// fires (in debug mode) and the field falls back to an empty
  /// string.
  factory HarParam.fromJson(Json json) => _fromJson(json);

  static HarParam _fromJson(Json json) {
    final nameRaw = json[kName];
    assert(nameRaw != null, 'HarParam: "$kName" is required');

    return HarParam(
      name: nameRaw?.toString() ?? '',
      value: json[kValue]?.toString(),
      fileName: json[kFileName]?.toString(),
      contentType: json[kContentType]?.toString(),
      comment: json[HarObject.kComment]?.toString(),
      custom: HarUtils.collectCustom(json),
    );
  }

  /// JSON key for the parameter name (`"name"`).
  static const kName = 'name';

  /// JSON key for the parameter value (`"value"`).
  static const kValue = 'value';

  /// JSON key for the uploaded file name (`"fileName"`).
  static const kFileName = 'fileName';

  /// JSON key for the content type of the uploaded file
  /// (`"contentType"`).
  static const kContentType = 'contentType';

  /// Name of the posted parameter.
  ///
  /// Required by the HAR 1.2 spec.
  final String name;

  /// Value of the posted parameter, or `null` if not available.
  final String? value;

  /// Name of the uploaded file, or `null` if not a file upload.
  final String? fileName;

  /// Content type of the uploaded file, or `null` if not a file
  /// upload.
  final String? contentType;

  /// Serialises this parameter back to a JSON-compatible map.
  ///
  /// Optional fields that are `null` are omitted from the output.
  @override
  Json toJson({bool includeNulls = false}) => HarUtils.applyNullPolicy(
    {
      kContentType: contentType,
      kFileName: fileName,
      kName: name,
      kValue: value,
      ...commonJson(includeNulls: includeNulls),
    },
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );

  @override
  String toString() =>
      '''HarParam(${['$kName: $name', if (value != null) '$kValue: $value', if (fileName != null) '$kFileName: $fileName', if (contentType != null) '$kContentType: $contentType', if (comment != null) '${HarObject.kComment}: $comment', if (custom.isNotEmpty) '${HarObject.kCustom}: $custom'].join(', ')})''';

  /// Creates a copy of this [HarParam] with the given fields replaced.
  @override
  HarParam copyWith({
    String? name,
    String? value,
    String? fileName,
    String? contentType,
    String? comment,
    Json? custom,
  }) => HarParam(
    name: name ?? this.name,
    value: value ?? this.value,
    fileName: fileName ?? this.fileName,
    contentType: contentType ?? this.contentType,
    comment: comment ?? this.comment,
    custom: custom ?? this.custom,
  );
}
