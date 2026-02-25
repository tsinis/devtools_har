import '../har_object.dart';
import '../har_utils.dart';

/// Timing breakdown for an HTTP request/response round trip.
///
/// All values are specified in milliseconds. Chrome DevTools and other
/// exporters may emit sub-millisecond precision as fractional numbers
/// (e.g. `72.348`), so every timing field is typed as [double] rather
/// than [int].
///
/// The HAR spec defines two classes of timing fields:
///
///  * Required ([send], [wait], [receive]) — must be non-negative.
///  * Optional ([blocked], [dns], [connect], [ssl]) — may be omitted
///    (`null`) or set to `-1` to indicate the information is not
///    available.
///
/// These two states are semantically distinct:
///
///  * `null` — the field was absent from the JSON; the exporting tool
///    was unable to provide any of the optional timings.
///  * `-1`   — the field was present but the specific timing does not
///    apply to this request (e.g. DNS lookup on a keep-alive
///    connection).
///
/// The spec requires that (when no `-1` values are present):
///
///  entry.time == blocked + dns + connect + send + wait + receive
///
/// The [ssl] time, when defined and not `-1`, is already included in
/// [connect] and must not be added separately.
///
/// Reference: http://www.softwareishard.com/blog/har-12-spec/#timings
class HarTimings extends HarObject {
  /// Creates a [HarTimings] with the given field values.
  ///
  /// [send], [wait], and [receive] are required by the HAR 1.2 spec
  /// and must be non-negative. All other parameters are optional.
  const HarTimings({
    required this.send,
    required this.wait,
    required this.receive,
    this.blocked,
    this.dns,
    this.connect,
    this.ssl,
    super.comment,
    super.custom,
  });

  /// Deserialises a [HarTimings] from a decoded JSON map.
  ///
  /// Numeric values are parsed via `num.tryParse(value.toString())`
  /// to tolerate both native JSON numbers and stringified
  /// representations.  The result is converted to [double] via
  /// [num.toDouble] to preserve sub-millisecond precision that
  /// some exporters (e.g. Chrome DevTools) emit.
  ///
  /// Required fields ([send], [wait], [receive]) default to `0.0`
  /// when missing or unparseable.  Optional fields default to `null`.
  factory HarTimings.fromJson(Json json) => _fromJson(json);

  // ignore: avoid-high-cyclomatic-complexity, a lot of fields to parse.
  static HarTimings _fromJson(Json json) {
    final send = num.tryParse(json[kSend]?.toString() ?? '')?.toDouble() ?? 0;
    final wait = num.tryParse(json[kWait]?.toString() ?? '')?.toDouble() ?? 0;
    final receive =
        num.tryParse(json[kReceive]?.toString() ?? '')?.toDouble() ?? 0;

    assert(send >= 0, 'HarTimings: "$kSend" must be non-negative, got $send');
    assert(wait >= 0, 'HarTimings: "$kWait" must be non-negative, got $wait');
    assert(receive >= 0, '"$kReceive" must be non-negative got $receive');

    return HarTimings(
      blocked: num.tryParse(json[kBlocked]?.toString() ?? '')?.toDouble(),
      dns: num.tryParse(json[kDns]?.toString() ?? '')?.toDouble(),
      connect: num.tryParse(json[kConnect]?.toString() ?? '')?.toDouble(),
      send: send,
      wait: wait,
      receive: receive,
      ssl: num.tryParse(json[kSsl]?.toString() ?? '')?.toDouble(),
      comment: json[HarObject.kComment]?.toString(),
      custom: HarUtils.collectCustom(json),
    );
  }

  /// JSON key for the time spent in a queue waiting for a network
  /// connection (`"blocked"`).
  static const kBlocked = 'blocked';

  /// JSON key for the DNS resolution time (`"dns"`).
  static const kDns = 'dns';

  /// JSON key for the time required to create a TCP connection
  /// (`"connect"`).
  static const kConnect = 'connect';

  /// JSON key for the time required to send the request to the
  /// server (`"send"`).
  static const kSend = 'send';

  /// JSON key for the time spent waiting for a response from the
  /// server (`"wait"`).
  static const kWait = 'wait';

  /// JSON key for the time required to read the entire response
  /// from the server (`"receive"`).
  static const kReceive = 'receive';

  /// JSON key for the time required for SSL/TLS negotiation
  /// (`"ssl"`).
  static const kSsl = 'ssl';

  /// Time spent in a queue waiting for a network connection, in
  /// milliseconds.
  ///
  /// `null` if the field was absent; `-1` if the timing does not
  /// apply to this request. Use `-1` if the timing cannot be
  /// determined.
  final double? blocked;

  /// DNS resolution time in milliseconds.
  ///
  /// `null` if the field was absent; `-1` if the timing does not
  /// apply (e.g. reused connection).
  final double? dns;

  /// Time required to create a TCP connection, in milliseconds.
  ///
  /// `null` if the field was absent; `-1` if the timing does not
  /// apply.
  ///
  /// When [ssl] is defined and not `-1` its value is included in
  /// this field (i.e. [connect] covers both TCP and TLS handshake).
  final double? connect;

  /// Time required to send the HTTP request to the server, in
  /// milliseconds.
  ///
  /// Required — must be non-negative.
  final double send;

  /// Time spent waiting for a response from the server (TTFB), in
  /// milliseconds.
  ///
  /// Required — must be non-negative.
  final double wait;

  /// Time required to read the entire response from the server, in
  /// milliseconds.
  ///
  /// Required — must be non-negative.
  final double receive;

  /// Time required for SSL/TLS negotiation, in milliseconds.
  ///
  /// `null` if the field was absent; `-1` if the timing does not
  /// apply (e.g. non-HTTPS request).
  ///
  /// When defined and not `-1`, this value is already included in
  /// [connect] and must not be added separately when summing
  /// timings.
  final double? ssl;

  /// Total time of the request/response round trip, in milliseconds.
  ///
  /// Computed as the sum of all timing phases, excluding `-1` values
  /// (which indicate "not available"). Per the HAR spec:
  ///
  /// `entry.time == blocked + dns + connect + send + wait + receive`
  ///
  /// The [ssl] time is already included in [connect] and is not added
  /// separately.
  double get time {
    final block = blocked ?? -1;
    final domain = dns ?? -1;
    final connection = connect ?? -1;

    return (block >= 0 ? block : 0) +
        (domain >= 0 ? domain : 0) +
        (connection >= 0 ? connection : 0) +
        send +
        wait +
        receive;
  }

  /// Serialises this timings object back to a JSON-compatible map.
  ///
  /// Optional fields that are `null` are omitted from the output.
  /// Fields set to `-1` are preserved, as they carry the semantic
  /// meaning "not available" per the HAR spec.
  @override
  Json toJson({bool includeNulls = false}) => HarUtils.applyNullPolicy(
    {
      kBlocked: HarUtils.normalizeNumber(blocked),
      kConnect: HarUtils.normalizeNumber(connect),
      kDns: HarUtils.normalizeNumber(dns),
      kReceive: HarUtils.normalizeNumber(receive),
      kSend: HarUtils.normalizeNumber(send),
      kSsl: HarUtils.normalizeNumber(ssl),
      kWait: HarUtils.normalizeNumber(wait),
      ...commonJson(includeNulls: includeNulls),
    },
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );

  @override
  String toString() =>
      '''HarTimings(${[if (blocked != null) '$kBlocked: $blocked', if (dns != null) '$kDns: $dns', if (connect != null) '$kConnect: $connect', '$kSend: $send', '$kWait: $wait', '$kReceive: $receive', if (ssl != null) '$kSsl: $ssl', if (comment != null) '${HarObject.kComment}: $comment', if (custom.isNotEmpty) '${HarObject.kCustom}: $custom'].join(', ')})''';
}
