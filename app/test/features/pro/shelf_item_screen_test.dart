import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/shelf_browse_item.dart';
import 'package:rawwers/api/models/shelf_browse_level.dart';
import 'package:rawwers/api/models/shelf_browse_response.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/shelf/shelf_controller.dart';
import 'package:rawwers/features/pro/shelf/shelf_item_screen.dart';

import '../../support/fake_shelf.dart';

class _FakeShelf extends ShelfController {
  _FakeShelf(this.view);

  final ShelfBrowseResponse view;

  @override
  Future<ShelfBrowseResponse> build() async => view;
}

Future<List<String>> _pump(WidgetTester tester, ShelfBrowseItem item, {bool locked = false, int spendable = 300}) async {
  tester.view.physicalSize = const Size(1170, 4000);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final ordered = <String>[];
  await tester.pumpWidget(ProviderScope(
    overrides: [
      shelfControllerProvider.overrideWith(() => _FakeShelf(shelfView(spendable: spendable, levels: [
            ShelfBrowseLevel(level: item.level, bandRaww: 100, bandEur: '10', locked: locked, unlocksAtTier: locked ? 'skilled' : null, items: [item]),
          ]))),
    ],
    child: MaterialApp(
      theme: buildProTheme(),
      home: ShelfItemScreen(itemId: item.id, orderItem: (_, i) => ordered.add(i.id)),
    ),
  ));
  await tester.pumpAndSettle();
  return ordered;
}

void main() {
  testWidgets('a swipeable gallery of the large photos, then what it is and costs', (tester) async {
    await _pump(
      tester,
      shelfItem(
        imageUrls: const ['https://example.test/1.jpg', 'https://example.test/2.jpg'],
        cameraNames: const ['Sony A7 IV'],
        fits: true,
        description: 'Original Sony battery.',
      ),
    );

    expect(find.byType(PageView), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);
    await tester.drag(find.byType(PageView), const Offset(-1000, 0));
    await tester.pumpAndSettle();
    expect(find.text('2 / 2'), findsOneWidget);
    expect(find.text('150 RAWW'), findsOneWidget);
    expect(find.text('Original Sony battery.'), findsOneWidget);
    expect(find.text('Fits your Sony A7 IV.'), findsOneWidget);
  });

  testWidgets('the order button orders', (tester) async {
    final ordered = await _pump(tester, shelfItem());
    await tester.tap(find.text('Order'));
    expect(ordered, ['i1']);
  });

  testWidgets('no order button when it cannot be ordered, and the reason instead', (tester) async {
    await _pump(tester, shelfItem(affordable: false), spendable: 100);
    expect(find.text('Order'), findsNothing);
    expect(find.text('Not enough RAWW yet: 100 of 150.'), findsOneWidget);
  });

  testWidgets('a locked item says what unlocks it', (tester) async {
    await _pump(tester, shelfItem(locked: true), locked: true);
    expect(find.text('Order'), findsNothing);
    expect(find.text('Unlocks at Skilled.'), findsOneWidget);
  });

  test('compatibility in words', () {
    expect(shelfCompatibility(shelfItem()), 'Fits any camera.');
    expect(shelfCompatibility(shelfItem(cameraNames: const ['Canon EOS R6'])), 'Made for Canon EOS R6.');
    expect(shelfCompatibility(shelfItem(cameraNames: const ['Sony A7 IV'], fits: true)), 'Fits your Sony A7 IV.');
  });
}
