import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/shelf_browse_item.dart';
import 'package:rawwers/api/models/shelf_browse_response.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';

part 'shelf_controller.g.dart';

String shelfExplain(ApiFailure failure) => switch (failure) {
      NetworkError() || Timeout() => 'Could not reach RAWWERS. Check your connection and try again.',
      BusinessError(:final message) => message,
      _ => 'That did not work. Try again.',
    };

/// The Shelf as this photographer sees it: levels, the items they can see
/// and the ones their tier has not unlocked yet, and their wish list.
@riverpod
class ShelfController extends _$ShelfController {
  @override
  Future<ShelfBrowseResponse> build() async {
    final result = await apiCall(
      () => ref.read(shelfClientProvider).browseShelfV1ProShelfGet(authorization: null, xMinusUserMinusId: null),
    );
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  /// Adds or removes it from the wish list. Null when done, otherwise what
  /// to tell the photographer (a full list says so).
  Future<String?> toggleWish(ShelfBrowseItem item) async {
    final client = ref.read(shelfClientProvider);
    final Result<Object?> result = item.wished
        ? await apiCall(() => client.unwishV1ProShelfWishlistItemIdDelete(itemId: item.id, authorization: null, xMinusUserMinusId: null))
        : await apiCall(() => client.wishForV1ProShelfWishlistItemIdPut(itemId: item.id, authorization: null, xMinusUserMinusId: null));
    switch (result) {
      case Ok():
        ref.invalidateSelf();
        await future;
        return null;
      case Err(:final failure):
        return shelfExplain(failure);
    }
  }
}
