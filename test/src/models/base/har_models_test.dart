// ignore_for_file: avoid-long-functions, prefer-class-destructuring

import 'package:devtools_har/src/models/base/har_cache.dart';
import 'package:devtools_har/src/models/base/har_content.dart';
import 'package:devtools_har/src/models/base/har_entry.dart';
import 'package:devtools_har/src/models/base/har_post_data.dart';
import 'package:devtools_har/src/models/base/har_request.dart';
import 'package:devtools_har/src/models/base/har_response.dart';
import 'package:devtools_har/src/models/base/har_timings.dart';
import 'package:devtools_har/src/models/har_object.dart';
import 'package:devtools_har/src/models/har_utils.dart';
import 'package:test/test.dart';

void main() {
  group('HarTimings', () {
    test('time getter calculates total correctly with all values', () {
      const timings = HarTimings(
        blocked: 10,
        dns: 5,
        connect: 20,
        send: 50,
        wait: 100,
        receive: 75,
      );

      expect(timings.time, 260.0);
    });

    test('time getter ignores -1 values', () {
      const timings = HarTimings(
        blocked: -1,
        dns: 5,
        send: 50,
        wait: 100,
        receive: 75,
      );

      expect(timings.time, 230.0);
    });

    test('time getter ignores null values', () {
      const timings = HarTimings(send: 50, wait: 100, receive: 75);

      expect(timings.time, 225.0);
    });

    test('fromJson deserializes all fields correctly', () {
      const json = {
        'blocked': 10.0,
        'connect': 20.3,
        'dns': 5.5,
        'receive': 75.8,
        'send': 50.5,
        'ssl': 15.0,
        'wait': 100.2,
      };

      final timings = HarTimings.fromJson(json);
      expect(timings.blocked, 10.0);
      expect(timings.dns, 5.5);
      expect(timings.connect, 20.3);
      expect(timings.send, 50.5);
      expect(timings.wait, 100.2);
      expect(timings.receive, 75.8);
      expect(timings.ssl, 15.0);
    });

    test('fromJson deserializes string numbers correctly', () {
      const json = {
        'blocked': '10.0',
        'receive': '75.8',
        'send': '50.5',
        'wait': '100.2',
      };

      final timings = HarTimings.fromJson(json);
      expect(timings.blocked, 10.0);
      expect(timings.send, 50.5);
      expect(timings.wait, 100.2);
      expect(timings.receive, 75.8);
    });

    test('fromJson with missing optional fields uses null', () {
      const json = {'receive': 75.0, 'send': 50.0, 'wait': 100.0};

      final timings = HarTimings.fromJson(json);
      expect(timings.blocked, isNull);
      expect(timings.dns, isNull);
      expect(timings.connect, isNull);
      expect(timings.ssl, isNull);
    });

    test('fromJson with missing required fields uses default 0', () {
      const json = <String, dynamic>{};

      final timings = HarTimings.fromJson(json);
      expect(timings.send, 0.0);
      expect(timings.wait, 0.0);
      expect(timings.receive, 0.0);
    });

    test('toJson serializes all fields correctly', () {
      const timings = HarTimings(
        blocked: 10,
        dns: 5,
        connect: 20,
        send: 50,
        wait: 100,
        receive: 75,
        ssl: 15,
      );

      final json = timings.toJson();
      expect(json['blocked'], 10.0);
      expect(json['dns'], 5.0);
      expect(json['connect'], 20.0);
      expect(json['send'], 50.0);
      expect(json['wait'], 100.0);
      expect(json['receive'], 75.0);
      expect(json['ssl'], 15.0);
    });

    test('toJson omits null optional fields', () {
      const timings = HarTimings(send: 50, wait: 100, receive: 75);

      final json = timings.toJson();
      expect(json.containsKey('blocked'), false);
      expect(json.containsKey('dns'), false);
      expect(json.containsKey('connect'), false);
      expect(json.containsKey('ssl'), false);
    });

    test('toString includes all non-null fields', () {
      const timings = HarTimings(
        blocked: 10,
        dns: 5,
        send: 50,
        wait: 100,
        receive: 75,
        comment: 'Test timing',
      );

      final str = timings.toString();
      expect(str, contains('HarTimings'));
      expect(str, contains('10.0'));
      expect(str, contains('5.0'));
      expect(str, contains('Test timing'));
    });
  });

  group('HarCache and HarCacheEntry', () {
    test('HarCache.fromJson with empty cache', () {
      const json = <String, dynamic>{};
      final cache = HarCache.fromJson(json);
      expect(cache.beforeRequest, isNull);
      expect(cache.afterRequest, isNull);
    });

    test('HarCache.fromJson with cache entries', () {
      const json = {
        'afterRequest': {
          'eTag': 'etag456',
          'hitCount': 10,
          'lastAccess': '2025-03-14T10:00:01.000Z',
        },
        'beforeRequest': {
          'eTag': 'etag123',
          'expires': '2025-03-15T10:00:00.000Z',
          'hitCount': 5,
          'lastAccess': '2025-03-14T10:00:00.000Z',
        },
      };

      final cache = HarCache.fromJson(json);
      expect(cache.beforeRequest?.eTag, 'etag123');
      expect(cache.beforeRequest?.hitCount, 5);
      expect(cache.afterRequest?.eTag, 'etag456');
      expect(cache.afterRequest?.hitCount, 10);
    });

    test('HarCache.toJson serializes correctly', () {
      final beforeEntry = HarCacheEntry(
        expires: DateTime.utc(2025, 3, 15),
        lastAccess: DateTime.utc(2025, 3, 14),
        eTag: 'etag123',
        hitCount: 5,
      );

      final cache = HarCache(beforeRequest: beforeEntry);
      final json = cache.toJson();

      expect(json['beforeRequest'], isNotNull);
      // ignore: avoid_dynamic_calls, it's a test.
      expect(json['beforeRequest']['eTag'], 'etag123');
    });

    test('HarCache.toString includes entries when present', () {
      final entry = HarCacheEntry(
        lastAccess: DateTime.utc(2025, 3, 14),
        eTag: 'etag123',
        hitCount: 5,
      );

      final cache = HarCache(beforeRequest: entry);
      final str = cache.toString();
      expect(str, contains('HarCache'));
      expect(str, contains('beforeRequest'));
    });

    test('HarCacheEntry.fromJson deserializes correctly', () {
      const json = {
        'eTag': 'etag123',
        'expires': '2025-03-15T10:00:00.000Z',
        'hitCount': 5,
        'lastAccess': '2025-03-14T10:00:00.000Z',
      };

      final entry = HarCacheEntry.fromJson(json);
      expect(entry.expires, isNotNull);
      expect(entry.eTag, 'etag123');
      expect(entry.hitCount, 5);
    });

    test('HarCacheEntry.fromJson with missing expires', () {
      const json = {
        'eTag': 'etag123',
        'hitCount': 5,
        'lastAccess': '2025-03-14T10:00:00.000Z',
      };

      final entry = HarCacheEntry.fromJson(json);
      expect(entry.expires, isNull);
    });

    test('HarCacheEntry.fromJson asserts on invalid lastAccess', () {
      const json = {
        'eTag': 'etag123',
        'hitCount': 5,
        'lastAccess': 'invalid-date',
      };

      expect(
        () => HarCacheEntry.fromJson(json),
        throwsA(isA<AssertionError>()),
      );
    });

    test('HarCacheEntry.toJson preserves raw datetime strings', () {
      final entry = HarCacheEntry(
        lastAccess: DateTime.utc(2025, 3, 14),
        lastAccessRaw: '2025-03-14T10:00:00.123Z',
        eTag: 'etag123',
        hitCount: 5,
      );

      final json = entry.toJson();
      expect(json['lastAccess'], '2025-03-14T10:00:00.123Z');
    });

    test('HarCacheEntry.toString includes all fields', () {
      final entry = HarCacheEntry(
        expires: DateTime.utc(2025, 3, 15),
        lastAccess: DateTime.utc(2025, 3, 14),
        eTag: 'etag123',
        hitCount: 5,
        comment: 'Test',
      );

      final str = entry.toString();
      expect(str, contains('HarCacheEntry'));
      expect(str, contains('eTag'));
      expect(str, contains('hitCount'));
      expect(str, contains('Test'));
    });
  });

  group('HarPostData and HarParam', () {
    test('HarPostData.fromJson deserializes correctly', () {
      const json = {
        'mimeType': 'application/x-www-form-urlencoded',
        'params': [
          {'name': 'field1', 'value': 'value1'},
          {'name': 'field2', 'value': 'value2'},
        ],
        'text': 'field1=value1&field2=value2',
      };

      final postData = HarPostData.fromJson(json);
      expect(postData.mimeType, 'application/x-www-form-urlencoded');
      expect(postData.params, hasLength(2));
      expect(postData.text, contains('field1=value1'));
    });

    test('HarPostData.fromJson with minimal data', () {
      const json = {
        'mimeType': 'application/json',
        'params': <Map<String, dynamic>>[],
      };

      final postData = HarPostData.fromJson(json);
      expect(postData.mimeType, 'application/json');
      expect(postData.params, isEmpty);
    });

    test('HarPostData.fromJson asserts on invalid params entries', () {
      const json = {
        'mimeType': 'application/x-www-form-urlencoded',
        'params': ['not-a-json-object'],
      };

      expect(() => HarPostData.fromJson(json), throwsA(isA<AssertionError>()));
    });

    test('HarPostData.fromJson with file upload', () {
      const json = {
        'mimeType': 'multipart/form-data',
        'params': [
          {'contentType': 'text/plain', 'fileName': 'test.txt', 'name': 'file'},
        ],
      };

      final postData = HarPostData.fromJson(json);
      final paramsFirst = postData.params.firstOrNull;
      expect(paramsFirst?.contentType, 'text/plain');
      expect(paramsFirst?.fileName, 'test.txt');
    });

    test('HarPostData.toJson serializes correctly', () {
      const param = HarParam(name: 'field1', value: 'value1');

      const postData = HarPostData(
        mimeType: 'application/x-www-form-urlencoded',
        params: [param],
        text: 'field1=value1',
      );

      final json = postData.toJson();
      expect(json['mimeType'], 'application/x-www-form-urlencoded');
      expect(json['params'], isNotEmpty);
      expect(json['text'], 'field1=value1');
    });

    test('HarPostData.toString includes fields when present', () {
      const postData = HarPostData(
        mimeType: 'application/json',
        text: '{"key": "value"}',
      );

      final str = postData.toString();
      expect(str, contains('HarPostData'));
      expect(str, contains('mimeType'));
      expect(str, contains('text'));
    });

    test('HarParam.fromJson deserializes correctly', () {
      const json = {'name': 'username', 'value': 'john_doe'};

      final param = HarParam.fromJson(json);
      expect(param.name, 'username');
      expect(param.value, 'john_doe');
    });

    test('HarParam.fromJson with minimal data', () {
      const json = {'name': 'field1'};

      final param = HarParam.fromJson(json);
      expect(param.name, 'field1');
      expect(param.value, isNull);
    });

    test('HarParam.toJson serializes all fields', () {
      const param = HarParam(
        name: 'file',
        fileName: 'test.txt',
        contentType: 'text/plain',
      );

      final json = param.toJson();
      expect(json['name'], 'file');
      expect(json['fileName'], 'test.txt');
      expect(json['contentType'], 'text/plain');
    });

    test('HarParam.toString includes all non-null fields', () {
      const param = HarParam(
        name: 'username',
        value: 'john_doe',
        comment: 'User field',
      );

      final str = param.toString();
      expect(str, contains('HarParam'));
      expect(str, contains('username'));
      expect(str, contains('john_doe'));
    });
  });

  group('HarEntry', () {
    test('fromJson with valid data preserves all fields', () {
      const json = {
        'pageref': 'page_1',
        'startedDateTime': '2025-03-14T00:00:00.000Z',
        'time': 245.5,
        'request': {
          'method': 'GET',
          'url': 'https://example.com',
          'httpVersion': 'HTTP/1.1',
          'cookies': <Map<String, dynamic>>[],
          'headers': <Map<String, dynamic>>[],
          'queryString': <Map<String, dynamic>>[],
          'headersSize': 100,
          'bodySize': 0,
        },
        'response': {
          'status': 200,
          'statusText': 'OK',
          'httpVersion': 'HTTP/1.1',
          'cookies': <Map<String, dynamic>>[],
          'headers': <Map<String, dynamic>>[],
          'content': {'size': 1024, 'mimeType': 'text/html'},
          'redirectURL': '',
          'headersSize': 200,
          'bodySize': 1024,
        },
        'cache': <String, dynamic>{},
        'timings': {'send': 50, 'wait': 100, 'receive': 75},
        'serverIPAddress': '192.168.1.1',
        'connection': 'conn_1',
        'comment': 'Test',
      };

      final entry = HarEntry.fromJson(json);

      expect(entry.pageref, 'page_1');
      expect(entry.startedDateTime, DateTime.utc(2025, 3, 14));
      expect(entry.startedDateTimeRaw, '2025-03-14T00:00:00.000Z');
      expect(entry.totalTime, 245.5);
      expect(entry.serverIPAddress, '192.168.1.1');
      expect(entry.connectionId, 'conn_1');
      expect(entry.comment, 'Test');
    });

    test('fromJson asserts on invalid startedDateTime', () {
      const json = {
        'cache': <String, dynamic>{},
        'request': {
          'bodySize': 0,
          'headers': <String>[],
          'headersSize': 100,
          'httpVersion': 'HTTP/1.1',
          'method': 'GET',
          'queryString': <String>[],
          'url': 'https://example.com',
        },
        'response': {
          'bodySize': 1024,
          'content': {'mimeType': 'text/html', 'size': 1024},
          'cookies': <String>[],
          'headers': <String>[],
          'headersSize': 200,
          'httpVersion': 'HTTP/1.1',
          'redirectURL': '',
          'status': 200,
          'statusText': 'OK',
        },
        'startedDateTime': 'invalid-date',
        'time': 245.5,
        'timings': {'receive': 95, 'send': 50, 'wait': 100},
      };

      expect(() => HarEntry.fromJson(json), throwsA(isA<AssertionError>()));
    });

    test('toJson preserves raw datetime string when provided', () {
      final entry = HarEntry(
        startedDateTime: DateTime.utc(2025, 3, 14),
        startedDateTimeRaw: '2025-03-14T10:00:00.123Z',
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

      final json = entry.toJson();
      expect(json['startedDateTime'], '2025-03-14T10:00:00.123Z');
    });

    test('toString includes all non-null fields', () {
      final entry = HarEntry(
        pageref: 'page_1',
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
        serverIPAddress: '192.168.1.1',
        connectionId: 'conn_1',
      );

      final str = entry.toString();
      expect(str, contains('HarEntry'));
      expect(str, contains('pageref'));
      expect(str, contains('startedDateTime'));
    });
  });

  group('HarObject', () {
    test('commonJson includes comment when present', () {
      const obj = _HarModelsTest(comment: 'Test comment');
      final json = obj.commonJson();
      expect(json['comment'], 'Test comment');
    });

    test('commonJson includes custom fields', () {
      final custom = {'_field1': 'value1'};
      final obj = _HarModelsTest(custom: custom);
      final json = obj.commonJson();
      expect(json['_field1'], 'value1');
    });

    test('toString includes comment when present', () {
      const obj = _HarModelsTest(comment: 'Test comment');
      final str = obj.toString();
      expect(str, contains('comment'));
    });

    test('toString includes custom fields when present', () {
      final custom = {'_field1': 'value1'};
      final obj = _HarModelsTest(custom: custom);
      final str = obj.toString();
      expect(str, contains('custom'));
    });
  });
}

class _HarModelsTest extends HarObject {
  const _HarModelsTest({super.comment, super.custom});

  @override
  Json toJson({bool includeNulls = false}) =>
      commonJson(includeNulls: includeNulls);
}
