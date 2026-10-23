// The niche banner: one component for every place a niche is shown, drawing
// the style the server sends.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/niche_banner_image_view.dart';
import 'package:rawwers/api/models/niche_banner_style.dart';
import 'package:rawwers/api/models/niche_banner_view.dart';
import 'package:rawwers/design/components/r_network_photo.dart';
import 'package:rawwers/design/components/r_niche_banner.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/design/tokens.dart';

// A real 1x1 PNG, so the placeholder decodes.
const _pixel = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';

NicheBannerView _image({double focalX = 0.5, double focalY = 0.5, double scrim = 0.4, String? tagline = 'Kept quietly'}) => NicheBannerView(
      style: NicheBannerStyle.image,
      name: 'Weddings',
      tagline: tagline,
      image: NicheBannerImageView(
        mediaAssetId: 'm',
        tileUrl: 'https://example.test/tile.jpg',
        heroUrl: 'https://example.test/hero.jpg',
        placeholder: _pixel,
        altText: 'A couple walking out of a church',
        focalX: focalX,
        focalY: focalY,
        scrimOpacity: scrim,
        width: 2400,
        height: 1350,
      ),
    );

const _text = NicheBannerView(style: NicheBannerStyle.text, name: 'Weddings', tagline: 'Kept quietly');

Future<void> _pump(WidgetTester tester, NicheBannerView? banner, {RNicheBannerShape shape = RNicheBannerShape.tile, VoidCallback? onTap}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildClientTheme(),
      home: Scaffold(
        body: RNicheBanner(title: 'Weddings in Lisbon', banner: banner, shape: shape, onTap: onTap),
      ),
    ),
  );
}

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  group('text only', () {
    testWidgets('makes no image request at all', (tester) async {
      await _pump(tester, _text, shape: RNicheBannerShape.hero);
      expect(find.byType(Image), findsNothing);
      expect(find.byType(RNetworkPhoto), findsNothing);
      expect(find.byKey(const ValueKey('niche-banner-text')), findsOneWidget);
    });

    testWidgets('even when the server still has an image on file', (tester) async {
      // Switching to Text only keeps the image; the app must not draw it.
      final both = _image().copyWith(style: NicheBannerStyle.text);
      await _pump(tester, both);
      expect(find.byType(RNetworkPhoto), findsNothing);
    });

    testWidgets('is a designed banner: the token ground, the name and, on the hero, the tagline', (tester) async {
      await _pump(tester, _text, shape: RNicheBannerShape.hero);
      final ground = tester.widget<ColoredBox>(find.byKey(const ValueKey('niche-banner-text')));
      expect(ground.color, RBanner.textGround);
      expect(find.text('Weddings in Lisbon'), findsOneWidget);
      expect(find.text('Kept quietly'), findsOneWidget);
    });

    testWidgets('the tile leaves the tagline to the hero', (tester) async {
      await _pump(tester, _text);
      expect(find.text('Kept quietly'), findsNothing);
    });

    test('its words clear AA contrast on its ground', () {
      expect(_contrast(RBanner.textName, RBanner.textGround), greaterThanOrEqualTo(4.5));
      expect(_contrast(RBanner.textTagline, RBanner.textGround), greaterThanOrEqualTo(4.5));
    });
  });

  group('image', () {
    testWidgets('the tile loads the tile copy, the hero the hero copy', (tester) async {
      await _pump(tester, _image());
      expect(tester.widget<RNetworkPhoto>(find.byType(RNetworkPhoto)).url, 'https://example.test/tile.jpg');
      await _pump(tester, _image(), shape: RNicheBannerShape.hero);
      expect(tester.widget<RNetworkPhoto>(find.byType(RNetworkPhoto)).url, 'https://example.test/hero.jpg');
    });

    testWidgets('is cropped around the focal point on every shape', (tester) async {
      for (final shape in RNicheBannerShape.values) {
        await _pump(tester, _image(focalX: 0.25, focalY: 0.8), shape: shape);
        final alignment = tester.widget<RNetworkPhoto>(find.byType(RNetworkPhoto)).alignment;
        expect(alignment.x, closeTo(-0.5, 1e-9), reason: '$shape');
        expect(alignment.y, closeTo(0.6, 1e-9), reason: '$shape');
      }
    });

    testWidgets('the corners of the image map to the corners of the crop', (tester) async {
      await _pump(tester, _image(focalX: 0, focalY: 1));
      expect(tester.widget<RNetworkPhoto>(find.byType(RNetworkPhoto)).alignment, Alignment.bottomLeft);
    });

    testWidgets('the scrim is as dark as the server measured this image needs', (tester) async {
      await _pump(tester, _image(scrim: 0.62));
      final scrim = tester.widgetList<DecoratedBox>(find.descendant(of: find.byKey(const ValueKey('niche-banner-image')), matching: find.byType(DecoratedBox)))
          .map((box) => box.decoration)
          .whereType<BoxDecoration>()
          .firstWhere((d) => d.gradient != null);
      final colors = (scrim.gradient! as LinearGradient).colors;
      expect(colors.last.a, closeTo(0.62, 0.01));
      expect(colors.first.a, 0);
    });

    testWidgets('the blurred placeholder stands in while the image loads', (tester) async {
      await _pump(tester, _image());
      expect(tester.widget<RNetworkPhoto>(find.byType(RNetworkPhoto)).loading, isA<Image>());
    });

    testWidgets('the alt text describes the image to a screen reader', (tester) async {
      await _pump(tester, _image());
      expect(tester.widget<RNetworkPhoto>(find.byType(RNetworkPhoto)).semanticLabel, 'A couple walking out of a church');
    });
  });

  group('the fallback', () {
    testWidgets('an image niche with nothing uploaded draws the neutral ground, with no image request', (tester) async {
      await _pump(tester, const NicheBannerView(style: NicheBannerStyle.image, name: 'Weddings'));
      expect(find.byKey(const ValueKey('niche-banner-neutral')), findsOneWidget);
      expect(find.byType(RNetworkPhoto), findsNothing);
      expect(find.text('Weddings in Lisbon'), findsOneWidget);
    });

    testWidgets('no banner at all draws the same', (tester) async {
      await _pump(tester, null);
      expect(find.byKey(const ValueKey('niche-banner-neutral')), findsOneWidget);
    });
  });

  testWidgets('a tappable banner is a button named by its title', (tester) async {
    var tapped = false;
    await _pump(tester, _text, onTap: () => tapped = true);
    final semantics = tester.ensureSemantics();
    expect(find.bySemanticsLabel(RegExp('Weddings in Lisbon')), findsWidgets);
    semantics.dispose();
    await tester.tap(find.byType(RNicheBanner));
    expect(tapped, isTrue);
  });
}
