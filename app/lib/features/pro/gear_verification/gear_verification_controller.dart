import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/gear_frame_submit_request.dart';
import 'package:rawwers/api/models/gear_frame_submit_response.dart';
import 'package:rawwers/api/models/gear_verification_list_response.dart';
import 'package:rawwers/api/models/gear_verification_view.dart';
import 'package:rawwers/api/models/lighting_declare_request.dart';
import 'package:rawwers/api/models/media_purpose.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/features/pro/gear_verification/gear_file_picker.dart';
import 'package:rawwers/features/pro/onboarding/onboarding_controller.dart';

part 'gear_verification_controller.g.dart';

/// What the photographer's gear looks like right now, from the server.
///
/// No local notion of "verified": the floor is computed there from real rows,
/// so a photographer who removes their lens sees the requirement reopen.
@riverpod
class GearVerificationController extends _$GearVerificationController {
  @override
  Future<GearVerificationListResponse> build() async {
    final client = ref.read(gearVerificationClientProvider);
    final result = await apiCall(
      () => client.listMyGearVerificationsV1ProMeGearVerificationsGet(authorization: null, xMinusUserMinusId: null),
    );
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Lighting is the photographer's word - nothing in a photograph identifies a
  /// strobe - so this asks for no file and the server records it as declared.
  Future<String?> declareLighting({String? make, required String model, String? notes}) async {
    final client = ref.read(gearVerificationClientProvider);
    final result = await apiCall(
      () => client.declareMyLightingV1ProMeGearVerificationsLightingPost(
        requestBody: LightingDeclareRequest(make: _blankToNull(make), model: model.trim(), notes: _blankToNull(notes)),
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    return _afterWrite(result, 'Could not save your lighting.');
  }

  Future<String?> release(String verificationId) async {
    final client = ref.read(gearVerificationClientProvider);
    final result = await apiCall(
      () => client.releaseMyGearV1ProMeGearVerificationsVerificationIdDelete(
        verificationId: verificationId,
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    return _afterWrite(result, 'Could not remove that.');
  }

  Future<String?> _afterWrite(Result<Object?> result, String fallback) async {
    switch (result) {
      case Ok():
        await _changed();
        return null;
      case Err(:final failure):
        return gearFailureMessage(failure, fallback);
    }
  }

  /// Gear feeds the onboarding checklist, so both are reread together.
  Future<void> _changed() async {
    ref.invalidate(onboardingControllerProvider);
    ref.invalidateSelf();
    await future;
  }
}

/// Where sending a file has got to.
@immutable
sealed class GearSubmitState {
  const GearSubmitState();
}

final class GearSubmitIdle extends GearSubmitState {
  const GearSubmitIdle();
}

final class GearSubmitUploading extends GearSubmitState {
  const GearSubmitUploading({required this.sent, required this.total});

  final int sent;
  final int total;

  double get fraction => total <= 0 ? 0 : (sent / total).clamp(0, 1).toDouble();
}

/// The file is up and the server is reading it.
final class GearSubmitReading extends GearSubmitState {
  const GearSubmitReading();
}

final class GearSubmitDone extends GearSubmitState {
  const GearSubmitDone({required this.items, required this.notes});

  /// What this file turned out to prove - the body, and the lens if it said.
  final List<GearVerificationView> items;
  final List<String> notes;
}

final class GearSubmitFailed extends GearSubmitState {
  const GearSubmitFailed(this.message);

  final String message;
}

/// Sending one camera file: choose it, upload it, have it read.
///
/// One file proves both the body and the lens it was shot on, so there is no
/// "add a body" and "add a lens" - which would have made a photographer prove
/// the same camera again for every lens.
@riverpod
class GearSubmitController extends _$GearSubmitController {
  @override
  GearSubmitState build() => const GearSubmitIdle();

  /// Set synchronously on entry. Checking `state` alone leaves a gap: it only
  /// changes once the picker has returned, so a second tap while the system
  /// dialog is still opening started a second flow.
  bool _inFlight = false;

  Future<void> pickAndSend() async {
    if (_inFlight) return;
    _inFlight = true;
    try {
      await _pickAndSend();
    } finally {
      _inFlight = false;
    }
  }

  Future<void> _pickAndSend() async {
    final picked = await ref.read(gearFilePickerProvider).pick();
    if (picked == null) return; // backed out: not an error

    // Checked here so a 50 MB upload is not started for a file the server will
    // refuse by name. Mirrors the server's list; the server stays the authority.
    if (!gearEvidenceExtensions.contains(picked.extension)) {
      state = const GearSubmitFailed(
        'That does not look like a camera file. Send the RAW file, or the original JPEG, straight from your camera.',
      );
      return;
    }
    if (picked.size > gearEvidenceMaxBytes) {
      state = const GearSubmitFailed('That file is too large. The limit is 150 MB.');
      return;
    }

    state = GearSubmitUploading(sent: 0, total: picked.size);

    final uploaded = await ref.read(photoUploadServiceProvider).uploadPhoto(
          openFile: picked.open,
          fileSize: picked.size,
          purpose: MediaPurpose.gearEvidence,
          contentType: gearContentTypeFor(picked.extension),
          fileName: picked.name,
          onSendProgress: (sent, total) => state = GearSubmitUploading(sent: sent, total: total > 0 ? total : picked.size),
        );

    switch (uploaded) {
      case Err(:final failure):
        state = GearSubmitFailed(gearFailureMessage(failure, 'The upload did not finish. Try again.'));
        return;
      case Ok(:final value):
        await _verify(value);
    }
  }

  Future<void> _verify(String mediaAssetId) async {
    state = const GearSubmitReading();
    final client = ref.read(gearVerificationClientProvider);
    final result = await apiCall(
      () => client.submitGearFrameV1ProMeGearVerificationsPost(
        requestBody: GearFrameSubmitRequest(evidenceMediaAssetId: mediaAssetId),
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );

    switch (result) {
      case Err(:final failure):
        state = GearSubmitFailed(gearFailureMessage(failure, 'We could not read that file. Try again.'));
      case Ok(:final value):
        _record(value);
    }
  }

  void _record(GearFrameSubmitResponse response) {
    state = GearSubmitDone(items: response.items ?? const [], notes: response.notes ?? const []);
    // The list and the onboarding checklist both moved.
    ref.invalidate(onboardingControllerProvider);
    ref.invalidate(gearVerificationControllerProvider);
  }

  void dismiss() {
    if (!_inFlight) state = const GearSubmitIdle();
  }
}

/// Mirrors the server's GEAR_EVIDENCE_EXTENSIONS. A convenience for failing
/// early, never the authority: the server checks again.
const gearEvidenceExtensions = {
  'cr3', 'cr2', 'arw', 'nef', 'nrw', 'raf', 'rw2', 'orf', 'dng', 'pef', 'srw', '3fr', //
  'jpg', 'jpeg', 'heic', 'tif', 'tiff',
};

/// Mirrors GEAR_EVIDENCE_MAX_BYTES.
const gearEvidenceMaxBytes = 150 * 1000 * 1000;

/// RAW files have no agreed MIME type; most travel as application/octet-stream.
String gearContentTypeFor(String extension) => switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'heic' => 'image/heic',
      'tif' || 'tiff' => 'image/tiff',
      _ => 'application/octet-stream',
    };

/// In words for a photographer, not a stack trace.
String gearFailureMessage(ApiFailure failure, String fallback) => switch (failure) {
      NetworkError() || Timeout() => 'Could not reach the server. Check your connection and try again.',
      BusinessError(:final message) when message.contains('camera data') =>
        'We could not read camera details from that file. Send the original RAW or JPEG straight from the camera - not a screenshot or an edited export.',
      // The server's own sentence: "already registered to another
      // photographer" says something no fallback here could.
      BusinessError(:final message) => message,
      RateLimited() => 'Too many attempts. Wait a moment and try again.',
      _ => fallback,
    };

String? _blankToNull(String? value) {
  final trimmed = value?.trim();
  return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
}
