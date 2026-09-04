import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/booking_request_list_item.dart';
import 'package:rawwers/api/models/booking_request_status.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/paging/cursor_page.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/requests/requests_controller.dart';
import 'package:rawwers/features/pro/requests/requests_screen.dart';

/// Renders the real RequestsScreen against fixture data.
///
/// This is the verification that the simulator could not provide: AppleScript
/// clicks reach the iOS springboard but not the Flutter canvas, so the tab
/// could never actually be driven by hand there. These assert what the screen
/// puts on screen for a given server response, which is the part that matters
/// and is reproducible in CI besides.
class _FakeRequests extends RequestsController {
  _FakeRequests(this._page);

  final CursorPage<BookingRequestListItem> _page;

  @override
  Future<CursorPage<BookingRequestListItem>> build() async => _page;
}

class _FailingRequests extends RequestsController {
  @override
  Future<CursorPage<BookingRequestListItem>> build() async => throw const NetworkError();
}

BookingRequestListItem _request({
  required String id,
  int? secondsUntilExpiry,
  BookingRequestStatus status = BookingRequestStatus.pending,
  String? location = 'Lisbon, Alfama',
  String? notes = 'Outdoor shoot, golden hour preferred.',
}) {
  final now = DateTime.utc(2026, 9, 8, 14);
  return BookingRequestListItem(
    id: id,
    proUserId: 'pro',
    clientUserId: 'client',
    packageId: 'package',
    requestedStart: now,
    requestedEnd: now.add(const Duration(hours: 2)),
    locationText: location,
    notes: notes,
    status: status,
    expiresAt: now,
    createdAt: now,
    secondsUntilExpiry: secondsUntilExpiry,
  );
}

Widget _wrap(CursorPage<BookingRequestListItem> page) => ProviderScope(
      overrides: [requestsControllerProvider.overrideWith(() => _FakeRequests(page))],
      child: MaterialApp(theme: buildProTheme(), home: const RequestsScreen()),
    );

void main() {
  testWidgets('renders a pending request with its countdown and actions', (tester) async {
    await tester.pumpWidget(
      _wrap(CursorPage(items: [_request(id: 'r1', secondsUntilExpiry: 3600 * 5)])),
    );
    await tester.pump();

    expect(find.text('Lisbon, Alfama'), findsOneWidget);
    expect(find.textContaining('to respond'), findsOneWidget);
    expect(find.text('Accept'), findsOneWidget);
    expect(find.text('Decline'), findsOneWidget);
  });

  testWidgets('a settled request offers no accept or decline', (tester) async {
    // The server omits secondsUntilExpiry once a request is decided, and the
    // screen keys its actions off that - so a declined request must not
    // present buttons that would 4xx.
    await tester.pumpWidget(
      _wrap(CursorPage(items: [_request(id: 'r1', status: BookingRequestStatus.declined)])),
    );
    await tester.pump();

    expect(find.text('Accept'), findsNothing);
    expect(find.text('Decline'), findsNothing);
    expect(find.textContaining('to respond'), findsNothing);
  });

  testWidgets('an empty pending queue explains the 24h window', (tester) async {
    await tester.pumpWidget(_wrap(const CursorPage(items: [])));
    await tester.pump();

    expect(find.text('Nothing waiting on you'), findsOneWidget);
    expect(find.textContaining('24 hours'), findsOneWidget);
  });

  testWidgets('offers load more when the server sent a cursor', (tester) async {
    await tester.pumpWidget(
      _wrap(CursorPage(items: [_request(id: 'r1', secondsUntilExpiry: 60)], nextCursor: 'c1')),
    );
    await tester.pump();

    expect(find.text('Load more'), findsOneWidget);
  });

  testWidgets('offers no load more on the last page', (tester) async {
    // Separate test rather than a second pumpWidget: re-pumping reuses the
    // ProviderScope element, so the new override never takes effect and the
    // assertion would pass or fail for the wrong reason.
    await tester.pumpWidget(
      _wrap(CursorPage(items: [_request(id: 'r1', secondsUntilExpiry: 60)])),
    );
    await tester.pump();

    expect(find.text('Load more'), findsNothing);
  });

  testWidgets('a failed append keeps the loaded rows and offers a retry', (tester) async {
    await tester.pumpWidget(
      _wrap(
        CursorPage(
          items: [_request(id: 'r1', secondsUntilExpiry: 60)],
          nextCursor: 'c1',
          loadMoreFailure: const NetworkError(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Lisbon, Alfama'), findsOneWidget, reason: 'loaded rows must survive a failed next page');
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('a failed first load shows a retryable error, not an empty list', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [requestsControllerProvider.overrideWith(_FailingRequests.new)],
        child: MaterialApp(theme: buildProTheme(), home: const RequestsScreen()),
      ),
    );
    await tester.pump();

    expect(find.textContaining('No connection'), findsOneWidget);
    expect(find.text('Nothing waiting on you'), findsNothing, reason: 'an error must never read as "you have none"');
  });
}
