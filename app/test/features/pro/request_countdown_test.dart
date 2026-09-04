import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/features/pro/requests/widgets/request_countdown.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('counts down from the server-supplied duration', (tester) async {
    await tester.pumpWidget(
      _wrap(RequestCountdown(secondsUntilExpiry: 3600 * 2 + 60, onExpired: () {})),
    );

    expect(find.textContaining('2h 01m'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    // pumpAndSettle would hang here - the countdown timer never settles.
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('to respond'), findsOneWidget);
  });

  testWidgets('refetches instead of rendering expired when it reaches zero', (tester) async {
    // The server sweeps expired requests every 15 minutes, so a deadline
    // passing locally does not mean the server would refuse the request.
    // Showing "expired" would present a closed door that is still open.
    var refetched = false;

    await tester.pumpWidget(
      _wrap(RequestCountdown(secondsUntilExpiry: 2, onExpired: () => refetched = true)),
    );

    await tester.pump(const Duration(seconds: 1));
    expect(refetched, isFalse, reason: 'must not refetch before the deadline actually passes');

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(refetched, isTrue);
  });

  testWidgets('a deadline already in the past refetches immediately', (tester) async {
    var refetched = false;

    await tester.pumpWidget(
      _wrap(RequestCountdown(secondsUntilExpiry: -30, onExpired: () => refetched = true)),
    );
    await tester.pump();

    expect(refetched, isTrue);
  });

  testWidgets('re-seeds from a fresh server value rather than continuing a stale count', (tester) async {
    await tester.pumpWidget(
      _wrap(RequestCountdown(secondsUntilExpiry: 120, onExpired: () {})),
    );
    expect(find.textContaining('2m'), findsOneWidget);

    await tester.pumpWidget(
      _wrap(RequestCountdown(secondsUntilExpiry: 7200, onExpired: () {})),
    );
    await tester.pump();

    expect(find.textContaining('2h'), findsOneWidget);
  });
}
