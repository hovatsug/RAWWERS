// When a client can book, on the photographer's profile.
//
// Which days are open, and when a shoot can start, are the server's answer -
// the same rule every booking path enforces (api/app/services/bookable_time.py,
// whose tests prove the paths agree). What can go wrong here is the app
// guessing: letting a closed or past day be picked, inventing start times,
// showing times in the phone's zone instead of the photographer's, or making
// the client choose the date twice. The fake backend answers availability the
// way the server does and records the booking request that is sent.
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/api/api_client/client_launch_client.dart';
import 'package:rawwers/api/models/client_pro_profile_response.dart';
import 'package:rawwers/api/models/client_profile_package.dart';
import 'package:rawwers/api/models/pro_reviews_response.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/features/client/pro_profile/availability_controller.dart';
import 'package:rawwers/features/client/pro_profile/pro_profile_controller.dart';
import 'package:rawwers/features/client/pro_profile/pro_profile_screen.dart';
import 'package:rawwers/features/shared/reviews/pro_reviews_controller.dart';

import '../../support/fake_http_client_adapter.dart';

const _proId = 'pro-1';
const _packageId = 'pkg-1';

/// A fixed Wednesday mid-month, so a past day is always on screen and no
/// check is skipped for falling at a month's edge.
final _todayUtc = DateTime.utc(2030, 6, 12);

/// The photographer's UTC offset, chosen five hours away from the machine
/// running the test. Were the two the same, showing the phone's local time
/// instead of the photographer's would pass by coincidence - it did, here.
String get _offset {
  final minutes = (DateTime(2030, 6, 12).timeZoneOffset.inMinutes + 5 * 60 + 12 * 60) % (24 * 60) - 12 * 60;
  final sign = minutes < 0 ? '-' : '+';
  final abs = minutes.abs();
  return '$sign${(abs ~/ 60).toString().padLeft(2, '0')}:${(abs % 60).toString().padLeft(2, '0')}';
}

String _iso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// The server, as far as availability and requests go.
class _Backend {
  _Backend({this.hasSchedule = true, Map<String, List<String>>? open, this.answersBeforeRange = 0})
      : open = open ?? {};

  final bool hasSchedule;

  /// A misbehaving server that also sends this many days before the range
  /// asked for. The app never asks about the past; this checks it would not
  /// offer the past even if told to.
  final int answersBeforeRange;

  /// Local date -> local start times, for the days the server says are open.
  final Map<String, List<String>> open;
  final availabilityQueries = <Map<String, String>>[];
  final requests = <Map<String, dynamic>>[];

  /// When set, a booking request is refused with this 409 message - the hour
  /// was taken between the calendar loading and the request being sent.
  String? refuseRequestWith;

  Future<ResponseBody> handle(RequestOptions o) async {
    if (o.method == 'GET' && o.uri.path == '/v1/client/pros/$_proId/availability') {
      final q = o.uri.queryParameters;
      availabilityQueries.add(q);
      final from = DateTime.parse(q['from']!).toUtc().subtract(Duration(days: answersBeforeRange));
      final to = DateTime.parse(q['to']!).toUtc();
      final days = <Map<String, dynamic>>[];
      for (var d = DateTime.utc(from.year, from.month, from.day); !d.isAfter(to); d = d.add(const Duration(days: 1))) {
        final times = open[_iso(d)] ?? const <String>[];
        days.add({
          'date': _iso(d),
          'open': times.isNotEmpty,
          'start_times': [
            // The instant in the photographer's zone, and the wall-clock
            // reading of it there - which the phone, elsewhere, would read
            // differently.
            for (final t in times) _window(_iso(d), t),
          ],
        });
      }
      return jsonResponseBody(
        jsonEncode({'timezone': 'Europe/Lisbon', 'has_schedule': hasSchedule, 'notice_hours': 24, 'days': days}),
        200,
      );
    }
    if (o.method == 'POST' && o.uri.path == '/v1/client/bookings/request') {
      if (refuseRequestWith case final message?) {
        return jsonResponseBody(jsonEncode({'error': {'code': 'slot_conflict', 'message': message}}), 409);
      }
      // Round-tripped through JSON: what the server would receive, whatever
      // object dio was handed.
      requests.add(jsonDecode(o.data is String ? o.data as String : jsonEncode(o.data)) as Map<String, dynamic>);
      return jsonResponseBody(jsonEncode({'booking_id': 'b-1', 'status': 'pending'}), 200);
    }
    return jsonResponseBody('{"error":{"code":"not_found","message":"no route in fake"}}', 404);
  }
}

ClientProProfileResponse _profile() => ClientProProfileResponse(
      proUserId: _proId,
      displayName: 'Bea',
      city: 'Lisbon',
      avgRating: '0.00',
      reviewCount: 0,
      portfolioPhotoCount: 0,
      portfolioVideoCount: 0,
      isGuestView: false,
      packages: [
        ClientProfilePackage(
          id: _packageId,
          nicheSlug: 'portraits',
          title: 'Portraits Starter',
          durationMinutes: 90,
          price: '4.80',
          currency: 'EUR',
          includedPhotos: 20,
          entryRate: '4.80',
          minimumPhotos: 20,
          startingTotal: '79.74',
          extraPhotoPrice: '7.00',
          proofsSlaDays: 3,
          finalsSlaDays: 7,
        ),
      ],
    );

/// One offered window as the server sends it: since scheduling presets
/// (api 056dcf9) every start carries its end - the 90-minute package's
/// length here - so the request sends exactly what was offered.
Map<String, dynamic> _window(String date, String time) {
  final start = DateTime.parse('${date}T$time:00$_offset');
  final end = start.add(const Duration(minutes: 90));
  final parts = time.split(':').map(int.parse).toList();
  final endMinutes = (parts[0] * 60 + parts[1] + 90) % (24 * 60);
  String two(int n) => n.toString().padLeft(2, '0');
  return {
    'start_at': '${date}T$time:00$_offset',
    'local_time': time,
    'end_at': end.toUtc().toIso8601String(),
    'local_end_time': '${two(endMinutes ~/ 60)}:${two(endMinutes % 60)}',
  };
}

Future<void> _pump(WidgetTester tester, _Backend backend) async {
  // Semantics are on by default in testWidgets, which the "not only in
  // colour" check reads.
  tester.view.physicalSize = const Size(1170, 8000);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'))..httpClientAdapter = FakeHttpClientAdapter(backend.handle);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        clientLaunchClientProvider.overrideWithValue(ClientLaunchClient(dio)),
        availabilityTodayProvider.overrideWithValue(_todayUtc),
        proProfileProvider(_proId).overrideWith((ref) async => _profile()),
        proReviewsProvider(_proId).overrideWith((ref) async => const ProReviewsResponse(total: 0, items: [])),
      ],
      // A router, because sending a request opens the booking it created.
      child: MaterialApp.router(
        theme: buildClientTheme(),
        routerConfig: GoRouter(
          routes: [
            GoRoute(path: '/', builder: (context, state) => const ProProfileScreen(proUserId: _proId)),
            GoRoute(
              path: '/bookings/:id',
              builder: (context, state) => Scaffold(body: Text('booking ${state.pathParameters['id']}')),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _day(DateTime d) => find.byKey(ValueKey('day-${_iso(d)}'));

bool _selectable(WidgetTester tester, DateTime d) {
  return tester.getSemantics(_day(d)).getSemanticsData().hasAction(SemanticsAction.tap);
}

void main() {
  testWidgets('open and closed days are the server\'s, and closed ones cannot be picked', (tester) async {
    final open = _todayUtc.add(const Duration(days: 3));
    final closed = _todayUtc.add(const Duration(days: 4));
    final backend = _Backend(open: {_iso(open): ['10:00', '11:30']});
    await _pump(tester, backend);
    expect(_selectable(tester, closed), isFalse, reason: 'a closed day must not be selectable at all');

    expect(_selectable(tester, open), isTrue);
    await tester.tap(_day(open));
    await tester.pumpAndSettle();

    // Exactly the server's start times, in the photographer's own time.
    expect(find.text('10:00'), findsOneWidget);
    expect(find.text('11:30'), findsOneWidget);
    expect(find.textContaining('Lisbon time'), findsWidgets);
  });

  testWidgets('a closed day says so in words, not only in colour', (tester) async {
    final open = _todayUtc.add(const Duration(days: 3));
    final backend = _Backend(open: {_iso(open): ['10:00']});
    await _pump(tester, backend);

    expect(tester.getSemantics(_day(open)).label, contains('available'));
    expect(tester.getSemantics(_day(open.add(const Duration(days: 1)))).label, contains('no times'));
  });

  testWidgets('a day before today can never be picked, whatever the server says', (tester) async {
    final yesterday = _todayUtc.subtract(const Duration(days: 1));
    // A server bug would not make the past bookable.
    final backend = _Backend(open: {_iso(yesterday): ['10:00']}, answersBeforeRange: 3);
    await _pump(tester, backend);
    expect(_selectable(tester, yesterday), isFalse);
    for (final q in backend.availabilityQueries) {
      expect(DateTime.parse(q['from']!).isBefore(_todayUtc), isFalse, reason: 'asked the server about the past');
    }
  });

  testWidgets('the chosen time goes into the request - no second date picker', (tester) async {
    final open = _todayUtc.add(const Duration(days: 3));
    final backend = _Backend(open: {_iso(open): ['10:00', '11:30']});
    await _pump(tester, backend);
    await tester.tap(_day(open));
    await tester.pumpAndSettle();
    await tester.tap(find.text('11:30'));
    await tester.pumpAndSettle();

    // The sheet states the choice and asks only what is left.
    expect(find.textContaining('11:30'), findsWidgets);
    expect(find.text('Choose a date'), findsNothing);
    expect(find.text('Choose a time'), findsNothing);
    expect(find.byType(DatePickerDialog), findsNothing);

    await tester.enterText(find.byType(TextField).first, 'Belém');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Send request'));
    await tester.pumpAndSettle();

    expect(backend.requests, hasLength(1));
    final window = backend.requests.single['date_window'] as Map<String, dynamic>;
    final start = DateTime.parse(window['start_at'] as String);
    final end = DateTime.parse(window['end_at'] as String);
    expect(start, DateTime.parse('${_iso(open)}T11:30:00$_offset'), reason: 'the instant the server offered, unchanged');
    expect(end.difference(start), const Duration(minutes: 90), reason: 'the package length');
    expect(find.text('booking b-1'), findsOneWidget, reason: 'sent, and on to the booking it made');
  });

  testWidgets('a photographer with no working hours says so instead of a dead calendar', (tester) async {
    await _pump(tester, _Backend(hasSchedule: false));
    expect(find.textContaining("hasn't set their working hours"), findsOneWidget);
    expect(find.byKey(ValueKey('day-${_iso(_todayUtc)}')), findsNothing);
  });

  testWidgets('it never asks beyond the 90-day horizon', (tester) async {
    final backend = _Backend();
    await _pump(tester, backend);
    for (var i = 0; i < 5; i++) {
      final next = find.widgetWithIcon(IconButton, Icons.chevron_right);
      if (next.evaluate().isEmpty || tester.widget<IconButton>(next).onPressed == null) break;
      await tester.tap(next);
      await tester.pumpAndSettle();
    }
    final limit = _todayUtc.add(const Duration(days: 90));
    for (final q in backend.availabilityQueries) {
      expect(DateTime.parse(q['to']!).isAfter(limit), isFalse, reason: 'asked past the horizon: ${q['to']}');
    }
  });

  group('after a booking, the calendar asks again', () {
    Future<void> sendRequest(WidgetTester tester, DateTime open) async {
      await tester.tap(_day(open));
      await tester.pumpAndSettle();
      await tester.tap(find.text('10:00'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Belém');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Send request'));
      await tester.pumpAndSettle();
    }

    testWidgets('once a request is sent - the hour is now held', (tester) async {
      final open = _todayUtc.add(const Duration(days: 3));
      final backend = _Backend(open: {_iso(open): ['10:00']});
      await _pump(tester, backend);
      final before = backend.availabilityQueries.length;

      await sendRequest(tester, open);

      expect(backend.availabilityQueries.length, greaterThan(before), reason: 'the calendar kept its old answer');
    });

    testWidgets('on coming back to the profile from the booking', (tester) async {
      final open = _todayUtc.add(const Duration(days: 3));
      final backend = _Backend(open: {_iso(open): ['10:00']});
      await _pump(tester, backend);
      await sendRequest(tester, open);
      expect(find.text('booking b-1'), findsOneWidget);
      final before = backend.availabilityQueries.length;

      // Someone else books meanwhile; coming back must show it.
      backend.open.clear();
      GoRouter.of(tester.element(find.text('booking b-1'))).pop();
      await tester.pumpAndSettle();

      expect(backend.availabilityQueries.length, greaterThan(before));
      expect(_selectable(tester, open), isFalse, reason: 'the profile still offered a taken hour');
    });

    testWidgets('when a request is refused because the hour was just taken', (tester) async {
      final open = _todayUtc.add(const Duration(days: 3));
      final backend = _Backend(open: {_iso(open): ['10:00']})..refuseRequestWith = 'That time clashes with another booking.';
      await _pump(tester, backend);
      final before = backend.availabilityQueries.length;

      await sendRequest(tester, open);

      expect(find.text('That time clashes with another booking.'), findsOneWidget);
      expect(backend.availabilityQueries.length, greaterThan(before));
    });

    testWidgets('on pull-to-refresh', (tester) async {
      final open = _todayUtc.add(const Duration(days: 3));
      final backend = _Backend(open: {_iso(open): ['10:00']});
      await _pump(tester, backend);
      final before = backend.availabilityQueries.length;

      // Far enough for the tall test surface: refresh triggers on a pull
      // that is a share of the viewport's height.
      await tester.fling(find.byType(CustomScrollView), const Offset(0, 1600), 1000);
      await tester.pumpAndSettle();

      expect(backend.availabilityQueries.length, greaterThan(before));
    });
  });
}
