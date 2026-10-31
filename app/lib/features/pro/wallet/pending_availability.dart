import 'package:decimal/decimal.dart';
import 'package:rawwers/api/models/earnings_entry_status.dart';
import 'package:rawwers/api/models/earnings_ledger_item_view.dart';
import 'package:rawwers/core/format/dates.dart';

/// When a pending earning can be withdrawn, said so it is never wrong.
///
/// The server's rule (payouts.py): an earning's `available_at` is fixed when
/// it is recorded - the moment the booking completes, plus the settlement
/// delay in force then (7 days by default; changing the policy later does
/// not move it). An hourly sweep then moves every pending earning whose time
/// has passed to available. So it becomes withdrawable at `available_at` or
/// up to an hour after, never before: "from 7 Nov" and "in about 5 hours"
/// are both true, where "on 7 Nov" could be a day out for an earning due at
/// 23:30. An earning on hold has no date at all: a hold waits for a dispute
/// or a review, not for time.
///
/// Worked out from the screen's clock when it is built - on opening, on
/// pull-to-refresh and on coming back to the app - not ticked by a timer.
String? whenAvailable(DateTime availableAt, DateTime now, RDates dates) {
  final left = availableAt.difference(now);
  if (left <= Duration.zero) return null;
  if (left <= const Duration(hours: 1)) return 'within the hour';
  if (left < const Duration(hours: 24)) {
    final hours = (left.inMinutes / 60).ceil();
    return 'in about $hours hours';
  }
  return 'from ${dates.dayMonth(availableAt)}';
}

/// The status line of one pending earning in the list.
String pendingLine(DateTime availableAt, DateTime now, RDates dates) => switch (whenAvailable(
      availableAt,
      now,
      dates,
    )) {
      final phrase? => 'Pending · available $phrase',
      // Due, and the sweep has not reached it yet; or it has, and this screen
      // is showing what it fetched before. Either way a refresh tells.
      null => 'Pending · being released - pull down to refresh',
    };

/// The pending earning that becomes available first, or null when there is
/// none - or when the list cannot be trusted to say.
///
/// The ledger is the most recent 100 earnings, newest first, so a
/// photographer with more than that inside one settlement delay would have
/// their *oldest* pending earnings - the ones due first - cut off, and this
/// would name a later date as the next. So it answers only when the pending
/// earnings in the list add up to the balance's pending figure, which the
/// server sums over every pending earning (photographer_money.py).
EarningsLedgerItemView? nextPending(List<EarningsLedgerItemView> ledger, {required String pendingEur}) {
  EarningsLedgerItemView? next;
  var listed = Decimal.zero;
  for (final entry in ledger) {
    if (entry.status != EarningsEntryStatus.pending) continue;
    listed += Decimal.parse(entry.netEur);
    if (next == null || entry.availableAt.isBefore(next.availableAt)) next = entry;
  }
  return listed == Decimal.parse(pendingEur) ? next : null;
}
