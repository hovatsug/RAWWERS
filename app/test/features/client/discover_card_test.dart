import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/client_discover_card.dart';
import 'package:rawwers/design/components/r_network_photo.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/features/shared/discover/discover_card.dart';

/// Discover is the first screen a client sees, so the cover photo reaching the
/// screen is the thing worth pinning down. `Image.network` cannot actually
/// fetch under `flutter_test` - there is no real HTTP client - so these assert
/// the widget tree rather than pixels: that the server's `cover_url` becomes
/// the image's URL, and that its absence degrades to a placeholder instead of
/// a broken frame.
ClientDiscoverCard _card({String? coverUrl}) => ClientDiscoverCard(
      proUserId: 'pro-1',
      displayName: 'Alex Lens',
      headline: 'Portraits specialist',
      coverUrl: coverUrl,
      city: 'New York',
      country: 'US',
      minPrice: '120.00',
      maxPrice: '340.00',
      currency: 'EUR',
      avgRating: '4.80',
      reviewCount: 12,
      topNiches: const [
        {'slug': 'weddings'},
        {'slug': 'portraits'},
      ],
      portfolioPhotoCount: 3,
      portfolioVideoCount: 0,
    );

Widget _wrap(ClientDiscoverCard card) => MaterialApp(
      theme: buildClientTheme(),
      home: Scaffold(
        // A list, like the real screen: a 3:2 cover on the 800x600 default
        // test surface is taller than the viewport and would overflow for
        // reasons that have nothing to do with the card.
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [DiscoverCard(card: card, onTap: () {})],
        ),
      ),
    );

/// A phone, not the 800x600 default - card layout is width-sensitive.
void _usePhoneSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('renders the cover photo the server resolved', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap(_card(coverUrl: 'https://media.example/cover.jpg')));

    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as NetworkImage).url, 'https://media.example/cover.jpg');
  });

  testWidgets('a pro with no cover falls back rather than showing a broken frame', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap(_card()));

    expect(find.byType(Image), findsNothing);
    // The same quiet placeholder an expired URL lands on.
    expect(find.byIcon(Icons.photo_camera_outlined), findsOneWidget);
  });

  testWidgets('keeps the details that let someone choose', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap(_card(coverUrl: 'https://media.example/cover.jpg')));

    expect(find.text('Alex Lens'), findsOneWidget);
    expect(find.text('Portraits specialist'), findsOneWidget);
    expect(find.text('From €120.00 to €340.00'), findsOneWidget);
    expect(find.text('Weddings · Portraits'), findsOneWidget);
    expect(find.text('4.80'), findsOneWidget);
  });

  testWidgets('the photo leads the card', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap(_card(coverUrl: 'https://media.example/cover.jpg')));

    final photo = tester.getTopLeft(find.byType(RNetworkPhoto));
    final name = tester.getTopLeft(find.text('Alex Lens'));
    expect(photo.dy, lessThan(name.dy));
  });
}
