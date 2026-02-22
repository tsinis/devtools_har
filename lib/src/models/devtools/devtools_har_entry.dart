// ignore_for_file: prefer-class-destructuring, avoid-similar-names

import '../base/har_entry.dart';
import '../har_object.dart';
import '../har_utils.dart';
import 'devtools_har_cookie.dart';
import 'devtools_har_request.dart';
import 'devtools_har_response.dart';
import 'devtools_har_timings.dart';

/// Entry with DevTools-specific `_`-prefixed fields.
///
/// Chrome DevTools extends the standard HAR 1.2 entry with custom
/// fields such as [initiator], [priority], [resourceType],
/// [fromCache], [fromServiceWorker], and [webSocketMessages].
///
/// Reference: https://chromedevtools.github.io/devtools-protocol/1-3/Network/
class DevToolsHarEntry extends HarEntry<DevToolsHarCookie> {
  /// Creates a [DevToolsHarEntry] with DevTools-specific fields.
  const DevToolsHarEntry({
    required super.startedDateTime,
    required super.totalTime,
    required super.request,
    required super.response,
    required super.cache,
    required super.timings,
    super.pageref,
    super.serverIPAddress,
    super.connectionId,
    super.startedDateTimeRaw,
    super.comment,
    super.custom,
    this.fromCache,
    this.fromServiceWorker,
    this.initiator,
    this.priority,
    this.resourceType,
    this.webSocketMessages,
  });

  /// Deserialises a [DevToolsHarEntry] from a decoded JSON map.
  ///
  /// Delegates all HAR 1.2 fields to [HarEntry.fromJson], then
  /// extracts Chrome DevTools-specific underscore-prefixed fields.
  factory DevToolsHarEntry.fromJson(Json json) => _fromJson(json);

  static DevToolsHarEntry _fromJson(Json json) {
    final harEntry = HarEntry.fromJson(json);

    final requestRaw = json[HarEntry.kRequest];
    final request = requestRaw is Json
        ? DevToolsHarRequest.fromJson(requestRaw)
        // ignore: avoid-type-casts, they are interchangeable in this case.
        : harEntry.request as DevToolsHarRequest;

    final responseRaw = json[HarEntry.kResponse];
    final response = responseRaw is Json
        ? DevToolsHarResponse.fromJson(responseRaw)
        // ignore: avoid-type-casts, they are interchangeable in this case.
        : harEntry.response as DevToolsHarResponse;

    final timingsRaw = json[HarEntry.kTimings];
    final timings = timingsRaw is Json
        ? DevToolsHarTimings.fromJson(timingsRaw)
        : harEntry.timings;

    final initiatorRaw = json[kInitiator];
    final fromServiceWorkerRaw = bool.tryParse(
      json[kFromServiceWorker]?.toString() ?? '',
      caseSensitive: false,
    );
    final webSocketMessagesRaw = json[kWebSocketMessages];

    return DevToolsHarEntry(
      pageref: harEntry.pageref,
      startedDateTime: harEntry.startedDateTime,
      startedDateTimeRaw: harEntry.startedDateTimeRaw,
      totalTime: harEntry.totalTime,
      request: request,
      response: response,
      cache: harEntry.cache,
      timings: timings,
      serverIPAddress: harEntry.serverIPAddress,
      connectionId: harEntry.connectionId,
      comment: harEntry.comment,
      custom: HarUtils.collectCustom(json, const {
        kFromCache,
        kFromServiceWorker,
        kInitiator,
        kPriority,
        kResourceType,
        kWebSocketMessages,
      }),
      initiator: initiatorRaw is Json ? initiatorRaw : null,
      priority: json[kPriority]?.toString(),
      resourceType: json[kResourceType]?.toString(),
      fromCache: json[kFromCache]?.toString(),
      fromServiceWorker: fromServiceWorkerRaw,
      webSocketMessages: webSocketMessagesRaw is List
          ? webSocketMessagesRaw.whereType<Json>().toList()
          : null,
    );
  }

  /// `"_fromCache"` — `"disk"`, `"memory"`, or empty string.
  static const kFromCache = '_fromCache';

  /// `"_fromServiceWorker"` — whether the response came from a service worker.
  static const kFromServiceWorker = '_fromServiceWorker';

  /// `"_initiator"` — what triggered the request (parser, script, etc.).
  static const kInitiator = '_initiator';

  /// `"_priority"` — Chrome resource priority (`VeryHigh`, `High`, `Medium`,
  /// `Low`, `VeryLow`).
  static const kPriority = '_priority';

  /// `"_resourceType"` — Chrome resource type (`document`, `stylesheet`,
  /// `script`, `image`, `fetch`, `xhr`, `font`, `websocket`, etc.).
  static const kResourceType = '_resourceType';

  /// `"_webSocketMessages"` — list of WebSocket frames for `ws://` entries.
  static const kWebSocketMessages = '_webSocketMessages';

  /// Cache source: `"disk"`, `"memory"`, or empty/`null` if not cached.
  final String? fromCache;

  /// Whether the response was served by a service worker.
  final bool? fromServiceWorker;

  /// Initiator metadata (type, URL, stack trace, line number).
  final Json? initiator;

  /// Chrome resource priority level.
  final String? priority;

  /// Chrome resource type classification.
  final String? resourceType;

  /// WebSocket frame messages for `ws://`/`wss://` entries.
  final List<Json>? webSocketMessages;

  @override
  Json toJson({bool includeNulls = false}) => HarUtils.applyNullPolicy(
    {
      ...super.toJson(includeNulls: includeNulls),
      kFromCache: fromCache,
      kInitiator: initiator,
      kPriority: priority,
      kResourceType: resourceType,
      kFromServiceWorker: fromServiceWorker,
      kWebSocketMessages: webSocketMessages,
    },
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );

  @override
  String toString() => 'DevToolsHarEntry(${[
    if (pageref != null) '${HarEntry.kPageref}: $pageref',
    '${HarEntry.kStartedDateTime}: $startedDateTime',
    if (startedDateTimeRaw != null) '${HarEntry.kStartedDateTimeRaw}: $startedDateTimeRaw',
    '${HarEntry.kTime}: $totalTime',
    '${HarEntry.kRequest}: $request',
    '${HarEntry.kResponse}: $response',
    '${HarEntry.kCache}: $cache',
    '${HarEntry.kTimings}: $timings',
    if (serverIPAddress != null) '${HarEntry.kServerIPAddress}: $serverIPAddress',
    if (connectionId != null) '${HarEntry.kConnection}: $connectionId',
    if (fromCache != null) '$kFromCache: $fromCache',
    if (fromServiceWorker != null) '$kFromServiceWorker: $fromServiceWorker',
    if (initiator != null) '$kInitiator: $initiator',
    if (priority != null) '$kPriority: $priority',
    if (resourceType != null) '$kResourceType: $resourceType',
    if (webSocketMessages != null) '$kWebSocketMessages: $webSocketMessages',
    if (comment != null) '${HarObject.kComment}: $comment',
    if (custom.isNotEmpty) '${HarObject.kCustom}: $custom',
  ].join(', ')})';
}
