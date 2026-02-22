import 'package:devtools_har/devtools_har.dart';
import 'package:test/test.dart';

void main() {
  group('toString() overrides', () {
    test('HarCookie', () {
      const cookie = HarCookie(name: 'foo', value: 'bar', path: '/');
      expect(cookie.toString(), contains('HarCookie(name: foo, value: bar, path: /)'));

      const cookieMinimal = HarCookie(name: 'foo', value: 'bar');
      expect(cookieMinimal.toString(), 'HarCookie(name: foo, value: bar)');
    });

    test('HarHeader', () {
      const header = HarHeader(name: 'Content-Type', value: 'text/plain');
      expect(header.toString(), 'HarHeader(name: Content-Type, value: text/plain)');
    });

    test('HarQueryParam', () {
      const param = HarQueryParam(name: 'q', value: 'dart');
      expect(param.toString(), 'HarQueryParam(name: q, value: dart)');
    });

    test('HarPostData and HarParam', () {
      const param = HarParam(name: 'foo', value: 'bar');
      const postData = HarPostData(mimeType: 'application/x-www-form-urlencoded', params: [param]);
      expect(param.toString(), 'HarParam(name: foo, value: bar)');
      expect(postData.toString(), contains('HarPostData(mimeType: application/x-www-form-urlencoded, params: [HarParam(name: foo, value: bar)])'));
    });

    test('HarContent', () {
      const content = HarContent(size: 100, mimeType: 'text/plain', text: 'hello');
      expect(content.toString(), 'HarContent(size: 100, mimeType: text/plain, text: hello)');
    });

    test('HarCache and HarCacheEntry', () {
      final now = DateTime.now();
      final cacheEntry = HarCacheEntry(lastAccess: now, eTag: 'abc', hitCount: 5);
      final cache = HarCache(beforeRequest: cacheEntry);
      expect(cacheEntry.toString(), contains('HarCacheEntry('));
      expect(cacheEntry.toString(), contains('lastAccess: $now'));
      expect(cacheEntry.toString(), contains('eTag: abc'));
      expect(cacheEntry.toString(), contains('hitCount: 5'));
      expect(cache.toString(), contains('HarCache(beforeRequest: HarCacheEntry('));
    });

    test('HarTimings', () {
      const timings = HarTimings(send: 1.0, wait: 2.0, receive: 3.0, dns: 0.5);
      expect(timings.toString(), 'HarTimings(dns: 0.5, send: 1.0, wait: 2.0, receive: 3.0)');
    });

    test('HarPage and HarPageTimings', () {
      final now = DateTime.now();
      const pageTimings = HarPageTimings(onLoad: 1000.0);
      final page = HarPage(startedDateTime: now, id: 'page1', title: 'Page 1', pageTimings: pageTimings);
      expect(pageTimings.toString(), 'HarPageTimings(onLoad: 1000.0)');
      expect(page.toString(), contains('HarPage(startedDateTime: $now, id: page1, title: Page 1, pageTimings: HarPageTimings(onLoad: 1000.0))'));
    });

    test('HarRequest', () {
      final url = Uri.parse('https://example.com');
      final request = HarRequest(url: url, headersSize: 100, bodySize: 0, method: HttpMethod.get);
      expect(request.toString(), contains('HarRequest(method: HttpMethod.get, url: https://example.com, httpVersion: HTTP/1.1, cookies: [], headers: [], queryString: [], headersSize: 100, bodySize: 0)'));
    });

    test('HarResponse', () {
      const content = HarContent(size: 0, mimeType: 'text/plain');
      const response = HarResponse(status: 200, statusText: 'OK', content: content, redirectURL: '', headersSize: 50, bodySize: 0);
      expect(response.toString(), contains('HarResponse(status: 200, statusText: OK, httpVersion: HTTP/1.1, cookies: [], headers: [], content: HarContent(size: 0, mimeType: text/plain), redirectURL: , headersSize: 50, bodySize: 0)'));
    });

    test('HarEntry', () {
      final now = DateTime.now();
      final request = HarRequest(url: Uri.parse('https://example.com'), headersSize: 0, bodySize: 0);
      final response = HarResponse(status: 200, statusText: 'OK', content: const HarContent(size: 0, mimeType: 'text/plain'), redirectURL: '', headersSize: 0, bodySize: 0);
      final entry = HarEntry(startedDateTime: now, totalTime: 100.0, request: request, response: response, cache: const HarCache(), timings: const HarTimings(send: 0, wait: 0, receive: 0));
      expect(entry.toString(), contains('HarEntry('));
      expect(entry.toString(), contains('startedDateTime: $now'));
      expect(entry.toString(), contains('request: HarRequest('));
    });

    test('HarLog and HarNameVersion', () {
      const creator = HarCreator(name: 'Tool', version: '1.0');
      const log = HarLog(creator: creator, version: '1.2', entries: <HarEntry>[]);
      expect(creator.toString(), 'HarNameVersion(name: Tool, version: 1.0)');
      expect(log.toString(), 'HarLog(version: 1.2, creator: HarNameVersion(name: Tool, version: 1.0), entries: [])');
    });

    test('HarRoot', () {
      const creator = HarCreator(name: 'Tool', version: '1.0');
      const log = HarLog(creator: creator, version: '1.2', entries: <HarEntry>[]);
      const root = HarRoot(log: log);
      expect(root.toString(), 'HarRoot(log: HarLog(version: 1.2, creator: HarNameVersion(name: Tool, version: 1.0), entries: []))');
    });

    test('DevToolsHarCookie', () {
      const cookie = DevToolsHarCookie(name: 'foo', value: 'bar', sameSite: CookieSameSite.lax);
      expect(cookie.toString(), 'DevToolsHarCookie(name: foo, value: bar, sameSite: CookieSameSite.lax)');
    });

    test('DevToolsHarTimings', () {
      const timings = DevToolsHarTimings(send: 1.0, wait: 2.0, receive: 3.0, blockedQueueing: 0.1);
      expect(timings.toString(), 'DevToolsHarTimings(send: 1.0, wait: 2.0, receive: 3.0, _blocked_queueing: 0.1)');
    });

    test('DevToolsHarRequest', () {
      final url = Uri.parse('https://example.com');
      final request = DevToolsHarRequest(url: url, headersSize: 100, bodySize: 0);
      expect(request.toString(), contains('DevToolsHarRequest('));
    });

    test('DevToolsHarResponse', () {
      const content = HarContent(size: 0, mimeType: 'text/plain');
      const response = DevToolsHarResponse(status: 200, statusText: 'OK', httpVersion: 'HTTP/1.1', content: content, redirectURL: '', headersSize: 50, bodySize: 0, transferSize: 150);
      expect(response.toString(), contains('DevToolsHarResponse('));
      expect(response.toString(), contains('transferSize: 150'));
    });

    test('DevToolsHarEntry', () {
      final now = DateTime.now();
      final request = DevToolsHarRequest(url: Uri.parse('https://example.com'), headersSize: 0, bodySize: 0);
      final response = DevToolsHarResponse(status: 200, statusText: 'OK', httpVersion: 'HTTP/1.1', content: const HarContent(size: 0, mimeType: 'text/plain'), redirectURL: '', headersSize: 0, bodySize: 0);
      final entry = DevToolsHarEntry(startedDateTime: now, totalTime: 100.0, request: request, response: response, cache: const HarCache(), timings: const DevToolsHarTimings(send: 0, wait: 0, receive: 0), priority: 'High');
      expect(entry.toString(), contains('DevToolsHarEntry('));
      expect(entry.toString(), contains('priority: High'));
    });

    test('DevToolsHarLog', () {
      const creator = HarCreator(name: 'Tool', version: '1.0');
      const log = DevToolsHarLog(version: '1.2', creator: creator, entries: <DevToolsHarEntry>[]);
      expect(log.toString(), contains('DevToolsHarLog('));
    });

    test('DevToolsHarRoot', () {
      const creator = HarCreator(name: 'Tool', version: '1.0');
      const log = DevToolsHarLog(version: '1.2', creator: creator, entries: <DevToolsHarEntry>[]);
      const root = DevToolsHarRoot(log: log);
      expect(root.toString(), contains('DevToolsHarRoot(log: DevToolsHarLog('));
    });

    test('Custom fields and comments', () {
      const cookie = HarCookie(name: 'foo', value: 'bar', comment: 'test comment', custom: {'_custom': 'value'});
      expect(cookie.toString(), 'HarCookie(name: foo, value: bar, comment: test comment, custom: {_custom: value})');
    });
  });
}
