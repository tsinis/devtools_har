import 'dart:convert' show jsonEncode;
import 'dart:io' show File;

import 'package:devtools_har/src/models/devtools/devtools_har_parser.dart';
import 'package:test/test.dart';

void main() => group('$DevToolsHarParser', () {
  test('parses real-world HAR', () {
    final harFile = File('test/input.har');
    final harContents = harFile.readAsStringSync();
    final parsed = DevToolsHarParser.parse(harContents);
    final parsedJson = jsonEncode(parsed.toJson());
    File('test/devtools_output.har').writeAsStringSync(parsedJson);

    expect(parsed.log.version, isNotEmpty);
    expect(parsed.log.creator.name, isNotEmpty);
    expect(parsed.log.entries, isNotEmpty);
  });
});
