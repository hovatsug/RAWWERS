// Client credit is shown in euros ("€5.00 credit"), never as RAW, RAWW or
// points (owner's decision, 2026-11-07). RAWW is the photographers' unit and
// stays in the pro app. This reads every string literal the client flavor can
// show: the client features, the shared features and the design components.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _forbidden = RegExp(r'\b(RAW|RAWW|RAWWs|points?)\b', caseSensitive: false);
final _literal = RegExp(r"'((?:[^'\\]|\\.)*)'" '|' r'"((?:[^"\\]|\\.)*)"');

/// Each string literal in [source] that says one of the words, with its line.
List<String> offendingStrings(String source, {String path = ''}) {
  final found = <String>[];
  final lines = source.split('\n');
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trimLeft();
    if (line.startsWith('//') || line.startsWith('import ') || line.startsWith('export ') || line.startsWith('part ')) continue;
    for (final m in _literal.allMatches(lines[i])) {
      final text = m.group(1) ?? m.group(2) ?? '';
      if (_forbidden.hasMatch(text)) found.add('$path:${i + 1}: $text');
    }
  }
  return found;
}

void main() {
  test('no client-facing string says RAW, RAWW or points', () {
    final found = <String>[];
    for (final root in ['lib/features/client', 'lib/features/shared', 'lib/design/components']) {
      for (final f in Directory(root).listSync(recursive: true).whereType<File>()) {
        if (!f.path.endsWith('.dart') || f.path.endsWith('.g.dart') || f.path.endsWith('.freezed.dart')) continue;
        found.addAll(offendingStrings(f.readAsStringSync(), path: f.path));
      }
    }
    expect(found, isEmpty, reason: 'client credit is euros:\n${found.join('\n')}');
  });

  test('the guard catches the words and spares RAWWERS', () {
    expect(offendingStrings("Text('Earn RAW credit')"), hasLength(1));
    expect(offendingStrings('label: "100 points"'), hasLength(1));
    expect(offendingStrings("Text('120 RAWW')"), hasLength(1));
    expect(offendingStrings("Text('Let RAWWERS feature photos')"), isEmpty);
    expect(offendingStrings("// RAWW in a comment"), isEmpty);
  });
}
