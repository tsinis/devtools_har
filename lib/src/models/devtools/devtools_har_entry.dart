// ignore_for_file: avoid-similar-names

import '../../helpers/har_utils.dart';
import '../base/har_cache.dart';
import '../base/har_entry.dart';
import '../base/har_request.dart';
import '../base/har_response.dart';
import '../base/har_timings.dart';
import '../har_object.dart';
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
///
/// ```dart
/// final entry = DevToolsHarEntry(
///   startedDateTime: DateTime.utc(2025),
///   totalTime: 260,
///   request: DevToolsHarRequest(
///     url: Uri(),
///     headersSize: -1,
///     bodySize: -1,
///   ),
///   response: const DevToolsHarResponse(
///     status: 200, statusText: 'OK', httpVersion: 'h2',
///     content: HarContent(size: 0),
///     redirectURL: '', headersSize: -1, bodySize: -1,
///   ),
///   cache: const HarCache(),
///   timings: const DevToolsHarTimings(
///     send: 10, wait: 200, receive: 50,
///   ),
///   resourceType: 'document',
/// );
/// print(entry.resourceType); // document
/// ```
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

  /// Creates a [DevToolsHarEntry] from an existing [HarEntry],
  /// copying all base fields (including [custom]) and adding
  /// DevTools-specific extras.
  ///
  /// When [request] or [response] are not provided, the base
  /// entry's instances are wrapped via their respective `from*`
  /// conversion constructors. [timings] and all other base fields
  /// are passed through unchanged.
  DevToolsHarEntry.fromHarEntry(
    HarEntry entry, {
    DevToolsHarRequest? request,
    DevToolsHarResponse? response,
    HarTimings? timings,
    this.fromCache,
    this.fromServiceWorker,
    this.initiator,
    this.priority,
    this.resourceType,
    this.webSocketMessages,
    Json? custom,
  }) : super(
         startedDateTime: entry.startedDateTime,
         totalTime: entry.totalTime,
         request: request ?? DevToolsHarRequest.fromHarRequest(entry.request),
         response:
             response ?? DevToolsHarResponse.fromHarResponse(entry.response),
         cache: entry.cache,
         timings: timings ?? entry.timings,
         pageref: entry.pageref,
         serverIPAddress: entry.serverIPAddress,
         connectionId: entry.connectionId,
         startedDateTimeRaw: entry.startedDateTimeRaw,
         comment: entry.comment,
         custom: custom ?? entry.custom,
       );

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
        : DevToolsHarRequest.fromHarRequest(harEntry.request);

    final responseRaw = json[HarEntry.kResponse];
    final response = responseRaw is Json
        ? DevToolsHarResponse.fromJson(responseRaw)
        : DevToolsHarResponse.fromHarResponse(harEntry.response);

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

    return DevToolsHarEntry.fromHarEntry(
      harEntry,
      request: request,
      response: response,
      timings: timings,
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
  String toString() =>
      '''DevToolsHarEntry(${[if (pageref != null) '${HarEntry.kPageref}: $pageref', '${HarEntry.kStartedDateTime}: $startedDateTime', if (startedDateTimeRaw != null) '${HarEntry.kStartedDateTimeRaw}: $startedDateTimeRaw', '${HarEntry.kTime}: $totalTime', '${HarEntry.kRequest}: $request', '${HarEntry.kResponse}: $response', '${HarEntry.kCache}: $cache', '${HarEntry.kTimings}: $timings', if (serverIPAddress != null) '${HarEntry.kServerIPAddress}: $serverIPAddress', if (connectionId != null) '${HarEntry.kConnection}: $connectionId', if (fromCache != null) '$kFromCache: $fromCache', if (fromServiceWorker != null) '$kFromServiceWorker: $fromServiceWorker', if (initiator != null) '$kInitiator: $initiator', if (priority != null) '$kPriority: $priority', if (resourceType != null) '$kResourceType: $resourceType', if (webSocketMessages != null) '$kWebSocketMessages: $webSocketMessages', if (comment != null) '${HarObject.kComment}: $comment', if (custom.isNotEmpty) '${HarObject.kCustom}: $custom'].join(', ')})''';

  @override
  DevToolsHarEntry copyWith({
    DateTime? startedDateTime,
    String? startedDateTimeRaw,
    double? totalTime,
    HarRequest<DevToolsHarCookie>? request,
    HarResponse<DevToolsHarCookie>? response,
    HarCache? cache,
    HarTimings? timings,
    String? pageref,
    String? serverIPAddress,
    String? connectionId,
    String? fromCache,
    bool? fromServiceWorker,
    Json? initiator,
    String? priority,
    String? resourceType,
    List<Json>? webSocketMessages,
    String? comment,
    Json? custom,
  }) => DevToolsHarEntry(
    startedDateTime: startedDateTime ?? this.startedDateTime,
    startedDateTimeRaw: startedDateTimeRaw ?? this.startedDateTimeRaw,
    totalTime: totalTime ?? this.totalTime,
    request: request ?? this.request,
    response: response ?? this.response,
    cache: cache ?? this.cache,
    timings: timings ?? this.timings,
    pageref: pageref ?? this.pageref,
    serverIPAddress: serverIPAddress ?? this.serverIPAddress,
    connectionId: connectionId ?? this.connectionId,
    fromCache: fromCache ?? this.fromCache,
    fromServiceWorker: fromServiceWorker ?? this.fromServiceWorker,
    initiator: initiator ?? this.initiator,
    priority: priority ?? this.priority,
    resourceType: resourceType ?? this.resourceType,
    webSocketMessages: webSocketMessages ?? this.webSocketMessages,
    comment: comment ?? this.comment,
    custom: custom ?? this.custom,
  );
}
