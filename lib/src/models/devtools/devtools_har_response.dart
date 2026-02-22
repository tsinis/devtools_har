// ignore_for_file: prefer-class-destructuring

import '../base/har_response.dart';
import '../har_object.dart';
import '../har_utils.dart';
import 'devtools_har_cookie.dart';
import 'devtools_har_entry.dart';

/// Chrome DevTools extension of [HarResponse].
///
/// Adds two Chrome-specific custom fields that appear in HAR files
/// exported by Chrome DevTools:
///
/// ### `_transferSize`
///
/// The number of bytes actually transferred over the network,
/// including HTTP headers. Unlike `bodySize` (which is the payload
/// only), this covers the full on-wire cost and may differ due to
/// compression, chunked encoding, or HTTP/2 framing overhead.
///
/// ### `_error`
///
/// A network-level error string emitted by Chromium's net stack,
/// e.g. `"net::ERR_INCOMPLETE_CHUNKED_ENCODING"` or
/// `"net::ERR_CONNECTION_RESET"`. Present only when the request
/// failed at the network layer.
///
/// See also:
///
/// * [HarResponse] — the base HAR 1.2 response model.
/// * [DevToolsHarEntry] — entry model with Chrome-specific fields.
class DevToolsHarResponse extends HarResponse<DevToolsHarCookie> {
  /// Creates a [DevToolsHarResponse] with DevTools-specific fields.
  const DevToolsHarResponse({
    required super.status,
    required super.statusText,
    required super.httpVersion,
    required super.content,
    required super.redirectURL,
    required super.headersSize,
    required super.bodySize,
    super.cookies,
    super.headers,
    super.comment,
    super.custom,
    this.transferSize,
    this.error,
  });

  /// Deserialises a [DevToolsHarResponse] from a decoded JSON map.
  ///
  /// Delegates all HAR 1.2 fields to [HarResponse.fromJson], then
  /// extracts Chrome-specific `_transferSize` and `_error` from the
  /// raw JSON. Cookies are re-parsed as [DevToolsHarCookie] to
  /// capture the `sameSite` attribute.
  factory DevToolsHarResponse.fromJson(Json json) => _fromJson(json);

  static DevToolsHarResponse _fromJson(Json json) {
    final harResponse = HarResponse.fromJson(json);
    final cookiesRaw = json[HarResponse.kCookies];
    final cookiesList = cookiesRaw is List
        ? cookiesRaw.whereType<Json>().map(DevToolsHarCookie.fromJson)
        : const <DevToolsHarCookie>[];

    final transferSize = json[kTransferSize];

    return DevToolsHarResponse(
      status: harResponse.status,
      statusText: harResponse.statusText,
      httpVersion: harResponse.httpVersion,
      cookies: List<DevToolsHarCookie>.from(cookiesList),
      headers: harResponse.headers,
      content: harResponse.content,
      redirectURL: harResponse.redirectURL,
      headersSize: harResponse.headersSize,
      bodySize: harResponse.bodySize,
      comment: harResponse.comment,
      custom: HarUtils.collectCustom(json, const {kTransferSize, kError}),
      transferSize: num.tryParse(transferSize?.toString() ?? '')?.toInt(),
      error: json[kError]?.toString(),
    );
  }

  /// JSON key for the on-wire transfer size (`"_transferSize"`).
  static const kTransferSize = '_transferSize';

  /// JSON key for the network error string (`"_error"`).
  static const kError = '_error';

  /// Actual bytes transferred over the network, including headers.
  ///
  /// `null` when the field was absent from the HAR source.
  /// Unlike [bodySize], this reflects the full on-wire cost
  /// (compression, chunked encoding, HTTP/2 framing).
  final int? transferSize;

  /// Network-level error string from Chromium's net stack,
  /// e.g. `"net::ERR_CONNECTION_RESET"`.
  ///
  /// `null` when the request completed without a network error.
  final String? error;

  @override
  Json toJson({bool includeNulls = false}) => HarUtils.applyNullPolicy(
    {
      ...super.toJson(includeNulls: includeNulls),
      kTransferSize: transferSize,
      kError: error,
    },
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );

  @override
  String toString() => 'DevToolsHarResponse(${[
    '${HarResponse.kStatus}: $status',
    '${HarResponse.kStatusText}: $statusText',
    '${HarResponse.kHttpVersion}: $httpVersion',
    '${HarResponse.kCookies}: $cookies',
    '${HarResponse.kHeaders}: $headers',
    '${HarResponse.kContent}: $content',
    '${HarResponse.kRedirectURL}: $redirectURL',
    '${HarResponse.kHeadersSize}: $headersSize',
    '${HarResponse.kBodySize}: $bodySize',
    if (transferSize != null) '$kTransferSize: $transferSize',
    if (error != null) '$kError: $error',
    if (comment != null) '${HarObject.kComment}: $comment',
    if (custom.isNotEmpty) '${HarObject.kCustom}: $custom',
  ].join(', ')})';
}
