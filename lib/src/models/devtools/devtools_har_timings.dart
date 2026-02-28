import '../../helpers/har_utils.dart';
import '../base/har_timings.dart';
import '../har_object.dart';

/// Chrome DevTools extension of [HarTimings] with additional
/// breakdown of the [HarTimings.blocked] phase.
///
/// Chrome DevTools splits the `blocked` (Stalled) time into two
/// custom sub-components:
///
///  * [blockedQueueing] — time spent waiting in Chrome's request
///    queue (e.g. waiting for an available TCP connection under the
///    HTTP/1.x six-connection-per-origin limit, or yielding to
///    higher-priority requests).
///  * [blockedProxy] — time spent negotiating with a proxy server.
///
/// Both are measured in milliseconds and may contain sub-millisecond
/// precision. They follow the same conventions as other timing
/// fields: `null` when absent, `-1` when not applicable.
///
/// These fields use underscore-prefixed keys (`_blocked_queueing`,
/// `_blocked_proxy`) per the HAR custom-field convention, but are
/// promoted to first-class fields here because they are consistently
/// present in Chrome DevTools HAR exports.
///
/// Note: these values are sub-components of [blocked] — they should
/// not be added to the [time] sum separately.
///
/// ```dart
/// const timings = DevToolsHarTimings(
///   send: 10,
///   wait: 200,
///   receive: 50,
///   blockedQueueing: 5.2,
/// );
/// print(timings.blockedQueueing); // 5.2
/// ```
// Reference: http://www.softwareishard.com/blog/har-12-spec/#timings
class DevToolsHarTimings extends HarTimings {
  /// Creates a [DevToolsHarTimings] with all [HarTimings] fields
  /// plus the optional [blockedQueueing] and [blockedProxy]
  /// breakdowns.
  const DevToolsHarTimings({
    required super.send,
    required super.wait,
    required super.receive,
    super.blocked,
    super.dns,
    super.connect,
    super.ssl,
    super.comment,
    super.custom,
    this.blockedQueueing,
    this.blockedProxy,
  });

  /// Creates a [DevToolsHarTimings] from an existing [HarTimings],
  /// copying all base fields (including [custom]) and adding the
  /// optional DevTools breakdowns.
  DevToolsHarTimings.fromHarTimings(
    HarTimings timings, {
    this.blockedQueueing,
    this.blockedProxy,
    Json? custom,
  }) : super(
         send: timings.send,
         wait: timings.wait,
         receive: timings.receive,
         blocked: timings.blocked,
         dns: timings.dns,
         connect: timings.connect,
         ssl: timings.ssl,
         comment: timings.comment,
         custom: custom ?? timings.custom,
       );

  /// Deserialises a [DevToolsHarTimings] from a decoded JSON map.
  ///
  /// Delegates all HAR 1.2 fields to [HarTimings.fromJson] semantics
  /// (including non-negative asserts on [send], [wait], [receive]).
  ///
  /// The DevTools-specific fields are parsed via
  /// `num.tryParse(value.toString())` for input tolerance and
  /// converted to [double] for sub-millisecond precision.
  factory DevToolsHarTimings.fromJson(Json json) => _fromJson(json);

  static DevToolsHarTimings _fromJson(Json json) {
    final blockedProxy = json[kBlockedProxy]?.toString();
    final blockedQueueing = json[kBlockedQueueing]?.toString();

    return DevToolsHarTimings.fromHarTimings(
      HarTimings.fromJson(json),
      custom: HarUtils.collectCustom(json, const {
        kBlockedQueueing,
        kBlockedProxy,
      }),
      blockedQueueing: num.tryParse(blockedQueueing ?? '')?.toDouble(),
      blockedProxy: num.tryParse(blockedProxy ?? '')?.toDouble(),
    );
  }

  /// JSON key for the queueing portion of blocked time
  /// (`"_blocked_queueing"`).
  static const kBlockedQueueing = '_blocked_queueing';

  /// JSON key for the proxy negotiation portion of blocked time
  /// (`"_blocked_proxy"`).
  static const kBlockedProxy = '_blocked_proxy';

  /// Time spent waiting in Chrome's request queue, in milliseconds.
  ///
  /// This is a sub-component of [blocked] — common causes include
  /// the HTTP/1.x six-connection-per-origin limit and yielding to
  /// higher-priority requests.
  ///
  /// `null` if absent; `-1` if not applicable.
  final double? blockedQueueing;

  /// Time spent negotiating with a proxy server, in milliseconds.
  ///
  /// This is a sub-component of [blocked].
  ///
  /// `null` if absent; `-1` if not applicable.
  final double? blockedProxy;

  @override
  Json toJson({bool includeNulls = false}) => HarUtils.applyNullPolicy(
    {
      ...super.toJson(includeNulls: includeNulls),
      kBlockedQueueing: HarUtils.normalizeNumber(blockedQueueing),
      kBlockedProxy: HarUtils.normalizeNumber(blockedProxy),
    },
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );

  @override
  String toString() =>
      '''DevToolsHarTimings(${[if (blocked != null) '${HarTimings.kBlocked}: $blocked', if (dns != null) '${HarTimings.kDns}: $dns', if (connect != null) '${HarTimings.kConnect}: $connect', '${HarTimings.kSend}: $send', '${HarTimings.kWait}: $wait', '${HarTimings.kReceive}: $receive', if (ssl != null) '${HarTimings.kSsl}: $ssl', if (blockedQueueing != null) '$kBlockedQueueing: $blockedQueueing', if (blockedProxy != null) '$kBlockedProxy: $blockedProxy', if (comment != null) '${HarObject.kComment}: $comment', if (custom.isNotEmpty) '${HarObject.kCustom}: $custom'].join(', ')})''';

  @override
  DevToolsHarTimings copyWith({
    double? send,
    double? wait,
    double? receive,
    double? blocked,
    double? dns,
    double? connect,
    double? ssl,
    double? blockedQueueing,
    double? blockedProxy,
    String? comment,
    Json? custom,
  }) => DevToolsHarTimings(
    send: send ?? this.send,
    wait: wait ?? this.wait,
    receive: receive ?? this.receive,
    blocked: blocked ?? this.blocked,
    dns: dns ?? this.dns,
    connect: connect ?? this.connect,
    ssl: ssl ?? this.ssl,
    blockedQueueing: blockedQueueing ?? this.blockedQueueing,
    blockedProxy: blockedProxy ?? this.blockedProxy,
    comment: comment ?? this.comment,
    custom: custom ?? this.custom,
  );
}
