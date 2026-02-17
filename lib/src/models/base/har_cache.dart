import '../har_object.dart';
import '../har_utils.dart';

/// Info about cache usage.
///
/// Models the "cache" object defined in the HAR 1.2 specification.
/// Both [beforeRequest] and [afterRequest] are optional and may be
/// `null` to indicate the information is not available.
///
/// Reference: http://www.softwareishard.com/blog/har-12-spec/#cache
class HarCache extends HarObject {
  /// Creates a [HarCache] container for cache metadata.
  const HarCache({
    this.beforeRequest,
    this.afterRequest,
    super.comment,
    super.custom,
  });

  /// Deserialises a [HarCache] from a decoded JSON map.
  factory HarCache.fromJson(Json json) => _fromJson(json);

  static HarCache _fromJson(Json json) {
    final beforeRequest = json[kBeforeRequest];
    final afterRequest = json[kAfterRequest];

    return HarCache(
      beforeRequest: beforeRequest is Json
          ? HarCacheEntry.fromJson(beforeRequest)
          : null,
      afterRequest: afterRequest is Json
          ? HarCacheEntry.fromJson(afterRequest)
          : null,
      comment: json[HarObject.kComment]?.toString(),
      custom: HarUtils.collectCustom(json),
    );
  }

  /// JSON key for the pre-request cache entry (`"beforeRequest"`).
  static const kBeforeRequest = 'beforeRequest';

  /// JSON key for the post-request cache entry (`"afterRequest"`).
  static const kAfterRequest = 'afterRequest';

  /// State of a cache entry before the request. `null` when
  /// the information is not available.
  final HarCacheEntry? beforeRequest;

  /// State of a cache entry after the request. `null` when
  /// the information is not available.
  final HarCacheEntry? afterRequest;

  @override
  Json toJson({bool includeNulls = false}) => HarUtils.applyNullPolicy(
    {
      kAfterRequest: afterRequest?.toJson(),
      kBeforeRequest: beforeRequest?.toJson(),
      ...commonJson(),
    },
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );
}

/// State of a cache entry (before or after the request).
///
/// Models the shared structure used by both `beforeRequest` and
/// `afterRequest` in the HAR 1.2 cache object.
///
/// Required fields ([lastAccess], [eTag], [hitCount]) are validated
/// with [assert] so that malformed input is caught during
/// development, while release builds degrade gracefully with safe
/// defaults.
///
/// Reference: http://www.softwareishard.com/blog/har-12-spec/#cache
// ignore: prefer-single-declaration-per-file, they are closely related.
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
    final hitCountRaw = num.tryParse(json[kHitCount]?.toString() ?? '');
    final expiresRaw = json[kExpires]?.toString();

    return HarCacheEntry(
      expires: HarUtils.optionalDateTime(json[kExpires]),
      expiresRaw: expiresRaw,
      lastAccess: parsedLastAccess ?? DateTime.utc(0),
      lastAccessRaw: lastAccessString,
      eTag: eTagRaw?.toString() ?? '',
      hitCount: hitCountRaw?.toInt() ?? 0,
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
      ...commonJson(),
    },
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );
}
