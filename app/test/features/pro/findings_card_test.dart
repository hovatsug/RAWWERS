import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/booking_pause_view.dart';
import 'package:rawwers/api/models/finding_view.dart';
import 'package:rawwers/api/models/my_findings_response.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/findings/findings_card.dart';
import 'package:rawwers/features/pro/findings/findings_controller.dart';

class _Fake extends FindingsController {
  _Fake(this._data);

  final MyFindingsResponse _data;
  final List<String> seen = [];

  @override
  Future<MyFindingsResponse> build() async => _data;

  @override
  Future<void> markSeen(String findingId) async => seen.add(findingId);
}

FindingView _finding({String status = 'pending', String? firstSeenAt, String? consequence, String? response}) => FindingView(
      id: 'f-1',
      gigId: 'gig-1',
      status: status,
      reason: 'Photos not delivered',
      note: '6 of 20 photos never delivered',
      severe: false,
      createdAt: '2026-10-20T10:00:00+00:00',
      firstSeenAt: firstSeenAt,
      windowEndsAt: '2026-11-10T10:00:00+00:00',
      response: response,
      consequence: consequence,
    );

Future<_Fake> _pump(WidgetTester tester, MyFindingsResponse data) async {
  final fake = _Fake(data);
  await tester.pumpWidget(ProviderScope(
    overrides: [findingsControllerProvider.overrideWith(() => fake)],
    child: MaterialApp(theme: buildProTheme(), home: const Scaffold(body: SingleChildScrollView(child: FindingsCard()))),
  ));
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  // Dates as a UK or Portuguese phone shows them (see test/core/dates_test.dart).
  setUp(() {
    final dispatcher = TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher;
    dispatcher.localeTestValue = const Locale('en', 'GB');
    dispatcher.localesTestValue = const [Locale('en', 'GB')];
  });
  tearDown(() => TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.clearAllTestValues());

  testWidgets('nothing to say, nothing shown', (tester) async {
    await _pump(tester, const MyFindingsResponse(strikes: 0, items: []));
    expect(find.text('Findings on your account'), findsNothing);
  });

  testWidgets('a pending finding says nothing takes effect before the window ends, and offers a response', (tester) async {
    await _pump(tester, MyFindingsResponse(strikes: 0, items: [_finding()]));

    expect(find.text('6 of 20 photos never delivered'), findsOneWidget);
    expect(find.textContaining('Nothing takes effect before 10 Nov'), findsOneWidget);
    expect(find.text('Respond'), findsOneWidget);
  });

  testWidgets('first seeing it starts the window - and only the first time', (tester) async {
    final fresh = await _pump(tester, MyFindingsResponse(strikes: 0, items: [_finding()]));
    expect(fresh.seen, ['f-1']);

    final seenBefore = await _pump(tester, MyFindingsResponse(strikes: 0, items: [_finding(firstSeenAt: '2026-10-21T09:00:00+00:00')]));
    expect(seenBefore.seen, isEmpty);
  });

  testWidgets('a pause is shown with its reason, and the strike count', (tester) async {
    await _pump(tester, MyFindingsResponse(
      strikes: 2,
      pause: const BookingPauseView(reason: 'Paused after a second confirmed finding.', since: '2026-10-22T10:00:00+00:00'),
      items: [_finding(status: 'confirmed', consequence: 'booking_pause', firstSeenAt: '2026-10-21T09:00:00+00:00')],
    ));

    expect(find.text('New bookings are paused'), findsOneWidget);
    expect(find.text('Paused after a second confirmed finding.'), findsOneWidget);
    expect(find.text('2 strikes counting now.'), findsOneWidget);
    expect(find.text('Respond'), findsNothing);
  });
}
