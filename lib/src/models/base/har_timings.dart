import '../../helpers/har_utils.dart';
import '../har_object.dart';

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
/// ```dart
/// const timings = HarTimings(send: 10, wait: 200, receive: 50);
/// print(timings.time); // 260.0
/// ```
// Reference: http://www.softwareishard.com/blog/har-12-spec/#timings
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
    final sendNum = num.tryParse(json[kSend]?.toString() ?? '') ?? 0;
    final waitNum = num.tryParse(json[kWait]?.toString() ?? '') ?? 0;
    final receiveNum = num.tryParse(json[kReceive]?.toString() ?? '') ?? 0;

    assert(
      sendNum >= 0,
      'HarTimings: "$kSend" must be non-negative, got $sendNum',
    );
    assert(
      waitNum >= 0,
      'HarTimings: "$kWait" must be non-negative, got $waitNum',
    );
    assert(
      receiveNum >= 0,
      'HarTimings: "$kReceive" must be non-negative, got $receiveNum',
    );

    return HarTimings(
      blocked: HarUtils.toDuration(
        num.tryParse(json[kBlocked]?.toString() ?? ''),
      ),
      dns: HarUtils.toDuration(num.tryParse(json[kDns]?.toString() ?? '')),
      connect: HarUtils.toDuration(
        num.tryParse(json[kConnect]?.toString() ?? ''),
      ),
      send: HarUtils.toDuration(sendNum) ?? Duration.zero,
      wait: HarUtils.toDuration(waitNum) ?? Duration.zero,
      receive: HarUtils.toDuration(receiveNum) ?? Duration.zero,
      ssl: HarUtils.toDuration(num.tryParse(json[kSsl]?.toString() ?? '')),
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

  /// Time spent in a queue waiting for a network connection.
  ///
  /// `null` if the field was absent; `-1` if the timing does not
  /// apply to this request. Use `-1` if the timing cannot be
  /// determined.
  final Duration? blocked;

  /// DNS resolution time.
  ///
  /// `null` if the field was absent; `-1` if the timing does not
  /// apply (e.g. reused connection).
  final Duration? dns;

  /// Time required to create a TCP connection.
  ///
  /// `null` if the field was absent; `-1` if the timing does not
  /// apply.
  ///
  /// When [ssl] is defined and not `-1` its value is included in
  /// this field (i.e. [connect] covers both TCP and TLS handshake).
  final Duration? connect;

  /// Time required to send the HTTP request to the server.
  ///
  /// Required — must be non-negative.
  final Duration send;

  /// Time spent waiting for a response from the server (TTFB).
  ///
  /// Required — must be non-negative.
  final Duration wait;

  /// Time required to read the entire response from the server.
  ///
  /// Required — must be non-negative.
  final Duration receive;

  /// Time required for SSL/TLS negotiation.
  ///
  /// `null` if the field was absent; `-1` if the timing does not
  /// apply (e.g. non-HTTPS request).
  ///
  /// When defined and not `-1`, this value is already included in
  /// [connect] and must not be added separately when summing
  /// timings.
  final Duration? ssl;

  /// Total time of the request/response round trip.
  ///
  /// Computed as the sum of all timing phases, excluding `-1` values
  /// (which indicate "not available"). Per the HAR spec:
  ///
  /// `entry.time == blocked + dns + connect + send + wait + receive`
  ///
  /// The [ssl] time is already included in [connect] and is not added
  /// separately.
  Duration get time {
    final block = blocked ?? const Duration(milliseconds: -1);
    final domain = dns ?? const Duration(milliseconds: -1);
    final connection = connect ?? const Duration(milliseconds: -1);

    return (block.inMicroseconds >= 0 ? block : Duration.zero) +
        (domain.inMicroseconds >= 0 ? domain : Duration.zero) +
        (connection.inMicroseconds >= 0 ? connection : Duration.zero) +
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
      kBlocked: HarUtils.fromDuration(blocked),
      kConnect: HarUtils.fromDuration(connect),
      kDns: HarUtils.fromDuration(dns),
      kReceive: HarUtils.fromDuration(receive),
      kSend: HarUtils.fromDuration(send),
      kSsl: HarUtils.fromDuration(ssl),
      kWait: HarUtils.fromDuration(wait),
      ...commonJson(includeNulls: includeNulls),
    },
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );

  @override
  String toString() =>
      '''HarTimings(${[if (blocked != null) '$kBlocked: $blocked', if (dns != null) '$kDns: $dns', if (connect != null) '$kConnect: $connect', '$kSend: $send', '$kWait: $wait', '$kReceive: $receive', if (ssl != null) '$kSsl: $ssl', if (comment != null) '${HarObject.kComment}: $comment', if (custom.isNotEmpty) '${HarObject.kCustom}: $custom'].join(', ')})''';

  /// Creates a copy of this [HarTimings] with the given fields replaced.
  HarTimings copyWith({
    Duration? send,
    Duration? wait,
    Duration? receive,
    Duration? blocked,
    Duration? dns,
    Duration? connect,
    Duration? ssl,
    String? comment,
    Json? custom,
  }) => HarTimings(
    send: send ?? this.send,
    wait: wait ?? this.wait,
    receive: receive ?? this.receive,
    blocked: blocked ?? this.blocked,
    dns: dns ?? this.dns,
    connect: connect ?? this.connect,
    ssl: ssl ?? this.ssl,
    comment: comment ?? this.comment,
    custom: custom ?? this.custom,
  );
}
