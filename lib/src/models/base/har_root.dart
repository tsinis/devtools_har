import '../har_object.dart';
import '../har_utils.dart';
import 'har_log.dart';

/// Root object — contains a single [HarLog].
class HarRoot<T extends HarLog> extends HarObject {
  /// Creates a [HarRoot] wrapping a single [HarLog].
  const HarRoot({required this.log, super.comment, super.custom = const {}});

  /// Deserialises a [HarRoot] from a decoded JSON map.
  factory HarRoot.fromJson(Json json) => _fromJson<T>(json);

  static HarRoot<T> _fromJson<T extends HarLog>(Json json) {
    final log = json[kLog];
    assert(log is Json, 'HarRoot: "$kLog" must be a JSON object');
    final logJson = log is Json ? log : const <String, dynamic>{};

    return HarRoot<T>(
      log: HarLog.fromJson(logJson) as T, // ignore: avoid-type-casts, it's ok.
      comment: json[HarObject.kComment]?.toString(),
      custom: HarUtils.collectCustom(json),
    );
  }

  /// JSON key for the root log object (`"log"`).
  static const kLog = 'log';

  /// The HAR log payload contained at the root.
  final T log;

  @override
  Json toJson({bool includeNulls = false}) => HarUtils.applyNullPolicy(
    {
      kLog: log.toJson(includeNulls: includeNulls),
      ...commonJson(includeNulls: includeNulls),
    },
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );

  @override
  String toString() =>
      '''HarRoot(${['$kLog: $log', if (comment != null) '${HarObject.kComment}: $comment', if (custom.isNotEmpty) '${HarObject.kCustom}: $custom'].join(', ')})''';
}
