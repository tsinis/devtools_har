import '../../helpers/har_utils.dart';
import '../har_object.dart';
import 'har_entry.dart' show HarEntry;

/// An exported page and its load timings.
///
/// Models the `pages` array entry defined in the HAR 1.2 specification.
///
/// Each page groups related [HarEntry] objects via its [id], which
/// entries reference through their `pageref` field. The [pageTimings]
/// object describes high-level page load milestones.
// Reference: http://www.softwareishard.com/blog/har-12-spec/#pages
class HarPage extends HarObject {
  /// Creates a [HarPage] with the given field values.
  ///
  /// [startedDateTime], [id], [title], and [pageTimings] are
  /// required by the HAR 1.2 spec.
  const HarPage({
    required this.startedDateTime,
    required this.id,
    required this.title,
    required this.pageTimings,
    this.startedDateTimeRaw,
    super.comment,
    super.custom,
  });

  /// Deserialises a [HarPage] from a decoded JSON map.
  ///
  /// Required fields ([startedDateTime], [id], [title],
  /// [pageTimings]) trigger assertions when missing and fall back
  /// to safe defaults so that parsing does not throw in production.
  ///
  /// [startedDateTime] is parsed via [DateTime.tryParse]; if the
  /// value is absent or unparseable it defaults to
  /// [DateTime.utc(0)] (Unix epoch).
  factory HarPage.fromJson(Json json) => _fromJson(json);

  static HarPage _fromJson(Json json) {
    final startedDateTimeRaw = json[kStartedDateTime];
    assert(
      startedDateTimeRaw != null,
      'HarPage: "$kStartedDateTime" is required',
    );
    final idRaw = json[kId];
    assert(idRaw != null, 'HarPage: "$kId" is required');
    final titleRaw = json[kTitle];
    assert(titleRaw != null, 'HarPage: "$kTitle" is required');
    final pageTimingsRaw = json[kPageTimings];
    assert(
      pageTimingsRaw is Json,
      'HarPage: "$kPageTimings" must be a JSON object',
    );

    final startedDateTimeString = startedDateTimeRaw?.toString();

    return HarPage(
      startedDateTime:
          DateTime.tryParse(startedDateTimeString ?? '') ?? DateTime.utc(0),
      startedDateTimeRaw: startedDateTimeString,
      id: idRaw?.toString() ?? '',
      title: titleRaw?.toString() ?? '',
      pageTimings: pageTimingsRaw is Json
          ? HarPageTimings.fromJson(pageTimingsRaw)
          : const HarPageTimings(),
      comment: json[HarObject.kComment]?.toString(),
      custom: HarUtils.collectCustom(json),
    );
  }

  /// JSON key for the page load start time (`"startedDateTime"`).
  static const kStartedDateTime = 'startedDateTime';

  /// JSON key for the unique page identifier (`"id"`).
  static const kId = 'id';

  /// JSON key for the page title (`"title"`).
  static const kTitle = 'title';

  /// JSON key for the page load timings object (`"pageTimings"`).
  static const kPageTimings = 'pageTimings';

  /// Public static constant used as a display label in `toString()`.
  /// This is not a JSON key.
  static const kStartedDateTimeRaw = 'startedDateTimeRaw';

  /// Date and time stamp for the beginning of the page load
  /// (ISO 8601 format).
  ///
  /// Required by the HAR 1.2 spec.
  final DateTime startedDateTime;

  /// Original `startedDateTime` string, preserved for round-tripping.
  final String? startedDateTimeRaw;

  /// Unique identifier of the page within the HAR file.
  ///
  /// Entries reference this value via their `pageref` field.
  /// Required by the HAR 1.2 spec.
  final String id;

  /// Page title. The title of the page is usually retrieved from
  /// the HTML `title` element.
  ///
  /// Required by the HAR 1.2 spec.
  final String title;

  /// Detailed timing information about the page load.
  ///
  /// Required by the HAR 1.2 spec.
  final HarPageTimings pageTimings;

  /// Serialises this page back to a JSON-compatible map.
  ///
  /// Optional fields that are `null` are omitted from the output.
  @override
  Json toJson({bool includeNulls = false}) => HarUtils.applyNullPolicy(
    {
      kId: id,
      kPageTimings: pageTimings.toJson(includeNulls: includeNulls),
      kStartedDateTime: startedDateTimeRaw ?? startedDateTime.toIso8601String(),
      kTitle: title,
      ...commonJson(includeNulls: includeNulls),
    },
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );

  @override
  String toString() =>
      '''HarPage(${['$kStartedDateTime: $startedDateTime', if (startedDateTimeRaw != null) '$kStartedDateTimeRaw: $startedDateTimeRaw', '$kId: $id', '$kTitle: $title', '$kPageTimings: $pageTimings', if (comment != null) '${HarObject.kComment}: $comment', if (custom.isNotEmpty) '${HarObject.kCustom}: $custom'].join(', ')})''';
}

/// Page-level load timing milestones.
///
/// Models the `pageTimings` object defined in the HAR 1.2 specification.
///
/// Values are milliseconds elapsed since [HarPage.startedDateTime].
/// Chrome DevTools may emit sub-millisecond precision (e.g.
/// `2663.376`), so both fields are typed as [double].
///
/// Like other HAR timing fields, `-1` means "does not apply to
/// the current request" and is semantically distinct from `null`
/// (field absent).
// Reference: http://www.softwareishard.com/blog/har-12-spec/#pageTimings.
// ignore: prefer-single-declaration-per-file, they are closely related.
class HarPageTimings extends HarObject {
  /// Creates a [HarPageTimings] with the given field values.
  ///
  /// Both fields are optional per the HAR 1.2 spec.
  const HarPageTimings({
    this.onContentLoad,
    this.onLoad,
    super.comment,
    super.custom,
  });

  /// Deserialises a [HarPageTimings] from a decoded JSON map.
  ///
  /// Numeric values are parsed via `num.tryParse(value.toString())`
  /// and converted to [double] for sub-millisecond precision.
  factory HarPageTimings.fromJson(Json json) => _fromJson(json);

  static HarPageTimings _fromJson(Json json) => HarPageTimings(
    onContentLoad: num.tryParse(
      json[kOnContentLoad]?.toString() ?? '', // Dart 3.8 formatting.
    )?.toDouble(),
    onLoad: num.tryParse(json[kOnLoad]?.toString() ?? '')?.toDouble(),
    comment: json[HarObject.kComment]?.toString(),
    custom: HarUtils.collectCustom(json),
  );

  /// JSON key for the DOMContentLoaded event time
  /// (`"onContentLoad"`).
  static const kOnContentLoad = 'onContentLoad';

  /// JSON key for the load event time (`"onLoad"`).
  static const kOnLoad = 'onLoad';

  /// Milliseconds from [HarPage.startedDateTime] until the page
  /// content is loaded (DOMContentLoaded event).
  ///
  /// `null` if absent; `-1` if the timing does not apply.
  // ignore: prefer-correct-callback-field-name, follows specifications naming.
  final double? onContentLoad;

  /// Milliseconds from [HarPage.startedDateTime] until the page is
  /// fully loaded (load event).
  ///
  /// `null` if absent; `-1` if the timing does not apply.
  // ignore: prefer-correct-callback-field-name, follows specifications naming.
  final double? onLoad;

  /// Serialises this page timings object back to a JSON-compatible
  /// map.
  ///
  /// Optional fields that are `null` are omitted from the output.
  /// Fields set to `-1` are preserved.
  @override
  Json toJson({bool includeNulls = false}) => HarUtils.applyNullPolicy(
    {
      kOnContentLoad: HarUtils.normalizeNumber(onContentLoad),
      kOnLoad: HarUtils.normalizeNumber(onLoad),
      ...commonJson(includeNulls: includeNulls),
    },
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );

  @override
  String toString() =>
      '''HarPageTimings(${[if (onContentLoad != null) '$kOnContentLoad: $onContentLoad', if (onLoad != null) '$kOnLoad: $onLoad', if (comment != null) '${HarObject.kComment}: $comment', if (custom.isNotEmpty) '${HarObject.kCustom}: $custom'].join(', ')})''';
}
