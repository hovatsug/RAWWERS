// The pro app's "Contact sheet" identity: a dark header band over a light
// paper body. Every colour pair the brief names is checked against WCAG AA
// here, so a token edit that drops one below its bar fails a test, not a
// photographer reading a screen in the sun.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/design/components/r_header_band.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/design/tokens.dart';

import 'contrast_test.dart' show contrastRatio;

void main() {
  group('AA contrast of every pair in the brief', () {
    // (what, foreground, background, minimum)
    final pairs = <(String, Color, Color, double)>[
      ('body text on paper', RInk.i950, RPaper.paper, 4.5),
      ('secondary text on paper', RInk.i600, RPaper.paper, 4.5),
      ('body text on a card', RInk.i950, RPaper.card, 4.5),
      ('secondary text on a card', RInk.i600, RPaper.card, 4.5),
      ('link (meter700) on paper', RAccent.meter700, RPaper.paper, 4.5),
      ('link (meter700) on a card', RAccent.meter700, RPaper.card, 4.5),
      ('error text on a card', RShade.shade600, RPaper.card, 4.5),
      ('primary button label on its fill', RInk.i050, RAccent.meter700, 4.5),
      ('band text', RInk.i050, RInk.i950, 4.5),
      ('band meta', RInk.i400, RInk.i950, 4.5),
      ('band button label on its fill', RInk.i950, RAccent.meter500Band, 4.5),
      ('error text on paper', RShade.shade600, RPaper.paper, 4.5),
      ('status chip label on the developed fill', RInk.i050, RDevelop.develop500, 4.5),
      ('status chip label on the stopped fill', RInk.i050, RShade.shade600, 4.5),
      ('brackets and needle on the band', RAccent.meter500, RInk.i950, 3.0),
      ('scale fill and needle on paper', RAccent.meter700, RPaper.paper, 3.0),
      ('input border on a card', RInk.i500, RPaper.card, 3.0),
      ('switch and control edges on a card', RInk.i500, RPaper.card, 3.0),
      ('input border on paper', RInk.i500, RPaper.paper, 3.0),
    ];
    for (final (what, fg, bg, min) in pairs) {
      test('$what clears $min:1', () {
        expect(contrastRatio(fg, bg), greaterThanOrEqualTo(min), reason: '${contrastRatio(fg, bg).toStringAsFixed(2)}:1');
      });
    }

    test('why meter500Band exists: meter500 behind a dark label is just under 4.5:1', () {
      expect(contrastRatio(RInk.i950, RAccent.meter500), lessThan(4.5));
    });

    test('why meter700 never goes on the band: it all but disappears', () {
      expect(contrastRatio(RAccent.meter700, RInk.i950), lessThan(3.0));
    });
  });

  group('the pro theme', () {
    final pro = buildProTheme();

    test('the scaffold is paper, not white', () => expect(pro.scaffoldBackgroundColor, RPaper.paper));

    test('a card is told apart from paper by its hairline, not by colour alone', () {
      // White on #F2F2F0 is 1.12:1: the edge is the hairline's job. Cards are
      // not controls, so the hairline is not held to 3:1 - controls are.
      final shape = pro.cardTheme.shape! as RoundedRectangleBorder;
      expect(shape.side.style, BorderStyle.solid);
      expect(shape.side.width, greaterThan(0));
    });

    test('cards, sheets and dialogs are white, the card with a hairline border', () {
      expect(pro.cardTheme.color, RPaper.card);
      expect(pro.dialogTheme.backgroundColor, RPaper.card);
      expect(pro.bottomSheetTheme.backgroundColor, RPaper.card);
      expect(pro.bottomSheetTheme.modalBackgroundColor, RPaper.card);
      final shape = pro.cardTheme.shape! as RoundedRectangleBorder;
      expect(shape.side.color, RInk.i200);
      expect(shape.borderRadius, BorderRadius.circular(RRadius.surface));
    });

    test('the accent on light is meter700, so links and active marks are legible', () {
      expect(pro.colorScheme.primary, RAccent.meter700);
    });

    test('controls are 4px, not 8px', () {
      final shape = pro.elevatedButtonTheme.style!.shape!.resolve({})! as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(RRadius.control));
    });

    test('outlined and text buttons are 4px rectangles too, never pills', () {
      for (final style in [pro.outlinedButtonTheme.style!, pro.textButtonTheme.style!]) {
        final shape = style.shape!.resolve({})! as RoundedRectangleBorder;
        expect(shape.borderRadius, BorderRadius.circular(RRadius.control));
      }
    });

    test('an input boundary clears 3:1', () {
      final border = pro.inputDecorationTheme.enabledBorder! as OutlineInputBorder;
      expect(border.borderSide.color, RInk.i500);
    });

    test('on the band, the primary button is meter500Band with a dark label', () {
      final band = RHeaderBand.themeFor(pro);
      final style = band.elevatedButtonTheme.style!;
      expect(style.backgroundColor!.resolve({}), RAccent.meter500Band);
      expect(style.foregroundColor!.resolve({}), RInk.i950);
      expect(band.colorScheme.primary, RAccent.meter500, reason: 'brackets and needles on the band stay meter500');
      expect(band.textTheme.bodyLarge!.color, RInk.i050);
      expect(band.textTheme.bodySmall!.color, RInk.i400);
    });
  });

  test('the client theme is untouched by any of this', () {
    final client = buildClientTheme();
    expect(client.scaffoldBackgroundColor, RInk.i950);
    expect(client.colorScheme.primary, RAccent.meter500);
    expect(client.cardTheme.color, RInk.i900);
    final button = client.elevatedButtonTheme.style!;
    expect(button.backgroundColor!.resolve({}), RAccent.meter700);
    expect((button.shape!.resolve({})! as RoundedRectangleBorder).borderRadius, BorderRadius.circular(RRadius.surface));
    expect(client.navigationBarTheme.backgroundColor, RInk.i950);
  });
}
