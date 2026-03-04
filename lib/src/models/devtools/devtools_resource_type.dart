import '../../helpers/extensions/enum_iterable_parsing.dart';

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
  /// CSP violation report.
  cspViolationReport('CSPViolationReport'),

  /// Main document.
  document('Document'),

  /// EventSource request.
  eventSource('EventSource'),

  /// FedCM (Federated Credential Management) request.
  fedCm('FedCM'),

  /// Fetch request.
  fetch('Fetch'),

  /// Font file.
  font('Font'),

  /// Image file.
  image('Image'),

  /// Manifest file.
  manifest('Manifest'),

  /// Media file (video/audio).
  media('Media'),

  /// Other resource type.
  other('Other'),

  /// Ping request.
  ping('Ping'),

  /// Prefetch request.
  prefetch('Prefetch'),

  /// Preflight request.
  preflight('Preflight'),

  /// JavaScript file.
  script('Script'),

  /// Signed exchange.
  signedExchange('SignedExchange'),

  /// CSS stylesheet.
  stylesheet('Stylesheet'),

  /// TextTrack resource.
  textTrack('TextTrack'),

  /// WebBundle.
  webBundle('WebBundle'),

  /// WebTransport.
  webTransport('WebTransport'),

  /// WebVTT file.
  webVtt('WebVTT'),

  /// WebSocket connection.
  websocket('WebSocket'),

  /// XHR request.
  xhr('XHR');

  const DevToolsResourceType(this.value);

  /// The string value as it appears in HAR / CDP JSON.
  final String value;

  /// Resolves a [DevToolsResourceType] from its JSON string [value].
  ///
  /// Returns `null` if [value] is `null` or does not match any known
  /// variant (case-insensitive).
  static DevToolsResourceType? tryParse(Object? value) =>
      values.tryParse(value);

  /// Serialises as the string value matching the CDP convention.
  String toJson() => value;
}
