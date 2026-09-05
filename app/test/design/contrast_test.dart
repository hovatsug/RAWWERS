import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
