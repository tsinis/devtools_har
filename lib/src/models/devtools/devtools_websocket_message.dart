import '../../helpers/extensions/har_duration.dart';
import '../../helpers/har_utils.dart';
import '../har_object.dart';

/// Chrome DevTools WebSocket frame message.
///
/// Maps to the Chrome DevTools Protocol
/// [`WebSocketFrame`](https://chromedevtools.github.io/devtools-protocol/1-3/Network/#type-WebSocketFrame)
/// type.
///
/// ```dart
/// const message = DevToolsWebSocketMessage(
///   type: 'send',
///   time: Duration(milliseconds: 12345, microseconds: 670),
///   opcode: 1,
///   data: 'Hello',
/// );
/// print(message.type); // send
/// ```
class DevToolsWebSocketMessage extends HarObject {
  /// Creates a [DevToolsWebSocketMessage] with the given field values.
  const DevToolsWebSocketMessage({
    required this.type,
    required this.time,
    required this.opcode,
    required this.data,
    super.comment,
    super.custom,
  });

  /// Deserialises a [DevToolsWebSocketMessage] from a decoded JSON map.
  factory DevToolsWebSocketMessage.fromJson(Json json) => _fromJson(json);

  static DevToolsWebSocketMessage _fromJson(Json json) =>
      DevToolsWebSocketMessage(
        type: json[kType]?.toString() ?? '',
        time: HarDuration.tryParse(json[kTime]?.toString()) ?? Duration.zero,
        opcode: num.tryParse(json[kOpcode]?.toString() ?? '')?.toInt() ?? 0,
        data: json[kData]?.toString() ?? '',
        comment: json[HarObject.kComment]?.toString(),
        custom: HarUtils.collectCustom(json),
      );

  /// JSON key for the message type (`"type"`).
  static const kType = 'type';

  /// JSON key for the message time (`"time"`).
  static const kTime = 'time';

  /// JSON key for the message opcode (`"opcode"`).
  static const kOpcode = 'opcode';

  /// JSON key for the message data (`"data"`).
  static const kData = 'data';

  /// Message type (`send`, `receive`).
  final String type;

  /// Time when the message was sent/received.
  final Duration time;

  /// WebSocket opcode.
  final int opcode;

  /// Message data.
  final String data;

  /// Serialises this WebSocket message back to a JSON-compatible map.
  @override
  Json toJson({bool includeNulls = false}) => HarUtils.applyNullPolicy(
    {
      kData: data,
      kOpcode: opcode,
      kTime: time.inNormalizedMilliseconds,
      kType: type,
      ...commonJson(includeNulls: includeNulls),
    },
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );

  @override
  String toString() =>
      '''DevToolsWebSocketMessage(${['$kType: $type', '$kTime: $time', '$kOpcode: $opcode', '$kData: $data', if (comment != null) '${HarObject.kComment}: $comment', if (custom.isNotEmpty) '${HarObject.kCustom}: $custom'].join(', ')})''';

  /// Creates a copy of this [DevToolsWebSocketMessage] with the given fields
  /// replaced.
  @override
  DevToolsWebSocketMessage copyWith({
    String? type,
    Duration? time,
    int? opcode,
    String? data,
    String? comment,
    Json? custom,
  }) => DevToolsWebSocketMessage(
    type: type ?? this.type,
    time: time ?? this.time,
    opcode: opcode ?? this.opcode,
    data: data ?? this.data,
    comment: comment ?? this.comment,
    custom: custom ?? this.custom,
  );
}
