import 'package:devtools_har/src/models/base/har_timings.dart';
import 'package:test/test.dart';

void main() {
  group('HarTimings.fromJson asserts', () {
    test('throws when send is negative', () {
      const json = {'receive': '0', 'send': '-1', 'wait': '0'};

      expect(() => HarTimings.fromJson(json), throwsA(isA<AssertionError>()));
    });

    test('throws when wait is negative', () {
      const json = {'receive': '0', 'send': '0', 'wait': '-0.5'};

      expect(() => HarTimings.fromJson(json), throwsA(isA<AssertionError>()));
    });

    test('throws when receive is negative', () {
      const json = {'receive': '-10', 'send': '0', 'wait': '0'};

      expect(() => HarTimings.fromJson(json), throwsA(isA<AssertionError>()));
    });

    test('does not throw when required timings are non-negative', () {
      const json = {'receive': 2, 'send': '1.25', 'wait': '0'};

      expect(() => HarTimings.fromJson(json), returnsNormally);
    });
  });
}
