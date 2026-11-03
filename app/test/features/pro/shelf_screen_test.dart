import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/shelf_browse_item.dart';
import 'package:rawwers/api/models/shelf_browse_level.dart';
import 'package:rawwers/api/models/shelf_browse_response.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/shelf/shelf_controller.dart';
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

Future<_FakeShelf> _pump(WidgetTester tester, ShelfBrowseResponse view, {String? wishResult, void Function(BuildContext, ShelfBrowseItem)? order, int unreadOrderUpdates = 0}) async {
  tester.view.physicalSize = const Size(1170, 4000);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final fake = _FakeShelf(view, wishResult: wishResult);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      shelfControllerProvider.overrideWith(() => fake),
      unreadCountProvider(typePrefix: shelfOrderUpdates).overrideWith((ref) async => unreadOrderUpdates),
    ],
    child: MaterialApp(theme: buildProTheme(), home: ShelfScreen(gearPath: '/gear', ordersPath: '/orders', orderItem: order)),
  ));
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  testWidgets('shows what can be spent, the levels, and a locked level with the tier that unlocks it', (tester) async {
    await _pump(tester, shelfView());

    expect(find.text('300 RAWW to spend'), findsOneWidget);
    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text('Level 4'), findsOneWidget);
    expect(find.text('Unlocks at Skilled'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget, reason: 'the teaser has no wish heart');
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

  testWidgets('says which items fit their camera', (tester) async {
    await _pump(tester, shelfView());
    expect(find.text('Fits your camera'), findsOneWidget);
  });

  testWidgets('with no camera in My gear it prompts them to add it', (tester) async {
    await _pump(tester, shelfView(hasCamera: false));
    expect(find.text('Add your camera'), findsOneWidget);
    expect(find.text('Add it in My gear'), findsOneWidget);
  });

  testWidgets('with a camera there is no prompt', (tester) async {
    await _pump(tester, shelfView());
    expect(find.text('Add your camera'), findsNothing);
  });

  testWidgets('the heart adds to the wish list, and a full list says why', (tester) async {
    final fake = await _pump(tester, shelfView(), wishResult: 'Your wish list holds 3 items. Take one off to add this.');

    await tester.tap(find.byIcon(Icons.favorite_border).first);
    await tester.pumpAndSettle();

    expect(fake.toggled, ['i1']);
    expect(find.text('Your wish list holds 3 items. Take one off to add this.'), findsOneWidget);
  });

  testWidgets('a wish now above their level stays a locked teaser they can take off the list', (tester) async {
    final fake = await _pump(
      tester,
      shelfView(levels: [
        ShelfBrowseLevel(level: 4, bandRaww: 3000, locked: true, unlocksAtTier: 'skilled', items: [
          shelfItem(id: 'w', title: 'Gimbal', level: 4, locked: true, wished: true),
          shelfItem(id: 'n', title: 'Light', level: 4, locked: true),
        ]),
      ]),
      order: (_, _) {},
    );

    expect(find.byIcon(Icons.lock_outline), findsNWidgets(2));
    expect(find.byIcon(Icons.favorite_border), findsNothing, reason: 'a locked item cannot be added');
    expect(find.text('Order'), findsNothing);
    await tester.tap(find.byTooltip('Take off your wish list'));
    await tester.pumpAndSettle();

    expect(fake.toggled, ['w']);
  });

  testWidgets('an item they cannot afford, or out of stock, says so and cannot be ordered', (tester) async {
    await _pump(
      tester,
      shelfView(levels: [
        ShelfBrowseLevel(level: 1, bandRaww: 100, locked: false, items: [
          shelfItem(id: 'a', title: 'Dear', affordable: false),
          shelfItem(id: 'b', title: 'Gone', inStock: false),
          shelfItem(id: 'c', title: 'Fine'),
        ]),
      ]),
      order: (_, _) {},
    );

    expect(find.text('Not enough RAWW yet'), findsOneWidget);
    expect(find.text('Out of stock'), findsOneWidget);
    expect(find.text('Order'), findsOneWidget, reason: 'only the one in stock and affordable');
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
