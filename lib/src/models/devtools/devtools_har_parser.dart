import 'dart:convert' show JsonCodec;
import '../../helpers/har_utils.dart';
import 'devtools_har_root.dart';

/// Simple parser that auto‐detects DevTools extras.
sealed class DevToolsHarParser {
  /// Parse a HAR (either core or DevTools‐extended) from a JSON string.
  static DevToolsHarRoot parse(
    String jsonStr, {
    JsonCodec codec = const JsonCodec(),
  }) {
    final json = codec.decode(jsonStr);
    assert(json is Json, 'DevToolsHarParser: "json" must be a JSON object');
    final jsonMap = json is Json ? json : const <String, dynamic>{};

    return DevToolsHarRoot.fromJson(jsonMap);
  }
}
