import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/design/tokens.dart';

void main() {
  testWidgets('RButton meets the 44pt minimum touch target', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildClientTheme(),
        home: Scaffold(body: Center(child: RButton(label: 'Confirm', onPressed: () {}))),
      ),
    );

    final size = tester.getSize(find.byType(RButton));
    expect(size.height, greaterThanOrEqualTo(rMinTouchTarget));
  });

  testWidgets('RTextLink meets the 44pt minimum touch target', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildClientTheme(),
        home: Scaffold(body: Center(child: RTextLink(label: 'Select all', onPressed: () {}))),
      ),
    );

    final size = tester.getSize(find.byType(RTextLink));
    expect(size.height, greaterThanOrEqualTo(rMinTouchTarget));
  });
}
