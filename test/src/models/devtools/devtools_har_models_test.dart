// ignore_for_file: avoid-long-functions, prefer-class-destructuring
// ignore_for_file: avoid-unsafe-collection-methods, prefer-moving-to-variable
// ignore_for_file: no-equal-arguments

import 'package:devtools_har/src/models/base/har_cache.dart';
import 'package:devtools_har/src/models/base/har_content.dart';
import 'package:devtools_har/src/models/base/har_cookie.dart';
import 'package:devtools_har/src/models/base/har_entry.dart';
import 'package:devtools_har/src/models/base/har_header.dart';
import 'package:devtools_har/src/models/base/har_log.dart';
import 'package:devtools_har/src/models/base/har_name_version.dart';
import 'package:devtools_har/src/models/base/har_query_param.dart';
import 'package:devtools_har/src/models/base/har_request.dart';
import 'package:devtools_har/src/models/base/har_response.dart';
import 'package:devtools_har/src/models/base/har_timings.dart';
import 'package:devtools_har/src/models/base/http_method.dart';
import 'package:devtools_har/src/models/devtools/devtools_har_cookie.dart';
import 'package:devtools_har/src/models/devtools/devtools_har_entry.dart';
import 'package:devtools_har/src/models/devtools/devtools_har_log.dart';
import 'package:devtools_har/src/models/devtools/devtools_har_request.dart';
import 'package:devtools_har/src/models/devtools/devtools_har_response.dart';
import 'package:devtools_har/src/models/devtools/devtools_har_timings.dart';
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
        cookies: const [HarCookie(name: 'sid', value: 'abc')],
      ),
      response: const HarResponse(
        status: 200,
        statusText: 'OK',
        content: HarContent(size: 1024, mimeType: 'text/html'),
        redirectURL: '',
        headersSize: 200,
        bodySize: 1024,
        cookies: [HarCookie(name: 'lang', value: 'en')],
      ),
      cache: const HarCache(),
      timings: const HarTimings(send: 50, wait: 100, receive: 75),
      custom: const {'_entryExtra': 'data'},
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

    test('preserves custom from base entry by default', () {
      final devEntry = DevToolsHarEntry.fromHarEntry(baseEntry);
      expect(devEntry.custom, {'_entryExtra': 'data'});
    });

    test('converts cookies in request and response by default', () {
      final devEntry = DevToolsHarEntry.fromHarEntry(baseEntry);
      expect(devEntry.request.cookies.single, isA<DevToolsHarCookie>());
      expect(devEntry.request.cookies.single.name, 'sid');
      expect(devEntry.response.cookies, hasLength(1));
      expect(devEntry.response.cookies.single, isA<DevToolsHarCookie>());
      expect(devEntry.response.cookies.single.name, 'lang');
    });

    test('preserves all DevTools-specific fields', () {
      final devEntry = DevToolsHarEntry.fromHarEntry(
        baseEntry,
        fromCache: 'disk',
        fromServiceWorker: true,
        initiator: const {'type': 'script', 'url': 'https://example.com'},
        priority: 'High',
        resourceType: 'document',
        webSocketMessages: const [
          {'data': 'hello', 'type': 'send'},
        ],
      );

      expect(devEntry.fromCache, 'disk');
      expect(devEntry.fromServiceWorker, isTrue);
      expect(devEntry.initiator?['type'], 'script');
      expect(devEntry.priority, 'High');
      expect(devEntry.resourceType, 'document');
      expect(devEntry.webSocketMessages, hasLength(1));
    });

    test('uses provided request and response when given', () {
      final devRequest = DevToolsHarRequest.fromHarRequest(baseEntry.request);
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

  group('DevToolsHarRequest.fromHarRequest', () {
    test('preserves all base fields including cookies and custom', () {
      final base = HarRequest(
        method: HttpMethod.post,
        url: Uri.parse('https://example.com/api'),
        httpVersion: 'HTTP/2',
        cookies: const [
          HarCookie(name: 'sid', value: 'abc123'),
          HarCookie(name: 'lang', value: 'en'),
        ],
        headers: const [HarHeader(name: 'Accept', value: 'application/json')],
        queryString: const [HarQueryParam(name: 'q', value: 'dart')],
        headersSize: 120,
        bodySize: 42,
        comment: 'test request',
        custom: const {'_extra': 'value'},
      );

      final converted = DevToolsHarRequest.fromHarRequest(base);

      expect(converted, isA<DevToolsHarRequest>());
      expect(converted.method, HttpMethod.post);
      expect(converted.url, Uri.parse('https://example.com/api'));
      expect(converted.httpVersion, 'HTTP/2');
      expect(converted.cookies, hasLength(2));
      expect(converted.cookies.first, isA<DevToolsHarCookie>());
      expect(converted.cookies.first.name, 'sid');
      expect(converted.cookies.last.name, 'lang');
      expect(converted.headers.single.name, 'Accept');
      expect(converted.queryString.single.name, 'q');
      expect(converted.headersSize, 120);
      expect(converted.bodySize, 42);
      expect(converted.comment, 'test request');
      expect(converted.custom, {'_extra': 'value'});
    });

    test('substitutes cookies with DevToolsHarCookie when provided', () {
      final base = HarRequest(
        url: Uri.parse('https://example.com'),
        headersSize: -1,
        bodySize: -1,
        cookies: const [HarCookie(name: 'sid', value: 'abc')],
      );

      final devCookies = [
        DevToolsHarCookie.fromHarCookie(
          const HarCookie(name: 'sid', value: 'abc'),
        ),
      ];

      final converted = DevToolsHarRequest.fromHarRequest(
        base,
        cookies: devCookies,
      );

      expect(converted.cookies.single, isA<DevToolsHarCookie>());
      expect(converted.cookies.single.name, 'sid');
    });

    test('preserves custom fields when provided', () {
      final base = HarRequest(
        url: Uri(),
        headersSize: -1,
        bodySize: -1,
        custom: const {'_original': 'kept'},
      );

      final converted = DevToolsHarRequest.fromHarRequest(
        base,
        custom: const {'_override': 'new'},
      );

      expect(converted.custom, {'_override': 'new'});
    });
  });

  group('DevToolsHarResponse.fromHarResponse', () {
    test('preserves cookies and custom from base by default', () {
      const base = HarResponse(
        status: 200,
        statusText: 'OK',
        content: HarContent(size: 0),
        redirectURL: '',
        headersSize: -1,
        bodySize: -1,
        cookies: [HarCookie(name: 'sid', value: 'abc')],
        headers: [HarHeader(name: 'X-Custom', value: 'val')],
        custom: {'_extra': 'data'},
      );

      final converted = DevToolsHarResponse.fromHarResponse(base);

      expect(converted.status, 200);
      expect(converted.cookies.single, isA<DevToolsHarCookie>());
      expect(converted.cookies.single.name, 'sid');
      expect(converted.headers, hasLength(1));
      expect(converted.custom, {'_extra': 'data'});
    });

    test('uses provided cookies when given', () {
      const base = HarResponse(
        status: 200,
        statusText: 'OK',
        content: HarContent(size: 0),
        redirectURL: '',
        headersSize: -1,
        bodySize: -1,
        cookies: [HarCookie(name: 'old', value: 'x')],
      );

      final converted = DevToolsHarResponse.fromHarResponse(
        base,
        cookies: const [DevToolsHarCookie(name: 'new', value: 'y')],
      );

      expect(converted.cookies.single.name, 'new');
    });
  });

  group('DevToolsHarTimings.fromHarTimings', () {
    test('preserves custom from base by default', () {
      const base = HarTimings(
        send: 10,
        wait: 200,
        receive: 50,
        custom: {'_timingExtra': 42},
      );

      final converted = DevToolsHarTimings.fromHarTimings(base);

      expect(converted.send, 10);
      expect(converted.wait, 200);
      expect(converted.receive, 50);
      expect(converted.custom, {'_timingExtra': 42});
    });

    test('uses provided custom when given', () {
      const base = HarTimings(
        send: 10,
        wait: 200,
        receive: 50,
        custom: {'_old': 1},
      );

      final converted = DevToolsHarTimings.fromHarTimings(
        base,
        custom: const {'_new': 2},
      );

      expect(converted.custom, {'_new': 2});
    });
  });

  group('DevToolsHarLog.fromHarLog', () {
    test('converts entries and preserves custom from base by default', () {
      final baseLog = HarLog(
        creator: const HarCreator(name: 'test', version: '1'),
        entries: [
          HarEntry(
            startedDateTime: DateTime.utc(2025),
            totalTime: 100,
            request: HarRequest(
              url: Uri.parse('https://example.com'),
              headersSize: -1,
              bodySize: -1,
            ),
            response: const HarResponse(
              status: 200,
              statusText: 'OK',
              content: HarContent(size: 0),
              redirectURL: '',
              headersSize: -1,
              bodySize: -1,
            ),
            cache: const HarCache(),
            timings: const HarTimings(send: 10, wait: 50, receive: 40),
          ),
        ],
        custom: const {'_logExtra': 'meta'},
      );

      final converted = DevToolsHarLog.fromHarLog(baseLog);

      expect(converted.version, '1.2');
      expect(converted.entries.single, isA<DevToolsHarEntry>());
      expect(
        converted.entries.single.request.url,
        Uri.parse('https://example.com'),
      );
      expect(converted.custom, {'_logExtra': 'meta'});
    });

    test('uses provided entries when given', () {
      final baseLog = HarLog(
        creator: const HarCreator(name: 'test', version: '1'),
        entries: [
          HarEntry(
            startedDateTime: DateTime.utc(2025),
            totalTime: 100,
            request: HarRequest(url: Uri(), headersSize: -1, bodySize: -1),
            response: const HarResponse(
              status: 200,
              statusText: 'OK',
              content: HarContent(size: 0),
              redirectURL: '',
              headersSize: -1,
              bodySize: -1,
            ),
            cache: const HarCache(),
            timings: const HarTimings(send: 0, wait: 0, receive: 0),
          ),
        ],
      );

      final converted = DevToolsHarLog.fromHarLog(baseLog, entries: const []);

      expect(converted.entries, isEmpty);
    });
  });
}
