// Gigs and Requests filter the same way: one bar, from the left gutter,
// scrolling with room after the last chip.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_filter_bar.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/design/tokens.dart';

Future<void> _pump(WidgetTester tester, List<String> values, {double textScale = 1.0}) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: buildProTheme(),
    home: MediaQuery(
      data: MediaQueryData(size: const Size(390, 844), textScaler: TextScaler.linear(textScale)),
      // A Column centres its children by default: the bar must not be.
      child: Scaffold(
        body: Column(children: [RFilterBar<String>(values: values, selected: values.first, label: (v) => v, onSelected: (_) {})]),
      ),
    ),
  ));
}

void main() {
  testWidgets('a row narrower than the screen starts at the 16px gutter, not centred', (tester) async {
    await _pump(tester, ['Active', 'Delivered', 'Cancelled']);
    expect(tester.getTopLeft(find.byType(RFilterChip).first).dx, RSpace.s16);
  });

  testWidgets('a row wider than the screen starts at the gutter too', (tester) async {
    await _pump(tester, ['Pending', 'Accepted', 'Declined', 'Expired', 'Withdrawn'], textScale: 1.3);
    expect(tester.getTopLeft(find.byType(RFilterChip).first).dx, RSpace.s16);
  });

  testWidgets('scrolled to its end, the last chip stops 16px short of the edge', (tester) async {
    await _pump(tester, ['Pending', 'Accepted', 'Declined', 'Expired', 'Withdrawn'], textScale: 1.3);
    await tester.drag(find.byType(SingleChildScrollView), const Offset(-2000, 0));
    await tester.pumpAndSettle();
    expect(tester.getTopRight(find.byType(RFilterChip).last).dx, 390 - RSpace.s16);
  });

  testWidgets('chips are 8px apart', (tester) async {
    await _pump(tester, ['Active', 'Delivered']);
    final first = tester.getTopRight(find.byType(RFilterChip).first).dx;
    final second = tester.getTopLeft(find.byType(RFilterChip).last).dx;
    expect(second - first, RSpace.s8);
  });
}
