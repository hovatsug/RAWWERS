import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/booking_date_window.dart';
import 'package:rawwers/api/models/client_booking_request_create_request.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/features/client/bookings/bookings_controller.dart';

part 'booking_request_controller.g.dart';

/// Sends a booking request for one package.
///
/// Not a `@riverpod` notifier with state: the form owns its own state and
/// this is a one-shot action. It returns either the new booking's id or a
/// message, so the caller decides what to do with each.
@riverpod
class BookingRequestController extends _$BookingRequestController {
  @override
  void build() {}

  Future<BookingRequestOutcome> submit({
    required String proUserId,
    required String packageId,
    required String nicheSlug,
    required DateTime startAt,
    required DateTime endAt,
    String? location,
    String? notes,
  }) async {
    final client = ref.read(clientLaunchClientProvider);
    final result = await apiCall(
      () => client.clientBookingRequestV1ClientBookingsRequestPost(
        requestBody: ClientBookingRequestCreateRequest(
          proUserId: proUserId,
          nicheSlug: nicheSlug,
          packageId: packageId,
          // Sent as UTC: the API stores instants, and a naive local time
          // would land the shoot in the wrong hour for anyone not on UTC.
          dateWindow: BookingDateWindow(startAt: startAt.toUtc(), endAt: endAt.toUtc()),
          location: (location == null || location.trim().isEmpty) ? null : location.trim(),
          notes: (notes == null || notes.trim().isEmpty) ? null : notes.trim(),
          // Left null so the account's own `consent_default` applies rather
          // than this form quietly overriding a preference set elsewhere.
          consentLevel: null,
        ),
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );

    switch (result) {
      case Ok(:final value):
        // Invalidated rather than awaited: the booking is already created, so
        // a failed list refetch must not turn a successful request into an
        // error the client sees. The Bookings tab refetches when it is next
        // built, which is where the client is about to be.
        ref.invalidate(bookingsControllerProvider);
        return BookingRequestSent(value.bookingId);
      case Err(:final failure):
        return BookingRequestFailed(_message(failure));
    }
  }
}

sealed class BookingRequestOutcome {
  const BookingRequestOutcome();
}

class BookingRequestSent extends BookingRequestOutcome {
  const BookingRequestSent(this.bookingId);

  final String bookingId;
}

class BookingRequestFailed extends BookingRequestOutcome {
  const BookingRequestFailed(this.message);

  final String message;
}

String _message(ApiFailure failure) {
  return switch (failure) {
    NetworkError() => 'No connection. Check your signal and try again.',
    Timeout() => 'That took too long. Try again in a moment.',
    // Five requests a day, per `enforce_rate_limit` on this endpoint.
    RateLimited() => 'You have sent a lot of requests today. Try again tomorrow.',
    Unauthorized() => 'Please sign in again.',
    Forbidden() => 'We are not taking bookings in this city yet.',
    NotFound() => 'That photographer is no longer available.',
    // 409 here is specifically "pro has no availability configured", which
    // is the photographer's setup problem, not the client's request.
    BusinessError() => 'This photographer has not opened their calendar yet.',
    Validation() => 'Check the date and try again.',
    ServerError() => 'Something went wrong on our end. Try again in a moment.',
  };
}
