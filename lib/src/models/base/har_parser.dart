import 'dart:convert' show JsonCodec;

import '../../helpers/har_utils.dart';
import 'har_root.dart';

/// Simple parser that works with HAR 1.2 files.
///
/// ```dart
/// final root = HarParser.parse('{"log":{"version":"1.2","entries":[]}}');
/// print(root.log.version); // 1.2
/// ```
sealed class HarParser {
  /// Parse a HAR (either core or DevTools‐extended) from a JSON string.
  static HarRoot parse(String jsonStr, {JsonCodec codec = const JsonCodec()}) {
    final json = codec.decode(jsonStr);
    assert(json is Json, 'HarParser: "json" must be a JSON object');
    final jsonMap = json is Json ? json : const <String, dynamic>{};

    return HarRoot.fromJson(jsonMap);
  }
}
