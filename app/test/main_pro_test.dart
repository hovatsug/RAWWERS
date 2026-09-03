import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/core/flavor.dart';
import 'package:rawwers/main_pro.dart';

void main() {
  testWidgets('pro app boots to the placeholder home screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentFlavorProvider.overrideWithValue(AppFlavor.pro)],
        child: const RawwersProApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('RAWWERS Pro'), findsOneWidget);
  });
}
