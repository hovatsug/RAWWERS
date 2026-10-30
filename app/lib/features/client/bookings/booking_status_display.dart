import 'package:flutter/foundation.dart';
import 'package:rawwers/design/components/r_chip.dart';

/// Turns the booking/gig/payment status triple into one thing a client can read.
///
/// The API returns three statuses because they answer different questions and
/// none of them is sufficient alone: an accepted request that has not been
/// paid for and one that has already been shot are the same `booking_status`.
/// The endpoint's own docstring makes the same point. This collapses them the
/// way a person would ask it - "where is my booking up to" - by reading the
/// most advanced signal available: gig status if a gig exists, otherwise the
/// booking status.
///
/// `gig_status` and `booking_status` arrive as plain strings rather than
/// enums (`ClientBookingListItem.booking_status: str`), so this matches on
/// their values and falls back to a humanised version of whatever it was
/// given. An unrecognised status shows as itself rather than as "Unknown" -
/// a new backend state should read oddly, not disappear.
class BookingStatusDisplay {
  const BookingStatusDisplay({required this.label, required this.kind, required this.canPay});

  final String label;
  final RStatusChipKind kind;

  /// Whether payment is the client's move right now. Derived from the same
  /// condition the backend uses to emit the `pay_now` next action: an
  /// accepted booking whose gig is waiting on payment.
  final bool canPay;

  static BookingStatusDisplay from({
    required String bookingStatus,
    String? gigStatus,
    String? paymentStatus,
  }) {
    final canPay = bookingStatus == 'accepted' && gigStatus == 'payment_pending';

    if (gigStatus != null) {
      final display = forGig(gigStatus);
      if (display != null) return BookingStatusDisplay(label: display.$1, kind: display.$2, canPay: canPay);
    }

    final display = forBooking(bookingStatus) ?? (_humanise(bookingStatus), RStatusChipKind.inProgress);
    return BookingStatusDisplay(label: display.$1, kind: display.$2, canPay: canPay);
  }

  /// One line per value of the server's `GigStatus`. This used to list
  /// statuses the server never sends (`delivered`, `closed`, ...) and miss the
  /// ones it does, so a completed booking matched nothing, fell back to its
  /// request's status and read "Accepted". The test checks every value of the
  /// generated `GigStatus` has a line here, so a new server status fails it.
  @visibleForTesting
  static (String, RStatusChipKind)? forGig(String status) {
    return switch (status) {
      'draft' || 'requested' => ('Waiting on the photographer', RStatusChipKind.inProgress),
      'accepted' => ('Accepted', RStatusChipKind.inProgress),
      'payment_pending' => ('Payment due', RStatusChipKind.inProgress),
      'paid' => ('Paid', RStatusChipKind.inProgress),
      'scheduled' => ('Scheduled', RStatusChipKind.inProgress),
      'shoot_done' => ('Shoot done', RStatusChipKind.inProgress),
      'proofs_delivered' => ('Photos ready', RStatusChipKind.inProgress),
      'selection_pending' => ('Choose your photos', RStatusChipKind.inProgress),
      'final_delivered' => ('Photos delivered', RStatusChipKind.positive),
      'completed' => ('Completed', RStatusChipKind.positive),
      'cancelled_by_client' => ('Cancelled by you', RStatusChipKind.stopped),
      'cancelled_by_pro' => ('Cancelled by the photographer', RStatusChipKind.stopped),
      'refunded' => ('Refunded', RStatusChipKind.stopped),
      'disputed' => ('Disputed', RStatusChipKind.stopped),
      _ => null,
    };
  }

  /// One line per value of the server's `BookingRequestStatus`, checked the
  /// same way.
  @visibleForTesting
  static (String, RStatusChipKind)? forBooking(String status) {
    return switch (status) {
      'pending' => ('Waiting on the photographer', RStatusChipKind.inProgress),
      'accepted' => ('Accepted', RStatusChipKind.inProgress),
      'declined' => ('Declined', RStatusChipKind.stopped),
      'expired' => ('Expired', RStatusChipKind.stopped),
      'cancelled' => ('Cancelled', RStatusChipKind.stopped),
      _ => null,
    };
  }
}

String _humanise(String status) {
  final words = status.split(RegExp('[-_]'));
  if (words.isEmpty || words.first.isEmpty) return status;
  final first = words.first;
  return [
    '${first[0].toUpperCase()}${first.substring(1)}',
    ...words.skip(1),
  ].join(' ');
}
