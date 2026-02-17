import 'dart:convert' show jsonEncode;
import 'dart:io' show File;

import 'package:devtools_har/src/models/base/har_parser.dart';
import 'package:test/test.dart';

void main() => group('$HarParser', () {
  test('parses real-world HAR', () {
    final harFile = File('test/input.har');
    final harContents = harFile.readAsStringSync();
    final parsed = HarParser.parse(harContents);
    final parsedJson = jsonEncode(parsed.toJson());

    expect(parsedJson, isNotEmpty);
    expect(parsed.log.version, isNotEmpty);
    expect(parsed.log.creator.name, isNotEmpty);
    expect(parsed.log.entries, isNotEmpty);
  });
});
