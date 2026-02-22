import '../har_object.dart';
import '../har_utils.dart';

/// Details about response content (embedded in the `response` object).
///
/// Describes the response body and its encoding. The [size] reflects the
/// uncompressed length; when the payload was compressed on the wire,
/// [compression] indicates how many bytes were saved.
///
/// Reference: http://www.softwareishard.com/blog/har-12-spec/#content.
class HarContent extends HarObject {
  /// Creates a [HarContent] with the given field values.
  ///
  /// [size] and [mimeType] are required by the HAR 1.2 spec.
  /// All other parameters are optional.
  const HarContent({
    required this.size,
    required this.mimeType,
    this.compression,
    this.text,
    this.encoding,
    super.comment,
    super.custom,
  });

  /// Deserialises a [HarContent] from a decoded JSON map.
  ///
  /// Numeric fields ([size], [compression]) are parsed via
  /// `num.tryParse(value.toString())` and then truncated to [int].
  /// This tolerates both integer and floating-point JSON
  /// representations as well as stringified numbers.
  ///
  /// If [size] is missing or unparseable it defaults to zero.
  /// If [mimeType] is missing it defaults to [kFallbackMimeType]
  /// (`"application/octet-stream"`).
  factory HarContent.fromJson(Json json) => _fromJson(json);

  static HarContent _fromJson(Json json) {
    final compression = num.tryParse(json[kCompression]?.toString() ?? '');
    final size = num.tryParse(json[kSize]?.toString() ?? '');

    return HarContent(
      size: size?.toInt() ?? 0,
      mimeType: json[kMimeType]?.toString() ?? kFallbackMimeType,
      compression: compression?.toInt(),
      text: json[kText]?.toString(),
      encoding: json[kEncoding]?.toString(),
      comment: json[HarObject.kComment]?.toString(),
      custom: HarUtils.collectCustom(json),
    );
  }

  /// JSON key for the uncompressed body length (`"size"`).
  static const kSize = 'size';

  /// JSON key for the bytes saved by compression (`"compression"`).
  static const kCompression = 'compression';

  /// JSON key for the MIME type (`"mimeType"`).
  static const kMimeType = 'mimeType';

  /// JSON key for the response body text (`"text"`).
  static const kText = 'text';

  /// JSON key for the text encoding (`"encoding"`).
  static const kEncoding = 'encoding';

  /// Fallback MIME type used when the `mimeType` field is missing
  /// from the JSON source. Defaults to `"application/octet-stream"`.
  static const kFallbackMimeType = 'application/octet-stream';

  /// Length of the returned content in bytes (uncompressed).
  ///
  /// Should be equal to `response.bodySize` when there is no
  /// compression, and larger when the content was compressed on
  /// the wire.
  ///
  /// Typed as [int] because byte counts are inherently integral.
  final int size;

  /// Number of bytes saved by compression, or `null` if unavailable.
  ///
  /// When present: `compression = size − response.bodySize`.
  ///
  /// Typed as [int] — the difference of 2 byte counts is always a whole number.
  final int? compression;

  /// MIME type of the response text (value of the `Content-Type`
  /// response header).
  ///
  /// The charset attribute is included when available, e.g.
  /// `"text/html; charset=utf-8"`.
  final String mimeType;

  /// Response body sent from the server or loaded from the browser
  /// cache, or `null` if the information is not available.
  ///
  /// Populated with textual content only.  The value is either
  /// HTTP-decoded text or an encoded (e.g. base64) representation
  /// of the response body — see [encoding].
  final String? text;

  /// Encoding used for the [text] field, e.g. `"base64"`.
  ///
  /// Omit (leave `null`) when [text] is already HTTP-decoded
  /// (decompressed & unchunked) and transcoded to UTF-8.
  ///
  /// Added in HAR 1.2.
  final String? encoding;

  /// Serialises this content object back to a JSON-compatible map.
  ///
  /// Optional fields that are `null` are omitted from the output
  /// so that the resulting JSON stays compact and spec-compliant.
  @override
  Json toJson({bool includeNulls = false}) => HarUtils.applyNullPolicy(
    {
      kCompression: compression,
      kEncoding: encoding,
      kMimeType: mimeType,
      kSize: size,
      kText: text,
      ...commonJson(includeNulls: includeNulls),
    },
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );

  @override
  String toString() => 'HarContent(${[
    'size: $size',
    'mimeType: $mimeType',
    if (compression != null) 'compression: $compression',
    if (text != null) 'text: $text',
    if (encoding != null) 'encoding: $encoding',
    if (comment != null) 'comment: $comment',
    if (custom.isNotEmpty) 'custom: $custom',
  ].join(', ')})';
}
