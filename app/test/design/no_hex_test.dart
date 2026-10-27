// Every colour in a pro screen comes from the tokens. A hex literal outside
// design/ is how a second accent, or a white that is not paper, gets in.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_header_band.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/design/tokens.dart';

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

  // Meter 500 is 4.13:1 on white and less on paper: a graphic colour on
  // light, never a text colour. Text takes the theme's accent (meter700 on
  // light). The band is dark, so the one place meter500 text may be named
  // directly is the band's own theme.
  test('no Meter 500 named as a text colour in the pro app or a shared component', () {
    final text = RegExp(
      r'(copyWith|TextStyle)\((?:[^()]|\([^()]*\))*?color:\s*RAccent\.meter500\b(?!Band)'
      r'|foregroundColor:\s*RAccent\.meter500\b(?!Band)',
    );
    final offenders = <String>[];
    for (final root in ['lib/features/pro', 'lib/features/shared', 'lib/design/components', 'lib/design/theme_pro.dart']) {
      final entity = FileSystemEntity.isDirectorySync(root) ? Directory(root).listSync(recursive: true) : [File(root)];
      for (final file in entity.whereType<File>()) {
        if (!file.path.endsWith('.dart') || file.path.endsWith('r_header_band.dart')) continue;
        for (final match in text.allMatches(file.readAsStringSync())) {
          offenders.add('${file.path}: ${match.group(0)!.replaceAll(RegExp(r'\s+'), ' ')}');
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  group('a text link takes the accent of the surface it is on', () {
    Future<Color?> linkColour(WidgetTester tester, ThemeData theme, {bool onBand = false}) async {
      final link = RTextLink(label: 'Verify your email', onPressed: () {});
      await tester.pumpWidget(MaterialApp(theme: theme, home: Scaffold(body: onBand ? RHeaderBand(child: link) : link)));
      return tester.widget<Text>(find.text('Verify your email')).style?.color;
    }

    testWidgets('meter700 on the pro app\'s light surfaces', (tester) async {
      expect(await linkColour(tester, buildProTheme()), RAccent.meter700);
    });
    testWidgets('meter500 on the pro app\'s dark band', (tester) async {
      expect(await linkColour(tester, buildProTheme(), onBand: true), RAccent.meter500);
    });
    testWidgets('meter500 on the client app, unchanged', (tester) async {
      expect(await linkColour(tester, buildClientTheme()), RAccent.meter500);
    });
  });
}
