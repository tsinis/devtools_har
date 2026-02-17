// ignore_for_file: prefer-class-destructuring

import '../base/har_request.dart';
import '../har_utils.dart';
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
class DevToolsHarRequest extends HarRequest<DevToolsHarCookie> {
  /// Creates a [DevToolsHarRequest] for DevTools cookie parsing.
  const DevToolsHarRequest({
    required super.method,
    required super.url,
    required super.httpVersion,
    required super.cookies,
    required super.headers,
    required super.queryString,
    required super.headersSize,
    required super.bodySize,
    super.postData,
    super.comment,
    super.custom = const {},
  });

  /// Deserialises a [DevToolsHarRequest] from a decoded JSON map.
  ///
  /// Delegates all HAR 1.2 fields to [HarRequest.fromJson], then
  /// re-parses cookies as [DevToolsHarCookie] to capture the
  /// `sameSite` attribute that Chrome DevTools emits.
  factory DevToolsHarRequest.fromJson(Json json) => _fromJson(json);

  static DevToolsHarRequest _fromJson(Json json) {
    final harRequest = HarRequest.fromJson(json);
    final cookiesRaw = json[HarRequest.kCookies];
    final cookiesList = cookiesRaw is List
        ? cookiesRaw.whereType<Json>().map(DevToolsHarCookie.fromJson)
        : const <DevToolsHarCookie>[];

    return DevToolsHarRequest(
      method: harRequest.method,
      url: harRequest.url,
      httpVersion: harRequest.httpVersion,
      cookies: List<DevToolsHarCookie>.from(cookiesList),
      headers: harRequest.headers,
      queryString: harRequest.queryString,
      headersSize: harRequest.headersSize,
      bodySize: harRequest.bodySize,
      postData: harRequest.postData,
      comment: harRequest.comment,
      custom: HarUtils.collectCustom(json),
    );
  }
}
