import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/presence_visibility.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';

part 'presence_visibility_controller.g.dart';

/// Said where the photographer decides: in Settings and while getting set up.
const presenceNotice =
    'While your app is open, clients see a green dot on your card and profile. '
    'Nobody ever sees when you were last online.';

/// Whether clients see the photographer's online dot. On unless turned off.
@riverpod
class PresenceVisibilityController extends _$PresenceVisibilityController {
  @override
  Future<bool> build() async {
    final client = ref.read(presenceClientProvider);
    final result = await apiCall(
      () => client.getVisibilityV1ProPresenceVisibilityGet(authorization: null, xMinusUserMinusId: null),
    );
    return switch (result) {
      Ok(:final value) => value.visible,
      Err(:final failure) => throw failure,
    };
  }

  /// Shows the new choice at once; puts it back, with a reason, if the
  /// server did not take it.
  Future<String?> set(bool visible) async {
    final before = state.valueOrNull;
    state = AsyncData(visible);
    final client = ref.read(presenceClientProvider);
    final result = await apiCall(
      () => client.putVisibilityV1ProPresenceVisibilityPut(
        requestBody: PresenceVisibility(visible: visible),
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    if (result case Err()) {
      if (before != null) state = AsyncData(before);
      return 'Could not save that. Check your connection and try again.';
    }
    return null;
  }
}
