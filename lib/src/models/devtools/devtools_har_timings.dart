// ignore_for_file: prefer-class-destructuring

import '../base/har_timings.dart';
import '../har_utils.dart';

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
/// Reference: http://www.softwareishard.com/blog/har-12-spec/#timings
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
    final harTimings = HarTimings.fromJson(json);
    final blockedProxy = json[kBlockedProxy]?.toString();
    final blockedQueueing = json[kBlockedQueueing]?.toString();

    return DevToolsHarTimings(
      blocked: harTimings.blocked,
      dns: harTimings.dns,
      connect: harTimings.connect,
      send: harTimings.send,
      wait: harTimings.wait,
      receive: harTimings.receive,
      ssl: harTimings.ssl,
      comment: harTimings.comment,
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
      ...super.toJson(),
      kBlockedQueueing: HarUtils.normalizeNumber(blockedQueueing),
      kBlockedProxy: HarUtils.normalizeNumber(blockedProxy),
    },
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );
}
