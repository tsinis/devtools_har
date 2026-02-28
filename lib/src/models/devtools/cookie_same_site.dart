import '../base/har_cookie.dart';

/// The `SameSite` attribute of an HTTP cookie as reported by browser's DevTools
///
/// Maps to the Chrome DevTools Protocol
/// [`CookieSameSite`](https://chromedevtools.github.io/devtools-protocol/1-3/Network/#type-CookieSameSite)
/// enum, which defines three values: `Strict`, `Lax`, and `None`.
///
/// ```dart
/// const sameSite = CookieSameSite.lax;
/// print(sameSite.value); // Lax
/// print(CookieSameSite.tryParse('Strict')); // CookieSameSite.strict
/// ```
enum CookieSameSite {
  /// The cookie is sent with top-level navigations and
  /// same-site requests.
  lax('Lax'),

  /// The cookie is sent in all contexts (requires [HarCookie.secure]
  /// to be `true`).
  none('None'),

  /// The cookie is sent only in a first-party context.
  strict('Strict');

  const CookieSameSite(this.value);

  /// The string value as it appears in HAR / CDP JSON (`"Strict"`,
  /// `"Lax"`, or `"None"`).
  final String value;

  /// Resolves a [CookieSameSite] from its JSON string [value].
  ///
  /// Returns `null` if [value] is `null` or does not match any known
  /// variant (case-insensitive).
  static CookieSameSite? tryParse(Object? value) {
    if (value == null) return null;

    final lower = value.toString().toLowerCase();
    for (final cookie in values) {
      if (cookie.value.toLowerCase() == lower) return cookie;
    }

    return null;
  }
}
