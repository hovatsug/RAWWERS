import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/gig_status.dart';
import 'package:rawwers/design/components/r_chip.dart';
import 'package:rawwers/features/pro/gigs/gig_status_display.dart';
import 'package:rawwers/features/pro/gigs/gigs_controller.dart';

void main() {
  test('every gig status maps to a chip kind and a label', () {
    // Guards the case where the backend adds a GigStatus and the switch falls
    // through to a default that quietly calls it "in progress" - a cancelled
    // gig rendered as ongoing is a real misread.
    for (final status in GigStatus.values) {
      expect(status.label, isNotEmpty, reason: '$status has no label');
      expect(status.chipKind, isNotNull);
    }
  });

  test('the four bad endings are the stopped treatment', () {
    const stopped = [
      GigStatus.cancelledByClient,
      GigStatus.cancelledByPro,
      GigStatus.refunded,
      GigStatus.disputed,
    ];
    for (final status in stopped) {
      expect(status.chipKind, RStatusChipKind.stopped, reason: '$status must be impossible to miss');
    }
  });

  test('delivered and completed are the only positive states', () {
    final positive = GigStatus.values.where((s) => s.chipKind == RStatusChipKind.positive).toSet();
    expect(positive, {GigStatus.finalDelivered, GigStatus.completed});
  });

  group('GigsFilter', () {
    test('partitions every status into exactly one group', () {
      // Overlapping groups would show the same gig under two filters;
      // a gap would make a gig invisible in all of them.
      for (final status in GigStatus.values) {
        final matches = GigsFilter.values.where((f) => f.matches(status)).toList();
        expect(matches, hasLength(1), reason: '$status matched ${matches.length} filters, expected exactly 1');
      }
    });

    test('an unrecognised in-flight state falls into active, not cancelled', () {
      expect(GigsFilter.active.matches(GigStatus.selectionPending), isTrue);
      expect(GigsFilter.cancelled.matches(GigStatus.selectionPending), isFalse);
    });
  });
}
