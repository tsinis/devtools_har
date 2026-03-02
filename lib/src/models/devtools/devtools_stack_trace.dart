import '../../helpers/har_utils.dart';
import '../har_object.dart';
import 'devtools_call_frame.dart';

/// Chrome DevTools stack trace metadata.
///
/// Maps to the Chrome DevTools Protocol
/// [`StackTrace`](https://chromedevtools.github.io/devtools-protocol/1-3/Runtime/#type-StackTrace)
/// type.
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
