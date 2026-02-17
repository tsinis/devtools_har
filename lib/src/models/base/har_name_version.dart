import '../har_object.dart';
import '../har_utils.dart';

/// Common "name / version / comment" structure shared by the
/// `creator` and `browser` objects in the HAR log.
///
/// Both objects have the same shape: a required [name], a required
/// [version], and an optional [comment].
///
/// The `creator` field is required on every HAR log and identifies
/// the tool that produced the file. The `browser` field is optional
/// and identifies the browser that generated the traffic.
///
/// Reference: http://www.softwareishard.com/blog/har-12-spec/#creator
class HarNameVersion extends HarObject {
  /// Creates a [HarNameVersion] with the given field values.
  ///
  /// [name] and [version] are required by the HAR 1.2 spec.
  const HarNameVersion({
    required this.name,
    required this.version,
    super.comment,
    super.custom = const {},
  });

  /// Deserialises a [HarNameVersion] from a decoded JSON map.
  ///
  /// [name] and [version] are required by the spec. When either is
  /// missing an assertion fires (in debug mode) and the field falls
  /// back to an empty string.
  factory HarNameVersion.fromJson(Json json) => _fromJson(json);

  static HarNameVersion _fromJson(Json json) {
    final nameRaw = json[kName];
    assert(nameRaw != null, 'HarNameVersion: "$kName" is required');
    final versionRaw = json[kVersion];
    assert(versionRaw != null, 'HarNameVersion: "$kVersion" is required');

    return HarNameVersion(
      name: nameRaw?.toString() ?? '',
      version: versionRaw?.toString() ?? '',
      comment: json[HarObject.kComment]?.toString(),
      custom: HarUtils.collectCustom(json),
    );
  }

  /// JSON key for the application or browser name (`"name"`).
  static const kName = 'name';

  /// JSON key for the application or browser version (`"version"`).
  static const kVersion = 'version';

  /// Name of the application or browser.
  ///
  /// Required by the HAR 1.2 spec.
  final String name;

  /// Version of the application or browser.
  ///
  /// Required by the HAR 1.2 spec.
  final String version;

  /// Serialises this object back to a JSON-compatible map.
  ///
  /// Optional fields that are `null` are omitted from the output.
  @override
  Json toJson({bool includeNulls = false}) => HarUtils.applyNullPolicy(
    {kName: name, kVersion: version, ...commonJson(includeNulls: includeNulls)},
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );
}

/// Creator application info (alias for [HarNameVersion]).
///
/// The `creator` object is required on every HAR log.
typedef HarCreator = HarNameVersion;

/// Browser info (alias for [HarNameVersion]).
///
/// The `browser` object is optional on a HAR log.
typedef HarBrowser = HarNameVersion;
