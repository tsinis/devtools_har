import '../../helpers/har_utils.dart';
import '../base/har_header.dart';
import '../base/har_post_data.dart';
import '../base/har_query_param.dart';
import '../base/har_request.dart';
import '../base/http_method.dart';
import '../har_object.dart';
import 'devtools_har_cookie.dart';
import 'devtools_har_entry.dart';

/// Chrome DevTools extension of [HarRequest].
///
/// Chrome DevTools does not add custom underscore-prefixed fields
/// directly to the request object itself — most DevTools extras
/// (`_initiator`, `_priority`, `_resourceType`, etc.) live at the
/// entry level and are modelled by [DevToolsHarEntry].
///
/// However, `DevToolsHarRequest` exists to re-parse cookies as
/// [DevToolsHarCookie] (which includes the `sameSite` attribute),
/// keeping the generic type consistent across the DevTools model
/// layer: `DevToolsHarEntry` → `DevToolsHarRequest` →
/// `DevToolsHarCookie`.
///
/// See also:
///
/// * [HarRequest] — the base HAR 1.2 request model.
/// * [DevToolsHarEntry] — entry model with Chrome-specific fields.
/// * [DevToolsHarCookie] — cookie model with `sameSite`.
///
/// ```dart
/// final request = DevToolsHarRequest(
///   url: Uri.parse('https://example.com'),
///   headersSize: 120,
///   bodySize: 0,
/// );
/// print(request.method); // HttpMethod.get
/// ```
class DevToolsHarRequest extends HarRequest<DevToolsHarCookie> {
  /// Creates a [DevToolsHarRequest] for DevTools cookie parsing.
  const DevToolsHarRequest({
    required super.url,
    required super.headersSize,
    required super.bodySize,
    super.method,
    super.httpVersion,
    super.cookies,
    super.headers,
    super.queryString,
    super.postData,
    super.comment,
    super.custom,
  });

  /// Creates a [DevToolsHarRequest] from an existing [HarRequest],
  /// copying all base fields (including [custom]) and substituting
  /// [cookies] with [DevToolsHarCookie] instances.
  DevToolsHarRequest.fromHarRequest(
    HarRequest request, {
    List<DevToolsHarCookie>? cookies,
    Json? custom,
  }) : super(
         url: request.url,
         headersSize: request.headersSize,
         bodySize: request.bodySize,
         method: request.method,
         httpVersion: request.httpVersion,
         cookies:
             cookies ??
             request.cookies.map(DevToolsHarCookie.fromHarCookie).toList(),
         headers: request.headers,
         queryString: request.queryString,
         postData: request.postData,
         comment: request.comment,
         custom: custom ?? request.custom,
       );

  /// Deserialises a [DevToolsHarRequest] from a decoded JSON map.
  ///
  /// Delegates all HAR 1.2 fields to [HarRequest.fromJson], then
  /// re-parses cookies as [DevToolsHarCookie] to capture the
  /// `sameSite` attribute that Chrome DevTools emits.
  factory DevToolsHarRequest.fromJson(Json json) => _fromJson(json);

  static DevToolsHarRequest _fromJson(Json json) {
    final cookiesRaw = json[HarRequest.kCookies];
    final cookiesList = cookiesRaw is List
        ? cookiesRaw.whereType<Json>().map(DevToolsHarCookie.fromJson).toList()
        : const <DevToolsHarCookie>[];

    return DevToolsHarRequest.fromHarRequest(
      HarRequest.fromJson(json),
      cookies: cookiesList,
      custom: HarUtils.collectCustom(json),
    );
  }

  @override
  String toString() =>
      // ignore: avoid-default-tostring, it's enum.
      '''DevToolsHarRequest(${['${HarRequest.kMethod}: $method', '${HarRequest.kUrl}: $url', '${HarRequest.kHttpVersion}: $httpVersion', '${HarRequest.kCookies}: $cookies', '${HarRequest.kHeaders}: $headers', '${HarRequest.kQueryString}: $queryString', if (postData != null) '${HarRequest.kPostData}: $postData', '${HarRequest.kHeadersSize}: $headersSize', '${HarRequest.kBodySize}: $bodySize', if (comment != null) '${HarObject.kComment}: $comment', if (custom.isNotEmpty) '${HarObject.kCustom}: $custom'].join(', ')})''';

  @override
  DevToolsHarRequest copyWith({
    HttpMethod? method,
    Uri? url,
    String? httpVersion,
    List<DevToolsHarCookie>? cookies,
    List<HarHeader>? headers,
    List<HarQueryParam>? queryString,
    HarPostData? postData,
    int? headersSize,
    int? bodySize,
    String? comment,
    Json? custom,
  }) => DevToolsHarRequest(
    method: method ?? this.method,
    url: url ?? this.url,
    httpVersion: httpVersion ?? this.httpVersion,
    cookies: cookies ?? this.cookies,
    headers: headers ?? this.headers,
    queryString: queryString ?? this.queryString,
    postData: postData ?? this.postData,
    headersSize: headersSize ?? this.headersSize,
    bodySize: bodySize ?? this.bodySize,
    comment: comment ?? this.comment,
    custom: custom ?? this.custom,
  );
}
