import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/booking_date_window.dart';
import 'package:rawwers/api/models/client_booking_request_create_request.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/features/client/pro_profile/availability_controller.dart';
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

    // Whatever the answer, the photographer's calendar has news: a sent
    // request now holds its hour, and a refused one was refused because the
    // hour was taken since the calendar loaded. Every month of it, for every
    // package - the cached answer is out of date either way.
    ref.invalidate(proAvailabilityProvider);

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
    // A 422 - FastAPI's own, or one of the backend's deliberate ones ("Invalid
    // date window", "Invalid package") - is about the request, not the
    // photographer. Must come before the general case below, or a bad date is
    // reported as their calendar being closed.
    BusinessError(status: 422) => 'Check the date and try again.',
    // A 409 is the server's own reason the time cannot be booked - notice,
    // working hours, blocked time, a clash, a full day, or no working hours
    // at all - worded for the person asking (api/app/services/bookable_time.py).
    // It used to be read as "no working hours" whatever it said, which became
    // wrong the day every booking path started applying the full rule.
    BusinessError(:final message) => message,
    Validation() => 'Check the date and try again.',
    ServerError() => 'Something went wrong on our end. Try again in a moment.',
  };
}
