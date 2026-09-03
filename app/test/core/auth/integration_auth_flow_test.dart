@Tags(['integration'])
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/user_role_type.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/auth/auth_controller.dart';
import 'package:rawwers/core/auth/auth_state.dart';

import '../../support/in_memory_session_storage.dart';

/// F-5's deliverable, verified against the real backend rather than a fake:
/// register -> auto-login -> authenticated -> role gate -> upgrade -> logout.
/// The simulator renders this same flow, but a screenshot can only prove the
/// first screen; this proves the whole sequence, including the two things
/// that were actual backend findings (register returns no tokens, and every
/// new account is client-only until it explicitly upgrades).
///
/// Requires `docker compose up` in api/ to be running.
void main() {
  late ProviderContainer container;
  late InMemorySessionStorage storage;

  setUp(() {
    storage = InMemorySessionStorage();
    container = ProviderContainer(overrides: [sessionStorageProvider.overrideWithValue(storage)]);
  });

  tearDown(() => container.dispose());

  test('register auto-logs in, lands client-only, upgrades to pro, then logs out', () async {
    // Fresh address per run - register is not idempotent, and re-running
    // against a seeded fixture email would fail on "already exists".
    final email = 'f5-${DateTime.now().microsecondsSinceEpoch}@rawwers.test';
    const password = 'correct-horse-8';

    // No stored session -> resolves to Unauthenticated with no network call.
    expect(await container.read(authControllerProvider.future), isA<AuthUnauthenticated>());

    final registerError = await container.read(authControllerProvider.notifier).register(
          email: email,
          password: password,
        );
    expect(registerError, isNull, reason: 'register + follow-up login should both succeed');

    // Register returns no tokens (checked against the real endpoint), so the
    // session only exists because register() followed with a real login.
    expect(storage.writeCallCount, 1);

    final afterRegister = container.read(authControllerProvider).valueOrNull;
    expect(afterRegister, isA<AuthAuthenticated>());

    // Every account starts client-only - this is what the pro app's
    // upgrade gate exists for, and it's the common path, not an edge case.
    final me = (afterRegister! as AuthAuthenticated).me;
    expect(me.email, email);
    expect(me.roles, contains(UserRoleType.client));
    expect(me.roles, isNot(contains(UserRoleType.pro)));

    final upgradeError = await container.read(authControllerProvider.notifier).upgradeToPro();
    expect(upgradeError, isNull);

    final afterUpgrade = container.read(authControllerProvider).valueOrNull;
    final upgradedMe = (afterUpgrade! as AuthAuthenticated).me;
    expect(upgradedMe.roles, contains(UserRoleType.pro));
    expect(upgradedMe.roles, contains(UserRoleType.client), reason: 'upgrading adds a role, it does not replace one');

    await container.read(authControllerProvider.notifier).logout();
    expect(container.read(authControllerProvider).valueOrNull, isA<AuthUnauthenticated>());
    expect(await storage.read(), isNull, reason: 'logout must clear the stored session, not just the in-memory state');
  });

  test('login with a wrong password surfaces a readable message and stores nothing', () async {
    final error = await container.read(authControllerProvider.notifier).login(
          email: 'nobody-${DateTime.now().microsecondsSinceEpoch}@rawwers.test',
          password: 'definitely-not-it',
        );

    expect(error, isNotNull);
    expect(error, isNot(contains('Exception')), reason: 'users see this string - it must not be a raw error');
    expect(storage.writeCallCount, 0);
  });
}
