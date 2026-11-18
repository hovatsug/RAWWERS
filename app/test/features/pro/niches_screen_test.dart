// The niches screen (BETA_SCOPE "Pro app: choose and manage niches") and the
// onboarding step that sends a photographer there.
//
// The rules are the server's: these check that the screen offers only what
// a photographer may choose, sends the change, and shows the server's
// refusal in its own words.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/api/models/pro_niche_view.dart';
import 'package:rawwers/api/models/pro_onboarding_checks_response.dart';
import 'package:rawwers/api/models/pro_onboarding_status.dart';
import 'package:rawwers/api/models/pro_profile_view.dart';
import 'package:rawwers/api/models/update_my_niches_response.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/niches/my_niches_controller.dart';
import 'package:rawwers/features/pro/niches/niches_screen.dart';
import 'package:rawwers/features/pro/onboarding/onboarding_controller.dart';
import 'package:rawwers/features/pro/onboarding/onboarding_screen.dart';
import 'package:rawwers/features/pro/portfolio/niches_controller.dart';
import 'package:rawwers/features/pro/settings/settings_controller.dart';

const _all = [
  NicheOption(id: '1', slug: 'weddings', name: 'Weddings'),
  NicheOption(id: '2', slug: 'portraits', name: 'Portraits'),
  NicheOption(id: '3', slug: 'food', name: 'Food'),
  NicheOption(id: '4', slug: 'events', name: 'Events'),
];

ProNicheView _niche(String slug, String name, {bool main = false}) => ProNicheView(slug: slug, name: name, isPrimary: main);

class _FakeMine extends MyNichesController {
  _FakeMine(this._value, {this.refusal});

  final UpdateMyNichesResponse _value;
  final String? refusal;
  final calls = <String>[];

  @override
  Future<UpdateMyNichesResponse> build() async => _value;

  @override
  Future<String?> add(String slug) async {
    calls.add('add $slug');
    return refusal;
  }

  @override
  Future<String?> remove(String slug) async {
    calls.add('remove $slug');
    return refusal;
  }

  @override
  Future<String?> makeMain(String slug) async {
    calls.add('main $slug');
    return refusal;
  }
}

class _FakeAll extends NichesController {
  @override
  Future<List<NicheOption>> build() async => _all;
}

UpdateMyNichesResponse _mine(List<ProNicheView> niches, {int maximum = 3, int minimum = 1}) => UpdateMyNichesResponse(
      primaryNicheSlug: niches.where((n) => n.isPrimary).map((n) => n.slug).firstOrNull,
      niches: niches,
      maximum: maximum,
      minimum: minimum,
    );

Future<_FakeMine> _pump(WidgetTester tester, UpdateMyNichesResponse value, {String? refusal}) async {
  final fake = _FakeMine(value, refusal: refusal);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        myNichesControllerProvider.overrideWith(() => fake),
        nichesControllerProvider.overrideWith(_FakeAll.new),
      ],
      child: MaterialApp(theme: buildProTheme(), home: const NichesScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  testWidgets('shows the photographer\'s niches, the main one marked, and the limits', (tester) async {
    await _pump(tester, _mine([_niche('portraits', 'Portraits'), _niche('weddings', 'Weddings', main: true)]));
    expect(find.text('Weddings'), findsOneWidget);
    expect(find.text('Portraits'), findsOneWidget);
    expect(find.text('Main'), findsOneWidget);
    expect(find.text('Make main'), findsOneWidget, reason: 'only the niche that is not the main one');
    expect(find.text('You can have up to 3. You need at least 1.'), findsOneWidget);
  });

  testWidgets('adding offers only the active niches the photographer does not have', (tester) async {
    final fake = await _pump(tester, _mine([_niche('weddings', 'Weddings', main: true)]));
    await tester.tap(find.text('Add a niche'));
    await tester.pumpAndSettle();
    final sheet = find.byType(BottomSheet);
    expect(find.descendant(of: sheet, matching: find.text('Portraits')), findsOneWidget);
    expect(find.descendant(of: sheet, matching: find.text('Food')), findsOneWidget);
    expect(find.descendant(of: sheet, matching: find.text('Weddings')), findsNothing, reason: 'already theirs');
    await tester.tap(find.descendant(of: sheet, matching: find.text('Food')));
    await tester.pumpAndSettle();
    expect(fake.calls, ['add food']);
  });

  testWidgets('at the maximum, adding is not offered and the screen says why', (tester) async {
    await _pump(
      tester,
      _mine([_niche('weddings', 'Weddings', main: true), _niche('food', 'Food'), _niche('events', 'Events')]),
    );
    expect(find.text('Add a niche'), findsNothing);
    expect(find.text('You have the most niches you can (3). Remove one to add another.'), findsOneWidget);
  });

  testWidgets('removing asks first, saying what stays, then sends it', (tester) async {
    final fake = await _pump(tester, _mine([_niche('weddings', 'Weddings', main: true), _niche('food', 'Food')]));
    await tester.tap(find.byTooltip('Remove Food'));
    await tester.pumpAndSettle();
    expect(find.text('Remove Food?'), findsOneWidget);
    expect(find.textContaining('Your photos tagged Food stay in your portfolio'), findsOneWidget);
    expect(fake.calls, isEmpty, reason: 'nothing is sent before the confirmation');
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(fake.calls, ['remove food']);
  });

  testWidgets('cancelling a removal sends nothing', (tester) async {
    final fake = await _pump(tester, _mine([_niche('weddings', 'Weddings', main: true), _niche('food', 'Food')]));
    await tester.tap(find.byTooltip('Remove Food'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(fake.calls, isEmpty);
  });

  testWidgets('a refusal is shown in the server\'s own words', (tester) async {
    const refusal = 'You have a booking in Food that is not finished. You can remove Food once it is completed or cancelled.';
    await _pump(tester, _mine([_niche('weddings', 'Weddings', main: true), _niche('food', 'Food')]), refusal: refusal);
    await tester.tap(find.byTooltip('Remove Food'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(find.text(refusal), findsOneWidget);
  });

  testWidgets('another niche can be made the main one', (tester) async {
    final fake = await _pump(tester, _mine([_niche('weddings', 'Weddings', main: true), _niche('food', 'Food')]));
    await tester.tap(find.text('Make main'));
    await tester.pumpAndSettle();
    expect(fake.calls, ['main food']);
  });

  testWidgets('a photographer with no niches is told to add one', (tester) async {
    await _pump(tester, _mine(const []));
    expect(find.text('No niches yet. Add the kind of shoot you do.'), findsOneWidget);
    expect(find.text('Add a niche'), findsOneWidget);
  });

  group('the onboarding step', () {
    Future<void> pumpChecklist(WidgetTester tester, {required bool done, int count = 0}) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const OnboardingScreen(
              profilePath: '/profile',
              portfolioPath: '/portfolio',
              nichesPath: '/niches',
              pricingPath: '/pricing',
              gearPath: '/gear',
            ),
          ),
          GoRoute(path: '/niches', builder: (context, state) => const Scaffold(body: Text('the niches screen'))),
          GoRoute(path: '/profile', builder: (context, state) => const Scaffold(body: Text('the profile screen'))),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            onboardingControllerProvider.overrideWith(() => _Checks(done: done, count: count)),
            proProfileControllerProvider.overrideWith(_Profile.new),
          ],
          child: MaterialApp.router(theme: buildProTheme(), routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('"What you shoot" opens the niches screen, not the profile', (tester) async {
      await pumpChecklist(tester, done: false);
      expect(find.text('Choose the niches you want to be found under.'), findsOneWidget);
      await tester.tap(find.text('What you shoot'));
      await tester.pumpAndSettle();
      expect(find.text('the niches screen'), findsOneWidget);
      expect(find.text('the profile screen'), findsNothing);
    });

    testWidgets('a chosen niche shows as done, with the count', (tester) async {
      await pumpChecklist(tester, done: true, count: 2);
      expect(find.text('2 niches chosen.'), findsOneWidget);
    });
  });
}

class _Checks extends OnboardingController {
  _Checks({required this.done, required this.count});

  final bool done;
  final int count;

  @override
  Future<ProOnboardingChecksResponse> build() async => ProOnboardingChecksResponse(
        status: ProOnboardingStatus.started,
        checks: {'niches_selected': done, 'niches_count': count, 'portfolio_count': 0, 'portfolio_min_required': 12},
        missing: const [],
      );

  @override
  Future<void> syncStages() async {}
}

class _Profile extends ProProfileController {
  @override
  Future<ProProfileView> build() async => ProProfileView(
        currency: 'EUR',
        userId: 'pro-1',
        displayName: 'Alex Lens',
        isAcceptingBookings: false,
        completenessScore: 80,
        kycStatus: 'unsubmitted',
      );
}
