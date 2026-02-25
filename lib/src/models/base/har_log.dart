import '../har_object.dart';
import '../har_utils.dart';
import 'har_entry.dart';
import 'har_name_version.dart';
import 'har_page.dart';

/// HAR 1.2 top-level log object.
///
/// Models the log object defined in the HAR 1.2 specification.
///
/// This is the root of all exported data. Every conforming HAR file
/// contains exactly one `log` object.
// Reference: http://www.softwareishard.com/blog/har-12-spec/#log
class HarLog<T extends HarEntry> extends HarObject {
  /// Creates a [HarLog] with the given field values.
  ///
  /// [version] and [creator] are required by the HAR 1.2 spec.
  /// [entries] is also required by the spec but defaults to an empty list.
  /// All other parameters are optional.
  const HarLog({
    required this.creator,
    this.entries = const [],
    this.version = kDefaultVersion,
    this.browser,
    this.pages = const [],
    super.comment,
    super.custom,
  });

  /// Deserialises a [HarLog] from a decoded JSON map.
  ///
  /// Required fields ([version], [creator], [entries]) are guarded
  /// by asserts that fire in debug mode. In release builds missing
  /// keys fall back to safe defaults (`"1.2"` for version, empty
  /// list for entries). The [creator] field must be a valid JSON
  /// object — if it is missing or has the wrong type, the assertion
  /// fires in debug mode and a default [HarCreator] is used in
  /// release mode.
  ///
  /// The [pages] array is optional per the spec; tools that cannot
  /// group requests by page may omit it entirely.
  ///
  /// List elements ([pages], [entries]) that are not JSON objects
  /// are silently skipped via `whereType<Json>()`.
  static HarLog<T> fromJson<T extends HarEntry>(Json json) =>
      _fromJson<T>(json);

  static HarLog<T> _fromJson<T extends HarEntry>(Json json) {
    assert(json.containsKey(kVersion), 'HarLog: "$kVersion" is required');
    assert(json.containsKey(kCreator), 'HarLog: "$kCreator" is required');
    assert(json.containsKey(kEntries), 'HarLog: "$kEntries" is required');

    final creatorRaw = json[kCreator];
    assert(creatorRaw is Json, 'HarLog: "$kCreator" must be a JSON object');

    final pagesRaw = json[kPages];
    final entriesRaw = json[kEntries];
    final browserRaw = json[kBrowser];
    final entriesList = entriesRaw is List
        ? entriesRaw.whereType<Json>().map(HarEntry.fromJson)
        : const <HarEntry>[];

    return HarLog<T>(
      version: json[kVersion]?.toString() ?? kDefaultVersion,
      creator: creatorRaw is Json
          ? HarCreator.fromJson(creatorRaw)
          : const HarCreator(name: '', version: ''),
      browser: browserRaw is Json ? HarBrowser.fromJson(browserRaw) : null,
      pages: pagesRaw is List
          ? pagesRaw.whereType<Json>().map(HarPage.fromJson).toList()
          : const [],
      entries: List<T>.from(entriesList),
      comment: json[HarObject.kComment]?.toString(),
      custom: HarUtils.collectCustom(json),
    );
  }

  /// JSON key for the format version string (`"version"`).
  static const kVersion = 'version';

  /// JSON key for the creator application info (`"creator"`).
  static const kCreator = 'creator';

  /// JSON key for the browser info (`"browser"`).
  static const kBrowser = 'browser';

  /// JSON key for the exported pages array (`"pages"`).
  static const kPages = 'pages';

  /// JSON key for the exported entries array (`"entries"`).
  static const kEntries = 'entries';

  /// Default version assumed when the field is missing or empty.
  ///
  /// The HAR spec states *"If empty, string `"1.1"` is assumed by
  /// default"*, but since virtually all modern files use `"1.2"`,
  /// this factory defaults to `"1.2"` to match current tooling.
  static const kDefaultVersion = '1.2';

  /// Version number of the HAR format (e.g. `"1.2"`).
  ///
  /// Required by the HAR 1.2 spec.
  final String version;

  /// Name and version info of the log creator application.
  ///
  /// Required by the HAR 1.2 spec.
  final HarCreator creator;

  /// Name and version info of the browser that produced the log,
  /// or `null` if not provided.
  final HarBrowser? browser;

  /// List of all exported (tracked) pages.
  ///
  /// Empty when the exporting tool does not support grouping
  /// requests by page.
  final List<HarPage> pages;

  /// List of all exported (tracked) HTTP requests.
  ///
  /// Required by the HAR 1.2 spec. The spec recommends sorting
  /// entries by [HarEntry.startedDateTime] (oldest first) for faster
  /// import, though readers should not rely on this ordering.
  final List<T> entries;

  /// Serialises this log object back to a JSON-compatible map.
  ///
  /// Optional fields that are `null` or empty are omitted:
  /// - [browser] is omitted when `null`.
  /// - [pages] is omitted when empty (per spec: leave out if
  ///   the tool doesn't support page grouping).
  /// - [comment] is omitted when `null`.
  @override
  Json toJson({bool includeNulls = false}) => HarUtils.applyNullPolicy(
    {
      kBrowser: browser?.toJson(includeNulls: includeNulls),
      kCreator: creator.toJson(includeNulls: includeNulls),
      kVersion: version,
      if (pages.isNotEmpty)
        kPages: pages.map((e) => e.toJson(includeNulls: includeNulls)).toList(),
      kEntries: entries
          .map((e) => e.toJson(includeNulls: includeNulls))
          .toList(),
      ...commonJson(includeNulls: includeNulls),
    },
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );

  @override
  String toString() =>
      '''HarLog(${['$kVersion: $version', '$kCreator: $creator', if (browser != null) '$kBrowser: $browser', if (pages.isNotEmpty) '$kPages: $pages', '$kEntries: $entries', if (comment != null) '${HarObject.kComment}: $comment', if (custom.isNotEmpty) '${HarObject.kCustom}: $custom'].join(', ')})''';
}
