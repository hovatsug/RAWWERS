import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/api/models/shelf_browse_item.dart';
import 'package:rawwers/api/models/shelf_browse_level.dart';
import 'package:rawwers/api/models/shelf_browse_response.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/design/components/r_card_row.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/shelf/shelf_controller.dart';
import 'package:rawwers/features/pro/shelf/shelf_item_screen.dart';
import 'package:rawwers/features/pro/shelf/shelf_orders_screen.dart';
import 'package:rawwers/features/pro/shelf/shelf_screen.dart';
import 'package:rawwers/features/shared/notifications/notifications_controller.dart';

import '../../support/fake_shelf.dart';

class _FakeShelf extends ShelfController {
  _FakeShelf(this.view, {this.wishResult});

  ShelfBrowseResponse view;
  final String? wishResult;
  final toggled = <String>[];

  @override
  Future<ShelfBrowseResponse> build() async => view;

  @override
  Future<String?> toggleWish(ShelfBrowseItem item) async {
    toggled.add(item.id);
    return wishResult;
  }
}

class _FailingShelf extends ShelfController {
  @override
  Future<ShelfBrowseResponse> build() async => throw const NetworkError();
}

Future<_FakeShelf> _pump(WidgetTester tester, ShelfBrowseResponse view, {String? wishResult, int unreadOrderUpdates = 0}) async {
  tester.view.physicalSize = const Size(1170, 6000);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final fake = _FakeShelf(view, wishResult: wishResult);
  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (_, _) => ShelfScreen(gearPath: '/gear', ordersPath: '/orders', itemPath: (id) => '/item/$id')),
    GoRoute(path: '/item/:id', builder: (_, state) => ShelfItemScreen(itemId: state.pathParameters['id']!, orderItem: (_, _) {})),
  ]);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      shelfControllerProvider.overrideWith(() => fake),
      unreadCountProvider(typePrefix: shelfOrderUpdates).overrideWith((ref) async => unreadOrderUpdates),
    ],
    child: MaterialApp.router(theme: buildProTheme(), routerConfig: router),
  ));
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  testWidgets('one horizontal row per level, titled with euros and RAWW, a locked one with its tier', (tester) async {
    await _pump(tester, shelfView());

    expect(find.text('300 RAWW to spend'), findsOneWidget);
    expect(find.byType(RCardRow), findsNWidgets(2));
    expect(find.text('Level 1 · about €10 · 100 RAWW'), findsOneWidget);
    expect(find.text('Level 4 · about €300 · 3000 RAWW'), findsOneWidget);
    expect(find.text('Unlocks at Skilled'), findsOneWidget);
    final list = tester.widget<ListView>(find.descendant(of: find.byType(RCardRow).first, matching: find.byType(ListView)));
    expect(list.scrollDirection, Axis.horizontal);
  });

  testWidgets('a card shows the cover, name, price and heart; a locked one is dimmed with a lock', (tester) async {
    await _pump(
      tester,
      shelfView(levels: [
        ShelfBrowseLevel(level: 1, bandRaww: 100, bandEur: '10', locked: false, items: [shelfItem(coverUrl: 'https://example.test/c.jpg')]),
        ShelfBrowseLevel(level: 4, bandRaww: 3000, bandEur: '300', locked: true, unlocksAtTier: 'skilled', items: [
          shelfItem(id: 'i4', title: 'Gimbal', level: 4, locked: true),
        ]),
      ]),
    );

    expect(find.text('NP-FZ100 battery'), findsOneWidget);
    expect(find.text('150 RAWW'), findsNWidgets(2));
    expect(find.byWidgetPredicate((w) => w is Image && w.image is NetworkImage && (w.image as NetworkImage).url == 'https://example.test/c.jpg'), findsOneWidget);
    expect(find.byTooltip('Add to your wish list'), findsOneWidget, reason: 'the locked card has no heart');
    expect(find.byIcon(Icons.lock_outline), findsNWidgets(2), reason: 'the heading and the card');
    final dimmed = tester.widget<Opacity>(find.ancestor(of: find.text('Gimbal'), matching: find.byType(Opacity)).first);
    expect(dimmed.opacity, lessThan(1));
  });

  testWidgets('a wish list row on top when something is wished', (tester) async {
    await _pump(
      tester,
      shelfView(levels: [
        ShelfBrowseLevel(level: 1, bandRaww: 100, bandEur: '10', locked: false, items: [shelfItem(wished: true), shelfItem(id: 'i2', title: 'Card')]),
      ]),
    );

    expect(find.text('Your wish list'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Your wish list')).dy, lessThan(tester.getTopLeft(find.text('Level 1 · about €10 · 100 RAWW')).dy));
    expect(find.text('NP-FZ100 battery'), findsNWidgets(2), reason: 'in the wish list and in its level');
  });

  testWidgets('no wish list row when nothing is wished', (tester) async {
    await _pump(tester, shelfView());
    expect(find.text('Your wish list'), findsNothing);
  });

  testWidgets('the heart adds to the wish list, and a full list says why', (tester) async {
    final fake = await _pump(tester, shelfView(), wishResult: 'Your wish list holds 3 items. Take one off to add this.');

    await tester.tap(find.byTooltip('Add to your wish list').first);
    await tester.pumpAndSettle();

    expect(fake.toggled, ['i1']);
    expect(find.text('Your wish list holds 3 items. Take one off to add this.'), findsOneWidget);
  });

  testWidgets('a wish now above their level stays a locked teaser they can take off the list', (tester) async {
    final fake = await _pump(
      tester,
      shelfView(levels: [
        ShelfBrowseLevel(level: 4, bandRaww: 3000, bandEur: '300', locked: true, unlocksAtTier: 'skilled', items: [
          shelfItem(id: 'w', title: 'Gimbal', level: 4, locked: true, wished: true),
          shelfItem(id: 'n', title: 'Light', level: 4, locked: true),
        ]),
      ]),
    );

    expect(find.byTooltip('Add to your wish list'), findsNothing, reason: 'a locked item cannot be added');
    await tester.tap(find.byTooltip('Take off your wish list').first);
    await tester.pumpAndSettle();
    expect(fake.toggled, ['w']);
  });

  testWidgets('a card opens the item', (tester) async {
    await _pump(tester, shelfView());
    await tester.tap(find.text('Card'));
    await tester.pumpAndSettle();
    expect(find.text('Fits any camera.'), findsOneWidget);
  });

  testWidgets('says which items fit their camera', (tester) async {
    await _pump(tester, shelfView());
    expect(find.text('Fits your camera'), findsOneWidget);
  });

  testWidgets('with no camera in My gear it prompts them to add it', (tester) async {
    await _pump(tester, shelfView(hasCamera: false));
    expect(find.text('Add your camera'), findsOneWidget);
    expect(find.text('Add it in My gear'), findsOneWidget);
  });

  testWidgets('shows the monthly order cap and the date it resets', (tester) async {
    await _pump(tester, shelfView(ordersThisMonth: 2, ordersResetAt: DateTime.utc(2027, 1, 1, 12)));
    expect(find.text('2 of 3 orders this month · resets 1 Jan 2027'), findsOneWidget);
  });

  testWidgets('My orders carries a dot while an order update is unread', (tester) async {
    await _pump(tester, shelfView(), unreadOrderUpdates: 2);
    final badge = tester.widget<Badge>(find.ancestor(of: find.text('My orders'), matching: find.byType(Badge)));
    expect(badge.isLabelVisible, isTrue);
  });

  testWidgets('and none when there is nothing new', (tester) async {
    await _pump(tester, shelfView());
    final badge = tester.widget<Badge>(find.ancestor(of: find.text('My orders'), matching: find.byType(Badge)));
    expect(badge.isLabelVisible, isFalse);
  });

  testWidgets('the terms open from the bottom, marked draft until reviewed', (tester) async {
    await _pump(tester, shelfView());
    await tester.tap(find.text('Terms for The Shelf'));
    await tester.pumpAndSettle();
    expect(find.text('Draft, not yet reviewed'), findsOneWidget);
    expect(find.textContaining('no cash value'), findsOneWidget);
  });

  testWidgets('a failed load offers a retry', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [shelfControllerProvider.overrideWith(_FailingShelf.new)],
      child: MaterialApp(theme: buildProTheme(), home: const ShelfScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('The Shelf could not be loaded.'), findsOneWidget);
  });
}
