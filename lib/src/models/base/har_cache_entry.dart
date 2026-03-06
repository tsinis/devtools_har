// ignore_for_file: avoid-similar-names

import '../../helpers/har_utils.dart';
import '../har_object.dart';

/// State of a cache entry (before or after the request).
///
/// Models the shared structure used by both `beforeRequest` and
/// `afterRequest` in the HAR 1.2 cache object.
///
/// Required fields ([lastAccess], [eTag], [hitCount]) are validated
/// with assert so that malformed input is caught during
/// development, while release builds degrade gracefully with safe
/// defaults.
///
/// ```dart
/// final entry = HarCacheEntry(
///   lastAccess: DateTime.utc(2025),
///   eTag: '"abc"',
///   hitCount: 3,
/// );
/// print(entry.hitCount); // 3
/// ```
// Reference: http://www.softwareishard.com/blog/har-12-spec/#cache.
class HarCacheEntry extends HarObject {
  /// Creates a [HarCacheEntry] describing one cache state snapshot.
  const HarCacheEntry({
    required this.lastAccess,
    required this.eTag,
    required this.hitCount,
    this.expires,
    this.expiresRaw,
    this.lastAccessRaw,
    super.comment,
    super.custom,
  });

  /// Deserialises a [HarCacheEntry] from a decoded JSON map.
  factory HarCacheEntry.fromJson(Json json) => _fromJson(json);

  static HarCacheEntry _fromJson(Json json) {
    final lastAccessRaw = json[kLastAccess];
    assert(lastAccessRaw != null, 'HarCacheEntry: "$kLastAccess" is required');
    final eTagRaw = json[kETag];
    assert(eTagRaw != null, 'HarCacheEntry: "$kETag" is required');
    final lastAccessString = lastAccessRaw?.toString();
    final parsedLastAccess = DateTime.tryParse(lastAccessString ?? '');
    assert(
      parsedLastAccess != null,
      '''HarCacheEntry: "$kLastAccess" must be a valid ISO 8601 string: $lastAccessRaw''',
    );
    final hitCountRaw = json[kHitCount]?.toString();
    assert(hitCountRaw != null, 'HarCacheEntry: "$kHitCount" is required');
    final parsedHitCountInteger = int.tryParse(hitCountRaw ?? '');
    final parsedHitCountNumber = num.tryParse(hitCountRaw ?? '');
    final hitCountFinal =
        parsedHitCountInteger != null && parsedHitCountInteger >= 0
        ? parsedHitCountInteger
        : (parsedHitCountNumber != null &&
              parsedHitCountNumber >= 0 &&
              parsedHitCountNumber == parsedHitCountNumber.toInt())
        ? parsedHitCountNumber.toInt()
        : 0;
    final expiresRaw = json[kExpires]?.toString();

    return HarCacheEntry(
      expires: HarUtils.optionalDateTime(json[kExpires]),
      expiresRaw: expiresRaw,
      lastAccess: parsedLastAccess ?? DateTime.utc(0),
      lastAccessRaw: lastAccessString,
      eTag: eTagRaw?.toString() ?? '',
      hitCount: hitCountFinal,
      comment: json[HarObject.kComment]?.toString(),
      custom: HarUtils.collectCustom(json),
    );
  }

  /// JSON key for the cache expiration timestamp (`"expires"`).
  static const kExpires = 'expires';

  /// JSON key for the last access timestamp (`"lastAccess"`).
  static const kLastAccess = 'lastAccess';

  /// JSON key for the cache entry ETag (`"eTag"`).
  static const kETag = 'eTag';

  /// JSON key for the cache hit count (`"hitCount"`).
  static const kHitCount = 'hitCount';

  /// Public static constant used as a display label in `toString()`.
  /// This is not a JSON key.
  static const kExpiresRaw = 'expiresRaw';

  /// Public static constant used as a display label in `toString()`.
  /// This is not a JSON key.
  static const kLastAccessRaw = 'lastAccessRaw';

  /// Expiration time of the cache entry. `null` when not available.
  final DateTime? expires;

  /// Original `expires` string, preserved for round-tripping.
  final String? expiresRaw;

  /// The last time the cache entry was accessed.
  final DateTime lastAccess;

  /// Original `lastAccess` string, preserved for round-tripping.
  final String? lastAccessRaw;

  /// ETag of the cache entry.
  final String eTag;

  /// The number of times the cache entry has been opened.
  final int hitCount;

  @override
  Json toJson({bool includeNulls = false}) => HarUtils.applyNullPolicy(
    {
      kETag: eTag,
      kExpires: expiresRaw ?? expires?.toIso8601String(),
      kHitCount: hitCount,
      kLastAccess: lastAccessRaw ?? lastAccess.toIso8601String(),
      ...commonJson(includeNulls: includeNulls),
    },
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );

  @override
  String toString() =>
      '''HarCacheEntry(${[if (expires != null) '$kExpires: $expires', if (expiresRaw != null) '$kExpiresRaw: $expiresRaw', '$kLastAccess: $lastAccess', if (lastAccessRaw != null) '$kLastAccessRaw: $lastAccessRaw', '$kETag: $eTag', '$kHitCount: $hitCount', if (comment != null) '${HarObject.kComment}: $comment', if (custom.isNotEmpty) '${HarObject.kCustom}: $custom'].join(', ')})''';

  /// Creates a copy of this [HarCacheEntry] with the given fields replaced.
  @override
  HarCacheEntry copyWith({
    DateTime? lastAccess,
    String? lastAccessRaw,
    String? eTag,
    int? hitCount,
    DateTime? expires,
    String? expiresRaw,
    String? comment,
    Json? custom,
  }) {
    final nextLastAccess = lastAccess ?? this.lastAccess;
    final nextExpires = expires ?? this.expires;

    return HarCacheEntry(
      lastAccess: nextLastAccess,
      lastAccessRaw: lastAccess == null
          ? (lastAccessRaw ?? this.lastAccessRaw)
          : null,
      eTag: eTag ?? this.eTag,
      hitCount: hitCount ?? this.hitCount,
      expires: nextExpires,
      expiresRaw: expires == null ? (expiresRaw ?? this.expiresRaw) : null,
      comment: comment ?? this.comment,
      custom: custom ?? this.custom,
    );
  }
}
