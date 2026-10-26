// Every colour in a pro screen comes from the tokens. A hex literal outside
// design/ is how a second accent, or a white that is not paper, gets in.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Where the pro app's screens live. The client app is not part of the
/// Contact sheet work; its one remaining literal (the hero carousel's scrim)
/// is left for its own redesign.
const _scanned = ['lib/features/pro', 'lib/features/shared', 'lib/core'];

void main() {
  test('no Color(0x...) literal in a pro or shared screen', () {
    final offenders = <String>[];
    for (final root in _scanned) {
      for (final file in Directory(root).listSync(recursive: true).whereType<File>()) {
        final path = file.path;
        if (!path.endsWith('.dart') || path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) continue;
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          if (RegExp(r'Color\(0x').hasMatch(lines[i]) || RegExp(r'\bColors\.(?!transparent\b)\w').hasMatch(lines[i])) {
            offenders.add('$path:${i + 1}: ${lines[i].trim()}');
          }
        }
      }
    }
    expect(offenders, isEmpty, reason: 'use a token from lib/design/tokens.dart:\n${offenders.join('\n')}');
  });
}
