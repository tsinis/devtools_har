// ignore_for_file: avoid-long-functions, prefer-class-destructuring

import 'package:devtools_har/src/models/base/har_cache.dart';
import 'package:devtools_har/src/models/base/har_content.dart';
import 'package:devtools_har/src/models/base/har_entry.dart';
import 'package:devtools_har/src/models/base/har_request.dart';
import 'package:devtools_har/src/models/base/har_response.dart';
import 'package:devtools_har/src/models/base/har_timings.dart';
import 'package:devtools_har/src/models/devtools/devtools_har_entry.dart';
import 'package:devtools_har/src/models/devtools/devtools_har_request.dart';
import 'package:devtools_har/src/models/devtools/devtools_har_response.dart';
import 'package:test/test.dart';

void main() {
  group('DevToolsHarEntry.fromHarEntry', () {
    final baseEntry = HarEntry(
      startedDateTime: DateTime.utc(2025, 3, 14),
      totalTime: 245.5,
      request: HarRequest(
        url: Uri.parse('https://example.com'),
        headersSize: 100,
        bodySize: 0,
      ),
      response: const HarResponse(
        status: 200,
        statusText: 'OK',
        content: HarContent(size: 1024, mimeType: 'text/html'),
        redirectURL: '',
        headersSize: 200,
        bodySize: 1024,
      ),
      cache: const HarCache(),
      timings: const HarTimings(send: 50, wait: 100, receive: 75),
    );

    test('wraps base entry with default request/response conversion', () {
      final devEntry = DevToolsHarEntry.fromHarEntry(baseEntry);

      expect(devEntry.startedDateTime, baseEntry.startedDateTime);
      expect(devEntry.totalTime, baseEntry.totalTime);
      expect(devEntry.request, isA<DevToolsHarRequest>());
      expect(devEntry.response, isA<DevToolsHarResponse>());
      expect(devEntry.request.url, baseEntry.request.url);
      expect(devEntry.response.status, 200);
    });

    test('preserves all DevTools-specific fields', () {
      final devEntry = DevToolsHarEntry.fromHarEntry(
        baseEntry,
        fromCache: 'disk',
        fromServiceWorker: true,
        initiator: const {'type': 'script', 'url': 'https://example.com'},
        priority: 'High',
        resourceType: 'document',
        webSocketMessages: const [{'data': 'hello', 'type': 'send'}],
      );

      expect(devEntry.fromCache, 'disk');
      expect(devEntry.fromServiceWorker, isTrue);
      expect(devEntry.initiator?['type'], 'script');
      expect(devEntry.priority, 'High');
      expect(devEntry.resourceType, 'document');
      expect(devEntry.webSocketMessages, hasLength(1));
    });

    test('uses provided request and response when given', () {
      final devRequest = DevToolsHarRequest.fromHarRequest(
        baseEntry.request,
      );
      final devResponse = DevToolsHarResponse.fromHarResponse(
        baseEntry.response,
        transferSize: 512,
        error: 'net::ERR_CONNECTION_RESET',
      );

      final devEntry = DevToolsHarEntry.fromHarEntry(
        baseEntry,
        request: devRequest,
        response: devResponse,
      );

      expect(devEntry.request, same(devRequest));
      expect(devEntry.response, same(devResponse));
      // ignore: avoid-type-casts, it's a test.
      expect((devEntry.response as DevToolsHarResponse).transferSize, 512);
    });

    test('fromServiceWorker false is preserved', () {
      final devEntry = DevToolsHarEntry.fromHarEntry(
        baseEntry,
        fromServiceWorker: false,
      );

      expect(devEntry.fromServiceWorker, isFalse);
    });
  });
}
