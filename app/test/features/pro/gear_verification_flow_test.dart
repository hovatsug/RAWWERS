// Sending a camera file: choose it, upload it, have it read.
//
// The real controller against a fake backend, a fake object store and a fake
// file picker, so what is asserted is what would go over the wire: the upload
// carries the gear-evidence purpose (not a portfolio one), the verification is
// asked about the asset that was actually uploaded, and a file the server would
// refuse by name never starts a 50 MB upload.
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/api_client/gear_verification_client.dart';
import 'package:rawwers/api/api_client/media_client.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/api/models/pro_onboarding_checks_response.dart';
import 'package:rawwers/api/models/pro_onboarding_status.dart';
import 'package:rawwers/core/upload/photo_upload_service.dart';
import 'package:rawwers/features/pro/gear_verification/gear_file_picker.dart';
import 'package:rawwers/features/pro/gear_verification/gear_verification_controller.dart';
import 'package:rawwers/features/pro/onboarding/onboarding_controller.dart';

import '../../support/fake_http_client_adapter.dart';

/// Counts how many times the checklist was asked to reread itself.
class _CountingOnboarding extends OnboardingController {
  static int builds = 0;

  @override
  Future<ProOnboardingChecksResponse> build() async {
    builds++;
    return const ProOnboardingChecksResponse(status: ProOnboardingStatus.started, checks: {}, missing: []);
  }
}

class _FakePicker implements GearFilePicker {
  _FakePicker(this.file);

  final PickedGearFile? file;
  int picks = 0;

  @override
  Future<PickedGearFile?> pick() async {
    picks++;
    return file;
  }
}

PickedGearFile _file(String name, {int size = 40960}) => PickedGearFile(
      name: name,
      size: size,
      open: () => Stream.value(Uint8List(size < 8 ? size : 8)),
    );

Map<String, dynamic> _view(String id, String category, String status, {String? model, String? hint}) => {
      'id': id,
      'category': category,
      'status': status,
      'model': model,
      'serial_hint': hint,
      'created_at': '2026-09-19T10:00:00Z',
    };

Map<String, dynamic> _floor({bool meets = false}) => {
      'meets_floor': meets,
      'has_full_frame_body': meets,
      'has_qualifying_lens': meets,
      'has_lighting': false,
      'lighting_required': false,
      'lighting_is_declared': false,
      'awaiting_review': 0,
      'missing': meets ? <String>[] : ['full_frame_body', 'qualifying_lens'],
    };

/// What the fake backend saw, in order.
class _Backend {
  final List<String> calls = [];
  Map<String, dynamic>? createBody;
  Map<String, dynamic>? verifyBody;
  Map<String, dynamic>? lightingBody;
  int verifyStatus = 200;
  Map<String, dynamic> verifyError = {'error': {'code': 'conflict', 'message': 'x'}};
  bool createFails = false;

  Future<ResponseBody> api(RequestOptions o) async {
    calls.add('${o.method} ${o.path}');
    if (o.path == '/v1/media/photos/uploads') {
      if (createFails) throw DioException.connectionError(requestOptions: o, reason: 'offline');
      createBody = jsonDecode(jsonEncode(o.data)) as Map<String, dynamic>;
      return jsonResponseBody(
        jsonEncode({
          'media_asset_id': 'asset-1',
          'upload': {
            'method': 'PUT',
            'url': 'https://storage.invalid/put-1',
            'headers': {'Content-Type': 'application/octet-stream'},
            'storage_key': 'key-1',
            'expires_in': 900,
          },
        }),
        200,
      );
    }
    if (o.path.endsWith('/complete')) {
      return jsonResponseBody(jsonEncode({'ok': true, 'current_status': 'ready'}), 200);
    }
    if (o.path == '/v1/pro/me/gear-verifications' && o.method == 'POST') {
      verifyBody = jsonDecode(jsonEncode(o.data)) as Map<String, dynamic>;
      if (verifyStatus != 200) return jsonResponseBody(jsonEncode(verifyError), verifyStatus);
      return jsonResponseBody(
        jsonEncode({
          'items': [
            _view('b1', 'camera_body', 'verified', model: 'Canon EOS R5', hint: '•••• 0411'),
            _view('l1', 'lens', 'verified', model: '50mm F1.4'),
          ],
          'notes': <String>[],
          'floor': _floor(meets: true),
        }),
        200,
      );
    }
    if (o.path == '/v1/pro/me/gear-verifications' && o.method == 'GET') {
      return jsonResponseBody(jsonEncode({'items': <dynamic>[], 'floor': _floor()}), 200);
    }
    if (o.path == '/v1/pro/me/gear-verifications/lighting') {
      lightingBody = jsonDecode(jsonEncode(o.data)) as Map<String, dynamic>;
      return jsonResponseBody(jsonEncode(_view('g1', 'lighting', 'declared', model: 'AD600')), 200);
    }
    if (o.method == 'DELETE') return ResponseBody.fromString('', 204);
    throw StateError('unexpected call: ${o.method} ${o.path}');
  }
}

({ProviderContainer container, _Backend backend, _FakePicker picker}) _setup(PickedGearFile? file) {
  final backend = _Backend();
  final apiDio = Dio(BaseOptions(baseUrl: 'https://example.invalid'))
    ..httpClientAdapter = FakeHttpClientAdapter(backend.api);
  final storageDio = Dio()
    ..httpClientAdapter = FakeHttpClientAdapter((o) async {
      backend.calls.add('${o.method} ${o.uri.host}');
      return ResponseBody.fromString('', 200);
    });
  final picker = _FakePicker(file);

  final container = ProviderContainer(
    overrides: [
      gearVerificationClientProvider.overrideWithValue(GearVerificationClient(apiDio)),
      photoUploadServiceProvider.overrideWithValue(
        PhotoUploadService(mediaClient: MediaClient(apiDio), storageDio: storageDio),
      ),
      gearFilePickerProvider.overrideWithValue(picker),
      onboardingControllerProvider.overrideWith(_CountingOnboarding.new),
    ],
  );
  addTearDown(container.dispose);
  _CountingOnboarding.builds = 0;
  // The screen watches these for as long as it is open. Without a listener an
  // auto-dispose provider resets between awaits, which no real screen would see.
  container.listen(gearSubmitControllerProvider, (_, _) {});
  container.listen(onboardingControllerProvider, (_, _) {});
  return (container: container, backend: backend, picker: picker);
}

void main() {
  test('uploads as gear evidence, then asks the server to read that exact upload', () async {
    final t = _setup(_file('IMG_0001.CR3'));

    await t.container.read(gearSubmitControllerProvider.notifier).pickAndSend();

    expect(t.backend.calls, [
      'POST /v1/media/photos/uploads',
      'PUT storage.invalid',
      'POST /v1/media/photos/asset-1/complete',
      'POST /v1/pro/me/gear-verifications',
    ]);
    // Not a portfolio purpose, and not an image type: a RAW is neither.
    expect(t.backend.createBody!['purpose'], 'gear_evidence');
    expect(t.backend.createBody!['content_type'], 'application/octet-stream');
    expect(t.backend.createBody!['file_name'], 'IMG_0001.CR3');
    expect(t.backend.verifyBody, {'evidence_media_asset_id': 'asset-1'}, reason: 'verified some other upload');

    final state = t.container.read(gearSubmitControllerProvider);
    expect(state, isA<GearSubmitDone>());
    expect((state as GearSubmitDone).items.map((i) => i.model), ['Canon EOS R5', '50mm F1.4']);
  });

  test('a camera JPEG travels as a JPEG', () async {
    final t = _setup(_file('DSC_0001.JPG'));

    await t.container.read(gearSubmitControllerProvider.notifier).pickAndSend();

    expect(t.backend.createBody!['content_type'], 'image/jpeg');
  });

  test('the stages are visible in order: uploading, then reading, then done', () async {
    final t = _setup(_file('IMG_0001.CR3'));
    final seen = <Type>[];
    t.container.listen(gearSubmitControllerProvider, (_, next) => seen.add(next.runtimeType), fireImmediately: true);

    await t.container.read(gearSubmitControllerProvider.notifier).pickAndSend();

    expect(seen, containsAllInOrder([GearSubmitIdle, GearSubmitUploading, GearSubmitReading, GearSubmitDone]));
  });

  test('backing out of the picker is not an error and starts nothing', () async {
    final t = _setup(null);

    await t.container.read(gearSubmitControllerProvider.notifier).pickAndSend();

    expect(t.container.read(gearSubmitControllerProvider), isA<GearSubmitIdle>());
    expect(t.backend.calls, isEmpty);
  });

  test('a file the server would refuse by name is refused before any upload starts', () async {
    final t = _setup(_file('payload.exe'));

    await t.container.read(gearSubmitControllerProvider.notifier).pickAndSend();

    final state = t.container.read(gearSubmitControllerProvider);
    expect(state, isA<GearSubmitFailed>());
    expect((state as GearSubmitFailed).message, contains('camera file'));
    expect(t.backend.calls, isEmpty, reason: 'a large upload was started for a file that could never be accepted');
  });

  test('a file over the size limit is refused before any upload starts', () async {
    final t = _setup(_file('huge.arw', size: gearEvidenceMaxBytes + 1));

    await t.container.read(gearSubmitControllerProvider.notifier).pickAndSend();

    expect(t.container.read(gearSubmitControllerProvider), isA<GearSubmitFailed>());
    expect(t.backend.calls, isEmpty);
  });

  test("the server's own sentence is shown when it has something specific to say", () async {
    final t = _setup(_file('IMG_0001.CR3'));
    t.backend.verifyStatus = 409;
    t.backend.verifyError = {
      'error': {'code': 'conflict', 'message': 'That equipment is already registered to another photographer'},
    };

    await t.container.read(gearSubmitControllerProvider.notifier).pickAndSend();

    final state = t.container.read(gearSubmitControllerProvider);
    expect((state as GearSubmitFailed).message, 'That equipment is already registered to another photographer');
  });

  test('a file with no readable camera data gets advice, not a parser error', () async {
    final t = _setup(_file('screenshot.jpg'));
    t.backend.verifyStatus = 422;
    t.backend.verifyError = {
      'error': {
        'code': 'validation_error',
        'message': 'Could not read camera data from that file: no EXIF headers found in this file',
      },
    };

    await t.container.read(gearSubmitControllerProvider.notifier).pickAndSend();

    final message = (t.container.read(gearSubmitControllerProvider) as GearSubmitFailed).message;
    expect(message, isNot(contains('EXIF')));
    expect(message, contains('straight from the camera'));
  });

  test('a dropped connection says so and can be retried', () async {
    final t = _setup(_file('IMG_0001.CR3'));
    t.backend.createFails = true;

    await t.container.read(gearSubmitControllerProvider.notifier).pickAndSend();

    final state = t.container.read(gearSubmitControllerProvider);
    expect(state, isA<GearSubmitFailed>());
    expect((state as GearSubmitFailed).message, contains('connection'));

    // Retrying starts over rather than being stuck in the failed state.
    t.backend.createFails = false;
    await t.container.read(gearSubmitControllerProvider.notifier).pickAndSend();
    expect(t.container.read(gearSubmitControllerProvider), isA<GearSubmitDone>());
  });

  test('a second tap while a file is on its way does not start a second upload', () async {
    final t = _setup(_file('IMG_0001.CR3'));
    final notifier = t.container.read(gearSubmitControllerProvider.notifier);

    final first = notifier.pickAndSend();
    final second = notifier.pickAndSend();
    await Future.wait([first, second]);

    expect(t.backend.calls.where((c) => c == 'POST /v1/media/photos/uploads').length, 1);
    expect(t.picker.picks, 1, reason: 'the picker opened twice');
  });

  test('lighting is declared with what was typed, trimmed, and a blank brand sent as absent', () async {
    final t = _setup(null);
    t.container.listen(gearVerificationControllerProvider, (_, _) {});
    await t.container.read(gearVerificationControllerProvider.future);

    final error = await t.container
        .read(gearVerificationControllerProvider.notifier)
        .declareLighting(make: '   ', model: '  AD600 Pro ', notes: '');

    expect(error, isNull);
    final body = t.backend.lightingBody!;
    expect(body['model'], 'AD600 Pro', reason: 'the model was not trimmed');
    expect(body['make'], isNull, reason: 'a blank brand was sent as an empty string');
    expect(body['notes'], isNull, reason: 'blank notes were sent as an empty string');
  });

  test('a verified file makes the onboarding checklist reread itself', () async {
    final t = _setup(_file('IMG_0001.CR3'));
    await t.container.read(onboardingControllerProvider.future);
    final before = _CountingOnboarding.builds;

    await t.container.read(gearSubmitControllerProvider.notifier).pickAndSend();
    await t.container.read(onboardingControllerProvider.future);

    expect(_CountingOnboarding.builds, greaterThan(before), reason: 'the checklist kept saying gear was missing');
  });

  test('declaring lighting and removing gear both make the checklist reread itself', () async {
    final t = _setup(null);
    t.container.listen(gearVerificationControllerProvider, (_, _) {});
    await t.container.read(gearVerificationControllerProvider.future);
    await t.container.read(onboardingControllerProvider.future);

    var before = _CountingOnboarding.builds;
    await t.container.read(gearVerificationControllerProvider.notifier).declareLighting(model: 'AD600');
    await t.container.read(onboardingControllerProvider.future);
    expect(_CountingOnboarding.builds, greaterThan(before));

    before = _CountingOnboarding.builds;
    await t.container.read(gearVerificationControllerProvider.notifier).release('row-9');
    await t.container.read(onboardingControllerProvider.future);
    expect(_CountingOnboarding.builds, greaterThan(before));
  });

  test('removing gear asks the server to release that exact row', () async {
    final t = _setup(null);
    t.container.listen(gearVerificationControllerProvider, (_, _) {});
    await t.container.read(gearVerificationControllerProvider.future);

    final error = await t.container.read(gearVerificationControllerProvider.notifier).release('row-9');

    expect(error, isNull);
    expect(t.backend.calls, contains('DELETE /v1/pro/me/gear-verifications/row-9'));
  });
}
