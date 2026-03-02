import '../../helpers/har_utils.dart';
import '../har_object.dart';

/// Chrome DevTools call frame metadata.
///
/// Maps to the Chrome DevTools Protocol
/// [`CallFrame`](https://chromedevtools.github.io/devtools-protocol/1-3/Runtime/#type-CallFrame)
/// type.
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
