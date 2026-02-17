# devtools_har

HAR 1.2 and browser DevTools-extended typed models for Dart.
Full coverage of log, entries, requests, responses, timings, cache,
cookies, and vendor-prefixed fields.

## Features

* **Full HAR 1.2 coverage** — typed Dart classes for every object in the
    [HAR 1.2 spec][har-spec]: `HarLog`, `HarEntry`, `HarRequest`,
    `HarResponse`, `HarCookie`, `HarHeader`, `HarQueryParam`, `HarPostData`,
    `HarContent`, `HarCache`, `HarTimings`, and `HarPage`.

* **Browser DevTools extensions** — `DevToolsHarEntry`, `DevToolsHarRequest`,
    `DevToolsHarResponse`, `DevToolsHarCookie`, and `DevToolsHarTimings`
    extend the base models with underscore-prefixed fields emitted by Chromium-based DevTools when exporting HAR files
    (`_initiator`, `_priority`, `_resourceType`, `_fromCache`,
    `_fromServiceWorker`, `_webSocketMessages`, `_sameSite`, etc.).

* **Lossless round-tripping** — `fromJson` → `toJson` preserves the
    original document, including unknown custom fields (`_`-prefixed) via
    a generic `custom` map and raw-value fields such as `expiresRaw`.

* **Numeric-type fidelity** — whole-number doubles (common after JSON
    deserialization) are normalized to `int` so that `42.0` serializes
    as `42`, matching the original HAR source.

* **Null-policy control** — `toJson(includeNulls: true)` emits every
    optional field for tooling that requires a complete schema;
    the default omits `null` values for compact output.

* **Pure Dart, no dependencies** — no Flutter SDK, no code generation,
    no `dart:io` / `dart:html`. Works on VM, Web, and ahead-of-time
    targets.

## Getting started

```yaml
dependencies:
  devtools_har: ^0.1.0
```

```dart
import 'package:devtools_har/devtools_har.dart';
```

## Usage

### Parse a HAR file

```dart
import 'dart:io';

import 'package:devtools_har/devtools_har.dart';

void main() {
  final jsonStr = File('network_log.har').readAsStringSync();
  final root = HarParser.parse(jsonStr);

  for (final entry in root.log.entries.take(3)) {
    print('${entry.request.method} ${entry.request.url} '
        '-> ${entry.response.status}');
  }
}
```

### Parse browser DevTools HAR exports

```dart
import 'dart:io';

import 'package:devtools_har/devtools_har.dart';

final jsonStr = File('network_log.har').readAsStringSync();
final root = DevToolsHarParser.parse(jsonStr);

final entry = root.log.entries.first;
print(entry.request.url);
print(entry.timings.wait);
print(entry.priority);     // e.g. "High"
print(entry.resourceType); // e.g. "XHR"
```

### Build and serialize

```dart
final entry = HarEntry(
  startedDateTime: DateTime.now().toUtc(),
  totalTime: 120,
  request: HarRequest(
    method: HttpMethod.get,
    url: Uri.parse('https://api.example.com/v1/vehicles'),
    httpVersion: 'HTTP/1.1',
    headers: [],
    queryString: [],
    headersSize: -1,
    bodySize: 0,
  ),
  response: HarResponse(
    status: 200,
    statusText: 'OK',
    httpVersion: 'HTTP/1.1',
    cookies: const [],
    headers: const [],
    content: const HarContent(
      size: 0,
      mimeType: HarContent.kFallbackMimeType,
    ),
    redirectURL: '',
    headersSize: -1,
    bodySize: 0,
  ),
  cache: const HarCache(),
  timings: const HarTimings(send: 0, wait: 0, receive: 0),
);

// Compact (omit nulls)
final compact = entry.toJson();

// Verbose (include all optional keys)
final verbose = entry.toJson(includeNulls: true);
```

### Round-trip fidelity

```dart
import 'dart:convert';

final original = '{"name":"sid","value":"abc","expires":"Sun, 15 Jul 2012 ..."}';
final cookie = HarCookie.fromJson(jsonDecode(original));

// expiresRaw preserves the original string format
assert(jsonEncode(cookie.toJson()).contains('Sun, 15 Jul 2012'));
```

## Architecture

The base models handle everything defined by the HAR 1.2 specification.
The `devtools/` layer extends each model with `_`-prefixed fields that
browser DevTools add when exporting network logs. Both layers share the
same `fromJson` / `toJson` contract and can be used interchangeably
where only HAR 1.2 fields are needed.

## Custom fields

All model classes carry a `Map<String, Object?> custom` property that
collects any unknown `_`-prefixed keys found during parsing. These
fields are re-emitted by `toJson`, ensuring vendor extensions survive
a round-trip without data loss.

```dart
final entry = DevToolsHarEntry.fromJson(json);

// Access a recognized DevTools field
print(entry.priority);

// Access an unrecognized vendor field
print(entry.custom['_myToolAnnotation']);
```

## References

* [HAR 1.2 Specification][har-spec]
* [Chromium DevTools Protocol — Network domain][cdp-network]

[har-spec]: http://www.softwareishard.com/blog/har-12-spec/
[cdp-network]: https://chromedevtools.github.io/devtools-protocol/1-3/Network/
