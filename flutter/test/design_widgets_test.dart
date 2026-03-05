import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers_flutter/design/widgets/r_badge.dart';
import 'package:rawwers_flutter/design/widgets/r_button.dart';
import 'package:rawwers_flutter/design/widgets/r_card.dart';
import 'package:rawwers_flutter/design/widgets/r_skeleton.dart';
import 'package:rawwers_flutter/design/widgets/r_tabs.dart';
import 'package:rawwers_flutter/design/widgets/r_text_field.dart';

void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('RButton renders label', (tester) async {
    await tester.pumpWidget(host(const RButton(label: 'Login')));
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('RCard renders child', (tester) async {
    await tester.pumpWidget(host(const RCard(child: Text('Card content'))));
    expect(find.text('Card content'), findsOneWidget);
  });

  testWidgets('RTextField renders hint', (tester) async {
    await tester.pumpWidget(host(const RTextField(hintText: 'Email')));
    expect(find.text('Email'), findsOneWidget);
  });

  testWidgets('RTabs renders all tabs', (tester) async {
    await tester.pumpWidget(host(RTabs(tabs: const ['A', 'B'], active: 'A', onChanged: (_) {})));
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('RBadge renders label', (tester) async {
    await tester.pumpWidget(host(const RBadge(label: 'NEW')));
    expect(find.text('NEW'), findsOneWidget);
  });

  testWidgets('RSkeleton renders container', (tester) async {
    await tester.pumpWidget(host(const RSkeleton()));
    expect(find.byType(RSkeleton), findsOneWidget);
  });
}
