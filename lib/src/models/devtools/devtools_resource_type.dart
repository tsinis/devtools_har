/// Chrome resource type classification.
///
/// Maps to the Chrome DevTools Protocol
/// [`ResourceType`](https://chromedevtools.github.io/devtools-protocol/1-3/Network/#type-ResourceType)
/// enum.
///
/// ```dart
/// const type = DevToolsResourceType.xhr;
/// print(type.value); // xhr
/// print(DevToolsResourceType.tryParse('Document')); // DevToolsResourceType.document
/// ```
enum DevToolsResourceType {
  /// Main document.
  document('Document'),

  /// CSS stylesheet.
  stylesheet('Stylesheet'),

  /// JavaScript file.
  script('Script'),

  /// Image file.
  image('Image'),

  /// Media file (video/audio).
  media('Media'),

  /// Font file.
  font('Font'),

  /// WebSocket connection.
  websocket('WebSocket'),

  /// Other resource type.
  other('Other'),

  /// XHR request.
  xhr('XHR'),

  /// Fetch request.
  fetch('Fetch'),

  /// EventSource request.
  eventSource('EventSource'),

  /// WebVTT file.
  webVtt('WebVTT'),

  /// Manifest file.
  manifest('Manifest'),

  /// Signed exchange.
  signedExchange('SignedExchange'),

  /// Ping request.
  ping('Ping'),

  /// CSP violation report.
  cspViolationReport('CSPViolationReport'),

  /// Preflight request.
  preflight('Preflight'),

  /// WebBundle.
  webBundle('WebBundle'),

  /// WebTransport.
  webTransport('WebTransport');

  const DevToolsResourceType(this.value);

  /// The string value as it appears in HAR / CDP JSON.
  final String value;

  /// Resolves a [DevToolsResourceType] from its JSON string [value].
  ///
  /// Returns `null` if [value] is `null` or does not match any known
  /// variant (case-insensitive).
  static DevToolsResourceType? tryParse(Object? value) {
    if (value == null) return null;

    final lower = value.toString().toLowerCase();
    for (final type in values) {
      if (type.value.toLowerCase() == lower) return type;
    }

    return null;
  }

  /// Serialises as the string value matching the CDP convention.
  String toJson() => value;
}
