import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_package_price.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/design/tokens.dart';

/// WCAG 2.1 relative luminance / contrast ratio, computed directly rather
/// than pulled in as a dependency - this is the same formula the F-4 design
/// plan's accent-candidate analysis was hand-calculated against. A
/// regression test for that math, so a future token edit can't silently
/// drop a pairing below AA without someone noticing.
double _relativeLuminance(Color c) {
  double channel(double c) {
    return c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = channel(c.r);
  final g = channel(c.g);
  final b = channel(c.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double contrastRatio(Color a, Color b) {
  final la = _relativeLuminance(a);
  final lb = _relativeLuminance(b);
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  test('text-primary on background clears AA normal text (4.5:1) in both themes', () {
    expect(contrastRatio(RInk.i050, RInk.i950), greaterThanOrEqualTo(4.5)); // client
    expect(contrastRatio(RInk.i950, RInk.i050), greaterThanOrEqualTo(4.5)); // pro
  });

  test('button label (i050) on button fill (meter700) clears AA normal text (4.5:1)', () {
    expect(contrastRatio(RInk.i050, RAccent.meter700), greaterThanOrEqualTo(4.5));
  });

  test('stopped-chip text (i050) on shade600 fill clears AA normal text (4.5:1)', () {
    expect(contrastRatio(RInk.i050, RShade.shade600), greaterThanOrEqualTo(4.5));
  });

  test('accent (meter500) clears AA for large text/graphical objects (3:1) on both theme backgrounds', () {
    expect(contrastRatio(RAccent.meter500, RInk.i950), greaterThanOrEqualTo(3.0));
    expect(contrastRatio(RAccent.meter500, RInk.i050), greaterThanOrEqualTo(3.0));
  });

  test(
    'accent (meter500) does not clear AA normal text (4.5:1) on both theme backgrounds simultaneously - '
    'documents why RTextLink always underlines rather than relying on color alone',
    () {
      final onDark = contrastRatio(RAccent.meter500, RInk.i950);
      final onLight = contrastRatio(RAccent.meter500, RInk.i050);
      expect(onDark < 4.5 || onLight < 4.5, isTrue);
    },
  );

  // -------------------------------------------------------------------------
  // Text on a card, not just on the page background.
  //
  // Everything above pairs a colour with RInk.i950 or RInk.i050 - the page.
  // Cards are a different surface, one step in from the page, and nothing
  // checked text against them. That gap hid a real bug: the package price's
  // secondary line rendered in `colorScheme.outline`, which is the card's own
  // hairline border colour, giving 1.11:1 on the card fill in both themes.
  // The rate above it was legible only because it set no colour at all.
  // -------------------------------------------------------------------------

  test('secondary text on a card clears AA normal text (4.5:1) in both themes', () {
    final client = buildClientTheme();
    final pro = buildProTheme();

    expect(
      contrastRatio(client.colorScheme.onSurfaceVariant, client.cardTheme.color!),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      contrastRatio(pro.colorScheme.onSurfaceVariant, pro.cardTheme.color!),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('outline is a border colour and must never be used as text on a card', () {
    // Pinned deliberately. `outline` reads like a plausible choice for muted
    // text, and it is one step from the card colour by design - so reaching
    // for it produces text that is very nearly invisible rather than merely
    // dim. Anyone who tries it should find this test, not a screenshot.
    final client = buildClientTheme();
    final pro = buildProTheme();

    expect(contrastRatio(client.colorScheme.outline, client.cardTheme.color!), lessThan(4.5));
    expect(contrastRatio(pro.colorScheme.outline, pro.cardTheme.color!), lessThan(4.5));
  });

  for (final (name, theme, card) in [
    ('client', buildClientTheme(), buildClientTheme().cardTheme.color!),
    ('pro', buildProTheme(), buildProTheme().cardTheme.color!),
  ]) {
    testWidgets('the package price secondary line is legible on a card ($name theme)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: RCard(
              child: RPackagePrice(
                entryRate: '5.07',
                minimumPhotos: 25,
                startingTotal: '93.24',
                currency: 'EUR',
              ),
            ),
          ),
        ),
      );

      final line = tester.widget<Text>(find.textContaining('minimum 25 photos'));
      final colour = line.style?.color;
      expect(colour, isNotNull, reason: 'the price line sets no colour, so this test proves nothing');

      final ratio = contrastRatio(colour!, card);
      expect(
        ratio,
        greaterThanOrEqualTo(4.5),
        reason: 'the starting total renders at ${ratio.toStringAsFixed(2)}:1 on the card, '
            'which is not readable',
      );
    });
  }

  // -------------------------------------------------------------------------
  // The accent's own rule, enforced rather than documented.
  // -------------------------------------------------------------------------

  test('the accent cannot clear AA normal text on a card in either theme', () {
    // Why the rule exists. meter500 is deliberately one hue, used in both
    // themes, and no single accent clears 4.5:1 against both a dark and a
    // light surface at once. It passes the 3:1 bar for graphical objects,
    // which is what lets it carry an icon.
    final client = buildClientTheme();
    final pro = buildProTheme();

    expect(contrastRatio(RAccent.meter500, client.cardTheme.color!), lessThan(4.5));
    expect(contrastRatio(RAccent.meter500, pro.cardTheme.color!), lessThan(4.5));
    expect(contrastRatio(RAccent.meter500, client.cardTheme.color!), greaterThanOrEqualTo(3.0));
    expect(contrastRatio(RAccent.meter500, pro.cardTheme.color!), greaterThanOrEqualTo(3.0));
  });

  testWidgets('accent-coloured body text carries a non-colour signal beside it', (tester) async {
    // The curve line keeps the accent because it is the fact most likely to
    // change what a client books. That is only allowed with a second signal
    // that does not depend on colour - an icon here, not an underline, which
    // means "link" in this design language.
    await tester.pumpWidget(
      MaterialApp(
        theme: buildClientTheme(),
        home: const Scaffold(
          body: RCard(
            child: RPackagePrice(
              entryRate: '5.07',
              minimumPhotos: 25,
              startingTotal: '93.24',
              currency: 'EUR',
            ),
          ),
        ),
      ),
    );

    final line = find.textContaining('drops as you choose more');
    expect(line, findsOneWidget);

    final accentIcon = find.descendant(
      of: find.ancestor(of: line, matching: find.byType(Row)).first,
      matching: find.byType(Icon),
    );
    expect(
      accentIcon,
      findsOneWidget,
      reason: 'accent-coloured body text with nothing but colour to carry it, at 3.99:1',
    );
    expect(tester.widget<Icon>(accentIcon).color, RAccent.meter500);
  });
}
