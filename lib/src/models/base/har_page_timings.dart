import '../../helpers/har_utils.dart';
import '../har_object.dart';
import 'har_page.dart';

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
///
/// ```dart
/// const timings = HarPageTimings(onContentLoad: 1200, onLoad: 2600);
/// print(timings.toJson()); // {onContentLoad: 1200, onLoad: 2600}
/// ```
// Reference: http://www.softwareishard.com/blog/har-12-spec/#pageTimings.
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
    onContentLoad: HarUtils.toDuration(
      num.tryParse(json[kOnContentLoad]?.toString() ?? ''),
    ),
    onLoad: HarUtils.toDuration(num.tryParse(json[kOnLoad]?.toString() ?? '')),
    comment: json[HarObject.kComment]?.toString(),
    custom: HarUtils.collectCustom(json),
  );

  /// JSON key for the DOMContentLoaded event time
  /// (`"onContentLoad"`).
  static const kOnContentLoad = 'onContentLoad';

  /// JSON key for the load event time (`"onLoad"`).
  static const kOnLoad = 'onLoad';

  /// Time from [HarPage.startedDateTime] until the page
  /// content is loaded (DOMContentLoaded event).
  ///
  /// `null` if absent; `-1` if the timing does not apply.
  // ignore: prefer-correct-callback-field-name, follows specifications naming.
  final Duration? onContentLoad;

  /// Time from [HarPage.startedDateTime] until the page is
  /// fully loaded (load event).
  ///
  /// `null` if absent; `-1` if the timing does not apply.
  // ignore: prefer-correct-callback-field-name, follows specifications naming.
  final Duration? onLoad;

  /// Serialises this page timings object back to a JSON-compatible
  /// map.
  ///
  /// Optional fields that are `null` are omitted from the output.
  /// Fields set to `-1` are preserved.
  @override
  Json toJson({bool includeNulls = false}) => HarUtils.applyNullPolicy(
    {
      kOnContentLoad: HarUtils.fromDuration(onContentLoad),
      kOnLoad: HarUtils.fromDuration(onLoad),
      ...commonJson(includeNulls: includeNulls),
    },
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );

  @override
  String toString() =>
      '''HarPageTimings(${[if (onContentLoad != null) '$kOnContentLoad: $onContentLoad', if (onLoad != null) '$kOnLoad: $onLoad', if (comment != null) '${HarObject.kComment}: $comment', if (custom.isNotEmpty) '${HarObject.kCustom}: $custom'].join(', ')})''';

  /// Creates a copy of this [HarPageTimings] with the given fields replaced.
  HarPageTimings copyWith({
    Duration? onContentLoad,
    Duration? onLoad,
    String? comment,
    Json? custom,
  }) => HarPageTimings(
    onContentLoad: onContentLoad ?? this.onContentLoad,
    onLoad: onLoad ?? this.onLoad,
    comment: comment ?? this.comment,
    custom: custom ?? this.custom,
  );
}
