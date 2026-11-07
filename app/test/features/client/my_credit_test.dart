import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/booking_credit_preview.dart';
import 'package:rawwers/api/models/client_booking_status_response.dart';
import 'package:rawwers/api/models/credit_history_item.dart';
import 'package:rawwers/api/models/my_credit_response.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/features/client/bookings/booking_detail_controller.dart';
import 'package:rawwers/features/client/bookings/booking_detail_screen.dart';
import 'package:rawwers/features/client/bookings/booking_payment_controller.dart';
import 'package:rawwers/features/client/credit/credit_controller.dart';
import 'package:rawwers/features/client/credit/credit_labels.dart';
import 'package:rawwers/features/client/credit/my_credit_screen.dart';

CreditHistoryItem _item(String kind, String amount, {String? name, DateTime? at}) => CreditHistoryItem(
      id: '$kind-$amount',
      createdAt: at ?? DateTime.utc(2026, 11, 5, 12),
      kind: kind,
      amountEur: amount,
      photographerFirstName: name,
    );

Future<void> _pumpCredit(WidgetTester tester, MyCreditResponse credit) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [myCreditProvider.overrideWith((ref) async => credit)],
    child: MaterialApp(theme: buildClientTheme(), home: const MyCreditScreen()),
  ));
  await tester.pumpAndSettle();
}

class _FakePay extends BookingPaymentController {
  final calls = <bool?>[];

  @override
  PaymentProgress build(String bookingId) => const PaymentIdle();

  @override
  Future<void> pay({bool? useCredit}) async => calls.add(useCredit);
}

void main() {
  group('labels and euros', () {
    test('credit is euros, never points', () {
      expect(creditEuros('1.00'), '€1.00');
      expect(signedCreditEuros('1.00'), '+€1.00');
      expect(signedCreditEuros('-2.00'), '−€2.00');
    });

    test('each kind in the client\'s words', () {
      expect(creditLabel(_item('marketing_permission', '1.00', name: 'Ana')), 'Marketing permission · booking with Ana');
      expect(creditLabel(_item('used_on_booking', '-2.00')), 'Used on a booking');
      expect(creditLabel(_item('returned', '2.00')), 'Returned to you');
      expect(creditLabel(_item('reversed', '-1.00')), 'Reversed');
    });
  });

  testWidgets('My credit: the balance, how to use it, how to earn it, and the history', (tester) async {
    await _pumpCredit(
      tester,
      MyCreditResponse(
        balanceEur: '1.00',
        maxDiscountPercent: 10,
        items: [
          _item('used_on_booking', '-2.00', at: DateTime.utc(2026, 11, 6, 12)),
          _item('marketing_permission', '3.00', name: 'Ana', at: DateTime.utc(2026, 11, 5, 12)),
        ],
      ),
    );

    expect(find.text('€1.00 credit'), findsOneWidget);
    expect(find.text('Use it on your next booking, up to 10% of the payment.'), findsOneWidget);
    expect(find.textContaining('Let RAWWERS feature photos'), findsOneWidget);
    expect(find.text('Used on a booking'), findsOneWidget);
    expect(find.text('−€2.00'), findsOneWidget);
    expect(find.text('Marketing permission · booking with Ana'), findsOneWidget);
    expect(find.text('+€3.00'), findsOneWidget);
    expect(find.text('5 Nov 2026'), findsOneWidget);
    for (final word in ['store', 'gift', 'book', 'print', 'RAWW']) {
      expect(find.textContaining(RegExp('\\b${word}s?\\b', caseSensitive: false)), findsNothing, reason: 'no $word');
    }
  });

  testWidgets('with no credit yet it says so', (tester) async {
    await _pumpCredit(tester, const MyCreditResponse(balanceEur: '0.00', maxDiscountPercent: 10, items: []));
    expect(find.text('No credit yet'), findsOneWidget);
  });

  testWidgets('checkout: a switch shows the discount and the new total, and paying uses it', (tester) async {
    final pay = _FakePay();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        bookingDetailProvider('b1').overrideWith(
          (ref) async => const ClientBookingStatusResponse(bookingId: 'b1', bookingStatus: 'accepted', gigStatus: 'payment_pending'),
        ),
        bookingCreditProvider('b1').overrideWith(
          (ref) async => const BookingCreditPreview(
            balanceEur: '30.00', discountEur: '10.00', priceEur: '100.00', totalEur: '90.00', maxDiscountPercent: 10, applied: false, currency: 'EUR',
          ),
        ),
        bookingPaymentControllerProvider('b1').overrideWith(() => pay),
      ],
      child: MaterialApp(theme: buildClientTheme(), home: const BookingDetailScreen(bookingId: 'b1')),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Use my credit (€30.00)'), findsOneWidget);
    expect(find.text('Up to 10% of this payment'), findsOneWidget);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text('−€10.00 · you pay €90.00'), findsOneWidget);

    await tester.tap(find.text('Pay now'));
    await tester.pumpAndSettle();
    expect(pay.calls, [true]);
  });

  testWidgets('without credit there is no switch and paying sends nothing about it', (tester) async {
    final pay = _FakePay();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        bookingDetailProvider('b1').overrideWith(
          (ref) async => const ClientBookingStatusResponse(bookingId: 'b1', bookingStatus: 'accepted', gigStatus: 'payment_pending'),
        ),
        bookingCreditProvider('b1').overrideWith(
          (ref) async => const BookingCreditPreview(
            balanceEur: '0.00', discountEur: '0.00', priceEur: '100.00', totalEur: '100.00', maxDiscountPercent: 10, applied: false, currency: 'EUR',
          ),
        ),
        bookingPaymentControllerProvider('b1').overrideWith(() => pay),
      ],
      child: MaterialApp(theme: buildClientTheme(), home: const BookingDetailScreen(bookingId: 'b1')),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(Switch), findsNothing);
    await tester.tap(find.text('Pay now'));
    await tester.pumpAndSettle();
    expect(pay.calls, [null]);
  });
}
