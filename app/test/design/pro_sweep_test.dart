// What a pro screen may not hold: every size, colour, currency symbol and
// text style comes from the design tokens, the theme or one formatter.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/design/components/r_chip.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/design/tokens.dart';

import 'contrast_test.dart' show contrastRatio;

List<String> _offenders(RegExp pattern, {List<String> roots = const ['lib/features/pro'], String allowMarker = '// wire format'}) {
  final found = <String>[];
  for (final root in roots) {
    for (final f in Directory(root).listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart') || f.path.endsWith('.g.dart') || f.path.endsWith('.freezed.dart')) continue;
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//') || line.contains(allowMarker)) continue;
        if (pattern.hasMatch(line)) found.add('${f.path}:${i + 1}: ${line.trim()}');
      }
    }
  }
  return found;
}

void main() {
  test('no bare size, radius, font size or spacing number in a pro screen', () {
    final offenders = _offenders(RegExp(
      r'\b(size|width|height|fontSize|radius|strokeWidth|elevation|thickness):\s*[1-9][0-9]*(\.[0-9]+)?\b'
      r'|EdgeInsets\.[a-zA-Z]+\([^)]*[(, :][1-9][0-9]*(\.[0-9]+)?[,)]'
      r'|SizedBox\((height|width): [1-9]',
    ));
    expect(offenders, isEmpty, reason: 'use a token:\n${offenders.join('\n')}');
  });

  test('no currency symbol typed into a pro screen: amounts go through eur()', () {
    final offenders = _offenders(RegExp('€'), roots: ['lib/features/pro']);
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('no amount written beside a raw currency code: money goes through RMoney', () {
    final offenders = _offenders(
      RegExp(r'\$\{[^}]*currency\}\s*\$|\beur\(|\$_symbol'),
      roots: ['lib/features/pro', 'lib/features/shared', 'lib/design/components'],
    );
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('no date or time formatted outside RDates in a pro or shared screen', () {
    final offenders = _offenders(
      RegExp(
        r'DateFormat\(|MaterialLocalizations\.of\(context\)\.format|TimeOfDay[^;]*\.format\(|'
        r'\.(day|month|year|hour|minute|weekday)\}|_months\b|_weekdays?\b|_monthNames\b|\b(AM|PM)\b',
      ),
      roots: ['lib/features/pro', 'lib/features/shared'],
    );
    expect(offenders, isEmpty, reason: 'use RDates (lib/core/format/dates.dart):\n${offenders.join('\n')}');
  });

  test('no raw TextStyle in a pro screen: text styles come from the theme', () {
    final offenders = _offenders(RegExp(r'\bTextStyle\('));
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('no Material switch in a pro screen: switches are RSwitch', () {
    final offenders = _offenders(RegExp(r'\bSwitchListTile\(|(?<![A-Za-z])Switch\('));
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  group('status chips', () {
    Future<BoxDecoration> pump(WidgetTester tester, ThemeData theme, RStatusChipKind kind) async {
      await tester.pumpWidget(MaterialApp(theme: theme, home: Scaffold(body: RStatusChip(label: 'Rookie', kind: kind))));
      return tester.widget<Container>(find.byType(Container).first).decoration! as BoxDecoration;
    }

    testWidgets('on the pro app\'s light ground a positive status is a filled chip with a light label', (tester) async {
      final decoration = await pump(tester, buildProTheme(), RStatusChipKind.positive);
      expect(decoration.color, RDevelop.develop500);
      expect(tester.widget<Text>(find.text('Rookie')).style!.color, RInk.i050);
      expect(contrastRatio(RInk.i050, RDevelop.develop500), greaterThanOrEqualTo(4.5));
    });

    testWidgets('the client app\'s dark chips are unchanged', (tester) async {
      final decoration = await pump(tester, buildClientTheme(), RStatusChipKind.positive);
      expect(decoration.color, isNull);
      expect(tester.widget<Text>(find.text('Rookie')).style!.color, RDevelop.develop500);
    });

    testWidgets('no status is shown by coloured text on paper', (tester) async {
      for (final kind in RStatusChipKind.values) {
        await pump(tester, buildProTheme(), kind);
        final colour = tester.widget<Text>(find.text('Rookie')).style!.color!;
        expect(colour == RDevelop.develop500, isFalse, reason: '$kind uses green text on light');
      }
    });
  });
}
