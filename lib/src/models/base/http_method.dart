import 'har_request.dart';

/// Type-safe HTTP method enumeration.
///
/// Covers the nine standard methods defined in
/// [RFC 7231](https://datatracker.ietf.org/doc/html/rfc7231) and
/// [RFC 5789](https://datatracker.ietf.org/doc/html/rfc5789) (PATCH).
///
/// Used by [HarRequest] for the `method` field, which the HAR spec
/// stores as an uppercase string (e.g. `"GET"`, `"POST"`).
///
/// ```dart
/// const method = HttpMethod.post;
/// print(method.toJson()); // POST
/// print(HttpMethod.tryParse('get')); // HttpMethod.get
/// ```
// Reference: http://www.softwareishard.com/blog/har-12-spec/#request
enum HttpMethod {
  /// Establishes a tunnel to the server (used for HTTPS proxying).
  connect,

  /// Removes the target resource.
  delete,

  /// Retrieves a representation of the target resource.
  get,

  /// Same as [get] but without the response body.
  head,

  /// Describes the communication options for the target resource.
  options,

  /// Applies partial modifications to a resource (RFC 5789).
  patch,

  /// Submits an entity to the target resource.
  post,

  /// Replaces the current representation of the target resource.
  put,

  /// Performs a message loop-back test along the path to the target.
  trace;

  /// Case-insensitive lookup; returns `null` for unknown methods.
  ///
  /// Accepts any casing (e.g. `"get"`, `"GET"`, `"Get"`) and matches
  /// against the enum member names.
  static HttpMethod? tryParse(Object? value) {
    if (value == null) return null;

    final upper = value.toString().toUpperCase();
    for (final method in values) {
      if (method.toJson() == upper) return method;
    }

    return null;
  }

  /// Serialises as an uppercase string (`GET`, `POST`, …) matching
  /// the HAR spec convention.
  String toJson() => name.toUpperCase();
}
