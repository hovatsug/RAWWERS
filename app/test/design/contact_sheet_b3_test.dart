// Contact sheet on the other tabs: every title bar is the dark band, a
// screen's headline number sits in it, and the tab bar is white with an
// underline, never a pill.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/design/components/r_band_hero.dart';
import 'package:rawwers/design/components/r_header_band.dart';
import 'package:rawwers/design/components/r_tab_bar.dart';
import 'package:rawwers/design/components/r_viewfinder_frame.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/design/tokens.dart';

import 'contrast_test.dart' show contrastRatio;

const _tabs = [
  RTabItem(label: 'You', icon: Icons.person_outline, selectedIcon: Icons.person),
  RTabItem(label: 'Requests', icon: Icons.inbox_outlined, selectedIcon: Icons.inbox),
  RTabItem(label: 'Wallet', icon: Icons.account_balance_wallet_outlined, selectedIcon: Icons.account_balance_wallet),
];

Future<int?> _pumpTabs(WidgetTester tester, {int selected = 1}) async {
  int? tapped;
  await tester.pumpWidget(MaterialApp(
    theme: buildProTheme(),
    home: Scaffold(bottomNavigationBar: RTabBar(items: _tabs, selectedIndex: selected, onSelected: (i) => tapped = i)),
  ));
  await tester.tap(find.text('Wallet'));
  return tapped;
}

void main() {
  group('the title bar is the band', () {
    final pro = buildProTheme();
    test('dark, light text, light status bar, a dark hairline', () {
      final bar = pro.appBarTheme;
      expect(bar.backgroundColor, RInk.i950);
      expect(bar.foregroundColor, RInk.i050);
      expect(bar.systemOverlayStyle, SystemUiOverlayStyle.light);
      expect(bar.titleTextStyle!.color, RInk.i050);
      expect(bar.elevation, 0);
      expect(bar.scrolledUnderElevation, 0);
      expect((bar.shape! as Border).bottom.color, RInk.i800);
    });

    test('its actions are meter500, which clears 3:1 on the band', () {
      expect(pro.appBarTheme.actionsIconTheme!.color, RAccent.meter500);
      expect(contrastRatio(RAccent.meter500, RInk.i950), greaterThanOrEqualTo(3.0));
    });

    test('the client app\'s bar is untouched', () {
      expect(buildClientTheme().appBarTheme.backgroundColor, isNot(RInk.i950));
    });

    testWidgets('a pro screen\'s AppBar draws on the band', (tester) async {
      await tester.pumpWidget(MaterialApp(theme: pro, home: Scaffold(appBar: AppBar(title: const Text('Gigs')))));
      final material = tester.widget<Material>(find.descendant(of: find.byType(AppBar), matching: find.byType(Material)).first);
      expect(material.color, RInk.i950);
    });
  });

  group('RBandHero', () {
    testWidgets('a label and the framed number, full width, read as one', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(MaterialApp(
        theme: buildProTheme(),
        home: const Scaffold(body: RHeaderBand(child: RBandHero(label: 'Available to withdraw', value: '€412.50'))),
      ));
      expect(find.text('AVAILABLE TO WITHDRAW'), findsOneWidget);
      expect(find.descendant(of: find.byType(RViewfinderFrame), matching: find.text('€412.50')), findsOneWidget);
      expect(find.bySemanticsLabel('Available to withdraw, €412.50'), findsOneWidget);
      final frame = tester.getRect(find.byKey(RViewfinderFrame.bracketsKey));
      final band = tester.getRect(find.byType(RHeaderBand));
      expect(frame.width, band.width - 2 * RSpace.s16);
      semantics.dispose();
    });
  });

  group('RTabBar', () {
    testWidgets('white, with a hairline on top', (tester) async {
      await _pumpTabs(tester);
      final bar = tester.widget<DecoratedBox>(find.byKey(RTabBar.groundKey));
      final decoration = bar.decoration as BoxDecoration;
      expect(decoration.color, RPaper.card);
      expect((decoration.border! as Border).top.color, RInk.i200);
    });

    testWidgets('12px labels; the selected one weight 600 with a 20x2 meter700 underline; no pill', (tester) async {
      await _pumpTabs(tester, selected: 1);
      final selected = tester.widget<Text>(find.text('Requests'));
      final other = tester.widget<Text>(find.text('You'));
      expect(selected.style!.fontSize, RType.tab);
      expect(other.style!.fontSize, RType.tab);
      expect(selected.style!.fontVariations, [RType.weightSemibold]);
      expect(other.style!.fontVariations, isNot([RType.weightSemibold]));
      final underline = find.byKey(RTabBar.indicatorKey);
      expect(underline, findsOneWidget, reason: 'one underline, under the selected tab');
      expect(tester.getSize(underline), const Size(RMotif.tabIndicatorWidth, RMotif.tabIndicatorHeight));
      expect((tester.widget<DecoratedBox>(underline).decoration as BoxDecoration).color, RAccent.meter700);
      expect(tester.getCenter(underline).dx, closeTo(tester.getCenter(find.text('Requests')).dx, 1));
      expect(tester.getTopLeft(underline).dy, greaterThan(tester.getBottomLeft(find.text('Requests')).dy - 1));
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('a tap selects; every tab is a 44px target and says if it is selected', (tester) async {
      final semantics = tester.ensureSemantics();
      expect(await _pumpTabs(tester, selected: 1), 2);
      for (final label in ['You', 'Requests', 'Wallet']) {
        final target = find.ancestor(of: find.text(label), matching: find.byType(InkWell)).first;
        expect(tester.getSize(target).height, greaterThanOrEqualTo(rMinTouchTarget));
      }
      expect(tester.getSemantics(find.ancestor(of: find.text('Requests'), matching: find.byType(InkWell)).first),
          matchesSemantics(label: 'Requests', isSelected: true, isButton: true, hasTapAction: true, isFocusable: true, hasSelectedState: true));
      expect(tester.getSemantics(find.ancestor(of: find.text('You'), matching: find.byType(InkWell)).first),
          matchesSemantics(label: 'You', isSelected: false, isButton: true, hasTapAction: true, isFocusable: true, hasSelectedState: true));
      semantics.dispose();
    });

    group('at large text sizes', () {
      const five = [
        RTabItem(label: 'You', icon: Icons.person_outline, selectedIcon: Icons.person),
        RTabItem(label: 'Requests', icon: Icons.inbox_outlined, selectedIcon: Icons.inbox),
        RTabItem(label: 'Messages', icon: Icons.chat_bubble_outline, selectedIcon: Icons.chat_bubble),
        RTabItem(label: 'Gigs', icon: Icons.camera_alt_outlined, selectedIcon: Icons.camera_alt),
        RTabItem(label: 'Wallet', icon: Icons.account_balance_wallet_outlined, selectedIcon: Icons.account_balance_wallet),
      ];
      const badgeKey = ValueKey('badge');
      final withBadge = [
        five[0],
        RTabItem(
          label: 'Requests',
          icon: Icons.inbox_outlined,
          selectedIcon: Icons.inbox,
          iconBuilder: (context, selected) => const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.inbox), Text('3', key: badgeKey)]),
        ),
        ...five.skip(2),
      ];

      Future<void> pumpAt(WidgetTester tester, double scale, {double width = 390}) async {
        tester.view.physicalSize = Size(width, 844) * 3;
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MaterialApp(
          theme: buildProTheme(),
          builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)), child: child!),
          home: Scaffold(bottomNavigationBar: RTabBar(items: withBadge, selectedIndex: 1, onSelected: (_) {})),
        ));
      }

      double drawnSize(WidgetTester tester, String label) {
        final text = tester.renderObject<RenderParagraph>(find.descendant(of: find.text(label), matching: find.byType(RichText)).first);
        return text.textScaler.scale(RType.tab);
      }

      for (final scale in [1.3, 2.0]) {
        testWidgets('labels stop growing at ${RType.tabMaxTextScale}x when the system asks for ${scale}x', (tester) async {
          await pumpAt(tester, scale);
          expect(drawnSize(tester, 'Messages'), RType.tab * RType.tabMaxTextScale);
        });
      }

      for (final width in [390.0, 320.0]) {
        testWidgets('neighbouring labels never touch at 1.3, ${width.toInt()}pt wide', (tester) async {
          await pumpAt(tester, 1.3, width: width);
          final labels = ['You', 'Requests', 'Messages', 'Gigs', 'Wallet'];
          for (var i = 0; i + 1 < labels.length; i++) {
            final right = tester.getRect(find.text(labels[i])).right;
            final left = tester.getRect(find.text(labels[i + 1])).left;
            expect(left - right, greaterThanOrEqualTo(RMotif.tabLabelGap), reason: '${labels[i]} | ${labels[i + 1]}');
          }
          expect(tester.takeException(), isNull);
        });
      }

      testWidgets('icons, badges and targets still follow the system size', (tester) async {
        await pumpAt(tester, 1.3);
        expect(tester.getSize(find.byIcon(Icons.person_outline)), const Size(24, 24));
        final badge = tester.renderObject<RenderParagraph>(find.descendant(of: find.byKey(badgeKey), matching: find.byType(RichText)));
        expect(badge.textScaler.scale(10), 13, reason: 'the badge is not clamped');
        final target = find.ancestor(of: find.text('You'), matching: find.byType(InkWell)).first;
        expect(tester.getSize(target).height, greaterThanOrEqualTo(rMinTouchTarget));
      });
    });

    test('its words clear AA on white', () {
      expect(contrastRatio(RInk.i950, RPaper.card), greaterThanOrEqualTo(4.5));
      expect(contrastRatio(RInk.i600, RPaper.card), greaterThanOrEqualTo(4.5));
      expect(contrastRatio(RAccent.meter700, RPaper.card), greaterThanOrEqualTo(3.0));
    });
  });
}
