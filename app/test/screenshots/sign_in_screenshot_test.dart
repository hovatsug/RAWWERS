// Screenshots of the signed-out screens in both apps, with the logo, and of
// one invoice - for a person to look at, not goldens. Skipped unless
// SCREENSHOT_DIR is set:
//
//   SCREENSHOT_DIR=/tmp/shots flutter test test/screenshots
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/gig_invoice_view.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/design/components/r_logo.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/wallet/invoice_controller.dart';
import 'package:rawwers/features/pro/wallet/invoice_screen.dart';
import 'package:rawwers/features/shared/auth/login_screen.dart';
import 'package:rawwers/features/shared/auth/register_screen.dart';

import '../support/in_memory_session_storage.dart';
import 'screenshot_support.dart';

Widget _app(ThemeData theme, Widget home, {List<Override> overrides = const []}) => ProviderScope(
      overrides: [sessionStorageProvider.overrideWithValue(InMemorySessionStorage()), ...overrides],
      child: MaterialApp(theme: theme, debugShowCheckedModeBanner: false, home: home),
    );

// The server's split of a EUR 1,137.43 booking at 18% retained, 2% RAWW
// credit and 3% to the client (test/fixtures/invoice_scenarios.json).
final _invoice = GigInvoiceView(
  gigId: 'gig-1',
  issuedAt: DateTime.utc(2026, 10, 24, 18),
  currency: 'EUR',
  clientTotal: '1137.43',
  platformRetained: '204.74',
  proRaww: '22.75',
  clientRaww: '34.12',
  proCash: '875.82',
  retainedPercent: 18,
  proRawwPercent: 2,
  clientCreditPercent: 3,
  photosDelivered: 42,
  ratesWereStamped: true,
  vatStatus: 'not_registered',
);

void main() {
  setUpAll(() async {
    if (screenshotDir != null) await loadScreenshotFonts();
    await RLogo.precache();
  });
  setUp(() => TestWidgetsFlutterBinding.instance.platformDispatcher.localeTestValue = const Locale('en', 'GB'));
  tearDown(() => TestWidgetsFlutterBinding.instance.platformDispatcher.clearLocaleTestValue());

  for (final (app, theme) in [('client', buildClientTheme()), ('pro', buildProTheme())]) {
    testWidgets('screenshot $app login', (tester) async {
      await shoot(tester, '$app-login', _app(theme, const LoginScreen(registerPath: '/r', forgotPasswordPath: '/f')));
    }, skip: screenshotDir == null);
    testWidgets('screenshot $app register', (tester) async {
      await shoot(tester, '$app-register', _app(theme, const RegisterScreen(loginPath: '/l')));
    }, skip: screenshotDir == null);
  }

  testWidgets('screenshot invoice', (tester) async {
    await shoot(
      tester,
      'pro-invoice',
      _app(
        buildProTheme(),
        const InvoiceScreen(gigId: 'gig-1'),
        overrides: [invoiceProvider(gigId: 'gig-1').overrideWith((ref) async => _invoice)],
      ),
    );
  }, skip: screenshotDir == null);
}
