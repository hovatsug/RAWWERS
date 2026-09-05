import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/pro_niche_pricing_preview_response.dart';
import 'package:rawwers/api/models/pro_package_view.dart';
import 'package:rawwers/api/models/pro_pricing_curve_point.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_input.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/portfolio/niches_controller.dart';
import 'package:rawwers/features/pro/pricing/pricing_controller.dart';
import 'package:rawwers/features/pro/pricing/pricing_screen.dart';

/// The decay curve is the entire argument for this pricing model, and a
/// photographer cannot hold it in their head. These check it is shown from
/// the server's numbers - the same ones that reach the client's invoice -
/// and that being over the cap is explained with the actual limit.
class _FakePackages extends PackagesController {
  _FakePackages(this._packages);

  final List<ProPackageView> _packages;
  String? sentPrice;
  String? sentSlug;
  String? nextError;

  @override
  Future<List<ProPackageView>> build() async => _packages;

  @override
  Future<String?> createOrUpdate({
    String? packageId,
    required String nicheSlug,
    required String title,
    required String price,
    required int includedPhotos,
    required String extraPhotoPrice,
    required int durationMinutes,
    String? description,
  }) async {
    sentPrice = price;
    sentSlug = nicheSlug;
    return nextError;
  }
}

class _FailingPackages extends PackagesController {
  @override
  Future<List<ProPackageView>> build() async => throw const NetworkError();
}

class _FakeNiches extends NichesController {
  @override
  Future<List<NicheOption>> build() async => const [
        NicheOption(id: 'niche-portraits', slug: 'portraits', name: 'Portraits'),
        NicheOption(id: 'niche-weddings', slug: 'weddings', name: 'Weddings'),
      ];
}

ProPackageView _package({String price = '12.00'}) => ProPackageView(
      id: 'pkg-1',
      proUserId: 'pro-1',
      nicheId: 'niche-portraits',
      title: 'Mini session',
      durationMinutes: 60,
      price: price,
      currency: 'EUR',
      includedPhotos: 10,
      extraPhotoPrice: '8.00',
      proofsSlaDays: 3,
      finalsSlaDays: 7,
      addons: const [],
      isActive: true,
    );

ProNichePricingPreviewResponse _preview({bool withinCap = true, String? max = '20.00'}) =>
    ProNichePricingPreviewResponse(
      nicheId: 'niche-portraits',
      nicheSlug: 'portraits',
      nicheName: 'Portraits',
      tier: 'rookie',
      entryPrice: '12.00',
      currency: 'EUR',
      entryPriceMin: '5.00',
      entryPriceMax: max,
      withinCap: withinCap,
      curve: const [
        ProPricingCurvePoint(photoCount: 10, total: '120.00', perPhoto: '12.00'),
        ProPricingCurvePoint(photoCount: 25, total: '268.67', perPhoto: '10.75'),
        ProPricingCurvePoint(photoCount: 200, total: '1225.53', perPhoto: '6.13'),
      ],
    );

Widget _wrap({
  PackagesController Function()? packages,
  ProNichePricingPreviewResponse? preview,
}) =>
    ProviderScope(
      overrides: [
        packagesControllerProvider.overrideWith(packages ?? () => _FakePackages([_package()])),
        nichesControllerProvider.overrideWith(_FakeNiches.new),
        pricingPreviewProvider(nicheId: 'niche-portraits', entryPrice: '12.00')
            .overrideWith((ref) async => preview ?? _preview()),
      ],
      child: MaterialApp(theme: buildProTheme(), home: const PricingScreen()),
    );

Finder _fieldNamed(String label) => find.descendant(
      of: find.byWidgetPredicate((w) => w is RInput && w.label == label),
      matching: find.byType(TextField),
    );

/// A phone, not the 800x600 default. A modal bottom sheet is capped at a
/// fraction of the viewport, and on the default surface the editor's Save
/// button falls outside the sheet's clip entirely - so the tap lands on
/// nothing and the test fails exactly as a broken handler would.
void _usePhoneSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// The editor sheet is taller than the test surface, so Save sits below the
/// fold. Scrolling to it is the difference between testing the save path and
/// testing nothing at all - a tap that lands on empty space fails the same
/// way a broken handler would.
Future<void> _tapSave(WidgetTester tester) async {
  final save = find.widgetWithText(RButton, 'Save');
  await tester.scrollUntilVisible(save, 200, scrollable: find.byType(Scrollable).last);
  await tester.pump();
  await tester.tap(save);
}

void main() {
  testWidgets('a package shows the per-photo rate the curve is built from', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap());
    await tester.pump();

    expect(find.textContaining('EUR 12.00 per photo'), findsOneWidget);
    expect(find.textContaining('10 included'), findsOneWidget);
  });

  testWidgets('no pricing says what it costs the pro', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap(packages: () => _FakePackages([])));
    await tester.pump();

    expect(find.text('No pricing set'), findsOneWidget);
    expect(find.textContaining('cannot book you'), findsOneWidget);
  });

  testWidgets('editing a package shows what a client pays at each count', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap());
    await tester.pump();

    await tester.tap(find.text('Mini session'));
    await tester.pumpAndSettle();

    expect(find.text('What a client pays'), findsOneWidget);
    expect(find.text('10 photos'), findsOneWidget);
    expect(find.text('EUR 120.00'), findsOneWidget);
    // The taper is the point: 200 photos cost far less than 200 x 12.00.
    expect(find.text('EUR 1225.53'), findsOneWidget);
    expect(find.text('EUR 6.13 each'), findsOneWidget);
  });

  testWidgets('a price over the cap names the limit while typing', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap(preview: _preview(withinCap: false)));
    await tester.pump();

    await tester.tap(find.text('Mini session'));
    await tester.pumpAndSettle();

    // "Invalid" would leave the pro guessing at a number that works.
    expect(find.textContaining('capped at EUR 20.00'), findsOneWidget);
  });

  testWidgets('the curve waits for a shoot type and a price', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap(packages: () => _FakePackages([])));
    await tester.pump();

    await tester.tap(find.widgetWithText(FloatingActionButton, 'Add a package'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Pick a shoot type and enter a price'), findsOneWidget);
  });

  testWidgets('saving without a shoot type says so instead of failing silently', (tester) async {
    _usePhoneSurface(tester);
    final packages = _FakePackages([]);
    await tester.pumpWidget(_wrap(packages: () => packages));
    await tester.pump();

    await tester.tap(find.widgetWithText(FloatingActionButton, 'Add a package'));
    await tester.pumpAndSettle();
    await tester.enterText(_fieldNamed('What you call it'), 'Mini session');
    await _tapSave(tester);
    await tester.pump();

    expect(find.text('Pick what kind of shoot this is.'), findsOneWidget);
    expect(packages.sentPrice, isNull);
  });

  testWidgets('money is sent as the string that was typed', (tester) async {
    // A double would turn 12.10 into 12.099999999999999 somewhere between
    // here and Stripe.
    final packages = _FakePackages([]);
    await tester.pumpWidget(_wrap(packages: () => packages));
    await tester.pump();

    await tester.tap(find.widgetWithText(FloatingActionButton, 'Add a package'));
    await tester.pumpAndSettle();
    await tester.enterText(_fieldNamed('What you call it'), 'Mini session');
    await tester.tap(find.text('Weddings'));
    await tester.pump();
    await tester.enterText(_fieldNamed('Price per photo'), '12.10');
    await _tapSave(tester);
    await tester.pumpAndSettle();

    expect(packages.sentPrice, '12.10');
    expect(packages.sentSlug, 'weddings');
  });

  testWidgets('a rejected save shows the reason the backend gave', (tester) async {
    _usePhoneSurface(tester);
    final packages = _FakePackages([])
      ..nextError = 'Entry price must be at most 20.00 for this niche and tier';
    await tester.pumpWidget(_wrap(packages: () => packages));
    await tester.pump();

    await tester.tap(find.widgetWithText(FloatingActionButton, 'Add a package'));
    await tester.pumpAndSettle();
    await tester.enterText(_fieldNamed('What you call it'), 'Mini session');
    await tester.tap(find.text('Weddings'));
    await tester.pump();
    await tester.enterText(_fieldNamed('Price per photo'), '50.00');
    await _tapSave(tester);
    await tester.pumpAndSettle();

    expect(find.textContaining('at most 20.00'), findsOneWidget);
  });

  testWidgets('a failed load offers a retry', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap(packages: _FailingPackages.new));
    await tester.pump();

    expect(find.text('Could not load your pricing.'), findsOneWidget);
  });
}
