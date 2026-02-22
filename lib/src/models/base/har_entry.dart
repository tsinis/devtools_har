// ignore_for_file: no-equal-arguments

import '../har_object.dart';
import '../har_utils.dart';
import 'har_cache.dart';
import 'har_content.dart';
import 'har_cookie.dart';
import 'har_request.dart';
import 'har_response.dart';
import 'har_timings.dart';

/// A single HTTP request/response pair recorded in a HAR log.
///
/// Models the "entries" element defined in the HAR 1.2
/// specification. Each entry captures the full lifecycle of one
/// HTTP transaction: request, response, cache state, and timing
/// breakdown.
///
/// The class is generic over [T] (the cookie type) so that
/// sub-classes can thread a richer cookie model through both
/// [request] and [response] without duplicating parsing logic.
/// For the base HAR 1.2 model, [T] is [HarCookie].
///
/// Reference: http://www.softwareishard.com/blog/har-12-spec/#entries
class HarEntry<T extends HarCookie> extends HarObject {
  /// Creates a [HarEntry] describing one request/response exchange.
  const HarEntry({
    required this.startedDateTime,
    required this.totalTime,
    required this.request,
    required this.response,
    required this.cache,
    required this.timings,
    this.pageref,
    this.serverIPAddress,
    this.connectionId,
    this.startedDateTimeRaw,
    super.comment,
    super.custom,
  });

  /// Deserialises a [HarEntry] from a decoded JSON map.
  ///
  /// Required fields ([startedDateTime], [request], [response],
  /// [cache], [timings]) are validated with [assert] so that
  /// malformed input is caught during development, while release
  /// builds degrade gracefully with safe defaults.
  ///
  /// [startedDateTime] is parsed via [DateTime.tryParse]. If the raw
  /// value is missing or unparseable, an assert fires in debug and
  /// [DateTime.utc] epoch (`0`) is used in release.
  ///
  /// [totalTime] is typed as [double] because the spec defines it
  /// as the sum of all timings in milliseconds, and exporters such
  /// as Chrome DevTools emit sub-millisecond precision.
  ///
  /// Reference: http://www.softwareishard.com/blog/har-12-spec/#entries

  static HarEntry<T> fromJson<T extends HarCookie>(Json json) =>
      _fromJson<T>(json);

  // ignore: avoid-long-functions, a lot of fields to parse/validate.
  static HarEntry<T> _fromJson<T extends HarCookie>(Json json) {
    final startedDateTimeRaw = json[kStartedDateTime];
    assert(
      startedDateTimeRaw != null,
      'HarEntry: "$kStartedDateTime" is required',
    );
    final request = json[kRequest];
    assert(request is Json, 'HarEntry: "$kRequest" must be a JSON object');
    final response = json[kResponse];
    assert(response is Json, 'HarEntry: "$kResponse" must be a JSON object');
    final cache = json[kCache];
    assert(cache is Json, 'HarEntry: "$kCache" must be a JSON object');
    final timings = json[kTimings];
    assert(timings is Json, 'HarEntry: "$kTimings" must be a JSON object');

    final startedDateTimeString = startedDateTimeRaw?.toString();
    final parsedDateTime = DateTime.tryParse(startedDateTimeString ?? '');
    assert(
      parsedDateTime != null,
      '''HarEntry: "$kStartedDateTime" must be a valid ISO 8601 string: $startedDateTimeRaw''',
    );

    return HarEntry(
      pageref: json[kPageref]?.toString(),
      startedDateTime: parsedDateTime ?? DateTime.utc(0),
      startedDateTimeRaw: startedDateTimeString,
      totalTime: num.tryParse(json[kTime]?.toString() ?? '')?.toDouble() ?? 0,
      request: request is Json
          ? HarRequest.fromJson(request)
          : HarRequest(url: Uri(), headersSize: -1, bodySize: -1),
      response: response is Json
          ? HarResponse.fromJson(response)
          : HarResponse(
              status: 0,
              statusText: '',
              content: const HarContent(
                size: 0,
                mimeType: HarContent.kFallbackMimeType,
              ),
              redirectURL: '',
              headersSize: -1,
              bodySize: -1,
            ),
      cache: cache is Json ? HarCache.fromJson(cache) : const HarCache(),
      timings: timings is Json
          ? HarTimings.fromJson(timings)
          : const HarTimings(send: 0, wait: 0, receive: 0),
      serverIPAddress: json[kServerIPAddress]?.toString(),
      connectionId: json[kConnection]?.toString(),
      comment: json[HarObject.kComment]?.toString(),
      custom: HarUtils.collectCustom(json),
    );
  }

  /// JSON key for the parent page reference (`"pageref"`).
  static const kPageref = 'pageref';

  /// JSON key for the request start timestamp (`"startedDateTime"`).
  static const kStartedDateTime = 'startedDateTime';

  /// JSON key for the total elapsed time (`"time"`).
  static const kTime = 'time';

  /// JSON key for the request object (`"request"`).
  static const kRequest = 'request';

  /// JSON key for the response object (`"response"`).
  static const kResponse = 'response';

  /// JSON key for the cache object (`"cache"`).
  static const kCache = 'cache';

  /// JSON key for the timings object (`"timings"`).
  static const kTimings = 'timings';

  /// JSON key for the server IP address (`"serverIPAddress"`).
  static const kServerIPAddress = 'serverIPAddress';

  /// JSON key for the connection identifier (`"connection"`).
  static const kConnection = 'connection';

  /// Internal key for preserving the original start timestamp string.
  static const kStartedDateTimeRaw = 'startedDateTimeRaw';

  /// Reference to the parent page.
  ///
  /// `null` if the exporting application does not support grouping
  /// by pages.
  final String? pageref;

  /// Date and time stamp of the request start.
  ///
  /// The spec mandates ISO 8601 with a timezone designator.
  final DateTime startedDateTime;

  /// Original `startedDateTime` string, preserved for round-tripping.
  final String? startedDateTimeRaw;

  /// Total elapsed time of the request in milliseconds.
  ///
  /// Per the spec, this is the sum of all timings in the [timings]
  /// object, excluding `-1` values.
  ///
  /// Typed as [double] to preserve sub-millisecond precision that
  /// some exporters (e.g. Chrome DevTools) emit.
  final double totalTime;

  /// Detailed info about the performed request.
  final HarRequest<T> request;

  /// Detailed info about the response.
  final HarResponse<T> response;

  /// Info about cache usage.
  final HarCache cache;

  /// Detailed timing breakdown for the request/response round trip.
  final HarTimings timings;

  /// IP address of the server that was connected (result of DNS
  /// resolution).
  ///
  /// `null` when the information is not available.
  final String? serverIPAddress;

  /// Unique ID of the parent TCP/IP connection.
  ///
  /// Can be the client or server port number, or any other unique
  /// connection identifier. `null` when the application does not
  /// support this info.
  final String? connectionId;

  /// Serialises this entry back to a JSON-compatible map.
  @override
  Json toJson({bool includeNulls = false}) => HarUtils.applyNullPolicy(
    {
      kCache: cache.toJson(includeNulls: includeNulls),
      kConnection: connectionId,
      kPageref: pageref,
      kRequest: request.toJson(includeNulls: includeNulls),
      kResponse: response.toJson(includeNulls: includeNulls),
      kServerIPAddress: serverIPAddress,
      kStartedDateTime: startedDateTimeRaw ?? startedDateTime.toIso8601String(),
      kTime: HarUtils.normalizeNumber(totalTime),
      kTimings: timings.toJson(includeNulls: includeNulls),
      ...commonJson(includeNulls: includeNulls),
    },
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );

  @override
  String toString() => 'HarEntry(${[
    if (pageref != null) '$kPageref: $pageref',
    '$kStartedDateTime: $startedDateTime',
    if (startedDateTimeRaw != null) '$kStartedDateTimeRaw: $startedDateTimeRaw',
    '$kTime: $totalTime',
    '$kRequest: $request',
    '$kResponse: $response',
    '$kCache: $cache',
    '$kTimings: $timings',
    if (serverIPAddress != null) '$kServerIPAddress: $serverIPAddress',
    if (connectionId != null) '$kConnection: $connectionId',
    if (comment != null) '${HarObject.kComment}: $comment',
    if (custom.isNotEmpty) '${HarObject.kCustom}: $custom',
  ].join(', ')})';
}
