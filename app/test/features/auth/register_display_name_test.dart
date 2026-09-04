import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/features/shared/auth/register_screen.dart';

import '../../support/fake_http_client_adapter.dart';
import '../../support/in_memory_session_storage.dart';

/// Registration is the only moment anyone will supply their name, and an
/// account created without one shows up as a blank in the other side's inbox
/// forever after. These assert the field exists, is required, and reaches the
/// wire - the API accepts `display_name` as optional, so nothing server-side
/// would catch its absence.
Widget _wrap(Dio dio) => ProviderScope(
      overrides: [
        sessionStorageProvider.overrideWithValue(InMemorySessionStorage()),
        dioProvider.overrideWithValue(dio),
      ],
      child: const MaterialApp(home: RegisterScreen(loginPath: '/l')),
    );

Dio _dio(void Function(RequestOptions) onRegister) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
  dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
    if (options.path.endsWith('/v1/auth/register')) {
      onRegister(options);
      return jsonResponseBody(jsonEncode({'ok': true, 'user_id': 'u-1'}), 200);
    }
    if (options.path.endsWith('/v1/auth/login')) {
      // register() follows a successful registration with a real login.
      return jsonResponseBody(
        jsonEncode({'access_token': 'a', 'refresh_token': 'r', 'expires_in': 900}),
        200,
      );
    }
    // ...and the login resolves the session by fetching /v1/me.
    return jsonResponseBody(
      jsonEncode({
        'user_id': 'u-1',
        'email': 'dana@example.com',
        'roles': ['client'],
        'status': 'active',
        'email_verified': false,
      }),
      200,
    );
  });
  return dio;
}

Future<void> _fill(WidgetTester tester, {String? name, String? email, String? password}) async {
  if (name != null) await tester.enterText(find.widgetWithText(TextField, 'Your name'), name);
  if (email != null) await tester.enterText(find.widgetWithText(TextField, 'Email'), email);
  if (password != null) await tester.enterText(find.widgetWithText(TextField, 'Password'), password);
}

void main() {
  testWidgets('asks for a name and says why', (tester) async {
    await tester.pumpWidget(_wrap(_dio((_) {})));
    await tester.pump();

    expect(find.widgetWithText(TextField, 'Your name'), findsOneWidget);

    final field = tester.widget<TextField>(
      find.ancestor(of: find.text('Your name'), matching: find.byType(TextField)).first,
    );
    expect(field.autofillHints, contains(AutofillHints.name));
  });

  testWidgets('will not create a nameless account', (tester) async {
    var registerCalled = false;
    await tester.pumpWidget(_wrap(_dio((_) => registerCalled = true)));
    await tester.pump();

    await _fill(tester, email: 'someone@example.com', password: 'correct-horse-8');
    await tester.tap(find.widgetWithText(RButton, 'Create account'));
    await tester.pump();

    expect(registerCalled, isFalse);
    expect(find.textContaining('Enter your name'), findsOneWidget);
  });

  testWidgets('sends the name to the API', (tester) async {
    Map<String, dynamic>? body;
    await tester.pumpWidget(
      _wrap(_dio((options) => body = jsonDecode(jsonEncode(options.data)) as Map<String, dynamic>)),
    );
    await tester.pump();

    await _fill(tester, name: '  Dana Reyes  ', email: 'dana@example.com', password: 'correct-horse-8');
    await tester.tap(find.widgetWithText(RButton, 'Create account'));
    await tester.pumpAndSettle();

    // Trimmed: leading space in a name is a typo, not a name.
    expect(body!['display_name'], 'Dana Reyes');
    expect(body!['email'], 'dana@example.com');
  });

  testWidgets('a whitespace-only name is not a name', (tester) async {
    var registerCalled = false;
    await tester.pumpWidget(_wrap(_dio((_) => registerCalled = true)));
    await tester.pump();

    await _fill(tester, name: '   ', email: 'someone@example.com', password: 'correct-horse-8');
    await tester.tap(find.widgetWithText(RButton, 'Create account'));
    await tester.pump();

    expect(registerCalled, isFalse);
  });
}
