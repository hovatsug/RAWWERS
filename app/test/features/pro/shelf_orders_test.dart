import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/shelf_address.dart';
import 'package:rawwers/api/models/shelf_address_response.dart';
import 'package:rawwers/api/models/shelf_order_view.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/shelf/shelf_checkout.dart';
import 'package:rawwers/features/pro/shelf/shelf_orders_controller.dart';
import 'package:rawwers/features/pro/shelf/shelf_orders_screen.dart';
import 'package:rawwers/features/shared/notifications/notifications_controller.dart';

import '../../support/fake_shelf.dart';

class _FakeAddress extends ShelfAddressController {
  _FakeAddress(this.saved);

  final ShelfAddress? saved;
  ShelfAddress? sent;

  @override
  Future<ShelfAddressResponse> build() async => ShelfAddressResponse(address: saved, allowedCountries: const ['GB']);

  @override
  Future<String?> save(ShelfAddress address) async {
    sent = address;
    return null;
  }
}

class _FakeOrders extends ShelfOrdersController {
  _FakeOrders({this.orders = const [], this.placeResult});

  final List<ShelfOrderView> orders;
  final String? placeResult;
  final placed = <String>[];
  final cancelled = <String>[];

  @override
  Future<List<ShelfOrderView>> build() async => orders;

  @override
  Future<String?> place({required String itemId, required String requestId}) async {
    placed.add(requestId);
    return placeResult;
  }

  @override
  Future<String?> cancel(String orderId) async {
    cancelled.add(orderId);
    return null;
  }
}

const _home = ShelfAddress(name: 'Sam Reyes', line1: '12 Rose Street', city: 'London', postalCode: 'E1 6AN', country: 'GB');

ShelfOrderView _order({String status = 'placed', bool canCancel = true, String? tracking}) => ShelfOrderView(
      id: 'o1',
      itemId: 'i1',
      title: 'NP-FZ100 battery',
      priceRaww: 150,
      status: status,
      placedAt: DateTime.utc(2026, 11, 3, 12),
      shippedAt: status == 'shipped' ? DateTime.utc(2026, 11, 5, 12) : null,
      refundedAt: status == 'refunded' ? DateTime.utc(2026, 11, 4, 12) : null,
      trackingCode: tracking,
      canCancel: canCancel,
    );

Future<(_FakeAddress, _FakeOrders)> _checkout(WidgetTester tester, {ShelfAddress? saved, String? placeResult}) async {
  tester.view.physicalSize = const Size(1170, 4000);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final address = _FakeAddress(saved);
  final orders = _FakeOrders(placeResult: placeResult);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      shelfAddressControllerProvider.overrideWith(() => address),
      shelfOrdersControllerProvider.overrideWith(() => orders),
    ],
    child: MaterialApp(theme: buildProTheme(), home: Scaffold(body: ShelfCheckout(item: shelfItem(price: 150), spendable: 400))),
  ));
  await tester.pumpAndSettle();
  return (address, orders);
}

void main() {
  test('each order attempt gets its own id', () {
    expect(newOrderRequestId(), hasLength(32));
    expect(newOrderRequestId(), isNot(newOrderRequestId()));
  });

  testWidgets('the checkout shows the price, what is left, and the saved address', (tester) async {
    await _checkout(tester, saved: _home);

    expect(find.text('150 RAWW'), findsOneWidget);
    expect(find.textContaining('250 RAWW left'), findsOneWidget);
    expect(find.textContaining('12 Rose Street'), findsOneWidget);
    expect(find.text('Change address'), findsOneWidget);
  });

  testWidgets('with no saved address it asks for one, and saves it before ordering', (tester) async {
    final (address, orders) = await _checkout(tester);

    expect(find.text('Postcode'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Sam Reyes');
    await tester.enterText(find.widgetWithText(TextField, 'Address'), '12 Rose Street');
    await tester.enterText(find.widgetWithText(TextField, 'Town or city'), 'London');
    await tester.enterText(find.widgetWithText(TextField, 'Postcode'), 'E1 6AN');
    await tester.tap(find.text('Place order'));
    await tester.pumpAndSettle();

    expect(address.sent?.line1, '12 Rose Street');
    expect(address.sent?.country, 'GB');
    expect(orders.placed, hasLength(1));
  });

  testWidgets('two taps send the same request id, so they are one order', (tester) async {
    final (_, orders) = await _checkout(tester, saved: _home, placeResult: 'Could not reach RAWWERS. Check your connection and try again.');

    await tester.tap(find.text('Place order'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Place order'));
    await tester.pumpAndSettle();

    expect(orders.placed, hasLength(2));
    expect(orders.placed.toSet(), hasLength(1));
  });

  testWidgets('a refused order says why', (tester) async {
    await _checkout(tester, saved: _home, placeResult: 'You can order 3 items a month. More next month.');
    await tester.tap(find.text('Place order'));
    await tester.pumpAndSettle();
    expect(find.text('You can order 3 items a month. More next month.'), findsOneWidget);
  });

  group('My orders', () {
    final readKinds = <String>[];

    Future<_FakeOrders> pump(WidgetTester tester, List<ShelfOrderView> list) async {
      final orders = _FakeOrders(orders: list);
      readKinds.clear();
      await tester.pumpWidget(ProviderScope(
        overrides: [
          shelfOrdersControllerProvider.overrideWith(() => orders),
          notificationKindReaderProvider.overrideWithValue((prefix) async => readKinds.add(prefix)),
        ],
        child: MaterialApp(theme: buildProTheme(), home: const ShelfOrdersScreen()),
      ));
      await tester.pumpAndSettle();
      return orders;
    }

    testWidgets('opening it reads the order updates, which clears the dot', (tester) async {
      await pump(tester, [_order()]);
      expect(readKinds, ['shelf.order_']);
    });

    testWidgets('a placed order can be cancelled after asking', (tester) async {
      final orders = await pump(tester, [_order()]);

      expect(find.textContaining('Placed on 3 Nov 2026'), findsOneWidget);
      await tester.tap(find.text('Cancel order'));
      await tester.pumpAndSettle();
      expect(find.text('Your 150 RAWW come back at once.'), findsOneWidget);
      await tester.tap(find.text('Cancel order').last);
      await tester.pumpAndSettle();

      expect(orders.cancelled, ['o1']);
    });

    testWidgets('keeping it cancels nothing', (tester) async {
      final orders = await pump(tester, [_order()]);

      await tester.tap(find.text('Cancel order'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep it'));
      await tester.pumpAndSettle();

      expect(orders.cancelled, isEmpty);
    });

    testWidgets('a shipped order shows its tracking and cannot be cancelled', (tester) async {
      await pump(tester, [_order(status: 'shipped', canCancel: false, tracking: 'RM123456GB')]);

      expect(find.textContaining('Shipped on 5 Nov 2026'), findsOneWidget);
      expect(find.text('Tracking: RM123456GB'), findsOneWidget);
      expect(find.text('Cancel order'), findsNothing);
    });

    testWidgets('a cancelled order says the RAWW are back', (tester) async {
      await pump(tester, [_order(status: 'refunded', canCancel: false)]);
      expect(find.textContaining('150 RAWW back in your balance'), findsOneWidget);
    });

    testWidgets('with no orders it says what will show', (tester) async {
      await pump(tester, const []);
      expect(find.text('No orders yet'), findsOneWidget);
    });
  });
}
