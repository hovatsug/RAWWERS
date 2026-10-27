import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/design/brand.dart';
import 'package:rawwers/design/components/r_logo.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/shared/auth/forgot_password_screen.dart';
import 'package:rawwers/features/shared/auth/login_screen.dart';
import 'package:rawwers/features/shared/auth/register_screen.dart';
import 'package:rawwers/features/shared/auth/reset_password_screen.dart';
import 'package:rawwers/features/shared/auth/verify_email_screen.dart';

import '../../support/in_memory_session_storage.dart';

/// The signed-out screens carry the logo, at the top, in the two-colour
/// version for the app's ground: on dark in the client app, on light (paper)
/// in the pro app. Verify email is a Settings screen for someone already
/// signed in, and has none.
Widget _wrap(ThemeData theme, Widget child) => ProviderScope(
      overrides: [sessionStorageProvider.overrideWithValue(InMemorySessionStorage())],
      child: MaterialApp(theme: theme, home: child),
    );

void main() {
  final screens = <String, Widget>{
    'login': const LoginScreen(registerPath: '/r', forgotPasswordPath: '/f'),
    'register': const RegisterScreen(loginPath: '/l'),
    'forgot password': const ForgotPasswordScreen(resetPasswordPath: '/p'),
    'reset password': const ResetPasswordScreen(loginPath: '/l'),
  };

  for (final (app, theme, tone) in [
    ('client', buildClientTheme(), RLogoTone.primaryOnDark),
    ('pro', buildProTheme(), RLogoTone.primaryOnLight),
  ]) {
    for (final MapEntry(key: name, value: screen) in screens.entries) {
      testWidgets('$app $name: the two-colour logo for its ground, above everything in the body', (tester) async {
        await tester.pumpWidget(_wrap(theme, screen));
        await tester.pump();

        final logo = tester.widget<RLogo>(find.byType(RLogo));
        expect(logo.drawn, tone);
        expect(logo.width, greaterThanOrEqualTo(RBrand.logoMinPrimaryWidth));

        final logoBottom = tester.getRect(find.byType(RLogo)).bottom;
        final body = find.descendant(of: find.byType(SingleChildScrollView), matching: find.byType(Text));
        for (final element in body.evaluate()) {
          expect(tester.getRect(find.byWidget(element.widget)).top, greaterThan(logoBottom), reason: '${(element.widget as Text).data} sits above the logo');
        }
        expect(
          tester.getRect(find.byType(RLogo)).left,
          tester.getRect(find.byType(SingleChildScrollView)).left + RSpace.s16,
          reason: 'on the content\'s start edge, the 16px gutter',
        );
      });
    }
  }

  testWidgets('verify email, a signed-in Settings screen, has no logo', (tester) async {
    await tester.pumpWidget(_wrap(buildProTheme(), const VerifyEmailScreen()));
    await tester.pump();
    expect(find.byType(RLogo), findsNothing);
  });
}
