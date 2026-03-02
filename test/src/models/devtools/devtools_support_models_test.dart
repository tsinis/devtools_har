// ignore_for_file: avoid-long-functions, avoid-unsafe-collection-methods,
// ignore_for_file: prefer-moving-to-variable, no-equal-arguments
// ignore_for_file: prefer-class-destructuring

import 'package:devtools_har/src/models/devtools/devtools_call_frame.dart';
import 'package:devtools_har/src/models/devtools/devtools_initiator.dart';
import 'package:devtools_har/src/models/devtools/devtools_stack_trace.dart';
import 'package:devtools_har/src/models/devtools/devtools_websocket_message.dart';
import 'package:devtools_har/src/models/har_object.dart';
import 'package:test/test.dart';

void main() {
  group('DevToolsCallFrame', () {
    test('fromJson parses values and preserves custom fields', () {
      final callFrame = DevToolsCallFrame.fromJson({
        '_vendor': 'custom-value',
        'columnNumber': 7.9,
        'comment': 'frame comment',
        'functionName': 'myFunction',
        'ignored': true,
        'lineNumber': '12.8',
        'scriptId': 99,
        'url': 'https://example.com/script.js',
      });

      expect(callFrame.functionName, 'myFunction');
      expect(callFrame.scriptId, '99');
      expect(callFrame.url, 'https://example.com/script.js');
      expect(callFrame.lineNumber, 12);
      expect(callFrame.columnNumber, 7);
      expect(callFrame.comment, 'frame comment');
      expect(callFrame.custom, {'_vendor': 'custom-value'});
    });

    test('fromJson falls back to defaults for invalid data', () {
      final callFrame = DevToolsCallFrame.fromJson({
        'columnNumber': Object(),
        'functionName': null,
        'lineNumber': 'not-a-number',
        'scriptId': null,
        'url': null,
      });

      expect(callFrame.functionName, '');
      expect(callFrame.scriptId, '');
      expect(callFrame.url, '');
      expect(callFrame.lineNumber, 0);
      expect(callFrame.columnNumber, 0);
    });

    test('toJson, copyWith, and toString expose expected values', () {
      const original = DevToolsCallFrame(
        functionName: 'fn',
        scriptId: '7',
        url: 'https://example.com/a.js',
        lineNumber: 4,
        columnNumber: 2,
        comment: 'note',
        custom: {'_trace': 'yes'},
      );

      final json = original.toJson();
      final copy = original.copyWith(lineNumber: 9, functionName: 'renamed');
      final fallbackCopy = original.copyWith(scriptId: '99');
      final text = original.toString();

      expect(json, {
        '_trace': 'yes',
        'columnNumber': 2,
        'comment': 'note',
        'functionName': 'fn',
        'lineNumber': 4,
        'scriptId': '7',
        'url': 'https://example.com/a.js',
      });
      expect(copy.functionName, 'renamed');
      expect(copy.lineNumber, 9);
      expect(copy.columnNumber, 2);
      expect(fallbackCopy.functionName, 'fn');
      expect(fallbackCopy.lineNumber, 4);
      expect(fallbackCopy.scriptId, '99');
      expect(text, contains('DevToolsCallFrame('));
      expect(text, contains('functionName: fn'));
      expect(text, contains('custom: {_trace: yes}'));
    });
  });

  group('DevToolsInitiator', () {
    test('fromJson parses optional fields and nested stack', () {
      final initiator = DevToolsInitiator.fromJson({
        '_source': 'network',
        'columnNumber': 21,
        'lineNumber': '14.0',
        'stack': {
          'callFrames': [
            {
              'columnNumber': 2,
              'functionName': 'main',
              'lineNumber': 1,
              'scriptId': '1',
              'url': 'https://example.com/main.js',
            },
            'invalid-entry',
          ],
        },
        'type': 'script',
        'url': 'https://example.com',
      });

      expect(initiator.type, 'script');
      expect(initiator.url, 'https://example.com');
      expect(initiator.lineNumber, 14);
      expect(initiator.columnNumber, 21);
      final stack = initiator.stack;
      expect(stack, isNotNull);
      expect(stack?.callFrames.single.functionName, 'main');
      expect(initiator.custom, {'_source': 'network'});
    });

    test('fromJson handles invalid optional values safely', () {
      final initiator = DevToolsInitiator.fromJson({
        'columnNumber': 'invalid',
        'lineNumber': 'invalid',
        'stack': ['not-a-map'],
        'type': null,
      });

      expect(initiator.type, '');
      expect(initiator.url, isNull);
      expect(initiator.lineNumber, isNull);
      expect(initiator.columnNumber, isNull);
      expect(initiator.stack, isNull);
    });

    test('toJson, copyWith, and toString expose expected values', () {
      const original = DevToolsInitiator(
        type: 'parser',
        url: 'https://example.com',
        lineNumber: 3,
        columnNumber: 4,
        stack: DevToolsStackTrace(),
        comment: 'initiator note',
        custom: {'_tag': 'origin'},
      );

      final json = original.toJson();
      final copy = original.copyWith(type: 'script', lineNumber: 10);
      final fallbackCopy = original.copyWith(url: 'https://example.org');
      final text = original.toString();

      expect(json['type'], 'parser');
      expect(json['url'], 'https://example.com');
      expect(json['lineNumber'], 3);
      expect(json['columnNumber'], 4);
      final stackJson = json['stack'];
      expect(stackJson, isA<Map<String, dynamic>>());
      if (stackJson case final Map<String, dynamic> stackMap) {
        expect(stackMap[DevToolsStackTrace.kCallFrames], isEmpty);
      }
      expect(json[HarObject.kComment], 'initiator note');
      expect(json['_tag'], 'origin');
      expect(copy.type, 'script');
      expect(copy.lineNumber, 10);
      expect(copy.columnNumber, 4);
      expect(fallbackCopy.type, 'parser');
      expect(fallbackCopy.lineNumber, 3);
      expect(fallbackCopy.url, 'https://example.org');
      expect(text, contains('DevToolsInitiator('));
      expect(text, contains('type: parser'));
      expect(text, contains('stack: DevToolsStackTrace('));
    });
  });

  group('DevToolsStackTrace', () {
    test('fromJson parses callFrames and nested parent stack', () {
      final stack = DevToolsStackTrace.fromJson({
        '_traceId': 'abc',
        'callFrames': [
          {
            'columnNumber': 1,
            'functionName': 'a',
            'lineNumber': 10,
            'scriptId': '1',
            'url': 'https://example.com/a.js',
          },
          12,
        ],
        'description': 'async chain',
        'parent': {
          'callFrames': [
            {
              'columnNumber': 5,
              'functionName': 'parentFn',
              'lineNumber': 30,
              'scriptId': '2',
              'url': 'https://example.com/p.js',
            },
          ],
        },
      });

      expect(stack.callFrames.single.functionName, 'a');
      expect(stack.description, 'async chain');
      final parent = stack.parent;
      expect(parent, isNotNull);
      expect(parent?.callFrames.single.functionName, 'parentFn');
      expect(stack.custom, {'_traceId': 'abc'});
    });

    test('fromJson falls back when callFrames and parent are invalid', () {
      final stack = DevToolsStackTrace.fromJson({
        'callFrames': 'not-a-list',
        'parent': 'not-a-map',
      });

      expect(stack.callFrames, isEmpty);
      expect(stack.description, isNull);
      expect(stack.parent, isNull);
    });

    test('toJson, copyWith, and toString expose expected values', () {
      const frame = DevToolsCallFrame(
        functionName: 'work',
        scriptId: '42',
        url: 'https://example.com/work.js',
        lineNumber: 5,
        columnNumber: 8,
      );
      const original = DevToolsStackTrace(
        callFrames: [frame],
        description: 'root stack',
        comment: 'trace note',
        custom: {'_meta': true},
      );

      final json = original.toJson();
      final copy = original.copyWith(description: 'updated stack');
      final fallbackCopy = original.copyWith(comment: 'changed comment');
      final text = original.toString();

      // ignore: avoid_dynamic_calls, it's a matter of test.
      expect(json[DevToolsStackTrace.kCallFrames].single, {
        'columnNumber': 8,
        'functionName': 'work',
        'lineNumber': 5,
        'scriptId': '42',
        'url': 'https://example.com/work.js',
      });
      expect(json[DevToolsStackTrace.kDescription], 'root stack');
      expect(json[HarObject.kComment], 'trace note');
      expect(json['_meta'], isTrue);
      expect(copy.description, 'updated stack');
      expect(copy.callFrames.single.functionName, 'work');
      expect(fallbackCopy.description, 'root stack');
      expect(fallbackCopy.comment, 'changed comment');
      expect(text, contains('DevToolsStackTrace('));
      expect(text, contains('description: root stack'));
    });
  });

  group('DevToolsWebSocketMessage', () {
    test('fromJson parses values and preserves custom fields', () {
      final message = DevToolsWebSocketMessage.fromJson({
        '_id': 'msg-1',
        'comment': 'message note',
        'data': 'hello',
        'opcode': '1.0',
        'time': '1234.5',
        'type': 'send',
      });

      expect(message.type, 'send');
      expect(
        message.time,
        const Duration(milliseconds: 1234, microseconds: 500),
      );
      expect(message.opcode, 1);
      expect(message.data, 'hello');
      expect(message.comment, 'message note');
      expect(message.custom, {'_id': 'msg-1'});
    });

    test('fromJson uses defaults for invalid values', () {
      final message = DevToolsWebSocketMessage.fromJson({
        'data': null,
        'opcode': Object(),
        'time': 'not-a-duration',
        'type': null,
      });

      expect(message.type, '');
      expect(message.time, Duration.zero);
      expect(message.opcode, 0);
      expect(message.data, '');
    });

    test('toJson, copyWith, and toString expose expected values', () {
      const original = DevToolsWebSocketMessage(
        type: 'receive',
        time: Duration(milliseconds: 250),
        opcode: 2,
        data: 'payload',
        comment: 'ws note',
        custom: {'_channel': 'chat'},
      );

      final json = original.toJson();
      final copy = original.copyWith(opcode: 8, data: 'close');
      final fallbackCopy = original.copyWith(type: 'send');
      final text = original.toString();

      expect(json, {
        '_channel': 'chat',
        'comment': 'ws note',
        'data': 'payload',
        'opcode': 2,
        'time': 250,
        'type': 'receive',
      });
      expect(copy.opcode, 8);
      expect(copy.data, 'close');
      expect(copy.type, 'receive');
      expect(fallbackCopy.type, 'send');
      expect(fallbackCopy.opcode, 2);
      expect(fallbackCopy.data, 'payload');
      expect(text, contains('DevToolsWebSocketMessage('));
      expect(text, contains('type: receive'));
      expect(text, contains('data: payload'));
    });
  });
}
