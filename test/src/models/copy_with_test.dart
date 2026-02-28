// ignore_for_file: prefer-class-destructuring, no-equal-arguments

import 'package:devtools_har/devtools_har.dart';
import 'package:test/test.dart';

// ignore: avoid-long-functions, it's a test...
void main() {
  // ignore: avoid-long-functions, it's a test...
  group('copyWith - base leaf classes', () {
    group('HarHeader', () {
      const original = HarHeader(
        name: 'Content-Type',
        value: 'text/html',
        comment: 'a comment',
        custom: {'_x': 1},
      );

      test('returns identical copy when no arguments given', () {
        final copy = original.copyWith();
        expect(copy.name, original.name);
        expect(copy.value, original.value);
        expect(copy.comment, original.comment);
        expect(copy.custom, original.custom);
      });

      test('replaces only specified fields', () {
        final copy = original.copyWith(name: 'Accept');
        expect(copy.name, 'Accept');
        expect(copy.value, original.value);
        expect(copy.comment, original.comment);
      });

      test('replaces all fields', () {
        final copy = original.copyWith(
          name: 'X-New',
          value: 'val',
          comment: 'new',
          custom: {'_y': 2},
        );
        expect(copy.name, 'X-New');
        expect(copy.value, 'val');
        expect(copy.comment, 'new');
        expect(copy.custom, {'_y': 2});
      });
    });

    group('HarQueryParam', () {
      const original = HarQueryParam(name: 'q', value: 'dart');

      test('returns identical copy when no arguments given', () {
        final copy = original.copyWith();
        expect(copy.name, 'q');
        expect(copy.value, 'dart');
      });

      test('replaces specified fields', () {
        final copy = original.copyWith(value: 'flutter');
        expect(copy.name, 'q');
        expect(copy.value, 'flutter');
      });
    });

    group('HarNameVersion (HarCreator / HarBrowser)', () {
      const original = HarCreator(name: 'App', version: '1.0');

      test('returns identical copy when no arguments given', () {
        final copy = original.copyWith();
        expect(copy.name, 'App');
        expect(copy.version, '1.0');
      });

      test('replaces specified fields', () {
        final copy = original.copyWith(version: '2.0');
        expect(copy.name, 'App');
        expect(copy.version, '2.0');
      });
    });

    group('HarContent', () {
      const original = HarContent(
        size: 1024,
        mimeType: 'text/html',
        compression: 100,
        text: 'body',
        encoding: 'utf-8',
        comment: 'c',
      );

      test('returns identical copy when no arguments given', () {
        final copy = original.copyWith();
        expect(copy.size, 1024);
        expect(copy.mimeType, 'text/html');
        expect(copy.compression, 100);
        expect(copy.text, 'body');
        expect(copy.encoding, 'utf-8');
        expect(copy.comment, 'c');
      });

      test('replaces only specified fields', () {
        final copy = original.copyWith(size: 2048, text: 'new body');
        expect(copy.size, 2048);
        expect(copy.text, 'new body');
        expect(copy.mimeType, 'text/html');
      });
    });

    group('HarPageTimings', () {
      const original = HarPageTimings(onContentLoad: 500, onLoad: 3200);

      test('returns identical copy when no arguments given', () {
        final copy = original.copyWith();
        expect(copy.onContentLoad, 500);
        expect(copy.onLoad, 3200);
      });

      test('replaces specified fields', () {
        final copy = original.copyWith(onLoad: 1000);
        expect(copy.onContentLoad, 500);
        expect(copy.onLoad, 1000);
      });
    });

    group('HarParam', () {
      const original = HarParam(
        name: 'file',
        value: 'data',
        fileName: 'test.txt',
        contentType: 'text/plain',
      );

      test('returns identical copy when no arguments given', () {
        final copy = original.copyWith();
        expect(copy.name, 'file');
        expect(copy.value, 'data');
        expect(copy.fileName, 'test.txt');
        expect(copy.contentType, 'text/plain');
      });

      test('replaces specified fields', () {
        final copy = original.copyWith(fileName: 'new.txt');
        expect(copy.name, 'file');
        expect(copy.fileName, 'new.txt');
      });
    });

    group('HarPostData', () {
      const original = HarPostData(
        mimeType: 'application/json',
        text: '{"key":"value"}',
        params: [HarParam(name: 'a')],
      );

      test('returns identical copy when no arguments given', () {
        final copy = original.copyWith();
        expect(copy.mimeType, 'application/json');
        expect(copy.text, '{"key":"value"}');
        expect(copy.params, hasLength(1));
      });

      test('replaces specified fields', () {
        final copy = original.copyWith(mimeType: 'text/plain', params: []);
        expect(copy.mimeType, 'text/plain');
        expect(copy.params, isEmpty);
        expect(copy.text, '{"key":"value"}');
      });
    });
  });

  // ignore: avoid-long-functions, it's a test...
  group('copyWith - base composite classes', () {
    group('HarCookie', () {
      final original = HarCookie(
        name: 'sid',
        value: 'abc',
        path: '/',
        domain: 'example.com',
        expires: DateTime.utc(2026),
        httpOnly: true,
        secure: false,
      );

      test('returns identical copy when no arguments given', () {
        final copy = original.copyWith();
        expect(copy.name, 'sid');
        expect(copy.value, 'abc');
        expect(copy.path, '/');
        expect(copy.domain, 'example.com');
        expect(copy.expires, DateTime.utc(2026));
        expect(copy.httpOnly, true);
        expect(copy.secure, false);
      });

      test('replaces specified fields', () {
        final copy = original.copyWith(name: 'token', secure: true);
        expect(copy.name, 'token');
        expect(copy.value, 'abc');
        expect(copy.secure, true);
      });
    });

    group('HarCacheEntry', () {
      final original = HarCacheEntry(
        lastAccess: DateTime.utc(2025),
        lastAccessRaw: '2025-01-01T00:00:00.000Z',
        eTag: '"abc"',
        hitCount: 3,
        expires: DateTime.utc(2026),
      );

      test('returns identical copy when no arguments given', () {
        final copy = original.copyWith();
        expect(copy.lastAccess, DateTime.utc(2025));
        expect(copy.lastAccessRaw, '2025-01-01T00:00:00.000Z');
        expect(copy.eTag, '"abc"');
        expect(copy.hitCount, 3);
        expect(copy.expires, DateTime.utc(2026));
      });

      test('replaces specified fields', () {
        final copy = original.copyWith(hitCount: 10, eTag: '"def"');
        expect(copy.hitCount, 10);
        expect(copy.eTag, '"def"');
        expect(copy.lastAccess, DateTime.utc(2025));
      });
    });

    group('HarCache', () {
      final entry = HarCacheEntry(
        lastAccess: DateTime.utc(2025),
        eTag: '"x"',
        hitCount: 1,
      );
      final original = HarCache(beforeRequest: entry);

      test('returns identical copy when no arguments given', () {
        final copy = original.copyWith();
        expect(copy.beforeRequest?.eTag, '"x"');
        expect(copy.afterRequest, isNull);
      });

      test('replaces specified fields', () {
        final after = HarCacheEntry(
          lastAccess: DateTime.utc(2026),
          eTag: '"y"',
          hitCount: 5,
        );
        final copy = original.copyWith(afterRequest: after);
        expect(copy.beforeRequest?.eTag, '"x"');
        expect(copy.afterRequest?.eTag, '"y"');
      });
    });

    group('HarTimings', () {
      const original = HarTimings(
        send: 10,
        wait: 200,
        receive: 50,
        blocked: 5,
        dns: 3,
        connect: 20,
        ssl: 15,
        comment: 'timing',
      );

      test('returns identical copy when no arguments given', () {
        final copy = original.copyWith();
        expect(copy.send, 10.0);
        expect(copy.wait, 200.0);
        expect(copy.receive, 50.0);
        expect(copy.blocked, 5.0);
        expect(copy.dns, 3.0);
        expect(copy.connect, 20.0);
        expect(copy.ssl, 15.0);
        expect(copy.comment, 'timing');
      });

      test('replaces specified fields', () {
        final copy = original.copyWith(wait: 100, ssl: 30);
        expect(copy.wait, 100.0);
        expect(copy.ssl, 30.0);
        expect(copy.send, 10.0);
      });
    });

    group('HarPage', () {
      final original = HarPage(
        startedDateTime: DateTime.utc(2025),
        id: 'page_1',
        title: 'Home',
        pageTimings: const HarPageTimings(onLoad: 3200),
      );

      test('returns identical copy when no arguments given', () {
        final copy = original.copyWith();
        expect(copy.startedDateTime, DateTime.utc(2025));
        expect(copy.id, 'page_1');
        expect(copy.title, 'Home');
        expect(copy.pageTimings.onLoad, 3200);
      });

      test('replaces specified fields', () {
        final copy = original.copyWith(
          title: 'About',
          pageTimings: const HarPageTimings(onLoad: 1000),
        );
        expect(copy.title, 'About');
        expect(copy.pageTimings.onLoad, 1000);
        expect(copy.id, 'page_1');
      });
    });
  });

  // ignore: avoid-long-functions, it's a test...
  group('copyWith - base top-level generic classes', () {
    group('HarRequest', () {
      final original = HarRequest(
        url: Uri.parse('https://example.com'),
        headersSize: 120,
        bodySize: 0,
        method: HttpMethod.post,
        headers: const [HarHeader(name: 'X-A', value: '1')],
      );

      test('returns identical copy when no arguments given', () {
        final copy = original.copyWith();
        expect(copy.url, Uri.parse('https://example.com'));
        expect(copy.headersSize, 120);
        expect(copy.bodySize, 0);
        expect(copy.method, HttpMethod.post);
        expect(copy.headers, hasLength(1));
      });

      test('replaces specified fields', () {
        final copy = original.copyWith(method: HttpMethod.get, bodySize: 512);
        expect(copy.method, HttpMethod.get);
        expect(copy.bodySize, 512);
        expect(copy.url, Uri.parse('https://example.com'));
        expect(copy.headers, hasLength(1));
      });
    });

    group('HarResponse', () {
      const original = HarResponse(
        status: 200,
        statusText: 'OK',
        content: HarContent(size: 1024),
        redirectURL: '',
        headersSize: 100,
        bodySize: 1024,
      );

      test('returns identical copy when no arguments given', () {
        final copy = original.copyWith();
        expect(copy.status, 200);
        expect(copy.statusText, 'OK');
        expect(copy.content.size, 1024);
        expect(copy.headersSize, 100);
      });

      test('replaces specified fields', () {
        final copy = original.copyWith(status: 404, statusText: 'Not Found');
        expect(copy.status, 404);
        expect(copy.statusText, 'Not Found');
        expect(copy.content.size, 1024);
      });
    });

    group('HarEntry', () {
      final original = HarEntry(
        startedDateTime: DateTime.utc(2025),
        totalTime: 260,
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
        timings: const HarTimings(send: 10, wait: 200, receive: 50),
        pageref: 'page_1',
        serverIPAddress: '1.2.3.4',
      );

      test('returns identical copy when no arguments given', () {
        final copy = original.copyWith();
        expect(copy.startedDateTime, DateTime.utc(2025));
        expect(copy.totalTime, 260.0);
        expect(copy.pageref, 'page_1');
        expect(copy.serverIPAddress, '1.2.3.4');
      });

      test('replaces specified fields', () {
        final copy = original.copyWith(
          totalTime: 500,
          pageref: 'page_2',
          comment: 'edited',
        );
        expect(copy.totalTime, 500.0);
        expect(copy.pageref, 'page_2');
        expect(copy.comment, 'edited');
        expect(copy.serverIPAddress, '1.2.3.4');
      });
    });

    group('HarLog', () {
      const original = HarLog(
        creator: HarCreator(name: 'App', version: '1.0'),
      );

      test('returns identical copy when no arguments given', () {
        final copy = original.copyWith();
        expect(copy.creator.name, 'App');
        expect(copy.version, '1.2');
        expect(copy.entries, isEmpty);
      });

      test('replaces specified fields', () {
        final copy = original.copyWith(
          version: '1.1',
          browser: const HarBrowser(name: 'Chrome', version: '120'),
        );
        expect(copy.version, '1.1');
        expect(copy.browser?.name, 'Chrome');
        expect(copy.creator.name, 'App');
      });
    });

    group('HarRoot', () {
      const original = HarRoot(
        log: HarLog(
          creator: HarCreator(
            name: 'App',
            version: '1.0', // Dart 3.8 formatting.
          ),
        ),
      );

      test('returns identical copy when no arguments given', () {
        final copy = original.copyWith();
        expect(copy.log.creator.name, 'App');
        expect(copy.comment, isNull);
      });

      test('replaces specified fields', () {
        final copy = original.copyWith(comment: 'root comment');
        expect(copy.comment, 'root comment');
        expect(copy.log.creator.name, 'App');
      });
    });
  });

  // ignore: avoid-long-functions, it's a test...
  group('copyWith - DevTools classes', () {
    group('DevToolsHarCookie', () {
      const original = DevToolsHarCookie(
        name: 'sid',
        value: 'abc',
        sameSite: CookieSameSite.lax,
        secure: true,
      );

      test('returns identical copy when no arguments given', () {
        final copy = original.copyWith();
        expect(copy.name, 'sid');
        expect(copy.value, 'abc');
        expect(copy.sameSite, CookieSameSite.lax);
        expect(copy.secure, true);
      });

      test('replaces specified fields including sameSite', () {
        final copy = original.copyWith(
          sameSite: CookieSameSite.strict,
          name: 'token',
        );
        expect(copy.sameSite, CookieSameSite.strict);
        expect(copy.name, 'token');
        expect(copy.value, 'abc');
      });

      test('returns DevToolsHarCookie type', () {
        expect(original.copyWith(), isA<DevToolsHarCookie>());
      });
    });

    group('DevToolsHarTimings', () {
      const original = DevToolsHarTimings(
        send: 10,
        wait: 200,
        receive: 50,
        blockedQueueing: 5.2,
        blockedProxy: 1.1,
      );

      test('returns identical copy when no arguments given', () {
        final copy = original.copyWith();
        expect(copy.send, 10.0);
        expect(copy.wait, 200.0);
        expect(copy.receive, 50.0);
        expect(copy.blockedQueueing, 5.2);
        expect(copy.blockedProxy, 1.1);
      });

      test('replaces specified fields including DevTools extras', () {
        final copy = original.copyWith(blockedQueueing: 10, wait: 100);
        expect(copy.blockedQueueing, 10.0);
        expect(copy.wait, 100.0);
        expect(copy.send, 10.0);
        expect(copy.blockedProxy, 1.1);
      });

      test('returns DevToolsHarTimings type', () {
        expect(original.copyWith(), isA<DevToolsHarTimings>());
      });
    });

    group('DevToolsHarRequest', () {
      final original = DevToolsHarRequest(
        url: Uri.parse('https://example.com'),
        headersSize: 120,
        bodySize: 0,
        method: HttpMethod.post,
      );

      test('returns identical copy when no arguments given', () {
        final copy = original.copyWith();
        expect(copy.url, Uri.parse('https://example.com'));
        expect(copy.method, HttpMethod.post);
        expect(copy.headersSize, 120);
      });

      test('replaces specified fields', () {
        final copy = original.copyWith(method: HttpMethod.put, bodySize: 256);
        expect(copy.method, HttpMethod.put);
        expect(copy.bodySize, 256);
        expect(copy.url, Uri.parse('https://example.com'));
      });

      test('returns DevToolsHarRequest type', () {
        expect(original.copyWith(), isA<DevToolsHarRequest>());
      });
    });

    group('DevToolsHarResponse', () {
      const original = DevToolsHarResponse(
        status: 200,
        statusText: 'OK',
        httpVersion: 'h2',
        content: HarContent(size: 1024),
        redirectURL: '',
        headersSize: 100,
        bodySize: 1024,
        transferSize: 512,
      );

      test('returns identical copy when no arguments given', () {
        final copy = original.copyWith();
        expect(copy.status, 200);
        expect(copy.transferSize, 512);
        expect(copy.error, isNull);
      });

      test('replaces specified fields including DevTools extras', () {
        final copy = original.copyWith(
          transferSize: 256,
          error: 'net::ERR_FAILED',
        );
        expect(copy.transferSize, 256);
        expect(copy.error, 'net::ERR_FAILED');
        expect(copy.status, 200);
      });

      test('returns DevToolsHarResponse type', () {
        expect(original.copyWith(), isA<DevToolsHarResponse>());
      });
    });

    group('DevToolsHarEntry', () {
      final original = DevToolsHarEntry(
        startedDateTime: DateTime.utc(2025),
        totalTime: 260,
        request: DevToolsHarRequest(url: Uri(), headersSize: -1, bodySize: -1),
        response: const DevToolsHarResponse(
          status: 200,
          statusText: 'OK',
          httpVersion: 'h2',
          content: HarContent(size: 0),
          redirectURL: '',
          headersSize: -1,
          bodySize: -1,
        ),
        cache: const HarCache(),
        timings: const DevToolsHarTimings(send: 10, wait: 200, receive: 50),
        pageref: 'page_1',
        resourceType: 'document',
        priority: 'High',
        fromCache: 'disk',
        webSocketMessages: [
          {'data': 'hello', 'type': 'send'},
        ],
      );

      test('returns identical copy when no arguments given', () {
        final copy = original.copyWith();
        expect(copy.startedDateTime, DateTime.utc(2025));
        expect(copy.totalTime, 260.0);
        expect(copy.resourceType, 'document');
        expect(copy.priority, 'High');
        expect(copy.fromCache, 'disk');
        expect(copy.pageref, 'page_1');
        expect(copy.webSocketMessages, hasLength(1));
      });

      test('replaces specified fields including DevTools extras', () {
        final copy = original.copyWith(
          resourceType: 'script',
          priority: 'Low',
          fromServiceWorker: true,
        );
        expect(copy.resourceType, 'script');
        expect(copy.priority, 'Low');
        expect(copy.fromServiceWorker, true);
        expect(copy.fromCache, 'disk');
        expect(copy.totalTime, 260.0);
      });

      test('returns DevToolsHarEntry type', () {
        expect(original.copyWith(), isA<DevToolsHarEntry>());
      });
    });

    group('DevToolsHarLog', () {
      const original = DevToolsHarLog(
        version: '1.2',
        creator: HarCreator(name: 'Chrome', version: '120'),
      );

      test('returns identical copy when no arguments given', () {
        final copy = original.copyWith();
        expect(copy.version, '1.2');
        expect(copy.creator.name, 'Chrome');
        expect(copy.entries, isEmpty);
      });

      test('replaces specified fields', () {
        final copy = original.copyWith(
          version: '1.1',
          browser: const HarBrowser(name: 'Firefox', version: '115'),
        );
        expect(copy.version, '1.1');
        expect(copy.browser?.name, 'Firefox');
        expect(copy.creator.name, 'Chrome');
      });

      test('returns DevToolsHarLog type', () {
        expect(original.copyWith(), isA<DevToolsHarLog>());
      });
    });

    group('DevToolsHarRoot', () {
      const original = DevToolsHarRoot(
        log: DevToolsHarLog(
          version: '1.2',
          creator: HarCreator(name: 'Chrome', version: '120'),
        ),
      );

      test('returns identical copy when no arguments given', () {
        final copy = original.copyWith();
        expect(copy.log.creator.name, 'Chrome');
        expect(copy.comment, isNull);
      });

      test('replaces specified fields', () {
        final copy = original.copyWith(comment: 'root comment');
        expect(copy.comment, 'root comment');
        expect(copy.log.creator.name, 'Chrome');
      });

      test('returns DevToolsHarRoot type', () {
        expect(original.copyWith(), isA<DevToolsHarRoot>());
      });
    });
  });
}
