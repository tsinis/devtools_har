import '../har_object.dart';
import '../har_utils.dart';
import 'har_content.dart';
import 'har_cookie.dart';
import 'har_header.dart';

/// Detailed info about an HTTP response.
///
/// Models the response object defined in the HAR 1.2 specification.
///
/// The [headersSize] and [bodySize] - Both are required by the spec and use
/// `-1` as a sentinel to indicate "not available" — they are never absent.
/// The total response size can be computed as:
///
/// `headersSize + bodySize  // when neither is -1`
///
/// Note that [headersSize] only counts headers actually received
/// from the server; browser-appended headers are excluded from the
/// count but still appear in the [headers] list.
///
/// [bodySize] should be `0` for `304 Not Modified` responses.
///
/// Reference: http://www.softwareishard.com/blog/har-12-spec/#response
class HarResponse<T extends HarCookie> extends HarObject {
  /// Creates a [HarResponse] with required HAR 1.2 response fields.
  const HarResponse({
    required this.status,
    required this.statusText,
    required this.content,
    required this.redirectURL,
    required this.headersSize,
    required this.bodySize,
    this.headers = const [],
    this.cookies = const [],
    this.httpVersion = HarObject.kDefaultHttpVersion,
    super.comment,
    super.custom,
  });

  /// Deserialises a [HarResponse] from a decoded JSON map.
  ///
  /// Required fields are guarded by [assert]s in debug mode.
  /// In release builds missing or mis-typed values fall back to
  /// safe defaults (`0` for [status], empty string for text fields,
  /// `-1` for sizes, empty lists for arrays).
  ///
  /// The [content] field must be a JSON object; when missing or
  /// mis-typed an assertion fires and a default [HarContent] is
  /// used in release mode.
  ///
  /// List elements ([cookies], [headers]) that are not JSON objects
  /// are silently skipped via `whereType<Json>()`.
  static HarResponse<T> fromJson<T extends HarCookie>(Json json) =>
      _fromJson<T>(json);

  // ignore: avoid-high-cyclomatic-complexity, a lot of fields to parse/validate.
  static HarResponse<T> _fromJson<T extends HarCookie>(Json json) {
    assert(
      json[kStatus] is int,
      'HarResponse: "$kStatus" must be an int',
    ); // TODO! Typed.
    assert(
      json[kStatusText] != null,
      'HarResponse: "$kStatusText" is required',
    );
    final contentRaw = json[kContent];
    assert(
      contentRaw is Json,
      'HarResponse: "$kContent" must be a JSON object',
    );

    final status = json[kStatus];
    final headers = json[kHeaders];
    final headersSize = json[kHeadersSize];
    final bodySize = json[kBodySize];
    final cookies = json[kCookies];
    final cookiesList = cookies is List
        ? cookies.whereType<Json>().map(HarCookie.fromJson)
        : const <HarCookie>[];

    return HarResponse(
      status: num.tryParse(status?.toString() ?? '')?.toInt() ?? 0,
      statusText: json[kStatusText]?.toString() ?? '',
      httpVersion:
          json[kHttpVersion]?.toString() ?? HarObject.kDefaultHttpVersion,
      cookies: List<T>.from(cookiesList),
      headers: headers is List
          ? headers.whereType<Json>().map(HarHeader.fromJson).toList()
          : const [],
      content: contentRaw is Json
          ? HarContent.fromJson(contentRaw)
          : const HarContent(size: 0, mimeType: HarContent.kFallbackMimeType),
      redirectURL: json[kRedirectURL]?.toString() ?? '',
      headersSize: num.tryParse(headersSize?.toString() ?? '')?.toInt() ?? -1,
      bodySize: num.tryParse(bodySize?.toString() ?? '')?.toInt() ?? -1,
      comment: json[HarObject.kComment]?.toString(),
      custom: HarUtils.collectCustom(json),
    );
  }

  /// JSON key for the HTTP status code (`"status"`).
  static const kStatus = 'status';

  /// JSON key for the HTTP status text (`"statusText"`).
  static const kStatusText = 'statusText';

  /// JSON key for the HTTP version (`"httpVersion"`).
  static const kHttpVersion = 'httpVersion';

  /// JSON key for the response cookies list (`"cookies"`).
  static const kCookies = 'cookies';

  /// JSON key for the response headers list (`"headers"`).
  static const kHeaders = 'headers';

  /// JSON key for the response body content (`"content"`).
  static const kContent = 'content';

  /// JSON key for the redirect URL (`"redirectURL"`).
  static const kRedirectURL = 'redirectURL';

  /// JSON key for the total header size (`"headersSize"`).
  static const kHeadersSize = 'headersSize';

  /// JSON key for the response body size (`"bodySize"`).
  static const kBodySize = 'bodySize';

  /// HTTP response status code (e.g. `200`, `304`, `404`).
  final int status;

  /// HTTP response status description (e.g. `"OK"`).
  ///
  /// May be empty for HTTP/2 responses where status text is not
  /// transmitted on the wire.
  final String statusText;

  /// Response HTTP version (e.g. `"HTTP/1.1"`, `"h2"`).
  final String httpVersion;

  /// List of cookie objects set by the response.
  final List<T> cookies;

  /// List of response header objects.
  ///
  /// May include browser-appended headers that are not counted
  /// in [headersSize].
  final List<HarHeader> headers;

  /// Details about the response body.
  final HarContent content;

  /// Redirection target URL from the `Location` response header,
  /// or empty string if no redirect.
  final String redirectURL;

  /// Total number of bytes from the start of the HTTP response
  /// message until (and including) the double CRLF before the body.
  ///
  /// `-1` if the information is not available. Only counts headers
  /// actually received from the server.
  final int headersSize;

  /// Size of the received response body in bytes.
  ///
  /// `0` for `304 Not Modified` responses (served from cache).
  /// `-1` if the information is not available.
  final int bodySize;

  /// Serialises this response back to a JSON-compatible map.
  ///
  /// The [comment] field is omitted when `null`.
  @override
  Json toJson({bool includeNulls = false}) => HarUtils.applyNullPolicy(
    {
      kBodySize: bodySize,
      kContent: content.toJson(includeNulls: includeNulls),
      kCookies: cookies
          .map((e) => e.toJson(includeNulls: includeNulls))
          .toList(),
      kHeaders: headers
          .map((e) => e.toJson(includeNulls: includeNulls))
          .toList(),
      kHeadersSize: headersSize,
      kHttpVersion: httpVersion,
      kRedirectURL: redirectURL,
      kStatus: status,
      kStatusText: statusText,
      ...commonJson(includeNulls: includeNulls),
    },
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );

  @override
  String toString() => 'HarResponse(${[
    'status: $status',
    'statusText: $statusText',
    'httpVersion: $httpVersion',
    'cookies: $cookies',
    'headers: $headers',
    'content: $content',
    'redirectURL: $redirectURL',
    'headersSize: $headersSize',
    'bodySize: $bodySize',
    if (comment != null) 'comment: $comment',
    if (custom.isNotEmpty) 'custom: $custom',
  ].join(', ')})';
}
