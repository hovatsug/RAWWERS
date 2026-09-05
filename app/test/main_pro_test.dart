import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/flavor.dart';
import 'package:rawwers/main_pro.dart';

import 'support/in_memory_session_storage.dart';

void main() {
  testWidgets('pro app boots unauthenticated to the login screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentFlavorProvider.overrideWithValue(AppFlavor.pro),
          // See main_client_test.dart for why this is faked rather than
          // real: no platform channel handler in the test sandbox, and the
          // launch screen's spinner never settles on its own.
          sessionStorageProvider.overrideWithValue(InMemorySessionStorage()),
        ],
        child: const RawwersProApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.widgetWithText(AppBar, 'Log in'), findsOneWidget);
  });
}
