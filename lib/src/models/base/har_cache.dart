import '../../helpers/har_utils.dart';
import '../har_object.dart';
import 'har_cache_entry.dart';

/// Info about cache usage.
///
/// Models the "cache" object defined in the HAR 1.2 specification.
/// Both [beforeRequest] and [afterRequest] are optional and may be
/// `null` to indicate the information is not available.
///
/// ```dart
/// const cache = HarCache(); // no cache info
/// print(cache.toJson()); // {}
/// ```
// Reference: http://www.softwareishard.com/blog/har-12-spec/#cache
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
      kAfterRequest: afterRequest?.toJson(includeNulls: includeNulls),
      kBeforeRequest: beforeRequest?.toJson(includeNulls: includeNulls),
      ...commonJson(includeNulls: includeNulls),
    },
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );

  @override
  String toString() =>
      '''HarCache(${[if (beforeRequest != null) '$kBeforeRequest: $beforeRequest', if (afterRequest != null) '$kAfterRequest: $afterRequest', if (comment != null) '${HarObject.kComment}: $comment', if (custom.isNotEmpty) '${HarObject.kCustom}: $custom'].join(', ')})''';

  /// Creates a copy of this [HarCache] with the given fields replaced.
  HarCache copyWith({
    HarCacheEntry? beforeRequest,
    HarCacheEntry? afterRequest,
    String? comment,
    Json? custom,
  }) => HarCache(
    beforeRequest: beforeRequest ?? this.beforeRequest,
    afterRequest: afterRequest ?? this.afterRequest,
    comment: comment ?? this.comment,
    custom: custom ?? this.custom,
  );
}
