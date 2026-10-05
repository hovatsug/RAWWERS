// The already-paid defensive guard: a stale Pay button, tapped again after
// the payment already succeeded, must read as reassurance and hand the
// screen back to a refresh - not as the same dead-end error a genuinely
// invalid booking gets.
//
// This is reachable without any client bug: the booking screen can reopen
// (or a tap can land) before the `payment_intent.succeeded` webhook has
// updated the gig's status, and `POST .../pay` is the backend's own source
// of truth for "did this already go through" - not something inferred
// client-side. The backend tells the two 409s apart by error code
// (`already_paid` vs `invalid_state`); this proves the controller acts on
// that distinction rather than treating every business error the same way.
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/api_client/client_launch_client.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/payments/payment_sheet_launcher.dart';
import 'package:rawwers/features/client/bookings/booking_payment_controller.dart';

import '../../support/fake_http_client_adapter.dart';

class _FakeLauncher implements PaymentSheetLauncher {
  const _FakeLauncher();

  @override
  bool get isConfigured => true;

  @override
  Future<PaymentSheetResult> present(String clientSecret) async =>
      throw StateError('the already-paid guard must return before the sheet is ever presented');
}

ProviderContainer _setup(Future<ResponseBody> Function(RequestOptions) payHandler) {
  final apiDio = Dio(BaseOptions(baseUrl: 'https://example.invalid'))..httpClientAdapter = FakeHttpClientAdapter(payHandler);

  final container = ProviderContainer(
    overrides: [
      clientLaunchClientProvider.overrideWithValue(ClientLaunchClient(apiDio)),
      paymentSheetLauncherProvider.overrideWithValue(const _FakeLauncher()),
    ],
  );
  addTearDown(container.dispose);
  container.listen(bookingPaymentControllerProvider('booking-1'), (_, _) {});
  return container;
}

void main() {
  test('a booking already paid for reads as success, not as an error', () async {
    final container = _setup(
      (o) async => jsonResponseBody(
        jsonEncodeError(code: 'already_paid', message: 'This booking has already been paid for.'),
        409,
      ),
    );

    await container.read(bookingPaymentControllerProvider('booking-1').notifier).pay();

    expect(container.read(bookingPaymentControllerProvider('booking-1')), isA<PaymentSucceeded>());
  });

  test('a genuinely invalid booking state still fails, distinctly from already-paid', () async {
    final container = _setup(
      (o) async => jsonResponseBody(
        jsonEncodeError(code: 'invalid_state', message: 'Gig is not awaiting payment'),
        409,
      ),
    );

    await container.read(bookingPaymentControllerProvider('booking-1').notifier).pay();

    final state = container.read(bookingPaymentControllerProvider('booking-1'));
    expect(state, isA<PaymentFailed>());
    expect(
      (state as PaymentFailed).message,
      'This booking is not ready for payment right now.',
      reason: 'a real invalid-state 409 must not be read as reassurance',
    );
  });

  for (final (code, message) in [
    ('payment_window_closed', 'The time held for this booking has been released. Request a new time.'),
    ('slot_conflict', 'That time clashes with another booking.'),
  ]) {
    test('a payment refused because the hour is no longer theirs says so: $code', () async {
      // The last check before charging (bookable_time, at_payment). These
      // are the client's to act on - pick a new time - so the server's own
      // words go through, not the generic "not ready" line.
      final container = _setup((o) async => jsonResponseBody(jsonEncodeError(code: code, message: message), 409));

      await container.read(bookingPaymentControllerProvider('booking-1').notifier).pay();

      final state = container.read(bookingPaymentControllerProvider('booking-1'));
      expect(state, isA<PaymentFailed>());
      expect((state as PaymentFailed).message, message);
    });
  }
}

String jsonEncodeError({required String code, required String message}) =>
    '{"error": {"code": "$code", "message": "$message"}}';
