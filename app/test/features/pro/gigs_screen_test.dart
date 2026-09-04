import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/booking_request_list_item.dart';
import 'package:rawwers/api/models/gig_response.dart';
import 'package:rawwers/api/models/gig_status.dart';
import 'package:rawwers/core/paging/cursor_page.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/gigs/gigs_controller.dart';
import 'package:rawwers/features/pro/gigs/gigs_screen.dart';
import 'package:rawwers/features/pro/requests/requests_controller.dart';
import 'package:rawwers/features/pro/today/today_screen.dart';

class _FakeGigs extends GigsController {
  _FakeGigs(this._page);

  final CursorPage<GigResponse> _page;

  @override
  Future<CursorPage<GigResponse>> build() async => _page;
}

/// Today also watches the Requests provider, for the pending count. Without
/// overriding it the screen makes a real network call and leaves a pending
/// timer behind, which fails the test for a reason unrelated to Today.
class _FakeRequestsEmpty extends RequestsController {
  @override
  Future<CursorPage<BookingRequestListItem>> build() async => const CursorPage(items: []);
}

class _FakeToday extends TodayController {
  _FakeToday(this._page);

  final CursorPage<GigResponse> _page;

  @override
  Future<CursorPage<GigResponse>> build() async => _page;
}

GigResponse _gig({
  required String id,
  GigStatus status = GigStatus.paid,
  String proGross = '120.00',
  DateTime? scheduledStart,
}) {
  return GigResponse(
    id: id,
    clientUserId: 'client',
    proUserId: 'pro',
    status: status,
    currency: 'EUR',
    amountMinimum: '150.00',
    amountPlatformFee: '30.00',
    amountProGross: proGross,
    locationText: 'Porto, Ribeira',
    scheduledStart: scheduledStart ?? DateTime.utc(2026, 9, 8, 14),
    scheduledEnd: DateTime.utc(2026, 9, 8, 16),
    createdAt: DateTime.utc(2026, 9, 1),
    updatedAt: DateTime.utc(2026, 9, 1),
  );
}

Widget _wrapGigs(CursorPage<GigResponse> page) => ProviderScope(
      overrides: [gigsControllerProvider.overrideWith(() => _FakeGigs(page))],
      child: MaterialApp(theme: buildProTheme(), home: const GigsScreen()),
    );

void main() {
  testWidgets('renders a gig with its status label and what the pro earns', (tester) async {
    await tester.pumpWidget(_wrapGigs(CursorPage(items: [_gig(id: 'g1')])));
    await tester.pump();

    expect(find.text('Porto, Ribeira'), findsOneWidget);
    expect(find.text('Paid'), findsOneWidget);
    expect(find.text('You earn'), findsOneWidget);
    // Money is rendered from the decimal string, never parsed to a double.
    expect(find.text('€120.00'), findsOneWidget);
  });

  testWidgets('the active filter hides delivered and cancelled gigs', (tester) async {
    await tester.pumpWidget(
      _wrapGigs(
        CursorPage(
          items: [
            _gig(id: 'g1', status: GigStatus.paid),
            _gig(id: 'g2', status: GigStatus.completed),
            _gig(id: 'g3', status: GigStatus.cancelledByClient),
          ],
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Paid'), findsOneWidget);
    expect(find.text('Completed'), findsNothing);
    expect(find.text('Cancelled by client'), findsNothing);
  });

  testWidgets('an unscheduled gig says so rather than rendering a blank date', (tester) async {
    await tester.pumpWidget(
      _wrapGigs(CursorPage(items: [GigResponse(
        id: 'g1',
        clientUserId: 'client',
        proUserId: 'pro',
        status: GigStatus.paymentPending,
        currency: 'EUR',
        amountMinimum: '150.00',
        amountPlatformFee: '30.00',
        amountProGross: '120.00',
        locationText: 'Lisbon',
        scheduledStart: null,
        scheduledEnd: null,
        createdAt: DateTime.utc(2026, 9, 1),
        updatedAt: DateTime.utc(2026, 9, 1),
      )])),
    );
    await tester.pump();

    expect(find.text('Not scheduled yet'), findsOneWidget);
    expect(find.text('Awaiting payment'), findsOneWidget);
  });

  testWidgets('an empty active list explains where gigs come from', (tester) async {
    await tester.pumpWidget(_wrapGigs(const CursorPage(items: [])));
    await tester.pump();

    expect(find.text('No gigs on the go'), findsOneWidget);
    expect(find.textContaining('once the client has paid'), findsOneWidget);
  });

  group('Today', () {
    Widget wrapToday(CursorPage<GigResponse> page) => ProviderScope(
          overrides: [
            todayControllerProvider.overrideWith(() => _FakeToday(page)),
            requestsControllerProvider.overrideWith(_FakeRequestsEmpty.new),
          ],
          child: MaterialApp(theme: buildProTheme(), home: const TodayScreen(settingsPath: '/settings')),
        );

    testWidgets('lists todays shoots', (tester) async {
      await tester.pumpWidget(wrapToday(CursorPage(items: [_gig(id: 'g1')])));
      await tester.pump();

      expect(find.text('Your shoots today'), findsOneWidget);
      expect(find.text('Porto, Ribeira'), findsOneWidget);
    });

    testWidgets('says nothing is scheduled rather than showing an empty area', (tester) async {
      await tester.pumpWidget(wrapToday(const CursorPage(items: [])));
      await tester.pump();

      expect(find.text('Nothing scheduled today.'), findsOneWidget);
    });

    testWidgets('reaches settings from the header, not a fifth tab', (tester) async {
      await tester.pumpWidget(wrapToday(const CursorPage(items: [])));
      await tester.pump();

      expect(find.byTooltip('Profile and settings'), findsOneWidget);
    });
  });
}
