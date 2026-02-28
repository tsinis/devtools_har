import '../../helpers/har_utils.dart';
import '../base/har_root.dart';
import '../har_object.dart';
import 'devtools_har_log.dart';

/// Root object that may contain DevTools extras.
///
/// ```dart
/// const root = DevToolsHarRoot(
///   log: DevToolsHarLog(
///     version: '1.2',
///     creator: HarCreator(name: 'Chrome', version: '120'),
///   ),
/// );
/// print(root.log.version); // 1.2
/// ```
class DevToolsHarRoot extends HarRoot<DevToolsHarLog> {
  /// Creates a [DevToolsHarRoot] wrapping a DevTools HAR log.
  const DevToolsHarRoot({required super.log, super.comment, super.custom});

  /// Deserialises a [DevToolsHarRoot] from a decoded JSON map.
  factory DevToolsHarRoot.fromJson(Json json) => _fromJson(json);

  static DevToolsHarRoot _fromJson(Json json) {
    final log = json[HarRoot.kLog];
    assert(
      log is Json,
      'DevToolsHarRoot: "${HarRoot.kLog}" must be a JSON object',
    );
    final logJson = log is Json ? log : const <String, dynamic>{};

    return DevToolsHarRoot(
      log: DevToolsHarLog.fromJson(logJson),
      comment: json[HarObject.kComment]?.toString(),
      custom: HarUtils.collectCustom(json),
    );
  }

  @override
  String toString() =>
      '''DevToolsHarRoot(${['${HarRoot.kLog}: $log', if (comment != null) '${HarObject.kComment}: $comment', if (custom.isNotEmpty) '${HarObject.kCustom}: $custom'].join(', ')})''';

  @override
  DevToolsHarRoot copyWith({
    DevToolsHarLog? log,
    String? comment,
    Json? custom,
  }) => DevToolsHarRoot(
    log: log ?? this.log,
    comment: comment ?? this.comment,
    custom: custom ?? this.custom,
  );
}
