import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/pro_onboarding_checks_response.dart';
import 'package:rawwers/api/models/pro_onboarding_status.dart';
import 'package:rawwers/api/models/pro_profile_view.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/onboarding/onboarding_controller.dart';
import 'package:rawwers/features/pro/onboarding/onboarding_screen.dart';
import 'package:rawwers/features/pro/settings/settings_controller.dart';

/// The checklist is read from the server, never from local step state.
/// These cover that it reopens when work is undone, and that the identity
/// step describes a wait a person controls rather than a spinner.
class _FakeOnboarding extends OnboardingController {
  _FakeOnboarding(this._response);

  final ProOnboardingChecksResponse _response;
  var kycSubmissions = 0;
  var goLiveCalls = 0;
  var stageSyncs = 0;

  @override
  Future<ProOnboardingChecksResponse> build() async => _response;

  @override
  Future<void> syncStages() async => stageSyncs++;

  @override
  Future<String?> submitKyc() async {
    kycSubmissions++;
    return null;
  }

  @override
  Future<String?> goLive() async {
    goLiveCalls++;
    return null;
  }
}

class _FailingOnboarding extends OnboardingController {
  @override
  Future<ProOnboardingChecksResponse> build() async => throw const NetworkError();
}

class _FakeProfile extends ProProfileController {
  _FakeProfile(this._kyc);

  final String _kyc;

  @override
  Future<ProProfileView> build() async => ProProfileView(
        userId: 'pro-1',
        displayName: 'Alex Lens',
        isAcceptingBookings: false,
        completenessScore: 80,
        kycStatus: _kyc,
      );
}

ProOnboardingChecksResponse _checks({
  bool profile = true,
  bool portfolio = false,
  bool packages = false,
  bool niches = false,
  bool kycSubmitted = false,
  bool kycApproved = false,
  bool ready = false,
  int photos = 7,
  bool gear = false,
  int gearAwaiting = 0,
  List<String> gearMissing = const ['full_frame_body', 'qualifying_lens'],
}) =>
    ProOnboardingChecksResponse(
      status: ProOnboardingStatus.started,
      checks: {
        'profile_completed': profile,
        'portfolio_uploaded': portfolio,
        'packages_configured': packages,
        'niches_selected': niches,
        'kyc_submitted': kycSubmitted,
        'kyc_approved': kycApproved,
        'ready_for_review': ready,
        'portfolio_count': photos,
        'portfolio_min_required': 12,
        'gear_verified': gear,
        'gear_awaiting_review': gearAwaiting,
        'gear_missing': gear ? <String>[] : gearMissing,
      },
      missing: const [],
    );

Widget _wrap({
  OnboardingController Function()? onboarding,
  String kyc = 'unsubmitted',
}) =>
    ProviderScope(
      overrides: [
        onboardingControllerProvider.overrideWith(onboarding ?? () => _FakeOnboarding(_checks())),
        proProfileControllerProvider.overrideWith(() => _FakeProfile(kyc)),
      ],
      child: MaterialApp(
        theme: buildProTheme(),
        home: const OnboardingScreen(
          profilePath: '/profile',
          portfolioPath: '/portfolio',
          pricingPath: '/pricing',
          gearPath: '/gear',
        ),
      ),
    );

/// The checklist is longer than the default 800x600 test surface, and the
/// identity step and the go-live button both sit at the bottom of it - a
/// tap that lands on empty space fails exactly like a broken handler.
Future<void> _tap(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(target, 200, scrollable: find.byType(Scrollable).first);
  await tester.pump();
  await tester.tap(target);
  await tester.pump();
}

void main() {
  testWidgets('portfolio progress is a count, not a percentage', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump();

    // "7 of 12" says how much work is left; "58%" does not.
    expect(find.text('7 of 12 photos.'), findsOneWidget);
  });

  testWidgets('a satisfied portfolio step stops counting down', (tester) async {
    await tester.pumpWidget(_wrap(
      onboarding: () => _FakeOnboarding(_checks(portfolio: true, photos: 14)),
    ));
    await tester.pump();

    expect(find.text('14 photos.'), findsOneWidget);
    expect(find.textContaining('of 12'), findsNothing);
  });

  testWidgets('a step the server no longer considers done is shown open', (tester) async {
    // Deleting photos reopens the step, because nothing here remembers a
    // position - a stored step index would have kept it ticked.
    await tester.pumpWidget(_wrap(
      onboarding: () => _FakeOnboarding(_checks(portfolio: false, photos: 6)),
    ));
    await tester.pump();

    expect(find.text('6 of 12 photos.'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget, reason: 'only the profile step is done');
  });

  testWidgets('the identity step says a person does the reviewing', (tester) async {
    await tester.pumpWidget(_wrap(
      onboarding: () => _FakeOnboarding(_checks(kycSubmitted: true)),
      kyc: 'pending',
    ));
    await tester.pump();

    await tester.scrollUntilVisible(
      find.text('Identity check in review'), 200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Identity check in review'), findsOneWidget);
    expect(find.textContaining('by hand'), findsOneWidget);
    // Copy that implied an instant check would have people refreshing.
    expect(find.textContaining('not need to keep checking'), findsOneWidget);
  });

  testWidgets('an unsubmitted identity check offers to start it', (tester) async {
    final onboarding = _FakeOnboarding(_checks());
    await tester.pumpWidget(_wrap(onboarding: () => onboarding));
    await tester.pump();

    await tester.scrollUntilVisible(
      find.textContaining('A person reviews it'), 200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('A person reviews it'), findsOneWidget);
    await _tap(tester, find.widgetWithText(RButton, 'Start identity check'));

    expect(onboarding.kycSubmissions, 1);
  });

  testWidgets('a submitted identity check no longer offers to start it', (tester) async {
    await tester.pumpWidget(_wrap(
      onboarding: () => _FakeOnboarding(_checks(kycSubmitted: true)),
      kyc: 'pending',
    ));
    await tester.pump();

    expect(find.widgetWithText(RButton, 'Start identity check'), findsNothing);
  });

  testWidgets('going live is not offered until everything is done', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump();

    expect(find.widgetWithText(RButton, 'Put my listing live'), findsNothing);
  });

  testWidgets('going live is offered once the server says ready', (tester) async {
    final onboarding = _FakeOnboarding(_checks(
      portfolio: true,
      packages: true,
      niches: true,
      kycSubmitted: true,
      kycApproved: true,
      ready: true,
      photos: 14,
    ));
    await tester.pumpWidget(_wrap(onboarding: () => onboarding, kyc: 'approved'));
    await tester.pump();

    expect(find.text('You are ready to go live'), findsOneWidget);
    await _tap(tester, find.widgetWithText(RButton, 'Put my listing live'));

    expect(onboarding.goLiveCalls, 1);
  });

  testWidgets('opening the screen tells the backend which stages are done', (tester) async {
    // The admin panel reads the onboarding status, not the computed
    // checks - without this every photographer reads as "started".
    final onboarding = _FakeOnboarding(_checks());
    await tester.pumpWidget(_wrap(onboarding: () => onboarding));
    // The sync runs after the first frame and awaits the checks future,
    // so it needs the microtask queue drained, not just a repaint.
    await tester.pump();
    await tester.pump(Duration.zero);
    await tester.pumpAndSettle();

    expect(onboarding.stageSyncs, 1);
  });

  testWidgets('a failed load says so rather than showing an empty checklist', (tester) async {
    await tester.pumpWidget(_wrap(onboarding: _FailingOnboarding.new));
    await tester.pump();

    expect(find.text('Could not load your progress.'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Gear. The server refused every photographer without verified gear while this
  // checklist never mentioned it: someone could see every step done, and be
  // unable to go live without being told why.
  // -------------------------------------------------------------------------

  testWidgets('gear is a step on the checklist, not something discovered at the end', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump();

    expect(find.text('Your gear'), findsOneWidget);
  });

  testWidgets('finishing every other step is not "done" while gear is outstanding', (tester) async {
    await tester.pumpWidget(_wrap(
      onboarding: () => _FakeOnboarding(_checks(portfolio: true, packages: true, niches: true, photos: 12)),
    ));
    await tester.pump();

    // Five steps now, and four of them done: the old checklist read "4 of 4".
    expect(find.text('4 of 5 done'), findsOneWidget);
    expect(find.text('Put my listing live'), findsNothing);
  });

  testWidgets('outstanding gear names what is missing in words', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump();

    expect(find.text('Still needed: a full-frame camera body, a prime or fixed-aperture lens.'), findsOneWidget);
  });

  testWidgets('gear waiting on a person reads as waiting on us, not as work to do', (tester) async {
    await tester.pumpWidget(_wrap(
      onboarding: () => _FakeOnboarding(_checks(gearAwaiting: 1)),
    ));
    await tester.pump();

    expect(find.text('Waiting on us: one item is being checked by hand.'), findsOneWidget);
    expect(find.textContaining('Still needed'), findsNothing);
  });

  testWidgets('verified gear closes the step', (tester) async {
    await tester.pumpWidget(_wrap(onboarding: () => _FakeOnboarding(_checks(gear: true))));
    await tester.pump();

    expect(find.text('A full-frame body and a lens that qualify, verified.'), findsOneWidget);
  });

  group('gearStepDetail', () {
    test('lists a missing lens on its own', () {
      expect(
        gearStepDetail({'gear_verified': false, 'gear_missing': ['qualifying_lens']}),
        'Still needed: a prime or fixed-aperture lens.',
      );
    });

    test('lists lighting when the niches call for it', () {
      expect(
        gearStepDetail({'gear_verified': false, 'gear_missing': ['lighting']}),
        'Still needed: your lighting.',
      );
    });

    test('pluralises the wait', () {
      expect(
        gearStepDetail({'gear_verified': false, 'gear_awaiting_review': 2}),
        'Waiting on us: 2 items are being checked by hand.',
      );
    });

    test('a requirement it has no words for is still shown, not dropped', () {
      expect(gearStepDetail({'gear_verified': false, 'gear_missing': ['tripod']}), 'Still needed: tripod.');
    });

    test('an older server that reports nothing about gear gives a prompt, not a blank', () {
      expect(gearStepDetail(<String, dynamic>{}), 'Send a file from your camera to prove your kit.');
    });
  });
}
