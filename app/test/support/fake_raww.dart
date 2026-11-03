import 'package:rawwers/api/models/pro_raww_view.dart';
import 'package:rawwers/api/models/raww_pending_booking.dart';

/// The RAWW card's answer while The Shelf is closed.
const closedRaww = ProRawwView(
  shelfOpen: false,
  spendable: 0,
  pending: 0,
  rawwEurValue: '0.10',
  pendingBookings: [],
  expiryWarning: false,
  inactivityMonths: 24,
);

ProRawwView openRaww({
  int spendable = 120,
  int pending = 75,
  List<RawwPendingBooking>? pendingBookings,
  DateTime? expiresAt,
  bool expiryWarning = false,
}) =>
    ProRawwView(
      shelfOpen: true,
      spendable: spendable,
      pending: pending,
      rawwEurValue: '0.10',
      pendingBookings: pendingBookings ??
          [
            RawwPendingBooking(gigId: 'g1', amount: 50, held: false, expectedAt: DateTime.utc(2026, 11, 10, 9)),
            const RawwPendingBooking(gigId: 'g2', amount: 25, held: true),
          ],
      expiresAt: expiresAt,
      expiryWarning: expiryWarning,
      inactivityMonths: 24,
    );
