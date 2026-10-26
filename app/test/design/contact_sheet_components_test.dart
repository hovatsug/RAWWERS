// The Contact sheet primitives: the dark band, the viewfinder frame, the
// exposure scale, the section label and the rectangular switch.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/design/components/r_exposure_scale.dart';
import 'package:rawwers/design/components/r_header_band.dart';
import 'package:rawwers/design/components/r_section_label.dart';
import 'package:rawwers/design/components/r_switch.dart';
import 'package:rawwers/design/components/r_viewfinder_frame.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/design/tokens.dart';

Future<void> _pump(WidgetTester tester, Widget child, {double textScale = 1.0}) => tester.pumpWidget(
      MaterialApp(
        theme: buildProTheme(),
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale), padding: const EdgeInsets.only(top: 47)),
          child: Scaffold(body: child),
        ),
      ),
    );

void main() {
  group('RHeaderBand', () {
    testWidgets('is the client app\'s dark, and its text is light', (tester) async {
      await _pump(tester, const RHeaderBand(child: Text('Available to withdraw')));
      final ground = tester.widget<ColoredBox>(find.byKey(RHeaderBand.groundKey));
      expect(ground.color, RInk.i950);
      final text = tester.widget<Text>(find.text('Available to withdraw'));
      final style = DefaultTextStyle.of(tester.element(find.text('Available to withdraw'))).style.merge(text.style);
      expect(style.color, RInk.i050);
    });

    testWidgets('reaches under the status bar and keeps its content below it', (tester) async {
      await _pump(tester, const RHeaderBand(child: Text('Top')));
      expect(tester.getTopLeft(find.byKey(RHeaderBand.groundKey)).dy, 0, reason: 'the band must fill the status bar area');
      expect(tester.getTopLeft(find.text('Top')).dy, greaterThanOrEqualTo(47), reason: 'content under the status bar');
    });

    testWidgets('asks for light status bar icons', (tester) async {
      await _pump(tester, const RHeaderBand(child: Text('x')));
      final region = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(find.byType(AnnotatedRegion<SystemUiOverlayStyle>).first);
      expect(region.value.statusBarIconBrightness, Brightness.light);
      expect(region.value.statusBarBrightness, Brightness.dark);
    });

    testWidgets('a primary button on it is meter500Band with a dark label', (tester) async {
      await _pump(tester, RHeaderBand(child: ElevatedButton(onPressed: () {}, child: const Text('Request payout'))));
      final material = tester.widget<Material>(find.descendant(of: find.byType(ElevatedButton), matching: find.byType(Material)).first);
      expect(material.color, RAccent.meter500Band);
    });

    testWidgets('ends in the dark hairline', (tester) async {
      await _pump(tester, const RHeaderBand(child: Text('x')));
      final edge = tester.widget<DecoratedBox>(find.byKey(RHeaderBand.hairlineKey));
      expect((edge.decoration as BoxDecoration).border!.bottom.color, RInk.i800);
    });
  });

  group('RViewfinderFrame', () {
    testWidgets('draws four brackets in the accent, from the motif tokens', (tester) async {
      await _pump(tester, const RViewfinderFrame(child: Text('£41.95')));
      final paint = tester.widget<CustomPaint>(find.byKey(RViewfinderFrame.bracketsKey));
      final painter = paint.painter! as ViewfinderPainter;
      expect(painter.color, RAccent.meter700, reason: 'on paper, the accent on light');
      expect(painter.arm, RMotif.bracketArm);
      expect(painter.stroke, RMotif.bracketStroke);
    });

    testWidgets('on the band, the brackets are meter500', (tester) async {
      await _pump(tester, const RHeaderBand(child: RViewfinderFrame(child: Text('£41.95'))));
      final painter = tester.widget<CustomPaint>(find.byKey(RViewfinderFrame.bracketsKey)).painter! as ViewfinderPainter;
      expect(painter.color, RAccent.meter500);
    });

    testWidgets('the brackets are decoration: a screen reader hears only the number', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pump(tester, const RViewfinderFrame(child: Text('£41.95')));
      expect(find.bySemanticsLabel('£41.95'), findsOneWidget);
      expect(
        find.ancestor(of: find.byKey(RViewfinderFrame.bracketsKey), matching: find.byType(ExcludeSemantics)),
        findsOneWidget,
      );
      semantics.dispose();
    });

    testWidgets('the brackets surround the number with room to spare', (tester) async {
      await _pump(tester, const Center(child: RViewfinderFrame(child: Text('£41.95'))));
      final frame = tester.getRect(find.byKey(RViewfinderFrame.bracketsKey));
      final number = tester.getRect(find.text('£41.95'));
      expect(frame.left, lessThan(number.left));
      expect(frame.right, greaterThan(number.right));
      expect(frame.top, lessThan(number.top));
      expect(frame.bottom, greaterThan(number.bottom));
    });
  });

  group('RExposureScale', () {
    testWidgets('says what it measures to a screen reader', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pump(tester, const RExposureScale(value: 0.7, semanticLabel: '70 percent to Tier 3'));
      expect(find.bySemanticsLabel('70 percent to Tier 3'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('fills to its value, with the motif sizes and the accent', (tester) async {
      await _pump(tester, const SizedBox(width: 200, child: RExposureScale(value: 0.7, semanticLabel: 'x')));
      final painter = tester.widget<CustomPaint>(find.byKey(RExposureScale.scaleKey)).painter! as ExposureScalePainter;
      expect(painter.value, 0.7);
      expect(painter.fill, RMotif.scaleFill);
      expect(painter.needle, RMotif.scaleNeedle);
      expect(painter.ticks, RMotif.scaleTicks);
      expect(painter.accent, RAccent.meter700);
    });

    testWidgets('clamps a value outside 0 to 1', (tester) async {
      await _pump(tester, const RExposureScale(value: 1.7, semanticLabel: 'x'));
      expect((tester.widget<CustomPaint>(find.byKey(RExposureScale.scaleKey)).painter! as ExposureScalePainter).value, 1.0);
      await _pump(tester, const RExposureScale(value: -0.2, semanticLabel: 'x'));
      expect((tester.widget<CustomPaint>(find.byKey(RExposureScale.scaleKey)).painter! as ExposureScalePainter).value, 0.0);
    });

    testWidgets('does not animate', (tester) async {
      await _pump(tester, const RExposureScale(value: 0.3, semanticLabel: 'x'));
      expect(tester.hasRunningAnimations, isFalse);
      expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
    });
  });

  group('RSectionLabel', () {
    testWidgets('is 11px, medium, tracked 0.14em, upper case, and reads naturally', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pump(tester, const RSectionLabel('Needs you'));
      final text = tester.widget<Text>(find.text('NEEDS YOU'));
      expect(text.style!.fontSize, RType.caption);
      expect(text.style!.letterSpacing, closeTo(RType.caption * RType.trackingSection, 1e-9));
      expect(text.style!.fontVariations, [RType.weightMedium]);
      expect(find.bySemanticsLabel('Needs you'), findsOneWidget, reason: 'spelt out, not read letter by letter');
      semantics.dispose();
    });
  });

  group('RSwitch', () {
    testWidgets('is rectangular: a 4px track, never a stadium', (tester) async {
      await _pump(tester, RSwitch(value: true, onChanged: (_) {}, semanticLabel: 'Available now'));
      final track = tester.widget<DecoratedBox>(find.byKey(RSwitch.trackKey));
      expect((track.decoration as BoxDecoration).borderRadius, BorderRadius.circular(RRadius.control));
    });

    testWidgets('keeps a 44px touch target', (tester) async {
      await _pump(tester, Center(child: RSwitch(value: false, onChanged: (_) {}, semanticLabel: 'x')));
      final size = tester.getSize(find.byType(RSwitch));
      expect(size.width, greaterThanOrEqualTo(rMinTouchTarget));
      expect(size.height, greaterThanOrEqualTo(rMinTouchTarget));
    });

    testWidgets('toggles, and says so the way a Material switch does', (tester) async {
      var value = false;
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(MaterialApp(
        theme: buildProTheme(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => RSwitch(value: value, onChanged: (v) => setState(() => value = v), semanticLabel: 'Available now'),
          ),
        ),
      ));
      expect(
        tester.getSemantics(find.byType(RSwitch)),
        matchesSemantics(label: 'Available now', hasToggledState: true, isToggled: false, hasEnabledState: true, isEnabled: true, hasTapAction: true, isFocusable: true),
      );
      await tester.tap(find.byType(RSwitch));
      await tester.pump();
      expect(value, isTrue);
      expect(
        tester.getSemantics(find.byType(RSwitch)),
        matchesSemantics(label: 'Available now', hasToggledState: true, isToggled: true, hasEnabledState: true, isEnabled: true, hasTapAction: true, isFocusable: true),
      );
      semantics.dispose();
    });

    testWidgets('disabled: says so and does nothing', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pump(tester, const RSwitch(value: true, onChanged: null, semanticLabel: 'Available now'));
      expect(
        tester.getSemantics(find.byType(RSwitch)),
        matchesSemantics(label: 'Available now', hasToggledState: true, isToggled: true, hasEnabledState: true, isEnabled: false, isFocusable: false),
      );
      await tester.tap(find.byType(RSwitch), warnIfMissed: false);
      semantics.dispose();
    });

    testWidgets('on uses the accent, off a neutral with a visible boundary', (tester) async {
      await _pump(tester, RSwitch(value: true, onChanged: (_) {}, semanticLabel: 'x'));
      expect(((tester.widget<DecoratedBox>(find.byKey(RSwitch.trackKey)).decoration) as BoxDecoration).color, RAccent.meter700);
      await _pump(tester, RSwitch(value: false, onChanged: (_) {}, semanticLabel: 'x'));
      final off = tester.widget<DecoratedBox>(find.byKey(RSwitch.trackKey)).decoration as BoxDecoration;
      expect(off.border!.top.color, RInk.i500, reason: 'an off switch still needs a 3:1 boundary');
    });
  });

  testWidgets('nothing here clips at text scale 1.3', (tester) async {
    await _pump(
      tester,
      const RHeaderBand(child: Column(children: [RSectionLabel('Available to withdraw'), RViewfinderFrame(child: Text('£1,234.56'))])),
      textScale: 1.3,
    );
    expect(tester.takeException(), isNull);
  });
}
