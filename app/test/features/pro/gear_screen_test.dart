import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/gear_category.dart';
import 'package:rawwers/api/models/gear_item_view.dart';
import 'package:rawwers/api/models/shelf_camera_model_view.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/gear/gear_controller.dart';
import 'package:rawwers/features/pro/gear/gear_screen.dart';

class _FakeGear extends GearController {
  _FakeGear(this._items);

  final List<GearItemView> _items;
  String? removed;
  String? lastRemoveError;

  @override
  Future<List<GearItemView>> build() async => _items;

  @override
  Future<String?> remove(String id) async {
    removed = id;
    return lastRemoveError;
  }

  Map<String, String?>? added;

  @override
  Future<String?> add({
    required GearCategory category,
    String? brand,
    String? model,
    String? cameraModel,
    String? serialNumber,
    String? notes,
  }) async {
    added = {'brand': brand, 'model': model, 'cameraModel': cameraModel};
    return null;
  }
}

class _FailingGear extends GearController {
  @override
  Future<List<GearItemView>> build() async => throw const NetworkError();
}

GearItemView _item({
  String id = 'g1',
  GearCategory category = GearCategory.cameraBody,
  String? brand = 'Sony',
  String? model = 'A7 IV',
  String? serial = 'SN-12345',
  String? cameraModel,
}) =>
    GearItemView(
      cameraModel: cameraModel,
      id: id,
      proUserId: 'pro-1',
      category: category,
      brand: brand,
      model: model,
      serialNumber: serial,
      createdAt: DateTime.utc(2026, 9, 1),
      updatedAt: DateTime.utc(2026, 9, 1),
    );

Widget _wrap(GearController Function() gear) => ProviderScope(
      overrides: [gearControllerProvider.overrideWith(gear)],
      child: MaterialApp(theme: buildProTheme(), home: const GearScreen()),
    );

void main() {
  testWidgets('an item shows its serial number', (tester) async {
    await tester.pumpWidget(_wrap(() => _FakeGear([_item()])));
    await tester.pump();

    expect(find.text('Sony A7 IV'), findsOneWidget);
    expect(find.text('Camera body'), findsOneWidget);
    expect(find.text('Serial SN-12345'), findsOneWidget);
  });

  testWidgets('the category reads in words, not in enum values', (tester) async {
    await tester.pumpWidget(_wrap(() => _FakeGear([_item(category: GearCategory.cameraBody, brand: null, model: null)])));
    await tester.pump();

    expect(find.text('camera_body'), findsNothing);
    expect(find.text('Camera body'), findsWidgets);
  });

  testWidgets('the empty state says why serial numbers matter', (tester) async {
    await tester.pumpWidget(_wrap(() => _FakeGear([])));
    await tester.pump();

    expect(find.text('No kit listed yet'), findsOneWidget);
    // Without the reason this is busywork a photographer will skip.
    expect(find.textContaining('claim for later'), findsOneWidget);
  });

  testWidgets('removing asks first', (tester) async {
    final gear = _FakeGear([_item()]);
    await tester.pumpWidget(_wrap(() => gear));
    await tester.pump();

    await tester.tap(find.byTooltip('Remove'));
    await tester.pumpAndSettle();
    expect(find.text('Remove this item?'), findsOneWidget);
    expect(gear.removed, isNull, reason: 'nothing should be removed before confirming');

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(gear.removed, isNull);
  });

  testWidgets('confirming removes the item', (tester) async {
    final gear = _FakeGear([_item()]);
    await tester.pumpWidget(_wrap(() => gear));
    await tester.pump();

    await tester.tap(find.byTooltip('Remove'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove').last);
    await tester.pumpAndSettle();

    expect(gear.removed, 'g1');
  });

  testWidgets('a refused removal shows the reason the backend gave', (tester) async {
    // The backend refuses when repair tickets reference the item; a generic
    // "could not remove" would leave the pro with no idea what to do.
    final gear = _FakeGear([_item()])
      ..lastRemoveError = 'This item has repair tickets against it and cannot be removed.';
    await tester.pumpWidget(_wrap(() => gear));
    await tester.pump();

    await tester.tap(find.byTooltip('Remove'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('repair tickets'), findsOneWidget);
  });

  testWidgets('a failed load offers a retry', (tester) async {
    await tester.pumpWidget(_wrap(_FailingGear.new));
    await tester.pump();

    expect(find.text('Could not load your kit.'), findsOneWidget);
  });

  testWidgets('a body on the camera list says The Shelf shows what fits it', (tester) async {
    await tester.pumpWidget(_wrap(() => _FakeGear([_item(cameraModel: 'ilce7m4'), _item(id: 'g2', model: 'Old one')])));
    await tester.pump();

    expect(find.text('On the camera list: The Shelf shows what fits it'), findsOneWidget);
  });

  testWidgets('a camera picked from the list fills make and model and is sent with the item', (tester) async {
    tester.view.physicalSize = const Size(1170, 4000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final gear = _FakeGear(const []);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        gearControllerProvider.overrideWith(() => gear),
        cameraSearchProvider('a7').overrideWith(
          (ref) async => const [ShelfCameraModelView(normalisedModel: 'ilce7m4', make: 'Sony', displayName: 'Sony A7 IV')],
        ),
      ],
      child: MaterialApp(theme: buildProTheme(), home: const GearScreen()),
    ));
    await tester.pump();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Find your camera on the list'), 'a7');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sony A7 IV'));
    await tester.pumpAndSettle();

    expect(find.text('On the camera list: Sony A7 IV'), findsOneWidget);
    await tester.tap(find.text('Add to kit'));
    await tester.pumpAndSettle();
    expect(gear.added, {'brand': 'Sony', 'model': 'A7 IV', 'cameraModel': 'ilce7m4'});
  });
}
