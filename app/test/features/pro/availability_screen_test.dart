import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/availability_exception_view.dart';
import 'package:rawwers/api/models/availability_location_mode.dart';
import 'package:rawwers/api/models/availability_rule_item.dart';
import 'package:rawwers/api/models/scheduling_availability_rule_view.dart';
import 'package:rawwers/api/models/scheduling_policy_view.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/availability/availability_controller.dart';
import 'package:rawwers/features/pro/availability/availability_screen.dart';

/// Availability is the one thing a photographer has to be able to trust:
/// blocked time that does not block is worse than no feature at all. These
/// cover the two ways this screen could quietly lose it - sending a
/// timezone the backend rejects, and dropping other blocks when removing
/// one from a replace-the-whole-set endpoint.
class _FakeHours extends WorkingHoursController {
  _FakeHours(this._rules);

  final List<SchedulingAvailabilityRuleView> _rules;
  List<AvailabilityRuleItem>? lastSent;

  @override
  Future<List<SchedulingAvailabilityRuleView>> build() async => _rules;

  @override
  Future<String?> replace(List<AvailabilityRuleItem> rules) async {
    lastSent = rules;
    return null;
  }
}

class _FakeBlocked extends BlockedTimeController {
  _FakeBlocked(this._items);

  final List<AvailabilityExceptionView> _items;
  List<String>? survivingReasons;

  @override
  Future<List<AvailabilityExceptionView>> build() async => _items;

  @override
  Future<String?> unblock(String id) async {
    survivingReasons = [
      for (final item in _items)
        if (item.id != id) item.reason ?? '',
    ];
    return null;
  }
}

class _FailingHours extends WorkingHoursController {
  @override
  Future<List<SchedulingAvailabilityRuleView>> build() async => throw const NetworkError();
}

SchedulingAvailabilityRuleView _rule(int weekday) => SchedulingAvailabilityRuleView(
      id: 'rule-$weekday',
      proUserId: 'pro-1',
      weekday: weekday,
      startLocal: '09:00:00',
      endLocal: '17:00:00',
      timezone: 'Europe/Lisbon',
      locationMode: AvailabilityLocationMode.both,
      createdAt: DateTime.utc(2026, 9, 1),
      updatedAt: DateTime.utc(2026, 9, 1),
    );

AvailabilityExceptionView _block(String id, String reason, int dayOffset) => AvailabilityExceptionView(
      id: id,
      proUserId: 'pro-1',
      startAtUtc: DateTime.utc(2026, 10, dayOffset),
      endAtUtc: DateTime.utc(2026, 10, dayOffset + 3),
      reason: reason,
      createdAt: DateTime.utc(2026, 9, 1),
    );

final _policy = SchedulingPolicyView(
  proUserId: 'pro-1',
  slotLengthMinutes: 60,
  bufferBeforeMinutes: 15,
  bufferAfterMinutes: 15,
  advanceNoticeHours: 24,
  updatedAt: DateTime.utc(2026, 9, 1),
);

Widget _wrap({
  WorkingHoursController Function()? hours,
  BlockedTimeController Function()? blocked,
}) =>
    ProviderScope(
      overrides: [
        workingHoursControllerProvider.overrideWith(hours ?? () => _FakeHours([_rule(0)])),
        blockedTimeControllerProvider.overrideWith(
          blocked ?? () => _FakeBlocked([_block('b1', 'honeymoon', 1)]),
        ),
        schedulingPolicyControllerProvider.overrideWith(() => _FakePolicy()),
        availabilityTimezoneProvider.overrideWith((ref) async => 'Europe/Lisbon'),
      ],
      child: MaterialApp(theme: buildProTheme(), home: const AvailabilityScreen()),
    );

class _FakePolicy extends SchedulingPolicyController {
  @override
  Future<SchedulingPolicyView> build() async => _policy;
}

Future<void> _scrollTo(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(target, 200, scrollable: find.byType(Scrollable).first);
  await tester.pump();
}

void main() {
  testWidgets('a day with no rule reads as not working, not as blank', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump();

    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('09:00 – 17:00'), findsOneWidget);
    // Six remaining days, each stating the absence rather than showing nothing.
    expect(find.text('Not working'), findsNWidgets(6));
  });

  testWidgets('turning a day on sends a real IANA timezone', (tester) async {
    // DateTime.now().timeZoneName returns an abbreviation like "WEST", which
    // the backend rejects with a 422 - every save would have failed.
    final hours = _FakeHours([_rule(0)]);
    await tester.pumpWidget(_wrap(hours: () => hours));
    await tester.pump();

    await tester.tap(find.byType(Switch).at(1));
    await tester.pumpAndSettle();

    final added = hours.lastSent!.firstWhere((r) => r.weekday == 1);
    expect(added.timezone, 'Europe/Lisbon');
    expect(added.timezone, isNot(matches(RegExp(r'^[A-Z]{2,5}$'))));
  });

  testWidgets('turning a day off keeps the other days', (tester) async {
    // The endpoint replaces the whole week, so a toggle that forgot to
    // resend the rest would silently wipe them.
    final hours = _FakeHours([_rule(0), _rule(2), _rule(4)]);
    await tester.pumpWidget(_wrap(hours: () => hours));
    await tester.pump();

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(hours.lastSent!.map((r) => r.weekday).toList()..sort(), [2, 4]);
  });

  testWidgets('unblocking one range keeps the others', (tester) async {
    final blocked = _FakeBlocked([
      _block('b1', 'honeymoon', 1),
      _block('b2', 'family', 10),
    ]);
    await tester.pumpWidget(_wrap(blocked: () => blocked));
    await tester.pump();

    await _scrollTo(tester, find.text('honeymoon'));
    await tester.tap(find.byTooltip('Unblock').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unblock').last);
    await tester.pumpAndSettle();

    expect(blocked.survivingReasons, ['family']);
  });

  testWidgets('the blocked range shows the last day away, not the exclusive end', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump();

    await _scrollTo(tester, find.text('honeymoon'));
    // Stored as 01/10 to 04/10 exclusive; the pro is away through the 3rd.
    expect(find.text('01/10/2026 – 03/10/2026'), findsOneWidget);
  });

  testWidgets('lead time shows the saved choice in days, not hours', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump();

    await _scrollTo(tester, find.text('1 day'));
    final chip = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '1 day'));
    expect(chip.selected, isTrue);
  });

  testWidgets('one section failing leaves the others usable', (tester) async {
    await tester.pumpWidget(_wrap(hours: _FailingHours.new));
    await tester.pump();

    expect(find.text('Could not load your working hours.'), findsOneWidget);
    await _scrollTo(tester, find.text('honeymoon'));
    expect(find.text('honeymoon'), findsOneWidget);
  });
}
