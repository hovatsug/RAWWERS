import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/design/components/r_switch_tile.dart';
import 'package:rawwers/design/components/r_switch.dart';
import 'package:rawwers/api/models/notification_digest_mode.dart';
import 'package:rawwers/api/models/notification_preference_view.dart';
import 'package:rawwers/api/models/payout_account_status.dart';
import 'package:rawwers/api/models/payout_account_view.dart';
import 'package:rawwers/api/models/payout_method.dart';
import 'package:rawwers/api/models/pro_profile_view.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/settings/pro_settings_screen.dart';
import 'package:rawwers/features/pro/settings/settings_controller.dart';
import 'package:rawwers/features/pro/presence/presence_visibility_controller.dart';

/// Settings is where a photographer checks the two things they worry about:
/// am I live, and where is my money going. These assert it answers both in
/// words, not status codes - and that a wait a human controls is described
/// as one.
class _FakeProfile extends ProProfileController {
  _FakeProfile(this._profile);

  final ProProfileView _profile;

  @override
  Future<ProProfileView> build() async => _profile;
}

class _FailingProfile extends ProProfileController {
  @override
  Future<ProProfileView> build() async => throw const NetworkError();
}

class _FakePrefs extends NotificationPreferencesController {
  _FakePrefs(this._prefs);

  final NotificationPreferenceView _prefs;

  bool? lastInApp;

  @override
  Future<NotificationPreferenceView> build() async => _prefs;

  @override
  Future<String?> setChannel({bool? email, bool? inApp}) async {
    lastInApp = inApp;
    state = AsyncData(
      _prefs.copyWith(
        channelInappEnabled: inApp ?? _prefs.channelInappEnabled,
        channelEmailEnabled: email ?? _prefs.channelEmailEnabled,
      ),
    );
    return null;
  }
}

ProProfileView _profile({
  String kycStatus = 'approved',
  bool live = true,
  int completeness = 92,
}) =>
    ProProfileView(
      userId: 'pro-1',
      displayName: 'Alex Lens',
      isAcceptingBookings: live,
      completenessScore: completeness,
      kycStatus: kycStatus,
    );

const _prefs = NotificationPreferenceView(
  timezone: 'Europe/Lisbon',
  quietHoursEnabled: false,
  channelEmailEnabled: true,
  channelInappEnabled: true,
  digestMode: NotificationDigestMode.instant,
);

final _payout = PayoutAccountView(
  proUserId: 'pro-1',
  payoutMethod: PayoutMethod.bankManual,
  status: PayoutAccountStatus.notSet,
  updatedAt: DateTime.utc(2026, 9, 1),
);

Widget _wrap({
  ProProfileController Function()? profile,
  NotificationPreferencesController Function()? prefs,
  PayoutAccountView? payout,
  String? gearVerificationPath,
}) =>
    ProviderScope(
      overrides: [
        proProfileControllerProvider.overrideWith(profile ?? () => _FakeProfile(_profile())),
        notificationPreferencesControllerProvider.overrideWith(prefs ?? () => _FakePrefs(_prefs)),
        payoutAccountProvider.overrideWith((ref) async => payout ?? _payout),
        presenceVisibilityControllerProvider.overrideWith(() => _FakeVisibility()),
      ],
      child: MaterialApp(
        theme: buildProTheme(),
        home: ProSettingsScreen(verifyEmailPath: '/verify', gearVerificationPath: gearVerificationPath),
      ),
    );

/// Settings is a long scroll; the sections below the fold need bringing into
/// view before they can be asserted on or tapped.
Future<void> _scrollTo(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(target, 200, scrollable: find.byType(Scrollable).first);
  await tester.pump();
}

class _FakeVisibility extends PresenceVisibilityController {
  @override
  Future<bool> build() async => true;
}

void main() {
  testWidgets('leads with whether the listing is live', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump();

    expect(find.text('Live — clients can book you'), findsOneWidget);
    expect(find.text('Live'), findsOneWidget);
  });

  testWidgets('a pro who is not live is told so plainly', (tester) async {
    await tester.pumpWidget(_wrap(profile: () => _FakeProfile(_profile(live: false, completeness: 40))));
    await tester.pump();

    expect(find.text('Not live yet'), findsOneWidget);
    expect(find.textContaining('Needs to reach 60%'), findsOneWidget);
  });

  testWidgets('KYC in review reads as a person reviewing, not a spinner', (tester) async {
    await tester.pumpWidget(_wrap(profile: () => _FakeProfile(_profile(kycStatus: 'pending'))));
    await tester.pump();

    expect(find.text('In review'), findsOneWidget);
    // The wait is a human one, and the copy has to say so - for the first
    // photographers it is literally someone approving them by hand.
    expect(find.textContaining('by hand'), findsOneWidget);
  });

  testWidgets('an unset payout account says who to talk to, not "unverified"', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump();

    // Below the fold since the "Your work" section landed above Payouts.
    await _scrollTo(tester, find.text('Not set up'));
    expect(find.text('Not set up'), findsOneWidget);
    expect(find.textContaining('Get in touch'), findsOneWidget);
  });

  testWidgets('email notifications admit they are not delivered yet', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump();

    // No provider is configured, so a toggle that implies delivery would be
    // a lie the photographer only discovers by missing a booking.
    await _scrollTo(tester, find.textContaining('Not being delivered yet'));
    expect(find.textContaining('Not being delivered yet'), findsOneWidget);
  });

  testWidgets('toggling a channel sends the change', (tester) async {
    final prefs = _FakePrefs(_prefs);
    await tester.pumpWidget(_wrap(prefs: () => prefs));
    await tester.pump();

    // Scrolled to by a text target: `find.byType(RSwitch).first` throws
    // inside scrollUntilVisible while no switch is built yet.
    await _scrollTo(tester, find.text('In-app'));
    await tester.tap(find.byType(RSwitch).first);
    await tester.pump();

    expect(prefs.lastInApp, isFalse);
  });

  testWidgets('one section failing does not take the screen down', (tester) async {
    await tester.pumpWidget(_wrap(profile: _FailingProfile.new));
    await tester.pump();

    expect(find.text('Could not load your listing status.'), findsOneWidget);
    // The rest still renders - a settings screen that goes blank because one
    // of four calls failed is worse than one that says which part is missing.
    await _scrollTo(tester, find.text('Not set up'));
    expect(find.text('Not set up'), findsOneWidget);
    await _scrollTo(tester, find.text('Log out'));
    expect(find.text('Log out'), findsOneWidget);
  });

  testWidgets('offers gear verification when the app wires it, described as what it unlocks', (tester) async {
    await tester.pumpWidget(_wrap(gearVerificationPath: '/gear-verification'));
    await tester.pump();

    await _scrollTo(tester, find.text('Verify your gear'));
    expect(find.text('Verify your gear'), findsOneWidget);
    expect(find.text('Prove your camera and lens to go live'), findsOneWidget);
  });

  testWidgets('no gear verification row when nothing is wired to it', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump();

    expect(find.text('Verify your gear'), findsNothing);
  });

  testWidgets('says what clients see while the app is open, and offers to hide it', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Show when I\u2019m online'), 300);

    expect(find.text(presenceNotice), findsOneWidget);
    expect(tester.widget<RSwitchTile>(find.widgetWithText(RSwitchTile, 'Show when I\u2019m online')).value, isTrue);
  });
}
