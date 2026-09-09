// Opening a portfolio photo.
//
// Two things here are load-bearing rather than cosmetic:
//
//   - A photo still processing has no preview to show, so tapping it must go
//     straight to the tagger instead of opening a viewer onto nothing.
//   - The viewer must be handed the 2048px preview, not the 512px thumbnail.
//     Passing the thumbnail would look correct in every screenshot and be
//     exactly the thing the backend field was added to avoid.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/pro_portfolio_item.dart';
import 'package:rawwers/api/models/pro_portfolio_response.dart';
import 'package:rawwers/design/components/r_photo_viewer.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/portfolio/portfolio_controller.dart';
import 'package:rawwers/features/pro/portfolio/portfolio_screen.dart';

class _FakePortfolio extends PortfolioController {
  _FakePortfolio(this._value);
  final ProPortfolioResponse _value;
  @override
  Future<ProPortfolioResponse> build() async => _value;
}

ProPortfolioItem _item({
  required String id,
  String? preview,
  String? thumb = 'https://example.test/thumb.jpg',
  String status = 'ready',
  List<String> niches = const [],
}) {
  return ProPortfolioItem(
    mediaAssetId: id,
    kind: 'photo',
    status: status,
    thumbnailUrl: thumb,
    previewUrl: preview,
    nicheSlugs: niches,
    isCover: false,
    createdAt: DateTime.utc(2026, 9, 9),
  );
}

Future<void> _pump(WidgetTester tester, List<ProPortfolioItem> items) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        portfolioControllerProvider.overrideWith(
          () => _FakePortfolio(
            ProPortfolioResponse(
              items: items,
              photoCount: items.length,
              videoCount: 0,
              photoMinimum: 8,
            ),
          ),
        ),
      ],
      child: MaterialApp(theme: buildProTheme(), home: const PortfolioScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('tapping a photo opens it full screen', (tester) async {
    await _pump(tester, [
      _item(id: 'a', preview: 'https://example.test/a_web.jpg'),
      _item(id: 'b', preview: 'https://example.test/b_web.jpg'),
    ]);

    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
    expect(find.byType(RPhotoViewer), findsOneWidget);
    expect(find.text('1 of 2'), findsOneWidget);
  });

  testWidgets('the viewer gets the full-size copy, not the thumbnail', (tester) async {
    await _pump(tester, [
      _item(id: 'a', preview: 'https://example.test/a_web.jpg', thumb: 'https://example.test/a_thumb.jpg'),
    ]);

    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    final viewer = tester.widget<RPhotoViewer>(find.byType(RPhotoViewer));
    expect(
      viewer.urls,
      ['https://example.test/a_web.jpg'],
      reason: 'a 512px thumbnail stretched full screen is what preview_url exists to avoid',
    );
  });

  testWidgets('a still-processing photo goes to the tagger, not an empty viewer', (tester) async {
    await _pump(tester, [
      _item(id: 'a', preview: null, thumb: null, status: 'processing'),
    ]);

    await tester.tap(find.byType(InkWell).first);
    // Fixed frames rather than pumpAndSettle: the tagger loads the niche list
    // from a provider that never resolves under test, so its spinner animates
    // forever and settling never returns.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(RPhotoViewer), findsNothing, reason: 'nothing to show full screen yet');
    expect(find.byType(BottomSheet), findsOneWidget, reason: 'the tagger should have opened instead');
  });

  testWidgets('the tagger is reachable from inside the viewer', (tester) async {
    await _pump(tester, [
      _item(id: 'a', preview: 'https://example.test/a_web.jpg'),
    ]);

    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
    expect(find.text('Tag niches'), findsOneWidget);
  });

  testWidgets('an already-tagged photo offers editing rather than tagging', (tester) async {
    await _pump(tester, [
      _item(id: 'a', preview: 'https://example.test/a_web.jpg', niches: ['weddings']),
    ]);

    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
    expect(find.text('Edit tags'), findsOneWidget);
    expect(find.text('Tag niches'), findsNothing);
  });
}
