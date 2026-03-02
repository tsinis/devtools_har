import '../../helpers/har_utils.dart';
import '../har_object.dart';

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
    this.stack,
    super.comment,
    super.custom,
  });

  /// Deserialises a [DevToolsInitiator] from a decoded JSON map.
  factory DevToolsInitiator.fromJson(Json json) => _fromJson(json);

  static DevToolsInitiator _fromJson(Json json) {
    final stack = json[kStack];

    return DevToolsInitiator(
      type: json[kType]?.toString() ?? '',
      url: json[kUrl]?.toString(),
      lineNumber: num.tryParse(json[kLineNumber]?.toString() ?? '')?.toInt(),
      columnNumber: num.tryParse(json[kColumnNumber]?.toString() ?? '')?.toInt(),
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

  /// Initiator stack trace, if applicable.
  final DevToolsStackTrace? stack;

  /// Serialises this initiator back to a JSON-compatible map.
  @override
  Json toJson({bool includeNulls = false}) => HarUtils.applyNullPolicy(
    {
      kType: type,
      if (url != null) kUrl: url,
      if (lineNumber != null) kLineNumber: lineNumber,
      if (columnNumber != null) kColumnNumber: columnNumber,
      if (stack != null) kStack: stack!.toJson(includeNulls: includeNulls),
      ...commonJson(includeNulls: includeNulls),
    },
    includeNulls: includeNulls,
  );

  @override
  String toString() =>
      '''DevToolsInitiator(${[
        '$kType: $type',
        if (url != null) '$kUrl: $url',
        if (lineNumber != null) '$kLineNumber: $lineNumber',
        if (columnNumber != null) '$kColumnNumber: $columnNumber',
        if (stack != null) '$kStack: $stack',
        if (comment != null) '${HarObject.kComment}: $comment',
        if (custom.isNotEmpty) '${HarObject.kCustom}: $custom'
      ].join(', ')})''';

  /// Creates a copy of this [DevToolsInitiator] with the given fields replaced.
  DevToolsInitiator copyWith({
    String? type,
    String? url,
    int? lineNumber,
    int? columnNumber,
    DevToolsStackTrace? stack,
    String? comment,
    Json? custom,
  }) => DevToolsInitiator(
    type: type ?? this.type,
    url: url ?? this.url,
    lineNumber: lineNumber ?? this.lineNumber,
    columnNumber: columnNumber ?? this.columnNumber,
    stack: stack ?? this.stack,
    comment: comment ?? this.comment,
    custom: custom ?? this.custom,
  );
}

/// Chrome DevTools stack trace metadata.
///
/// Maps to the Chrome DevTools Protocol
/// [`StackTrace`](https://chromedevtools.github.io/devtools-protocol/1-3/Runtime/#type-StackTrace)
/// type.
// ignore: prefer-single-declaration-per-file
class DevToolsStackTrace extends HarObject {
  /// Creates a [DevToolsStackTrace] with the given field values.
  const DevToolsStackTrace({
    required this.callFrames,
    this.description,
    this.parent,
    super.comment,
    super.custom,
  });

  /// Deserialises a [DevToolsStackTrace] from a decoded JSON map.
  factory DevToolsStackTrace.fromJson(Json json) => _fromJson(json);

  static DevToolsStackTrace _fromJson(Json json) {
    final frames = json[kCallFrames];
    final parent = json[kParent];

    return DevToolsStackTrace(
      callFrames:
          frames is List
              ? frames.whereType<Json>().map(DevToolsCallFrame.fromJson).toList()
              : const [],
      description: json[kDescription]?.toString(),
      parent: parent is Json ? DevToolsStackTrace.fromJson(parent) : null,
      comment: json[HarObject.kComment]?.toString(),
      custom: HarUtils.collectCustom(json),
    );
  }

  /// JSON key for the call frames (`"callFrames"`).
  static const kCallFrames = 'callFrames';

  /// JSON key for the description (`"description"`).
  static const kDescription = 'description';

  /// JSON key for the parent stack trace (`"parent"`).
  static const kParent = 'parent';

  /// JavaScript call frames in the stack.
  final List<DevToolsCallFrame> callFrames;

  /// Description of the stack trace.
  final String? description;

  /// Parent stack trace, for asynchronous calls.
  final DevToolsStackTrace? parent;

  @override
  Json toJson({bool includeNulls = false}) => HarUtils.applyNullPolicy(
    {
      kCallFrames: callFrames.map((f) => f.toJson(includeNulls: includeNulls)).toList(),
      if (description != null) kDescription: description,
      if (parent != null) kParent: parent!.toJson(includeNulls: includeNulls),
      ...commonJson(includeNulls: includeNulls),
    },
    includeNulls: includeNulls,
  );

  @override
  String toString() =>
      '''DevToolsStackTrace(${[
        '$kCallFrames: $callFrames',
        if (description != null) '$kDescription: $description',
        if (parent != null) '$kParent: $parent',
        if (comment != null) '${HarObject.kComment}: $comment',
        if (custom.isNotEmpty) '${HarObject.kCustom}: $custom'
      ].join(', ')})''';
}

/// Chrome DevTools call frame metadata.
///
/// Maps to the Chrome DevTools Protocol
/// [`CallFrame`](https://chromedevtools.github.io/devtools-protocol/1-3/Runtime/#type-CallFrame)
/// type.
// ignore: prefer-single-declaration-per-file
class DevToolsCallFrame extends HarObject {
  /// Creates a [DevToolsCallFrame] with the given field values.
  const DevToolsCallFrame({
    required this.functionName,
    required this.scriptId,
    required this.url,
    required this.lineNumber,
    required this.columnNumber,
    super.comment,
    super.custom,
  });

  /// Deserialises a [DevToolsCallFrame] from a decoded JSON map.
  factory DevToolsCallFrame.fromJson(Json json) => _fromJson(json);

  static DevToolsCallFrame _fromJson(Json json) => DevToolsCallFrame(
    functionName: json[kFunctionName]?.toString() ?? '',
    scriptId: json[kScriptId]?.toString() ?? '',
    url: json[kUrl]?.toString() ?? '',
    lineNumber: num.tryParse(json[kLineNumber]?.toString() ?? '')?.toInt() ?? 0,
    columnNumber:
        num.tryParse(json[kColumnNumber]?.toString() ?? '')?.toInt() ?? 0,
    comment: json[HarObject.kComment]?.toString(),
    custom: HarUtils.collectCustom(json),
  );

  /// JSON key for the function name (`"functionName"`).
  static const kFunctionName = 'functionName';

  /// JSON key for the script identifier (`"scriptId"`).
  static const kScriptId = 'scriptId';

  /// JSON key for the script URL (`"url"`).
  static const kUrl = 'url';

  /// JSON key for the line number (`"lineNumber"`).
  static const kLineNumber = 'lineNumber';

  /// JSON key for the column number (`"columnNumber"`).
  static const kColumnNumber = 'columnNumber';

  /// Name of the JavaScript function.
  final String functionName;

  /// Script identifier.
  final String scriptId;

  /// Script URL.
  final String url;

  /// Line number in the script (0-indexed).
  final int lineNumber;

  /// Column number in the script (0-indexed).
  final int columnNumber;

  @override
  Json toJson({bool includeNulls = false}) => HarUtils.applyNullPolicy(
    {
      kFunctionName: functionName,
      kScriptId: scriptId,
      kUrl: url,
      kLineNumber: lineNumber,
      kColumnNumber: columnNumber,
      ...commonJson(includeNulls: includeNulls),
    },
    includeNulls: includeNulls,
  );

  @override
  String toString() =>
      '''DevToolsCallFrame(${[
        '$kFunctionName: $functionName',
        '$kScriptId: $scriptId',
        '$kUrl: $url',
        '$kLineNumber: $lineNumber',
        '$kColumnNumber: $columnNumber',
        if (comment != null) '${HarObject.kComment}: $comment',
        if (custom.isNotEmpty) '${HarObject.kCustom}: $custom'
      ].join(', ')})''';
}
