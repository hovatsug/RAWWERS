import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/client_booking_pay_request.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/core/env.dart';
import 'package:rawwers/features/client/bookings/booking_detail_controller.dart';
import 'package:rawwers/features/client/bookings/bookings_controller.dart';

part 'booking_payment_controller.g.dart';

/// Where a payment attempt got to.
sealed class PaymentProgress {
  const PaymentProgress();
}

class PaymentIdle extends PaymentProgress {
  const PaymentIdle();
}

class PaymentWorking extends PaymentProgress {
  const PaymentWorking();
}

class PaymentSucceeded extends PaymentProgress {
  const PaymentSucceeded();
}

/// A payment that failed for a reason worth showing. Cancelling the sheet is
/// not one of those reasons - it returns to [PaymentIdle] instead, because
/// backing out of a payment deliberately is not an error to apologise for.
class PaymentFailed extends PaymentProgress {
  const PaymentFailed(this.message);

  final String message;
}

@riverpod
class BookingPaymentController extends _$BookingPaymentController {
  @override
  PaymentProgress build(String bookingId) => const PaymentIdle();

  /// Creates (or reuses) the PaymentIntent and opens the Stripe payment sheet.
  ///
  /// Safe to call again after a failure: `POST /v1/client/bookings/{id}/pay`
  /// is get-or-create on the backend - `create_or_get_gig_payment_intent`
  /// passes a fixed idempotency key per gig and payment kind - so a retry
  /// resumes the same intent rather than charging twice.
  Future<void> pay() async {
    if (state is PaymentWorking) return;
    if (!Env.hasStripe) {
      state = const PaymentFailed('Payments are not configured in this build.');
      return;
    }

    state = const PaymentWorking();

    final client = ref.read(clientLaunchClientProvider);
    final intent = await apiCall(
      () => client.clientBookingPayV1ClientBookingsBookingIdPayPost(
        bookingId: bookingId,
        // MVP is a single payment per booking; deposit mode exists on the
        // endpoint but no flow offers it yet.
        requestBody: const ClientBookingPayRequest(paymentMode: 'full'),
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );

    switch (intent) {
      case Err(:final failure):
        state = PaymentFailed(_payFailureMessage(failure));
        return;
      case Ok(:final value):
        await _presentSheet(value.paymentIntentClientSecret);
    }
  }

  Future<void> _presentSheet(String clientSecret) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'RAWWERS',
        ),
      );
      await Stripe.instance.presentPaymentSheet();
    } on StripeException catch (error) {
      // Backing out of the sheet is a decision, not a failure.
      if (error.error.code == FailureCode.Canceled) {
        state = const PaymentIdle();
        return;
      }
      state = PaymentFailed(error.error.localizedMessage ?? 'That payment could not be completed.');
      return;
    } catch (_) {
      state = const PaymentFailed('That payment could not be completed.');
      return;
    }

    state = const PaymentSucceeded();

    // The sheet returning is Stripe confirming the intent, not our backend
    // recording it - that happens on the `payment_intent.succeeded` webhook.
    // Refetching is what moves the screen forward, and it may briefly still
    // show the pre-payment state if the webhook has not landed yet.
    ref.invalidate(bookingDetailProvider(bookingId));
    await ref.read(bookingsControllerProvider.notifier).refresh();
  }
}

String _payFailureMessage(ApiFailure failure) {
  return switch (failure) {
    NetworkError() => 'No connection. Check your signal and try again.',
    Timeout() => 'That took too long. Try again in a moment.',
    ServerError() => 'Something went wrong on our end. Try again in a moment.',
    Unauthorized() => 'Please sign in again.',
    Forbidden() => 'This booking is not yours to pay for.',
    NotFound() => 'That booking no longer exists.',
    Validation() => 'This booking cannot be paid for right now.',
    // 409 here means the booking is not accepted yet, or the gig has moved
    // past payment - both of which the refreshed screen will explain better
    // than this line can.
    BusinessError() => 'This booking is not ready for payment right now.',
    RateLimited() => 'Too many attempts. Wait a moment and try again.',
  };
}
