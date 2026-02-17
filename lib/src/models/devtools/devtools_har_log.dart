// ignore_for_file: prefer-class-destructuring

import '../base/har_entry.dart';
import '../base/har_log.dart';
import '../har_utils.dart';
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

  /// Deserialises a [DevToolsHarLog] from a decoded JSON map.

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
    final harLog = HarLog.fromJson(json);
    final entriesRaw = json[HarLog.kEntries];
    final entriesList = entriesRaw is List
        ? entriesRaw.whereType<Json>().map(DevToolsHarEntry.fromJson)
        : const <DevToolsHarEntry>[];

    return DevToolsHarLog(
      version: harLog.version,
      creator: harLog.creator,
      browser: harLog.browser,
      pages: harLog.pages,
      entries: List<DevToolsHarEntry>.from(entriesList),
      comment: harLog.comment,
      custom: HarUtils.collectCustom(json),
    );
  }
}
