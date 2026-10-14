import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/available_now_update.dart';
import 'package:rawwers/api/models/available_now_view.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';

part 'available_now_controller.g.dart';

/// Thrown by [AvailableNowController.set] when switching on would do nothing:
/// no package may be booked at short notice. The card answers it by asking
/// which packages should, rather than showing a toggle that books nothing.
class NoShortNoticePackages implements Exception {
  const NoShortNoticePackages();
}

/// The photographer's "Available now": switched on or not, until when, and
/// whether clients can book at short notice right now - all the server's
/// answer, never worked out on the phone.
@riverpod
class AvailableNowController extends _$AvailableNowController {
  @override
  Future<AvailableNowView> build() async {
    final client = ref.read(availableNowClientProvider);
    final result = await apiCall(
      () => client.getAvailableNowV1ProAvailableNowGet(authorization: null, xMinusUserMinusId: null),
    );
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  /// Switch on or off, optionally changing the preparation time. Returns an
  /// error message, or throws [NoShortNoticePackages].
  Future<String?> set({required bool on, int? prepMinutes}) async {
    final client = ref.read(availableNowClientProvider);
    final result = await apiCall(
      () => client.putAvailableNowV1ProAvailableNowPut(
        requestBody: AvailableNowUpdate(switchedOn: on, prepMinutes: prepMinutes),
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    switch (result) {
      case Ok(:final value):
        state = AsyncData(value);
        return null;
      case Err(failure: BusinessError(code: 'no_short_notice_packages')):
        throw const NoShortNoticePackages();
      case Err(:final failure):
        return switch (failure) {
          NetworkError() || Timeout() => 'Not saved - check your connection.',
          _ => 'Could not change that. Try again.',
        };
    }
  }
}
