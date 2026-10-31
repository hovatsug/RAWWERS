import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/delivery_devices_response.dart';
import 'package:rawwers/api/models/pairing_code_response.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';

part 'connect_lightroom_controller.g.dart';

/// The devices paired with Lightroom, newest use first, and the most there
/// may be.
@riverpod
class LightroomDevicesController extends _$LightroomDevicesController {
  @override
  Future<DeliveryDevicesResponse> build() async {
    final result = await apiCall(
      () => ref.read(lightroomClientProvider).listDevicesV1ProLightroomDevicesGet(authorization: null, xMinusUserMinusId: null),
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

  /// Stops the device at once: its next call to RAWWERS is refused. Returns
  /// null on success, or what to tell the photographer.
  Future<String?> revoke(String deviceId) async {
    final result = await apiCall(
      () => ref.read(lightroomClientProvider).revokeDeviceV1ProLightroomDevicesDeviceIdDelete(
            deviceId: deviceId,
            authorization: null,
            xMinusUserMinusId: null,
          ),
    );
    switch (result) {
      case Ok():
        await refresh();
        return null;
      case Err(:final failure):
        // Already gone (revoked elsewhere): the list is what matters.
        if (failure is NotFound) {
          await refresh();
          return null;
        }
        return _message(failure);
    }
  }
}

/// A one-time pairing code: none yet, or the last one asked for.
@riverpod
class PairingCodeController extends _$PairingCodeController {
  @override
  AsyncValue<PairingCodeResponse?> build() => const AsyncData(null);

  Future<void> issue() async {
    state = const AsyncLoading();
    final result = await apiCall(
      () => ref.read(lightroomClientProvider).createPairingCodeV1ProLightroomPairingCodePost(authorization: null, xMinusUserMinusId: null),
    );
    state = switch (result) {
      Ok(:final value) => AsyncData(value),
      Err(:final failure) => AsyncError(_message(failure), StackTrace.current),
    };
  }
}

String _message(ApiFailure failure) => switch (failure) {
      BusinessError(:final message) => message,
      RateLimited() => 'Too many codes in the last hour. Try again later.',
      NetworkError() => 'No connection - check your network and try again.',
      Timeout() => 'That took too long - try again.',
      _ => 'Something went wrong. Please try again.',
    };
