import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `colorScheme.outline` is a border colour, and must never end up as text.
///
/// It is one step from the surface it borders, by design. On a card that is
/// 1.11:1 against a 4.5:1 requirement - text that is present, selectable and
/// effectively invisible. It went unnoticed on the package price card for as
/// long as it existed, and was then written again on the same screen hours
/// after being found, which is what makes this worth a structural check
/// rather than a note.
///
/// A source scan rather than a widget test, because the failure is that
/// somebody reaches for a plausible-looking token in a file nobody thought to
/// write a contrast test for. Rendering assertions only cover the components
/// someone remembered to cover.
///
/// Legitimate uses - borders, dividers, icons, a skeleton's base, a progress
/// track - are untouched: this only looks inside text styles.
void main() {
  test('no text style anywhere in lib/ paints with colorScheme.outline', () {
    final offences = <String>[];

    for (final file in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      // Generated, and regenerated wholesale - not somewhere to fix anything.
      if (file.path.startsWith('lib/api/')) continue;

      final src = file.readAsStringSync();
      for (final marker in ['style:', 'TextStyle(']) {
        var from = src.indexOf(marker);
        while (from != -1) {
          final expression = _styleExpression(src, from + marker.length);
          if (expression.contains('colorScheme.outline')) {
            final line = '\n'.allMatches(src.substring(0, from)).length + 1;
            offences.add('${file.path}:$line');
          }
          from = src.indexOf(marker, from + marker.length);
        }
      }
    }

    expect(
      offences,
      isEmpty,
      reason: 'outline is the border colour of the surface it sits on, so text painted with it '
          'renders at about 1.11:1. Use colorScheme.onSurfaceVariant for secondary text. Found at:\n'
          '${offences.join('\n')}',
    );
  });
}

/// The text of one `style:` value, from just after the marker to the comma
/// that ends it, ignoring commas nested inside calls.
String _styleExpression(String src, int start) {
  var depth = 0;
  var i = start;
  while (i < src.length) {
    final c = src[i];
    if (c == '(' || c == '[') {
      depth++;
    } else if (c == ')' || c == ']') {
      if (depth == 0) break;
      depth--;
    } else if (c == ',' && depth == 0) {
      break;
    }
    i++;
  }
  return src.substring(start, i);
}
