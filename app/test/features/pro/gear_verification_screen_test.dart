// What a photographer is told about their gear.
//
// The wording carries the design: someone whose camera is in the review queue
// has nothing left to do, and a screen that said "still needed" would send them
// round the loop again; a rejection has to say why; lighting has to be shown as
// what they said, never as if a photograph had proved it.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/gear_category.dart';
import 'package:rawwers/api/models/gear_floor_view.dart';
import 'package:rawwers/api/models/gear_verification_list_response.dart';
import 'package:rawwers/api/models/gear_verification_view.dart';
import 'package:rawwers/api/models/verification_status.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/gear_verification/gear_verification_controller.dart';
import 'package:rawwers/features/pro/gear_verification/gear_verification_screen.dart';

class _FakeGear extends GearVerificationController {
  _FakeGear(this._response);

  final GearVerificationListResponse _response;
  final List<Map<String, String?>> lighting = [];
  final List<String> released = [];
  String? lightingError;

  @override
  Future<GearVerificationListResponse> build() async => _response;

  @override
  Future<String?> declareLighting({String? make, required String model, String? notes}) async {
    lighting.add({'make': make, 'model': model, 'notes': notes});
    return lightingError;
  }

  @override
  Future<String?> release(String verificationId) async {
    released.add(verificationId);
    return null;
  }
}

class _FailingGear extends GearVerificationController {
  @override
  Future<GearVerificationListResponse> build() async => throw const NetworkError();
}

class _FakeSubmit extends GearSubmitController {
  _FakeSubmit(this._initial);

  final GearSubmitState _initial;
  int taps = 0;

  @override
  GearSubmitState build() => _initial;

  @override
  Future<void> pickAndSend() async => taps++;
}

GearFloorView _floor({
  bool body = false,
  bool lens = false,
  bool lighting = false,
  bool lightingRequired = false,
  bool declared = false,
  int awaiting = 0,
}) =>
    GearFloorView(
      meetsFloor: body && lens && (!lightingRequired || lighting),
      hasFullFrameBody: body,
      hasQualifyingLens: lens,
      hasLighting: lighting,
      lightingRequired: lightingRequired,
      lightingIsDeclared: declared,
      awaitingReview: awaiting,
      missing: const [],
    );

GearVerificationView _row({
  String id = 'r1',
  GearCategory category = GearCategory.cameraBody,
  VerificationStatus status = VerificationStatus.verified,
  String? make = 'Canon',
  String? model = 'Canon EOS R5',
  String? hint = '•••• 0411',
  String? reason,
}) =>
    GearVerificationView(
      id: id,
      category: category,
      status: status,
      make: make,
      model: model,
      serialHint: hint,
      reviewReason: reason,
      createdAt: DateTime.utc(2026, 9, 19),
    );

Widget _wrap({
  List<GearVerificationView> items = const [],
  GearFloorView? floor,
  GearSubmitState submit = const GearSubmitIdle(),
  _FakeGear? gear,
  _FakeSubmit? submitController,
}) {
  final fake = gear ?? _FakeGear(GearVerificationListResponse(items: items, floor: floor ?? _floor()));
  return ProviderScope(
    overrides: [
      gearVerificationControllerProvider.overrideWith(() => fake),
      gearSubmitControllerProvider.overrideWith(() => submitController ?? _FakeSubmit(submit)),
    ],
    child: MaterialApp(theme: buildProTheme(), home: const GearVerificationScreen()),
  );
}

Future<void> _pump(WidgetTester tester, Widget w, {bool settle = true}) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(w);
  // A loading button animates forever, so a screen mid-upload cannot "settle".
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump();
  }
}

void main() {
  testWidgets('says what to send, and what not to, before a 50 MB file is chosen', (tester) async {
    await _pump(tester, _wrap());

    expect(find.textContaining('straight from your camera'), findsOneWidget);
    expect(find.textContaining('Screenshots and exports'), findsOneWidget);
    expect(find.text('Send a file from your camera'), findsOneWidget);
  });

  testWidgets('one file proves both, so there is no separate body and lens button', (tester) async {
    await _pump(tester, _wrap());

    expect(find.textContaining('one file proves both'), findsOneWidget);
    expect(find.text('Add a camera body'), findsNothing);
    expect(find.text('Add a lens'), findsNothing);
  });

  testWidgets('a verified body shows as verified with only the serial hint', (tester) async {
    await _pump(tester, _wrap(items: [_row()], floor: _floor(body: true)));

    expect(find.text('Canon Canon EOS R5'), findsOneWidget);
    expect(find.text('Verified'), findsOneWidget);
    expect(find.textContaining('•••• 0411'), findsOneWidget);
  });

  testWidgets('a body waiting for review says a person is checking and there is nothing to do', (tester) async {
    await _pump(
      tester,
      _wrap(
        items: [_row(status: VerificationStatus.pendingReview, reason: 'This body published no serial number')],
        floor: _floor(awaiting: 1),
      ),
    );

    expect(find.text('Being checked'), findsOneWidget);
    expect(find.textContaining('You do not need to do anything'), findsOneWidget);
    expect(find.textContaining('Nothing more for you to do'), findsOneWidget);
    // The machine's reason is true and reads like an accusation.
    expect(find.textContaining('published no serial'), findsNothing);
  });

  testWidgets('a rejection states its reason and offers to try again', (tester) async {
    await _pump(
      tester,
      _wrap(items: [_row(status: VerificationStatus.rejected, reason: 'Fujifilm X-T4 is not a full-frame body')]),
    );

    expect(find.text('Not accepted'), findsOneWidget);
    expect(find.text('Fujifilm X-T4 is not a full-frame body'), findsOneWidget);
    expect(find.text('Remove and try again'), findsOneWidget);
  });

  testWidgets('declared lighting is shown as what they said, never as verified', (tester) async {
    await _pump(
      tester,
      _wrap(
        items: [_row(category: GearCategory.lighting, status: VerificationStatus.declared, make: 'Godox', model: 'AD600')],
        floor: _floor(body: true, lens: true, lighting: true, lightingRequired: true, declared: true),
      ),
    );

    expect(find.text('As you described'), findsOneWidget);
    expect(find.text('Verified'), findsNothing);
    expect(find.textContaining('cannot be checked from a photo'), findsWidgets);
    expect(find.text('Lighting (as you described it)'), findsOneWidget);
  });

  testWidgets('the requirement lines reflect what is done and what is not', (tester) async {
    await _pump(tester, _wrap(floor: _floor(body: true)));

    final icons = tester.widgetList<Icon>(find.byType(Icon)).map((i) => i.icon).toList();
    expect(icons.where((i) => i == Icons.check_circle_outline).length, 1, reason: 'body done, lens not');
    expect(find.text('Where you stand'), findsOneWidget);
  });

  testWidgets('lighting is not listed as a requirement when the niches do not need it', (tester) async {
    await _pump(tester, _wrap(floor: _floor(body: true, lens: true)));

    expect(find.text('Lighting'), findsNothing);
  });

  testWidgets('lighting is listed as a requirement when the niches need it', (tester) async {
    await _pump(tester, _wrap(floor: _floor(body: true, lens: true, lightingRequired: true)));

    expect(find.text('Lighting'), findsOneWidget);
  });

  testWidgets('meeting the requirement says so', (tester) async {
    await _pump(tester, _wrap(floor: _floor(body: true, lens: true)));

    expect(find.text('Your gear meets the requirement'), findsOneWidget);
  });

  testWidgets('tapping send opens the picker exactly once', (tester) async {
    final submit = _FakeSubmit(const GearSubmitIdle());
    await _pump(tester, _wrap(submitController: submit));

    await tester.tap(find.text('Send a file from your camera'));
    await tester.pump();

    expect(submit.taps, 1);
  });

  testWidgets('while a file is on its way the button is disabled and progress is shown', (tester) async {
    final submit = _FakeSubmit(const GearSubmitUploading(sent: 42, total: 100));
    await _pump(tester, _wrap(submitController: submit), settle: false);

    expect(find.text('Uploading 42%'), findsOneWidget);
    // Loading swaps the label for a spinner; a tap must not start a second upload.
    await tester.tap(find.byType(ElevatedButton).first, warnIfMissed: false);
    await tester.pump();
    expect(submit.taps, 0);
  });

  testWidgets('reading the file is its own visible stage', (tester) async {
    await _pump(tester, _wrap(submit: const GearSubmitReading()), settle: false);

    expect(find.text('Reading your file…'), findsOneWidget);
  });

  testWidgets('a failed attempt shows its reason and leaves the button usable', (tester) async {
    final submit = _FakeSubmit(const GearSubmitFailed('That file is too large. The limit is 150 MB.'));
    await _pump(tester, _wrap(submitController: submit));

    expect(find.text('That file is too large. The limit is 150 MB.'), findsOneWidget);
    await tester.tap(find.text('Send a file from your camera'));
    await tester.pump();
    expect(submit.taps, 1);
  });

  testWidgets('notes from the server are shown, such as a frame with no lens data', (tester) async {
    await _pump(
      tester,
      _wrap(submit: const GearSubmitDone(items: [], notes: ['This file carries no lens information.'])),
    );

    expect(find.text('This file carries no lens information.'), findsOneWidget);
  });

  testWidgets('lighting needs a model and sends what was typed', (tester) async {
    final gear = _FakeGear(GearVerificationListResponse(items: const [], floor: _floor()));
    await _pump(tester, _wrap(gear: gear));

    await tester.tap(find.text('Add lighting'));
    await tester.pumpAndSettle();

    // Saving with nothing typed is refused here, without a request.
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Say which lighting you use.'), findsOneWidget);
    expect(gear.lighting, isEmpty);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Godox');
    await tester.enterText(fields.at(1), 'AD600 Pro');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(gear.lighting, [
      {'make': 'Godox', 'model': 'AD600 Pro', 'notes': ''},
    ]);
  });

  testWidgets('a server refusal of the lighting stays in the sheet with its reason', (tester) async {
    final gear = _FakeGear(GearVerificationListResponse(items: const [], floor: _floor()))
      ..lightingError = 'Could not save your lighting.';
    await _pump(tester, _wrap(gear: gear));

    await tester.tap(find.text('Add lighting'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(1), 'AD600');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Could not save your lighting.'), findsOneWidget);
    expect(find.text('Your lighting'), findsOneWidget, reason: 'the sheet closed and lost what was typed');
  });

  testWidgets('removing asks first, and only then releases that row', (tester) async {
    final gear = _FakeGear(GearVerificationListResponse(items: [_row(id: 'row-7')], floor: _floor(body: true)));
    await _pump(tester, _wrap(gear: gear));

    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(gear.released, isEmpty, reason: 'released before anyone confirmed');

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(gear.released, isEmpty);

    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Remove')));
    await tester.pumpAndSettle();
    expect(gear.released, ['row-7']);
  });

  testWidgets('a load failure offers a retry instead of a blank screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gearVerificationControllerProvider.overrideWith(_FailingGear.new),
          gearSubmitControllerProvider.overrideWith(() => _FakeSubmit(const GearSubmitIdle())),
        ],
        child: MaterialApp(theme: buildProTheme(), home: const GearVerificationScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Could not load your gear.'), findsOneWidget);
  });
}
