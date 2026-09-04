import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/features/shared/auth/login_screen.dart';
import 'package:rawwers/features/shared/auth/register_screen.dart';

import '../../support/in_memory_session_storage.dart';

/// iOS guesses autofill from surrounding labels when a field gives no hint,
/// and it guesses badly - an unhinted sign-up email field was offered the
/// device's Apple ID. These assert the hints are actually attached, since the
/// failure mode is silent and only visible on a real device.
Widget _wrap(Widget child) => ProviderScope(
      overrides: [sessionStorageProvider.overrideWithValue(InMemorySessionStorage())],
      child: MaterialApp(home: child),
    );

List<String>? _hintsFor(WidgetTester tester, String label) {
  final field = tester.widget<TextField>(
    find.ancestor(of: find.text(label), matching: find.byType(TextField)).first,
  );
  return field.autofillHints?.toList();
}

void main() {
  testWidgets('login offers an existing credential', (tester) async {
    await tester.pumpWidget(_wrap(const LoginScreen(registerPath: '/r', forgotPasswordPath: '/f')));
    await tester.pump();

    expect(_hintsFor(tester, 'Email'), containsAll([AutofillHints.username, AutofillHints.email]));
    expect(
      _hintsFor(tester, 'Password'),
      contains(AutofillHints.password),
      reason: 'login must offer to fill a saved password, not to save a new one',
    );
    expect(find.byType(AutofillGroup), findsOneWidget);
  });

  testWidgets('register asks the OS to save a new password', (tester) async {
    await tester.pumpWidget(_wrap(const RegisterScreen(loginPath: '/l')));
    await tester.pump();

    expect(_hintsFor(tester, 'Email'), containsAll([AutofillHints.username, AutofillHints.email]));
    expect(
      _hintsFor(tester, 'Password'),
      contains(AutofillHints.newPassword),
      reason: 'newPassword is what prompts the OS to offer to save; password would only offer to fill',
    );
  });

  testWidgets('the two screens use different password hints', (tester) async {
    await tester.pumpWidget(_wrap(const LoginScreen(registerPath: '/r', forgotPasswordPath: '/f')));
    await tester.pump();
    final loginHints = _hintsFor(tester, 'Password');

    await tester.pumpWidget(_wrap(const RegisterScreen(loginPath: '/l')));
    await tester.pump();
    final registerHints = _hintsFor(tester, 'Password');

    expect(loginHints, isNot(equals(registerHints)));
  });
}
