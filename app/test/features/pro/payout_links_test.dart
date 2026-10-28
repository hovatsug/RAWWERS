// Payout setup's way out to Stripe and back: the pro flavor alone registers
// rawwerspro://, the return link only makes the app ask the server again
// (never navigates, never reads the link), coming back to the app does the
// same, and Stripe's form opens in the in-app browser.
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/connect_status_response.dart';
import 'package:rawwers/api/models/earnings_balance_view.dart';
import 'package:rawwers/api/models/payout_account_status.dart';
import 'package:rawwers/api/models/payout_account_view.dart';
import 'package:rawwers/api/models/payout_method.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/payouts/payout_links.dart';
import 'package:rawwers/features/pro/payouts/payouts_controller.dart';
import 'package:rawwers/features/pro/payouts/payouts_screen.dart';
import 'package:rawwers/features/pro/settings/settings_controller.dart';
import 'package:rawwers/features/pro/wallet/wallet_controller.dart';

String _read(String path) => File(path).readAsStringSync();

/// Info-Pro.plist with its URL types removed, to compare with Info.plist.
String _withoutUrlTypes(String plist) =>
    plist.replaceFirst(RegExp(r'\t<key>CFBundleURLTypes</key>\n\t<array>[\s\S]*?\n\t</array>\n'), '');

class _FakePlatform implements PayoutLinkPlatform {
  final links = StreamController<Uri>.broadcast();
  final opened = <Uri>[];
  var closed = 0;
  var openResult = true;

  @override
  Future<bool> open(Uri url) async {
    opened.add(url);
    return openResult;
  }

  @override
  Future<void> closeBrowser() async => closed++;

  @override
  Stream<Uri> get incoming => links.stream;
}

class _Counts {
  var connect = 0;
  var wallet = 0;
  var account = 0;
}

class _CountingConnect extends ConnectStatusController {
  _CountingConnect(this.counts);

  final _Counts counts;

  @override
  Future<ConnectStatusResponse> build() async {
    counts.connect++;
    return const ConnectStatusResponse(accountStatus: 'not_set');
  }

  @override
  Future<({String? url, String? error})> onboardingLink() async =>
      (url: 'https://connect.stripe.test/setup/${counts.connect}', error: null);
}

class _CountingWallet extends WalletController {
  _CountingWallet(this.counts);

  final _Counts counts;

  @override
  Future<WalletData> build() {
    counts.wallet++;
    return Completer<WalletData>().future;
  }
}

class _FakeBalance extends EarningsBalanceController {
  @override
  Future<EarningsBalanceView> build() async => const EarningsBalanceView(
        pendingEur: '0.00',
        availableEur: '0.00',
        heldEur: '0.00',
        reservedEur: '0.00',
        withdrawableEur: '0.00',
      );
}

final _account = PayoutAccountView(
  proUserId: 'pro-1',
  payoutMethod: PayoutMethod.stripeConnect,
  status: PayoutAccountStatus.pendingVerification,
  updatedAt: DateTime.utc(2026, 10, 28),
);

/// The listener over a screen that keeps the three status readers alive,
/// as the Payouts screen, the Wallet and Settings do in the app.
Widget _app(_FakePlatform platform, _Counts counts) => ProviderScope(
      overrides: [
        payoutLinkPlatformProvider.overrideWithValue(platform),
        connectStatusControllerProvider.overrideWith(() => _CountingConnect(counts)),
        walletControllerProvider.overrideWith(() => _CountingWallet(counts)),
        payoutAccountProvider.overrideWith((ref) async {
          counts.account++;
          return _account;
        }),
      ],
      child: MaterialApp(
        home: PayoutReturnListener(
          child: Consumer(
            builder: (context, ref, _) {
              ref.watch(connectStatusControllerProvider);
              ref.watch(walletControllerProvider);
              ref.watch(payoutAccountProvider);
              return const SizedBox();
            },
          ),
        ),
      ),
    );

void main() {
  group('the pro flavor alone answers rawwerspro://', () {
    test('the scheme is the one the API\'s return pages hand over to', () {
      final api = _read('../api/app/services/connect_return.py');
      expect(api, contains('PRO_APP_SCHEME = "$proAppScheme"'));
      expect(proAppScheme, 'rawwerspro');
    });

    test('iOS: Info-Pro.plist is Info.plist plus one URL type, rawwerspro', () {
      final client = _read('ios/Runner/Info.plist');
      final pro = _read('ios/Runner/Info-Pro.plist');
      expect(client, isNot(contains('CFBundleURLTypes')), reason: 'the client app registers no scheme');
      expect(RegExp('CFBundleURLTypes').allMatches(pro).length, 1);
      expect(pro, contains('<string>$proAppScheme</string>'));
      expect(_withoutUrlTypes(pro), client, reason: 'the two plists may differ only by the URL type');
    });

    test('iOS: each flavor\'s xcconfig chooses its plist; the project does not override it', () {
      expect(_read('ios/Flutter/Pro.xcconfig'), contains('INFOPLIST_FILE = Runner/Info-Pro.plist'));
      for (final name in ['Client', 'Debug', 'Release']) {
        expect(_read('ios/Flutter/$name.xcconfig'), contains('INFOPLIST_FILE = Runner/Info.plist'), reason: name);
      }
      expect(_read('ios/Runner.xcodeproj/project.pbxproj'), isNot(contains('INFOPLIST_FILE = Runner/')));
    });

    test('Android: the pro flavor\'s manifest has the intent filter; main and client do not', () {
      final pro = _read('android/app/src/pro/AndroidManifest.xml');
      final filter = RegExp(r'<intent-filter>([\s\S]*?)</intent-filter>').firstMatch(pro)!.group(1)!;
      expect(filter, contains('android.intent.action.VIEW'));
      expect(filter, contains('android.intent.category.DEFAULT'));
      expect(filter, contains('android.intent.category.BROWSABLE'));
      expect(filter, contains('android:scheme="$proAppScheme"'));
      expect(filter, contains('android:host="payouts"'));
      expect(_read('android/app/src/main/AndroidManifest.xml'), isNot(contains(proAppScheme)));
      final client = File('android/app/src/client/AndroidManifest.xml');
      if (client.existsSync()) expect(client.readAsStringSync(), isNot(contains(proAppScheme)));
    });

    test('url_launcher and app_links are pinned exactly', () {
      final pubspec = _read('pubspec.yaml');
      expect(pubspec, contains('\n  url_launcher: 6.3.2\n'));
      expect(pubspec, contains('\n  app_links: 7.0.0\n'));
    });
  });

  group('recognising a return', () {
    test('rawwerspro://payouts/..., with or without anything after it', () {
      for (final link in [
        'rawwerspro://payouts/return',
        'rawwerspro://payouts/refresh',
        'rawwerspro://payouts/return?account=acct_1&status=complete',
      ]) {
        expect(isPayoutReturn(Uri.parse(link)), isTrue, reason: link);
      }
    });

    test('nothing else', () {
      for (final link in [
        'https://payouts/return',
        'rawwerspro://wallet/return',
        'rawwers://payouts/return',
        'https://connect.stripe.com/setup/e/acct_1',
      ]) {
        expect(isPayoutReturn(Uri.parse(link)), isFalse, reason: link);
      }
    });
  });

  group('coming back', () {
    testWidgets('the return link closes the browser and asks the server again, everywhere', (tester) async {
      final platform = _FakePlatform();
      final counts = _Counts();
      await tester.pumpWidget(_app(platform, counts));
      await tester.pump();
      final before = (counts.connect, counts.wallet, counts.account);

      platform.links.add(Uri.parse('rawwerspro://payouts/return'));
      await tester.pumpAndSettle();

      expect(platform.closed, 1);
      expect(counts.connect, before.$1 + 1, reason: 'the live Connect status, re-read');
      expect(counts.wallet, before.$2 + 1, reason: 'the Wallet, which gates Request payout');
      expect(counts.account, before.$3 + 1, reason: 'Settings and the You band');
    });

    testWidgets('what the link carries changes nothing: the same re-read, no more', (tester) async {
      final platform = _FakePlatform();
      final counts = _Counts();
      await tester.pumpWidget(_app(platform, counts));
      await tester.pump();
      final before = counts.connect;

      platform.links.add(Uri.parse('rawwerspro://payouts/return?status=complete&payouts_enabled=true'));
      await tester.pumpAndSettle();
      expect(counts.connect, before + 1);
      expect(find.byType(SizedBox), findsOneWidget, reason: 'nothing navigated');
    });

    testWidgets('a link that is not a payout return does nothing', (tester) async {
      final platform = _FakePlatform();
      final counts = _Counts();
      await tester.pumpWidget(_app(platform, counts));
      await tester.pump();
      final before = (counts.connect, counts.wallet, counts.account);

      platform.links.add(Uri.parse('rawwerspro://wallet/return'));
      platform.links.add(Uri.parse('https://example.test/payouts/return'));
      await tester.pumpAndSettle();

      expect(platform.closed, 0);
      expect((counts.connect, counts.wallet, counts.account), before);
    });

    testWidgets('switching back to the app asks the server again', (tester) async {
      // Done in the in-app browser, or leaving Safari by hand, sends no link.
      final platform = _FakePlatform();
      final counts = _Counts();
      await tester.pumpWidget(_app(platform, counts));
      await tester.pump();
      final before = (counts.connect, counts.wallet);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(counts.connect, before.$1, reason: 'leaving is not coming back');
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(counts.connect, before.$1 + 1);
      expect(counts.wallet, before.$2 + 1);
    });
  });

  group('going out', () {
    Widget screen(_FakePlatform platform) => ProviderScope(
          overrides: [
            payoutLinkPlatformProvider.overrideWithValue(platform),
            connectStatusControllerProvider.overrideWith(() => _CountingConnect(_Counts())),
            earningsBalanceControllerProvider.overrideWith(_FakeBalance.new),
          ],
          child: MaterialApp(theme: buildProTheme(), home: const PayoutsScreen()),
        );

    testWidgets('Set up payouts opens the server\'s link through the platform', (tester) async {
      final platform = _FakePlatform();
      await tester.pumpWidget(screen(platform));
      await tester.pump();

      await tester.tap(find.widgetWithText(RButton, 'Set up payouts'));
      await tester.pumpAndSettle();

      expect(platform.opened.single.toString(), startsWith('https://connect.stripe.test/setup/'));
      expect(find.textContaining('Link copied'), findsNothing);
    });

    testWidgets('only when the platform cannot open it is the link copied instead', (tester) async {
      final platform = _FakePlatform()..openResult = false;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async => null,
      );
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
      await tester.pumpWidget(screen(platform));
      await tester.pump();

      await tester.tap(find.widgetWithText(RButton, 'Set up payouts'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Link copied'), findsOneWidget);
    });

    test('the device opens it in the in-app browser', () {
      expect(_read('lib/features/pro/payouts/payout_links.dart'), contains('mode: LaunchMode.inAppBrowserView'));
    });
  });

  test('the pro shell listens for the return', () {
    expect(_read('lib/features/pro/pro_shell.dart'), contains('PayoutReturnListener('));
  });
}
