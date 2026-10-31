// When a pending earning can be withdrawn. The server makes it available at
// `available_at` or within the hour after (an hourly sweep), never before,
// so every phrase here has to be true for that whole hour: "from 6 Nov",
// "in about 5 hours", "within the hour" - and nothing at all once the time
// has passed, because then only a refresh knows.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/earnings_entry_status.dart';
import 'package:rawwers/api/models/earnings_ledger_item_view.dart';
import 'package:rawwers/api/models/earnings_source_type.dart';
import 'package:rawwers/core/format/dates.dart';
import 'package:rawwers/features/pro/wallet/pending_availability.dart';

final _dates = RDates.forLocale(const Locale('en', 'GB'));

/// Noon UTC, so the calendar day is the same in any time zone a test machine
/// is likely to be in.
final _now = DateTime.utc(2026, 10, 31, 12);

EarningsLedgerItemView _entry(String net, DateTime availableAt, {EarningsEntryStatus status = EarningsEntryStatus.pending}) =>
    EarningsLedgerItemView(
      id: 'e-$net',
      sourceType: EarningsSourceType.gigBase,
      sourceId: 'gig-$net',
      grossEur: net,
      platformFeeEur: '0.00',
      netEur: net,
      status: status,
      availableAt: availableAt,
      createdAt: availableAt.subtract(const Duration(days: 7)),
    );

void main() {
  group('how long is left', () {
    String? left(Duration d) => whenAvailable(_now.add(d), _now, _dates);

    test('a day or more: the date it is available from', () {
      expect(left(const Duration(days: 6)), 'from 6 Nov');
      expect(left(const Duration(hours: 24)), 'from 1 Nov');
    });

    test('under a day: hours, rounded up', () {
      expect(left(const Duration(hours: 23)), 'in about 23 hours');
      expect(left(const Duration(hours: 4, minutes: 10)), 'in about 5 hours');
      expect(left(const Duration(hours: 1, minutes: 1)), 'in about 2 hours');
    });

    test('an hour or less: within the hour', () {
      expect(left(const Duration(hours: 1)), 'within the hour');
      expect(left(const Duration(minutes: 5)), 'within the hour');
    });

    test('once the time has passed it gives no time at all', () {
      expect(left(Duration.zero), isNull);
      expect(left(const Duration(hours: -3)), isNull);
    });

    test('never says a time sooner than the server will release it', () {
      // Every minute of the next three days: the phrase must not promise
      // anything before available_at. "within the hour" is only used inside
      // the last hour; "N hours" never undershoots.
      for (var m = 1; m <= 3 * 24 * 60; m++) {
        final phrase = left(Duration(minutes: m))!;
        if (phrase.startsWith('in about ')) {
          final hours = int.parse(phrase.split(' ')[2]);
          expect(hours * 60, greaterThanOrEqualTo(m), reason: '$m minutes left read as "$phrase"');
        } else if (phrase == 'within the hour') {
          expect(m, lessThanOrEqualTo(60));
        } else {
          expect(m, greaterThanOrEqualTo(24 * 60));
        }
      }
    });
  });

  test('a pending line says when, and after the time asks for a refresh', () {
    expect(pendingLine(DateTime.utc(2026, 11, 6, 12), _now, _dates), 'Pending · available from 6 Nov');
    expect(pendingLine(_now.subtract(const Duration(minutes: 5)), _now, _dates), 'Pending · being released - pull down to refresh');
  });

  group('the next one', () {
    final early = _entry('69.47', DateTime.utc(2026, 11, 6, 12));
    final late = _entry('75.20', DateTime.utc(2026, 11, 7, 12));
    final settled = _entry('41.95', DateTime.utc(2026, 10, 20, 12), status: EarningsEntryStatus.available);
    final held = _entry('10.00', DateTime.utc(2026, 11, 1, 12), status: EarningsEntryStatus.held);

    test('is the pending earning due first, whatever the list order', () {
      expect(nextPending([late, settled, early, held], pendingEur: '144.67'), early);
    });

    test('ignores earnings that are available or on hold', () {
      expect(nextPending([settled, held], pendingEur: '0.00'), isNull);
    });

    test('says nothing when the list does not hold every pending earning', () {
      // 100 most recent only: the oldest pending ones - due first - can be
      // the ones cut off, and the next date would then be wrong.
      expect(nextPending([late], pendingEur: '144.67'), isNull);
    });
  });
}
