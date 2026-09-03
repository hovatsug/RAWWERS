import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/flavor.dart';
import 'package:rawwers/main_client.dart';

import 'support/in_memory_session_storage.dart';

void main() {
  testWidgets('client app boots unauthenticated to the login screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentFlavorProvider.overrideWithValue(AppFlavor.client),
          // Real SecureSessionStorage hits a platform channel with no
          // handler registered in the test sandbox, and the launch screen's
          // indeterminate spinner never stops animating on its own - so this
          // avoids both pumpAndSettle() (which waits on that animation) and
          // any real storage/network dependency, same as the F-3 transport
          // tests use InMemorySessionStorage instead of the real thing.
          sessionStorageProvider.overrideWithValue(InMemorySessionStorage()),
        ],
        child: const RawwersClientApp(),
      ),
    );

    // No stored session -> AuthController.build() resolves to
    // Unauthenticated without any network call, so a few frames is enough
    // for the router to redirect off the launch screen.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.widgetWithText(AppBar, 'Log in'), findsOneWidget);
  });
}
