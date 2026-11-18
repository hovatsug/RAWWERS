import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/design/components/r_cover_photo.dart';
import 'package:rawwers/design/components/r_network_photo.dart';

/// A portrait cover is cut around its upper third, not its middle, so the
/// card, the tile and the profile header keep a person's head. Landscapes,
/// squares and photos whose size never arrived are cut from the centre.
void main() {
  group('coverAlignment', () {
    test('a 2:3 portrait on a 3:2 card is centred on its upper-third line', () {
      final a = coverAlignment(photoWidth: 1702, photoHeight: 2550, frame: const Size(361, 240.7));
      expect(a.x, 0);
      expect(a.y, closeTo(-0.6, 0.01));
      // The shown band is 44% of the height; its centre sits a third of the way down.
      const shown = (240.7 / 361) / (2550 / 1702);
      final top = (a.y + 1) / 2 * (1 - shown);
      expect(top + shown / 2, closeTo(1 / 3, 0.01));
    });

    test('in a square tile the band reaches the top edge, never above it', () {
      final a = coverAlignment(photoWidth: 342, photoHeight: 512, frame: const Size(148, 148));
      expect(a.y, closeTo(-1, 0.01));
    });

    test('a 3:4 portrait in a square tile stops at the top edge, never above it', () {
      final a = coverAlignment(photoWidth: 1536, photoHeight: 2048, frame: const Size(148, 148));
      expect(a.y, -1);
    });

    test('in the profile header it leans up too', () {
      final a = coverAlignment(photoWidth: 1702, photoHeight: 2550, frame: const Size(393, 280));
      expect(a.y, lessThan(-0.5));
    });

    test('a landscape photo stays centred', () {
      expect(coverAlignment(photoWidth: 2048, photoHeight: 1365, frame: const Size(361, 240.7)), Alignment.center);
      expect(coverAlignment(photoWidth: 2048, photoHeight: 1365, frame: const Size(148, 148)), Alignment.center);
    });

    test('a 4:3 landscape on a 3:2 card is cut a little top and bottom, from the centre', () {
      expect(coverAlignment(photoWidth: 2048, photoHeight: 1536, frame: const Size(361, 240.7)), Alignment.center);
    });

    test('a square photo stays centred', () {
      expect(coverAlignment(photoWidth: 1000, photoHeight: 1000, frame: const Size(361, 240.7)), Alignment.center);
    });

    test('no size from the server is the centre, not a crash', () {
      expect(coverAlignment(photoWidth: null, photoHeight: null, frame: const Size(361, 240.7)), Alignment.center);
      expect(coverAlignment(photoWidth: 1702, photoHeight: null, frame: const Size(361, 240.7)), Alignment.center);
      expect(coverAlignment(photoWidth: 0, photoHeight: 0, frame: const Size(361, 240.7)), Alignment.center);
    });

    test('a frame that shows the whole height, or has no size yet, is the centre', () {
      expect(coverAlignment(photoWidth: 1000, photoHeight: 2000, frame: const Size(100, 300)), Alignment.center);
      expect(coverAlignment(photoWidth: 1000, photoHeight: 2000, frame: Size.zero), Alignment.center);
      expect(coverAlignment(photoWidth: 1000, photoHeight: 2000, frame: const Size(double.infinity, 200)), Alignment.center);
    });
  });

  testWidgets('RCoverPhoto hands the leaned alignment to the photo it shows', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 300,
            height: 200,
            child: RCoverPhoto(url: 'https://x.test/p.jpg', photoWidth: 1702, photoHeight: 2550),
          ),
        ),
      ),
    );
    final photo = tester.widget<RNetworkPhoto>(find.byType(RNetworkPhoto));
    expect(photo.url, 'https://x.test/p.jpg');
    expect(photo.alignment.y, closeTo(-0.6, 0.01));
  });
}
