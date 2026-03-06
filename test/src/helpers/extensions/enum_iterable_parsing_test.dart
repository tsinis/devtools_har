// ignore_for_file: avoid-long-functions

import 'package:devtools_har/src/helpers/extensions/enum_iterable_parsing.dart';
import 'package:test/test.dart';

enum _EnumIterableParsingTest { bar, baz, foo }

class _NameCarrier {
  const _NameCarrier(this.value);

  final String value;

  @override
  String toString() => value;
}

enum _Custom {
  high,
  low;

  String get value => name.toUpperCase();

  @override
  String toString() => value;
}

void main() => group('EnumIterableParsing.tryParse', () {
  group('null / empty', () {
    test(
      'returns null when value is null',
      () => expect(_EnumIterableParsingTest.values.tryParse(null), isNull),
    );

    test(
      'returns null for empty string',
      () => expect(_EnumIterableParsingTest.values.tryParse(''), isNull),
    );

    test(
      'returns null for whitespace-only string',
      () => expect(_EnumIterableParsingTest.values.tryParse('   '), isNull),
    );

    test(
      'empty iterable returns null',
      () => expect(<_EnumIterableParsingTest>[].tryParse('foo'), isNull),
    );
  });

  group('default valueOf (name)', () {
    test('matches exact (case-insensitive)', () {
      expect(_Custom.values.tryParse('LOW'), _Custom.low);
      expect(_Custom.values.tryParse('low'), _Custom.low);
      expect(_Custom.values.tryParse('High'), _Custom.high);
    });

    test('matches with leading/trailing whitespace in input', () {
      expect(_Custom.values.tryParse('  low  '), _Custom.low);
      expect(_Custom.values.tryParse('\thigh\n'), _Custom.high);
    });

    test(
      'returns null for no match',
      () => expect(_Custom.values.tryParse('medium'), isNull),
    );

    test(
      'coerces non-string input via toString()',
      () => expect(
        _EnumIterableParsingTest.values.tryParse(
          _NameCarrier(_EnumIterableParsingTest.foo.name),
        ),
        _EnumIterableParsingTest.foo,
      ),
    );

    test(
      'returns null for unrelated int input',
      () => expect(_EnumIterableParsingTest.values.tryParse(1), isNull),
    );
  });

  group('custom valueOf', () {
    test('matches using custom field', () {
      expect(
        _Custom.values.tryParse('low', valueOf: (e) => e.value),
        _Custom.low,
      );
      expect(
        _Custom.values.tryParse('HIGH', valueOf: (e) => e.value),
        _Custom.high,
      );
    });

    test(
      'matches with whitespace when using custom valueOf',
      () => expect(
        _Custom.values.tryParse('  low  ', valueOf: (e) => e.value),
        _Custom.low,
      ),
    );

    test(
      'returns null when custom field does not match',
      () => expect(
        _Custom.values.tryParse('medium', valueOf: (e) => e.value),
        isNull,
      ),
    );

    test(
      'matches on .name via valueOf',
      () => expect(
        _EnumIterableParsingTest.values.tryParse('BAR', valueOf: (e) => e.name),
        _EnumIterableParsingTest.bar,
      ),
    );
  });
});
