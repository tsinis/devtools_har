import '../har_object.dart';
import '../har_utils.dart';

/// Posted data sent with a request.
///
/// Models the `postData` object defined in the HAR 1.2 specification.
///
/// The spec states that [text] and [params] are mutually exclusive —
/// use [text] for raw body payloads and [params] for
/// `application/x-www-form-urlencoded` or `multipart/form-data`
/// parameters. In practice, Chrome and Firefox often emit both.
///
/// Reference: http://www.softwareishard.com/blog/har-12-spec/#postData
class HarPostData extends HarObject {
  /// Creates a [HarPostData] with the given field values.
  ///
  /// [mimeType], [params], and [text] are required by the HAR 1.2
  /// spec (though [text] and [params] are mutually exclusive, so
  /// [text] is typed as nullable here).
  const HarPostData({
    required this.mimeType,
    required this.params,
    required this.text,
    super.comment,
    super.custom = const {},
  });

  /// Deserialises a [HarPostData] from a decoded JSON map.
  ///
  /// [mimeType] is required by the spec. When missing, an assertion
  /// fires (in debug mode) and the field falls back to
  /// `"application/octet-stream"`.
  ///
  /// [params] entries that are not JSON maps are skipped with an
  /// assertion warning.
  factory HarPostData.fromJson(Json json) => _fromJson(json);

  static HarPostData _fromJson(Json json) {
    final mimeTypeRaw = json[kMimeType];
    assert(mimeTypeRaw != null, 'HarPostData: "$kMimeType" is required');
    final paramsRaw = json[kParams];

    return HarPostData(
      mimeType: mimeTypeRaw?.toString() ?? kFallbackMimeType,
      params: paramsRaw is List
          ? [
              for (final e in paramsRaw)
                if (e is Json) HarParam.fromJson(e) else ..._assertParam(e),
            ]
          : const [],
      text: json[kText]?.toString(),
      comment: json[HarObject.kComment]?.toString(),
      custom: HarUtils.collectCustom(json),
    );
  }

  /// Fires an assertion and returns an empty iterable so the
  /// malformed entry is skipped.
  static Iterable<HarParam> _assertParam(Object? value) {
    assert(
      false, // ignore: avoid-constant-assert-conditions, checked by the caller.
      'HarPostData: "$kParams" entries must be JSON objects, got: $value',
    );

    return const [];
  }

  /// JSON key for the MIME type (`"mimeType"`).
  static const kMimeType = 'mimeType';

  /// JSON key for the list of posted parameters (`"params"`).
  static const kParams = 'params';

  /// JSON key for the plain posted data body (`"text"`).
  static const kText = 'text';

  /// Fallback MIME type used when `mimeType` is absent.
  static const kFallbackMimeType = 'application/octet-stream';

  /// MIME type of the posted data.
  ///
  /// Required by the HAR 1.2 spec.
  final String mimeType;

  /// List of posted parameters (for form submissions).
  ///
  /// Mutually exclusive with [text] per the spec, though real-world
  /// exporters often populate both. Empty when the field is absent
  /// or when the body is a raw [text] payload.
  final List<HarParam> params;

  /// Plain text representation of the posted data body.
  ///
  /// Mutually exclusive with [params] per the spec. `null` when
  /// the field is absent or when the body is described by [params].
  final String? text;

  /// Serialises this post data object back to a JSON-compatible map.
  ///
  /// Optional fields that are `null` are omitted from the output.
  @override
  Json toJson({bool includeNulls = false}) => HarUtils.applyNullPolicy(
    {
      kMimeType: mimeType,
      kParams: params.map((e) => e.toJson(includeNulls: includeNulls)).toList(),
      kText: text,
      ...commonJson(includeNulls: includeNulls),
    },
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );
}

/// A single posted parameter (embedded in a [HarPostData] object).
///
/// Models one entry in the `params` array defined in the HAR 1.2 specification.
///
/// For `multipart/form-data` uploads the [fileName] and [contentType]
/// fields describe the uploaded file.
///
/// Reference: http://www.softwareishard.com/blog/har-12-spec/#params
// ignore: prefer-single-declaration-per-file, they are closely related.
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
    super.custom = const {},
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
}
