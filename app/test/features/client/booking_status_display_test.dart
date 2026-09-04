import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/design/components/r_chip.dart';
import 'package:rawwers/features/client/bookings/booking_status_display.dart';

/// The collapse of the booking/gig/payment triple into one readable state.
///
/// The case worth pinning down is the one the endpoint's own docstring warns
/// about: an accepted request that has not been paid for and one that has
/// already been shot share a `booking_status`, so reading that field alone
/// tells a client the same thing in two very different situations.
void main() {
  test('an accepted booking reads by its gig, not its booking status', () {
    final unpaid = BookingStatusDisplay.from(bookingStatus: 'accepted', gigStatus: 'payment_pending');
    final shot = BookingStatusDisplay.from(bookingStatus: 'accepted', gigStatus: 'shoot_done');

    expect(unpaid.label, 'Payment due');
    expect(shot.label, 'Shoot done');
    expect(unpaid.label, isNot(shot.label));
  });

  test('payment is only offered when the gig is actually waiting for it', () {
    expect(BookingStatusDisplay.from(bookingStatus: 'accepted', gigStatus: 'payment_pending').canPay, isTrue);
    expect(BookingStatusDisplay.from(bookingStatus: 'accepted', gigStatus: 'paid').canPay, isFalse);
    expect(BookingStatusDisplay.from(bookingStatus: 'pending').canPay, isFalse);
    // No gig yet: the pro accepted but the gig row has not appeared.
    expect(BookingStatusDisplay.from(bookingStatus: 'accepted').canPay, isFalse);
  });

  test('a booking with no gig falls back to its own status', () {
    expect(BookingStatusDisplay.from(bookingStatus: 'pending').label, 'Waiting on the photographer');
    expect(BookingStatusDisplay.from(bookingStatus: 'expired').kind, RStatusChipKind.stopped);
    expect(BookingStatusDisplay.from(bookingStatus: 'declined').kind, RStatusChipKind.stopped);
  });

  test('finished work reads as positive, stopped work as stopped', () {
    expect(BookingStatusDisplay.from(bookingStatus: 'accepted', gigStatus: 'delivered').kind, RStatusChipKind.positive);
    expect(BookingStatusDisplay.from(bookingStatus: 'accepted', gigStatus: 'disputed').kind, RStatusChipKind.stopped);
  });

  test('an unrecognised status shows as itself rather than disappearing', () {
    // A state added to the backend later must read oddly, not silently become
    // "Unknown" - the latter hides a real deploy mismatch.
    final display = BookingStatusDisplay.from(bookingStatus: 'awaiting_something_new');
    expect(display.label, 'Awaiting something new');
  });

  test('an unrecognised gig status defers to the booking status', () {
    final display = BookingStatusDisplay.from(bookingStatus: 'accepted', gigStatus: 'teleported');
    expect(display.label, 'Accepted');
  });
}
