import '../../helpers/har_utils.dart';
import '../har_object.dart';
import 'devtools_stack_trace.dart';

/// Chrome DevTools request initiator metadata.
///
/// Maps to the Chrome DevTools Protocol
/// [`Initiator`](https://chromedevtools.github.io/devtools-protocol/1-3/Network/#type-Initiator)
/// type.
///
/// ```dart
/// const initiator = DevToolsInitiator(type: 'parser', url: 'https://example.com');
/// print(initiator.type); // parser
/// ```
class DevToolsInitiator extends HarObject {
  /// Creates a [DevToolsInitiator] with the given field values.
  const DevToolsInitiator({
    required this.type,
    this.url,
    this.lineNumber,
    this.columnNumber,
    this.requestId,
    this.stack,
    super.comment,
    super.custom,
  });

  /// Deserialises a [DevToolsInitiator] from a decoded JSON map.
  factory DevToolsInitiator.fromJson(Json json) => _fromJson(json);

  static DevToolsInitiator _fromJson(Json json) {
    final stack = json[kStack];
    final columnNumber = num.tryParse(json[kColumnNumber]?.toString() ?? '');

    return DevToolsInitiator(
      type: json[kType]?.toString() ?? '',
      url: json[kUrl]?.toString(),
      lineNumber: num.tryParse(json[kLineNumber]?.toString() ?? '')?.toInt(),
      columnNumber: columnNumber?.toInt(),
      requestId: json[kRequestId]?.toString(),
      stack: stack is Json ? DevToolsStackTrace.fromJson(stack) : null,
      comment: json[HarObject.kComment]?.toString(),
      custom: HarUtils.collectCustom(json),
    );
  }

  /// JSON key for the initiator type (`"type"`).
  static const kType = 'type';

  /// JSON key for the initiator URL (`"url"`).
  static const kUrl = 'url';

  /// JSON key for the initiator line number (`"lineNumber"`).
  static const kLineNumber = 'lineNumber';

  /// JSON key for the initiator column number (`"columnNumber"`).
  static const kColumnNumber = 'columnNumber';

  /// JSON key for the initiator request ID (`"requestId"`).
  static const kRequestId = 'requestId';

  /// JSON key for the initiator stack trace (`"stack"`).
  static const kStack = 'stack';

  /// Type of initiator.
  final String type;

  /// Initiator URL, if applicable.
  final String? url;

  /// Initiator line number, if applicable.
  final int? lineNumber;

  /// Initiator column number, if applicable.
  final int? columnNumber;

  /// Request ID that triggered this request (e.g., in preflights).
  final String? requestId;

  /// Initiator stack trace, if applicable.
  final DevToolsStackTrace? stack;

  /// Serialises this initiator back to a JSON-compatible map.
  @override
  Json toJson({bool includeNulls = false}) => HarUtils.applyNullPolicy(
    {
      kColumnNumber: columnNumber,
      kLineNumber: lineNumber,
      kRequestId: requestId,
      kStack: stack?.toJson(includeNulls: includeNulls),
      kType: type,
      kUrl: url,
      ...commonJson(includeNulls: includeNulls),
    },
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );

  @override
  String toString() =>
      '''DevToolsInitiator(${['$kType: $type', if (url != null) '$kUrl: $url', if (lineNumber != null) '$kLineNumber: $lineNumber', if (columnNumber != null) '$kColumnNumber: $columnNumber', if (requestId != null) '$kRequestId: $requestId', if (stack != null) '$kStack: $stack', if (comment != null) '${HarObject.kComment}: $comment', if (custom.isNotEmpty) '${HarObject.kCustom}: $custom'].join(', ')})''';

  /// Creates a copy of this [DevToolsInitiator] with the given fields replaced.
  @override
  DevToolsInitiator copyWith({
    String? type,
    String? url,
    int? lineNumber,
    int? columnNumber,
    String? requestId,
    DevToolsStackTrace? stack,
    String? comment,
    Json? custom,
  }) => DevToolsInitiator(
    type: type ?? this.type,
    url: url ?? this.url,
    lineNumber: lineNumber ?? this.lineNumber,
    columnNumber: columnNumber ?? this.columnNumber,
    requestId: requestId ?? this.requestId,
    stack: stack ?? this.stack,
    comment: comment ?? this.comment,
    custom: custom ?? this.custom,
  );
}
