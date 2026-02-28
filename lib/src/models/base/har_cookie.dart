import '../../helpers/har_utils.dart';
import '../har_object.dart';
import 'har_request.dart' show HarRequest;
import 'har_response.dart' show HarResponse;

/// An HTTP cookie exchanged in a [request][HarRequest] or
/// [response][HarResponse].
///
/// Models the cookie object defined in the:
/// http://www.softwareishard.com/blog/har-12-spec/#cookies.
///
/// ```dart
/// const cookie = HarCookie(name: 'sid', value: 'abc123');
/// print(cookie.toJson()); // {name: sid, value: abc123}
/// ```
class HarCookie extends HarObject {
  /// Creates a [HarCookie] with the given field values.
  ///
  /// [name] and [value] are required by the HAR 1.2 spec.
  /// All other parameters are optional.
  const HarCookie({
    required this.name,
    required this.value,
    this.path,
    this.domain,
    this.expires,
    this.expiresRaw,
    this.httpOnly,
    this.secure,
    super.comment,
    super.custom,
  });

  /// Deserialises a [HarCookie] from a decoded JSON map.
  ///
  /// Asserts if the required `name` or `value` keys are missing or `null`.
  /// The [expires] string is parsed via [HarUtils.optionalDateTime].
  factory HarCookie.fromJson(Json json) => _fromJson(json);

  static HarCookie _fromJson(Json json) {
    final nameRaw = json[kName];
    assert(nameRaw != null, 'HarCookie: "$kName" is required');
    final valueRaw = json[kValue];
    assert(valueRaw != null, 'HarCookie: "$kValue" is required');
    final httpOnly = bool.tryParse(
      json[kHttpOnly]?.toString() ?? '',
      caseSensitive: false,
    );
    final secure = bool.tryParse(
      json[kSecure]?.toString() ?? '',
      caseSensitive: false,
    );

    final expiresRaw = json[kExpires]?.toString();

    return HarCookie(
      name: nameRaw.toString(),
      value: valueRaw.toString(),
      path: json[kPath]?.toString(),
      domain: json[kDomain]?.toString(),
      expires: HarUtils.optionalDateTime(json[kExpires]),
      expiresRaw: expiresRaw,
      httpOnly: httpOnly,
      secure: secure,
      comment: json[HarObject.kComment]?.toString(),
      custom: HarUtils.collectCustom(json),
    );
  }

  /// JSON key for the cookie name (`"name"`).
  static const kName = 'name';

  /// JSON key for the cookie value (`"value"`).
  static const kValue = 'value';

  /// JSON key for the URL path scope (`"path"`).
  static const kPath = 'path';

  /// JSON key for the host scope (`"domain"`).
  static const kDomain = 'domain';

  /// JSON key for the expiration timestamp (`"expires"`).
  static const kExpires = 'expires';

  /// JSON key for the HTTP-only flag (`"httpOnly"`).
  static const kHttpOnly = 'httpOnly';

  /// JSON key for the secure flag (`"secure"`).
  static const kSecure = 'secure';

  /// Public static constant used as a display label in `toString()`.
  /// This is not a JSON key.
  static const kExpiresRaw = 'expiresRaw';

  /// The name of the cookie.
  ///
  /// Required by the HAR 1.2 spec.
  final String name;

  /// The value of the cookie.
  ///
  /// Required by the HAR 1.2 spec.
  final String value;

  /// The URL path scope of the cookie, or `null` if not specified.
  final String? path;

  /// The host (domain) scope of the cookie, or `null` if not specified.
  final String? domain;

  /// The expiration time of the cookie, or `null` if the cookie is a
  /// session cookie or the field was omitted.
  ///
  /// Serialised as an ISO 8601 string by [toJson].
  final DateTime? expires;

  /// Original `expires` string, preserved for round-tripping.
  final String? expiresRaw;

  /// Whether the cookie is marked as HTTP-only, or `null` if the
  /// field was omitted from the HAR source.
  final bool? httpOnly;

  /// Whether the cookie is restricted to secure (HTTPS) connections,
  /// or `null` if the field was omitted from the HAR source.
  final bool? secure;

  /// Serialises this cookie back to a JSON-compatible map.
  ///
  /// Optional fields that are `null` are omitted from the output
  /// so that the resulting JSON stays compact and spec-compliant.
  /// The [expires] value is emitted as an ISO 8601 string.
  @override
  Json toJson({bool includeNulls = false}) => HarUtils.applyNullPolicy(
    {
      kDomain: domain,
      kExpires: expiresRaw ?? expires?.toIso8601String(),
      kHttpOnly: httpOnly,
      kName: name,
      kPath: path,
      kSecure: secure,
      kValue: value,
      ...commonJson(includeNulls: includeNulls),
    },
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );

  @override
  String toString() =>
      '''HarCookie(${['$kName: $name', '$kValue: $value', if (path != null) '$kPath: $path', if (domain != null) '$kDomain: $domain', if (expires != null) '$kExpires: $expires', if (expiresRaw != null) '$kExpiresRaw: $expiresRaw', if (httpOnly != null) '$kHttpOnly: $httpOnly', if (secure != null) '$kSecure: $secure', if (comment != null) '${HarObject.kComment}: $comment', if (custom.isNotEmpty) '${HarObject.kCustom}: $custom'].join(', ')})''';

  /// Creates a copy of this [HarCookie] with the given fields replaced.
  HarCookie copyWith({
    String? name,
    String? value,
    String? path,
    String? domain,
    DateTime? expires,
    String? expiresRaw,
    bool? httpOnly,
    bool? secure,
    String? comment,
    Json? custom,
  }) => HarCookie(
    name: name ?? this.name,
    value: value ?? this.value,
    path: path ?? this.path,
    domain: domain ?? this.domain,
    expires: expires ?? this.expires,
    expiresRaw: expiresRaw ?? this.expiresRaw,
    httpOnly: httpOnly ?? this.httpOnly,
    secure: secure ?? this.secure,
    comment: comment ?? this.comment,
    custom: custom ?? this.custom,
  );
}
