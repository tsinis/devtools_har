import '../../helpers/har_utils.dart';
import '../base/har_entry.dart';
import '../base/har_log.dart';
import '../har_object.dart';
import 'devtools_har_entry.dart';

/// Chrome DevTools extension of [HarLog].
///
/// Structurally identical to [HarLog] — the only difference is that
/// [entries] are deserialised as [DevToolsHarEntry] instances, which
/// carry Chrome-specific custom fields (`_initiator`, `_priority`,
/// `_resourceType`, `_fromCache`, `_fromServiceWorker`, etc.).
///
/// If you don't need typed access to those DevTools extensions, use
/// [HarLog] directly — all underscore-prefixed fields are still
/// preserved in each entry's [custom] map.
///
/// See also:
///
/// * [HarLog] — the base HAR 1.2 log model.
/// * [DevToolsHarEntry] — entry model with Chrome-specific fields.
class DevToolsHarLog extends HarLog<DevToolsHarEntry> {
  /// Creates a [DevToolsHarLog] with all [HarLog] fields.
  ///
  /// [entries] should contain [DevToolsHarEntry] instances to
  /// benefit from typed DevTools fields. Defaults to an empty list.
  const DevToolsHarLog({
    required super.version,
    required super.creator,
    super.entries = const [],
    super.browser,
    super.pages = const [],
    super.comment,
    super.custom,
  });

  /// Creates a [DevToolsHarLog] from an existing [HarLog],
  /// copying all base fields and substituting [entries] with
  /// [DevToolsHarEntry] instances.
  DevToolsHarLog.fromHarLog(
    HarLog log, {
    super.entries = const [],
    super.custom = const {},
  }) : super(
         version: log.version,
         creator: log.creator,
         browser: log.browser,
         pages: log.pages,
         comment: log.comment,
       );

  /// Deserialises a [DevToolsHarLog] from a decoded JSON map.
  ///
  /// Delegates all shared parsing logic to [HarLog]'s field
  /// handling but produces [DevToolsHarEntry] instances instead of
  /// plain [HarEntry].
  ///
  /// See [HarLog.fromJson] for details on assertions, defaults,
  /// and error handling.
  factory DevToolsHarLog.fromJson(Json json) => _fromJson(json);

  static DevToolsHarLog _fromJson(Json json) {
    final entriesRaw = json[HarLog.kEntries];
    final entriesList = entriesRaw is List
        ? entriesRaw.whereType<Json>().map(DevToolsHarEntry.fromJson).toList()
        : const <DevToolsHarEntry>[];

    return DevToolsHarLog.fromHarLog(
      HarLog.fromJson(json),
      entries: entriesList,
      custom: HarUtils.collectCustom(json),
    );
  }

  @override
  String toString() =>
      '''DevToolsHarLog(${['${HarLog.kVersion}: $version', '${HarLog.kCreator}: $creator', if (browser != null) '${HarLog.kBrowser}: $browser', if (pages.isNotEmpty) '${HarLog.kPages}: $pages', '${HarLog.kEntries}: $entries', if (comment != null) '${HarObject.kComment}: $comment', if (custom.isNotEmpty) '${HarObject.kCustom}: $custom'].join(', ')})''';
}
