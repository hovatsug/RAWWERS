import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/pro_portfolio_item.dart';
import 'package:rawwers/api/models/pro_portfolio_response.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/portfolio/niches_controller.dart';
import 'package:rawwers/features/pro/portfolio/portfolio_controller.dart';
import 'package:rawwers/features/pro/portfolio/portfolio_screen.dart';

class _FakePortfolio extends PortfolioController {
  _FakePortfolio(this._response);

  final ProPortfolioResponse _response;
  List<String>? taggedWith;

  @override
  Future<ProPortfolioResponse> build() async => _response;

  @override
  Future<String?> tagNiches({required String mediaAssetId, required List<String> nicheSlugs}) async {
    taggedWith = nicheSlugs;
    return null;
  }
}

class _FailingPortfolio extends PortfolioController {
  @override
  Future<ProPortfolioResponse> build() async => throw const NetworkError();
}

class _FakeUploads extends PortfolioUploadController {
  _FakeUploads(this._state);

  final Map<String, UploadProgress> _state;

  @override
  Map<String, UploadProgress> build() => _state;
}

class _FakeNiches extends NichesController {
  @override
  Future<List<NicheOption>> build() async => const [
        NicheOption(id: 'niche-portraits', slug: 'portraits', name: 'Portraits'),
        NicheOption(id: 'niche-weddings', slug: 'weddings', name: 'Weddings'),
      ];
}

ProPortfolioItem _item({
  String id = 'a1',
  bool isCover = false,
  List<String>? niches,
}) =>
    ProPortfolioItem(
      mediaAssetId: id,
      kind: 'photo',
      thumbnailUrl: null,
      nicheSlugs: niches,
      isCover: isCover,
      createdAt: DateTime.utc(2026, 9, 1),
    );

ProPortfolioResponse _response({int photos = 3, List<ProPortfolioItem>? items}) => ProPortfolioResponse(
      items: items ?? [for (var i = 0; i < photos; i++) _item(id: 'a$i')],
      photoCount: photos,
      videoCount: 0,
      photoMinimum: 12,
    );

Widget _wrap({
  PortfolioController Function()? portfolio,
  Map<String, UploadProgress> uploads = const {},
}) =>
    ProviderScope(
      overrides: [
        portfolioControllerProvider.overrideWith(portfolio ?? () => _FakePortfolio(_response())),
        portfolioUploadControllerProvider.overrideWith(() => _FakeUploads(uploads)),
        nichesControllerProvider.overrideWith(_FakeNiches.new),
      ],
      child: MaterialApp(theme: buildProTheme(), home: const PortfolioScreen()),
    );

void main() {
  testWidgets('leads with progress toward the minimum', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump();

    expect(find.text('3 of 12 photos'), findsOneWidget);
    // The consequence, not just the number: this is what keeps them dark.
    expect(find.textContaining('cannot go live'), findsOneWidget);
  });

  testWidgets('a met minimum stops nagging', (tester) async {
    await tester.pumpWidget(_wrap(portfolio: () => _FakePortfolio(_response(photos: 14))));
    await tester.pump();

    expect(find.text('You have enough photos to go live'), findsOneWidget);
    expect(find.textContaining('cannot go live'), findsNothing);
  });

  testWidgets('untagged photos are flagged on the tile', (tester) async {
    // An untagged photo is invisible to the niche filtering most clients
    // arrive through, so it should not take a tap to discover.
    await tester.pumpWidget(_wrap(
      portfolio: () => _FakePortfolio(_response(
        photos: 2,
        items: [_item(id: 'a1', niches: const ['portraits']), _item(id: 'a2')],
      )),
    ));
    await tester.pump();

    expect(find.text('Untagged'), findsOneWidget);
  });

  testWidgets('the cover is marked', (tester) async {
    await tester.pumpWidget(_wrap(
      portfolio: () => _FakePortfolio(_response(photos: 1, items: [_item(isCover: true)])),
    ));
    await tester.pump();

    expect(find.text('Cover'), findsOneWidget);
  });

  testWidgets('tapping a photo tags it by niche', (tester) async {
    final portfolio = _FakePortfolio(_response(photos: 1, items: [_item()]));
    await tester.pumpWidget(_wrap(portfolio: () => portfolio));
    await tester.pump();

    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Weddings'));
    await tester.pump();
    await tester.tap(find.text('Save tags'));
    await tester.pumpAndSettle();

    expect(portfolio.taggedWith, ['weddings']);
  });

  testWidgets('an upload in flight shows its progress', (tester) async {
    await tester.pumpWidget(_wrap(uploads: const {
      'k1': UploadProgress(fileName: 'IMG_0042.jpg', sent: 50, total: 200),
    }));
    await tester.pump();

    expect(find.text('IMG_0042.jpg'), findsOneWidget);
    final bar = tester.widgetList<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
    expect(bar.any((b) => b.value == 0.25), isTrue);
  });

  testWidgets('a failed upload names the file and stays put', (tester) async {
    // Out of twenty picked photos, the pro needs to know which failed.
    await tester.pumpWidget(_wrap(uploads: const {
      'k1': UploadProgress(fileName: 'IMG_0042.jpg', sent: 10, total: 200, error: 'Upload failed - check your connection.'),
    }));
    await tester.pump();

    expect(find.text('IMG_0042.jpg'), findsOneWidget);
    expect(find.textContaining('check your connection'), findsOneWidget);
    expect(find.byTooltip('Dismiss'), findsOneWidget);
  });

  testWidgets('an empty portfolio says what good looks like', (tester) async {
    await tester.pumpWidget(_wrap(portfolio: () => _FakePortfolio(_response(photos: 0, items: []))));
    await tester.pump();

    expect(find.text('Nothing here yet'), findsOneWidget);
    expect(find.textContaining('Twelve of your best'), findsOneWidget);
  });

  testWidgets('a failed load offers a retry', (tester) async {
    await tester.pumpWidget(_wrap(portfolio: _FailingPortfolio.new));
    await tester.pump();

    expect(find.text('Could not load your portfolio.'), findsOneWidget);
  });
}
