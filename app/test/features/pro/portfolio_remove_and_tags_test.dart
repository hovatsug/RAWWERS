// "Remove from portfolio" (BETA_SCOPE #11, first half), the niche tagger
// offering only the photographer's own niches (owner's approval of
// 2026-11-17), and "Set as cover" (BETA_SCOPE #74, 2026-11-18).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/pro_niche_view.dart';
import 'package:rawwers/api/models/pro_portfolio_item.dart';
import 'package:rawwers/api/models/pro_portfolio_response.dart';
import 'package:rawwers/api/models/update_my_niches_response.dart';
import 'package:rawwers/design/components/r_chip.dart';
import 'package:rawwers/design/components/r_overlay_badge.dart';
import 'package:rawwers/design/components/r_photo_viewer.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/niches/my_niches_controller.dart';
import 'package:rawwers/features/pro/portfolio/niches_controller.dart';
import 'package:rawwers/features/pro/portfolio/portfolio_controller.dart';
import 'package:rawwers/features/pro/portfolio/portfolio_screen.dart';
import 'package:rawwers/design/tokens.dart';

import '../../design/contrast_test.dart' show contrastRatio;

class _FakePortfolio extends PortfolioController {
  _FakePortfolio(this._value, {this.refusal, this.coverRefusal});

  ProPortfolioResponse _value;
  final String? refusal;
  final String? coverRefusal;
  final removed = <String>[];
  final covers = <String>[];

  @override
  Future<ProPortfolioResponse> build() async => _value;

  @override
  Future<String?> setCover(String mediaAssetId) async {
    covers.add(mediaAssetId);
    if (coverRefusal != null) return coverRefusal;
    _value = _value.copyWith(
      items: [for (final i in _value.items ?? const <ProPortfolioItem>[]) i.copyWith(isCover: i.mediaAssetId == mediaAssetId)],
      coverMediaAssetId: mediaAssetId,
      coverChosen: true,
    );
    state = AsyncData(_value);
    return null;
  }

  @override
  Future<String?> removePhoto(String mediaAssetId) async {
    removed.add(mediaAssetId);
    return refusal;
  }
}

class _FakeMine extends MyNichesController {
  @override
  Future<UpdateMyNichesResponse> build() async => const UpdateMyNichesResponse(
        primaryNicheSlug: 'weddings',
        niches: [ProNicheView(slug: 'weddings', name: 'Weddings', isPrimary: true), ProNicheView(slug: 'portraits', name: 'Portraits', isPrimary: false)],
        minimum: 1,
        maximum: 3,
      );
}

class _FakeAll extends NichesController {
  @override
  Future<List<NicheOption>> build() async => const [
        NicheOption(id: '1', slug: 'weddings', name: 'Weddings'),
        NicheOption(id: '2', slug: 'portraits', name: 'Portraits'),
        NicheOption(id: '3', slug: 'food', name: 'Food'),
        NicheOption(id: '4', slug: 'events', name: 'Events'),
      ];
}

ProPortfolioItem _item(String id, {bool cover = false, List<String> niches = const [], bool processing = false}) => ProPortfolioItem(
      mediaAssetId: id,
      kind: 'photo',
      status: processing ? 'processing' : 'ready',
      thumbnailUrl: processing ? null : 'https://example.test/$id-thumb.jpg',
      previewUrl: processing ? null : 'https://example.test/$id-web.jpg',
      nicheSlugs: niches,
      isCover: cover,
      createdAt: DateTime.utc(2026, 11, 17),
    );

Future<_FakePortfolio> _pump(
  WidgetTester tester,
  List<ProPortfolioItem> items, {
  String? refusal,
  String? coverRefusal,
  bool coverChosen = false,
}) async {
  final cover = items.where((i) => i.isCover).map((i) => i.mediaAssetId).firstOrNull;
  final fake = _FakePortfolio(
    ProPortfolioResponse(
      items: items,
      photoCount: items.length,
      videoCount: 0,
      photoMinimum: 12,
      coverMediaAssetId: cover,
      coverChosen: coverChosen,
    ),
    refusal: refusal,
    coverRefusal: coverRefusal,
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        portfolioControllerProvider.overrideWith(() => fake),
        myNichesControllerProvider.overrideWith(_FakeMine.new),
        nichesControllerProvider.overrideWith(_FakeAll.new),
      ],
      child: MaterialApp(theme: buildProTheme(), home: const PortfolioScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return fake;
}

Future<void> _openFirst(WidgetTester tester) async {
  await tester.tap(find.byType(InkWell).first);
  await tester.pumpAndSettle();
}

void main() {
  group('Remove from portfolio', () {
    testWidgets('the photo screen offers it next to the tags', (tester) async {
      await _pump(tester, [_item('a')]);
      await _openFirst(tester);
      expect(find.byType(RPhotoViewer), findsOneWidget);
      expect(find.text('Remove from portfolio'), findsOneWidget);
    });

    testWidgets('it asks first, in plain words, and cancelling sends nothing', (tester) async {
      final fake = await _pump(tester, [_item('a')]);
      await _openFirst(tester);
      await tester.tap(find.text('Remove from portfolio'));
      await tester.pumpAndSettle();
      expect(find.text('Remove from portfolio?'), findsOneWidget);
      expect(find.text('This photo disappears from your profile and from Discover. It cannot be recovered.'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(fake.removed, isEmpty);
      expect(find.byType(RPhotoViewer), findsOneWidget);
    });

    testWidgets('confirmed, it removes that photo and closes the viewer', (tester) async {
      final fake = await _pump(tester, [_item('a'), _item('b')]);
      await _openFirst(tester);
      await tester.tap(find.text('Remove from portfolio'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      expect(fake.removed, ['a']);
      expect(find.byType(RPhotoViewer), findsNothing);
      expect(find.text('Removed from your portfolio.'), findsOneWidget);
    });

    testWidgets('for the cover, it says another photo will be used', (tester) async {
      await _pump(tester, [_item('a', cover: true), _item('b')]);
      await _openFirst(tester);
      await tester.tap(find.text('Remove from portfolio'));
      await tester.pumpAndSettle();
      expect(find.textContaining('This is your cover. Another photo will be used until you choose a new one.'), findsOneWidget);
    });

    testWidgets('for a cover that is the only ready photo, it says the listing will show no photo', (tester) async {
      await _pump(tester, [_item('a', cover: true), _item('b', processing: true)]);
      await _openFirst(tester);
      await tester.tap(find.text('Remove from portfolio'));
      await tester.pumpAndSettle();
      expect(find.textContaining('your listing will show no photo until you add one'), findsOneWidget);
    });

    testWidgets('it is readable on the dark viewer and as wide as Edit tags', (tester) async {
      await _pump(tester, [_item('a', niches: ['weddings'])]);
      await _openFirst(tester);
      final label = tester.widget<Text>(find.text('Remove from portfolio'));
      final color = DefaultTextStyle.of(tester.element(find.text('Remove from portfolio'))).style.merge(label.style).color!;
      expect(contrastRatio(color, RInk.i900), greaterThanOrEqualTo(4.5), reason: 'label on the viewer\'s near-black');
      final remove = tester.getSize(find.widgetWithText(OutlinedButton, 'Remove from portfolio'));
      final tags = tester.getSize(find.widgetWithText(ElevatedButton, 'Edit tags'));
      expect(remove.width, tags.width);
    });

    testWidgets('a refusal shows the server\'s reason and keeps the photo open', (tester) async {
      const refusal = 'Add another photo first, then remove this one. A live listing needs at least 12 photos.';
      final fake = await _pump(tester, [_item('a')], refusal: refusal);
      await _openFirst(tester);
      await tester.tap(find.text('Remove from portfolio'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      expect(fake.removed, ['a']);
      expect(find.text('Not removed'), findsOneWidget);
      expect(find.text(refusal), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(RPhotoViewer), findsOneWidget, reason: 'the photo is still there, so is its screen');
    });

    testWidgets('a photo still processing can be removed from the tagger', (tester) async {
      final fake = await _pump(tester, [_item('a', processing: true)]);
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove from portfolio'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      expect(fake.removed, ['a']);
    });
  });

  group('Set as cover', () {
    testWidgets('the photo screen offers it, above Remove from portfolio', (tester) async {
      await _pump(tester, [_item('a'), _item('b', cover: true)]);
      await _openFirst(tester);
      final set = tester.getTopLeft(find.text('Set as cover'));
      final remove = tester.getTopLeft(find.text('Remove from portfolio'));
      expect(set.dy, lessThan(remove.dy));
    });

    testWidgets('tapping it sets that photo, and the photo screen then says Cover', (tester) async {
      final fake = await _pump(tester, [_item('a'), _item('b', cover: true)]);
      await _openFirst(tester);
      expect(find.descendant(of: find.byType(RPhotoViewer), matching: find.byType(ROverlayBadge)), findsNothing);
      await tester.tap(find.text('Set as cover'));
      await tester.pumpAndSettle();
      expect(fake.covers, ['a']);
      expect(find.descendant(of: find.byType(RPhotoViewer), matching: find.widgetWithText(ROverlayBadge, 'Cover')), findsOneWidget);
      expect(find.text('Clients see this photo first.'), findsOneWidget);
      expect(find.text('Set as cover'), findsNothing, reason: 'it is the cover already');
    });

    testWidgets('a cover picked automatically says so and can still be chosen', (tester) async {
      await _pump(tester, [_item('a', cover: true)]);
      await _openFirst(tester);
      expect(find.text('Clients see this photo first until you choose a cover.'), findsOneWidget);
      expect(find.text('Set as cover'), findsOneWidget);
    });

    testWidgets('a refusal shows the server\'s reason', (tester) async {
      const reason = 'This photo is still being prepared. Once it shows in your portfolio, you can make it your cover.';
      await _pump(tester, [_item('a')], coverRefusal: reason);
      await _openFirst(tester);
      await tester.tap(find.text('Set as cover'));
      await tester.pumpAndSettle();
      expect(find.text('Not set as cover'), findsOneWidget);
      expect(find.text(reason), findsOneWidget);
    });

    testWidgets('the grid marks the cover', (tester) async {
      await _pump(tester, [_item('a'), _item('b', cover: true)]);
      expect(find.widgetWithText(ROverlayBadge, 'Cover'), findsOneWidget);
    });
  });

  group('the tagger', () {
    List<String> chipLabels(WidgetTester tester) =>
        tester.widgetList<RSelectableChip>(find.byType(RSelectableChip)).map((c) => c.label).toList();

    testWidgets('offers only the photographer\'s own niches', (tester) async {
      await _pump(tester, [_item('a')]);
      await _openFirst(tester);
      await tester.tap(find.text('Tag niches'));
      await tester.pumpAndSettle();
      expect(chipLabels(tester), ['Weddings', 'Portraits']);
    });

    testWidgets('keeps a tag of a niche that is not theirs, and says so', (tester) async {
      await _pump(tester, [_item('a', niches: ['food', 'weddings'])]);
      await _openFirst(tester);
      await tester.tap(find.text('Edit tags'));
      await tester.pumpAndSettle();
      expect(chipLabels(tester), ['Weddings', 'Portraits', 'Food (not your niche)']);
      final food = tester.widget<RSelectableChip>(find.widgetWithText(RSelectableChip, 'Food (not your niche)'));
      expect(food.selected, isTrue, reason: 'the tag stays as it is');
      expect(find.textContaining('also tagged with a niche that is not one of yours'), findsOneWidget);
    });
  });
}
