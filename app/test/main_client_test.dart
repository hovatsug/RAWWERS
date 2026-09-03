import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/core/flavor.dart';
import 'package:rawwers/main_client.dart';

void main() {
  testWidgets('client app boots to the placeholder home screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentFlavorProvider.overrideWithValue(AppFlavor.client)],
        child: const RawwersClientApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('RAWWERS'), findsOneWidget);
  });
}
