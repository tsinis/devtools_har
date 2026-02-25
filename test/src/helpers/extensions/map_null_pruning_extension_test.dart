// ignore_for_file: avoid-long-functions, avoid-collection-mutating-methods

import 'package:devtools_har/src/helpers/extensions/map_null_pruning_extension.dart';
import 'package:test/test.dart';

void main() => group('MapNullPruningExtension', () {
  group('withoutNullValues', () {
    test('removes entries with null values', () {
      final input = <String, int?>{'a': 1, 'b': null, 'c': 3};
      final result = input.withoutNullValues;

      expect(result, equals({'a': 1, 'c': 3}));
    });

    test('returns Map<K, V> - non-nullable value type', () {
      final input = <String, int?>{'a': 1, 'b': null};
      final result = input.withoutNullValues;

      expect(result, isA<Map<String, int>>());
    });

    test('does NOT mutate the original map', () {
      final input = {'a': 1, 'b': null, 'c': 3}..withoutNullValues;

      expect(input, equals({'a': 1, 'b': null, 'c': 3}));
    });

    test('preserves insertion order', () {
      final input = <String, String?>{'a': null, 'm': 'm', 'z': 'z'};
      final result = input.withoutNullValues;

      expect(result.keys.toList(), equals(['m', 'z']));
    });

    test('returns empty map when all values are null', () {
      final input = <String, int?>{'a': null, 'b': null};
      expect(input.withoutNullValues, isEmpty);
    });

    test('returns empty map when source is empty', () {
      expect(<String, int?>{}.withoutNullValues, isEmpty);
    });

    test('returns full copy when no values are null', () {
      final input = <String, int?>{'a': 1, 'b': 2};
      final result = input.withoutNullValues;

      expect(result, equals({'a': 1, 'b': 2}));

      expect(identical(result, input), isFalse);
    });

    test('works with non-String keys (int keys)', () {
      final input = <int, String?>{1: 'one', 2: null, 3: 'three'};
      expect(input.withoutNullValues, equals({1: 'one', 3: 'three'}));
    });

    test('works with Object value type', () {
      final input = <String, Object?>{'a': 42, 'b': null, 'c': 'text'};
      final result = input.withoutNullValues;

      expect(result, equals({'a': 42, 'c': 'text'}));
      expect(result, isA<Map<String, Object>>());
    });

    test('single non-null entry survives', () {
      final input = <String, double?>{'gone': null, 'only': 3.14};
      expect(input.withoutNullValues, equals({'only': 3.14}));
    });
  });

  group('removeNullValues', () {
    test('should not work on compile-time const maps', () {
      const input = <String, int?>{'a': 1, 'b': null};
      expect(input.removeNullValues, throwsA(isA<UnsupportedError>()));
    });

    test('removes entries with null values in place', () {
      final map = <String, int?>{'a': 1, 'b': null, 'c': 3}..removeNullValues();

      expect(map, equals({'a': 1, 'c': 3}));
    });

    test('mutates the original map', () {
      final map = <String, int?>{'a': 1, 'b': null};
      final before = map.length;
      map.removeNullValues(); // ignore: avoid-ignoring-return-values, it's test.

      expect(map.length, lessThan(before));
      expect(map.containsKey('b'), isFalse);
    });

    test('returns the same map instance (for chaining)', () {
      final map = <String, int?>{'a': 1, 'b': null};
      final returned = map.removeNullValues();

      expect(identical(returned, map), isTrue);
    });

    test('supports method chaining', () {
      final map = <String, int?>{'a': 1, 'b': null, 'c': 3};
      final chained = map.removeNullValues()..addAll({'d': 4});

      expect(chained, equals({'a': 1, 'c': 3, 'd': 4}));
    });

    test('no-ops on an already clean map', () {
      final map = <String, int?>{'a': 1, 'b': 2}..removeNullValues();

      expect(map, equals({'a': 1, 'b': 2}));
    });

    test('clears map when all values are null', () {
      final map = <String, int?>{'a': null, 'b': null}..removeNullValues();

      expect(map, isEmpty);
    });

    test('no-ops on empty map', () {
      final map = <String, int?>{}..removeNullValues();

      expect(map, isEmpty);
    });

    test('works with non-String keys', () {
      final map = <int, bool?>{1: true, 2: null, 3: false}..removeNullValues();

      expect(map, equals({1: true, 3: false}));
    });
  });

  group('contract: withoutNullValues and removeNullValues agree', () {
    test('produce the same key-value pairs', () {
      final source = <String, int?>{'a': 1, 'b': null, 'c': 3, 'd': null};

      final immutable = source.withoutNullValues;

      final mutableOne = Map<String, int?>.of(source)..removeNullValues();
      expect(immutable, equals(Map<String, int?>.of(mutableOne)));
    });
  });
});
