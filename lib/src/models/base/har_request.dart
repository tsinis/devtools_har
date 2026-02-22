import '../har_object.dart';
import '../har_utils.dart';
import 'har_cookie.dart';
import 'har_header.dart';
import 'har_post_data.dart';
import 'har_query_param.dart';
import 'http_method.dart';

/// Detailed info about a performed HTTP request.
///
/// Models the "request" object defined in the HAR 1.2 specification.
///
/// [url], [headersSize], and [bodySize] are required. The remaining
/// spec-required fields ([method], [httpVersion], [cookies], [headers],
/// [queryString]) have safe defaults and may be omitted at the call site.
/// Only [postData] and [comment] are truly optional per the spec.
///
/// The class is generic over the cookie type [T] so that sub-classes
/// (e.g. a DevTools variant) can substitute a richer cookie model
/// without duplicating parsing logic.
///
/// Reference: http://www.softwareishard.com/blog/har-12-spec/#request
class HarRequest<T extends HarCookie> extends HarObject {
  /// Creates a [HarRequest] for a HAR 1.2 request, applying defaults for
  /// spec-required fields when they are omitted.
  const HarRequest({
    required this.url,
    required this.headersSize,
    required this.bodySize,
    this.queryString = const [],
    this.headers = const [],
    this.cookies = const [],
    this.method = HttpMethod.get,
    this.httpVersion = HarObject.kDefaultHttpVersion,
    this.postData,
    super.comment,
    super.custom,
  });

  /// Deserialises a [HarRequest] from a decoded JSON map.
  ///
  /// Required fields are validated with [assert] so that malformed
  /// input is caught during development while still allowing
  /// graceful degradation in release builds.
  ///
  /// List fields (cookies, headers, queryString) use
  /// `.whereType<Json>()` to silently skip malformed elements
  /// instead of aborting the entire parse.
  ///
  /// Numeric sizes ([headersSize], [bodySize]) are parsed to [int]
  /// via `num.tryParse` because byte counts are inherently integral.
  /// They default to `-1` ("not available") when missing or invalid.
  ///
  /// Reference: http://www.softwareishard.com/blog/har-12-spec/#request
  static HarRequest<T> fromJson<T extends HarCookie>(Json json) =>
      _fromJson<T>(json);

  static HarRequest<T> _fromJson<T extends HarCookie>(Json json) {
    final methodRaw = json[kMethod];
    assert(methodRaw != null, 'HarRequest: "$kMethod" is required');
    final urlRaw = json[kUrl];
    assert(urlRaw != null, 'HarRequest: "$kUrl" is required');

    final headers = json[kHeaders];
    final queryString = json[kQueryString];
    final postData = json[kPostData];
    final cookies = json[kCookies];
    final cookiesList = cookies is List
        ? cookies.whereType<Json>().map(HarCookie.fromJson)
        : const <HarCookie>[];

    return HarRequest<T>(
      method: HttpMethod.tryParse(methodRaw) ?? HttpMethod.get,
      url: Uri.tryParse(urlRaw?.toString() ?? '') ?? Uri(),
      httpVersion:
          json[kHttpVersion]?.toString() ?? HarObject.kDefaultHttpVersion,
      cookies: List<T>.from(cookiesList),
      headers: headers is List
          ? headers.whereType<Json>().map(HarHeader.fromJson).toList()
          : const [],
      queryString: queryString is List
          ? queryString.whereType<Json>().map(HarQueryParam.fromJson).toList()
          : const [],
      headersSize:
          num.tryParse(json[kHeadersSize]?.toString() ?? '')?.toInt() ?? -1,
      bodySize: num.tryParse(json[kBodySize]?.toString() ?? '')?.toInt() ?? -1,
      postData: postData is Json ? HarPostData.fromJson(postData) : null,
      comment: json[HarObject.kComment]?.toString(),
      custom: HarUtils.collectCustom(json),
    );
  }

  /// JSON key for the HTTP method (`"method"`).
  static const kMethod = 'method';

  /// JSON key for the absolute request URL (`"url"`).
  static const kUrl = 'url';

  /// JSON key for the HTTP version string (`"httpVersion"`).
  static const kHttpVersion = 'httpVersion';

  /// JSON key for the list of cookies (`"cookies"`).
  static const kCookies = 'cookies';

  /// JSON key for the list of headers (`"headers"`).
  static const kHeaders = 'headers';

  /// JSON key for the list of query-string parameters
  /// (`"queryString"`).
  static const kQueryString = 'queryString';

  /// JSON key for the optional posted data (`"postData"`).
  static const kPostData = 'postData';

  /// JSON key for the total request header size in bytes
  /// (`"headersSize"`).
  static const kHeadersSize = 'headersSize';

  /// JSON key for the request body size in bytes (`"bodySize"`).
  static const kBodySize = 'bodySize';

  /// The HTTP method of this request (GET, POST, etc.).
  ///
  /// Parsed via [HttpMethod.tryParse]; defaults to [HttpMethod.get]
  /// when the raw value is missing or unrecognised.
  final HttpMethod method;

  /// Absolute URL of the request.
  ///
  /// Per the spec, fragments are not included. Parsed via
  /// [Uri.tryParse]; defaults to an empty [Uri] when the raw value
  /// is missing or malformed.
  final Uri url;

  /// HTTP version string (e.g. `"HTTP/1.1"`, `"h2"`, `"h3"`).
  final String httpVersion;

  /// Cookies sent with the request.
  ///
  /// The list type is generic ([T]) so that DevTools-extended
  /// cookies (e.g. with `sameSite`) can be used transparently.
  final List<T> cookies;

  /// HTTP headers sent with the request.
  final List<HarHeader> headers;

  /// Query-string parameters parsed from the URL.
  final List<HarQueryParam> queryString;

  /// Posted data info, or `null` if the request has no body
  /// (e.g. GET requests).
  final HarPostData? postData;

  /// Total number of bytes from the start of the HTTP request
  /// message until (and including) the double CRLF before the body.
  ///
  /// Set to `-1` if the information is not available. Typed as
  /// [int] because byte counts are inherently integral.
  final int headersSize;

  /// Size of the request body (POST data payload) in bytes.
  ///
  /// Set to `-1` if the information is not available. Typed as
  /// [int] because byte counts are inherently integral.
  ///
  /// The total request size can be computed as:
  ///   `headersSize + bodySize` (when both are available).
  final int bodySize;

  /// Serialises this request back to a JSON-compatible map.
  ///
  /// Required fields are always present. Optional fields that are
  /// `null` are omitted so the output stays compact and
  /// spec-compliant.
  @override
  Json toJson({bool includeNulls = false}) => HarUtils.applyNullPolicy(
    {
      kBodySize: bodySize,
      kCookies: cookies
          .map((e) => e.toJson(includeNulls: includeNulls))
          .toList(),
      kHeaders: headers
          .map((e) => e.toJson(includeNulls: includeNulls))
          .toList(),
      kHeadersSize: headersSize,
      kHttpVersion: httpVersion,
      kMethod: method.toJson(),
      kPostData: postData?.toJson(includeNulls: includeNulls),
      kQueryString: queryString
          .map((e) => e.toJson(includeNulls: includeNulls))
          .toList(),
      kUrl: url.toString(),
      ...commonJson(includeNulls: includeNulls),
    },
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );

  @override
  String toString() => 'HarRequest(${[
    '$kMethod: $method',
    '$kUrl: $url',
    '$kHttpVersion: $httpVersion',
    '$kCookies: $cookies',
    '$kHeaders: $headers',
    '$kQueryString: $queryString',
    if (postData != null) '$kPostData: $postData',
    '$kHeadersSize: $headersSize',
    '$kBodySize: $bodySize',
    if (comment != null) '${HarObject.kComment}: $comment',
    if (custom.isNotEmpty) '${HarObject.kCustom}: $custom',
  ].join(', ')})';
}
