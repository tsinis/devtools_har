// ignore_for_file: prefer_asserts_with_message,avoid_print,avoid-long-functions
// ignore_for_file: prefer-extracting-function-callbacks, avoid-adjacent-strings
// ignore_for_file: prefer-moving-to-variable, avoid-nullable-interpolation
// ignore_for_file: avoid-default-tostring

import 'dart:convert';
import 'dart:io';
import 'package:devtools_har/devtools_har.dart';

void main(List<String> args) {
  final path = args.firstOrNull ?? 'network_log.har';
  final file = File(path);

  if (file.existsSync()) {
    final jsonStr = file.readAsStringSync();

    final root = HarParser.parse(jsonStr);
    for (final entry in root.log.entries.take(3)) {
      print(
        '${entry.request.method} ${entry.request.url} '
        '-> ${entry.response.status}',
      );
    }

    final devtoolsRoot = DevToolsHarParser.parse(jsonStr);
    final entry = devtoolsRoot.log.entries.firstOrNull;
    if (entry != null) {
      print('Priority: ${entry.priority}');
      print('Resource type: ${entry.resourceType}');
    }
  } else {
    print('Missing HAR file: $path');
  }

  final entry = HarEntry(
    startedDateTime: DateTime.now().toUtc(),
    totalTime: 120,
    request: HarRequest(
      url: Uri.parse('https://api.example.com/v1/vehicles'),
      headersSize: -1,
      bodySize: 0,
    ),
    response: const HarResponse(
      status: 200,
      statusText: 'OK',
      content: HarContent(size: 0),
      redirectURL: '',
      headersSize: -1,
      bodySize: 0,
    ),
    cache: const HarCache(),
    timings: const HarTimings(send: 0, wait: 0, receive: 0),
  );

  final compact = entry.toJson();
  final verbose = entry.toJson(includeNulls: true);
  print('Compact keys: ${compact.length}, verbose keys: ${verbose.length}');

  const original =
      '{"name":"sid","value":"abc","expires":"Sun, 15 Jul 2012 ..."}';
  final cookie = HarCookie.fromJson(
    // ignore: avoid-type-casts, just an example, the structure is correct.
    jsonDecode(original) as Map<String, dynamic>,
  );
  assert(jsonEncode(cookie.toJson()).contains('Sun, 15 Jul 2012'));
}
