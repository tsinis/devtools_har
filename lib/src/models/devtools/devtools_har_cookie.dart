import '../../helpers/har_utils.dart';
import '../base/har_cookie.dart';
import '../har_object.dart';
import 'cookie_same_site.dart';

/// A Chrome DevTools extension of [HarCookie] that adds the
/// [`sameSite`][CookieSameSite] attribute.
///
/// The `sameSite` field is not part of the HAR 1.2 specification
/// but is commonly present in HAR files exported by Chrome DevTools,
/// which extends the cookie object with:
///
/// ```json
/// { "sameSite": "Lax" }
/// ```
///
/// The value corresponds to the Chrome DevTools Protocol
/// [`CookieSameSite`](https://chromedevtools.github.io/devtools-protocol/1-3/Network/#type-CookieSameSite)
/// enum: `"Strict"`, `"Lax"`, or `"None"`.
///
/// ```dart
/// const cookie = DevToolsHarCookie(
///   name: 'sid',
///   value: 'abc123',
///   sameSite: CookieSameSite.lax,
/// );
/// print(cookie.sameSite); // CookieSameSite.lax
/// ```
class DevToolsHarCookie extends HarCookie {
  /// Creates a [DevToolsHarCookie] with all [HarCookie] fields plus
  /// the optional [sameSite] attribute.
  const DevToolsHarCookie({
    required super.name,
    required super.value,
    super.path,
    super.domain,
    super.expires,
    super.expiresRaw,
    super.httpOnly,
    super.secure,
    super.comment,
    super.custom,
    this.sameSite,
  });

  /// Creates a [DevToolsHarCookie] from an existing [HarCookie],
  /// copying all base fields and adding the optional [sameSite].
  DevToolsHarCookie.fromHarCookie(
    HarCookie cookie, {
    this.sameSite, // Dart 3.8 formatting.
  }) : super(
         name: cookie.name,
         value: cookie.value,
         path: cookie.path,
         domain: cookie.domain,
         expires: cookie.expires,
         expiresRaw: cookie.expiresRaw,
         httpOnly: cookie.httpOnly,
         secure: cookie.secure,
         comment: cookie.comment,
         custom: cookie.custom,
       );

  /// Deserialises a [DevToolsHarCookie] from a decoded JSON map.
  ///
  /// Delegates all HAR 1.2 fields to [HarCookie.fromJson] semantics
  /// (including UTC normalisation of [expires] and strict `null`
  /// checks on [name]/[value]).
  ///
  /// The `sameSite` string is resolved via
  /// [CookieSameSite.tryParse]; unrecognised values are silently
  /// treated as `null`.
  factory DevToolsHarCookie.fromJson(Json json) => _fromJson(json);

  static DevToolsHarCookie _fromJson(Json json) =>
      DevToolsHarCookie.fromHarCookie(
        HarCookie.fromJson(json),
        sameSite: CookieSameSite.tryParse(json[kSameSite]),
      );

  /// JSON key for the SameSite attribute (`"sameSite"`).
  static const kSameSite = 'sameSite';

  /// The `SameSite` attribute of this cookie, or `null` if the
  /// attribute was not present in the HAR source.
  ///
  /// Possible values: [CookieSameSite.strict], [CookieSameSite.lax],
  /// or [CookieSameSite.none].
  final CookieSameSite? sameSite;

  @override
  Json toJson({bool includeNulls = false}) => HarUtils.applyNullPolicy(
    {...super.toJson(includeNulls: includeNulls), kSameSite: sameSite?.value},
    includeNulls: includeNulls, // Dart 3.8 formatting.
  );

  @override
  String toString() =>
      // ignore: avoid-default-tostring, it's enum.
      '''DevToolsHarCookie(${['${HarCookie.kName}: $name', '${HarCookie.kValue}: $value', if (path != null) '${HarCookie.kPath}: $path', if (domain != null) '${HarCookie.kDomain}: $domain', if (expires != null) '${HarCookie.kExpires}: $expires', if (expiresRaw != null) '${HarCookie.kExpiresRaw}: $expiresRaw', if (httpOnly != null) '${HarCookie.kHttpOnly}: $httpOnly', if (secure != null) '${HarCookie.kSecure}: $secure', if (sameSite != null) '$kSameSite: $sameSite', if (comment != null) '${HarObject.kComment}: $comment', if (custom.isNotEmpty) '${HarObject.kCustom}: $custom'].join(', ')})''';

  @override
  DevToolsHarCookie copyWith({
    String? name,
    String? value,
    String? path,
    String? domain,
    DateTime? expires,
    String? expiresRaw,
    bool? httpOnly,
    bool? secure,
    CookieSameSite? sameSite,
    String? comment,
    Json? custom,
  }) => DevToolsHarCookie(
    name: name ?? this.name,
    value: value ?? this.value,
    path: path ?? this.path,
    domain: domain ?? this.domain,
    expires: expires ?? this.expires,
    expiresRaw: expiresRaw ?? this.expiresRaw,
    httpOnly: httpOnly ?? this.httpOnly,
    secure: secure ?? this.secure,
    sameSite: sameSite ?? this.sameSite,
    comment: comment ?? this.comment,
    custom: custom ?? this.custom,
  );
}
