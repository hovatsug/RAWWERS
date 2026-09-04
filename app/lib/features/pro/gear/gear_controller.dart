import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/gear_category.dart';
import 'package:rawwers/api/models/gear_item_create_request.dart';
import 'package:rawwers/api/models/gear_item_update_request.dart';
import 'package:rawwers/api/models/gear_item_view.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';

part 'gear_controller.g.dart';

/// The kit a photographer owns.
///
/// Serial numbers are why this exists rather than a free-text "gear" field:
/// they are what an insurer or a police report needs, and nobody types them
/// from memory after the bag is gone.
@riverpod
class GearController extends _$GearController {
  @override
  Future<List<GearItemView>> build() async {
    final client = ref.read(repairsClientProvider);
    final result = await apiCall(
      () => client.listMyGearItemsV1ProMeGearItemsGet(authorization: null, xMinusUserMinusId: null),
    );
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  Future<String?> add({
    required GearCategory category,
    String? brand,
    String? model,
    String? serialNumber,
    String? notes,
  }) async {
    final client = ref.read(repairsClientProvider);
    final result = await apiCall(
      () => client.createGearItemV1ProMeGearItemsPost(
        requestBody: GearItemCreateRequest(
          category: category,
          brand: _trimmed(brand),
          model: _trimmed(model),
          serialNumber: _trimmed(serialNumber),
          notes: _trimmed(notes),
        ),
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    return _applyOrExplain(result, 'Could not add that item.');
  }

  Future<String?> edit({
    required String id,
    required GearCategory category,
    String? brand,
    String? model,
    String? serialNumber,
    String? notes,
  }) async {
    final client = ref.read(repairsClientProvider);
    final result = await apiCall(
      () => client.updateGearItemV1ProMeGearItemsGearItemIdPut(
        gearItemId: id,
        requestBody: GearItemUpdateRequest(
          category: category,
          brand: _trimmed(brand),
          model: _trimmed(model),
          serialNumber: _trimmed(serialNumber),
          notes: _trimmed(notes),
        ),
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    return _applyOrExplain(result, 'Could not save that item.');
  }

  Future<String?> remove(String id) async {
    final client = ref.read(repairsClientProvider);
    final result = await apiCall(
      () => client.deleteGearItemV1ProMeGearItemsGearItemIdDelete(
        gearItemId: id,
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    return _applyOrExplain(result, 'Could not remove that item.');
  }

  /// Refetches the list after a write, and turns a failure into a sentence.
  ///
  /// The refresh is awaited here, unlike after a booking, because the list
  /// *is* the screen: there is nowhere else for the pro to go that would
  /// show the change, so a stale list would be the more confusing outcome.
  Future<String?> _applyOrExplain(Result<Object?> result, String fallback) async {
    switch (result) {
      case Ok():
        ref.invalidateSelf();
        await future;
        return null;
      case Err(:final failure):
        return switch (failure) {
          NetworkError() || Timeout() => 'Could not reach the server. Check your connection.',
          // A 409 here means repair tickets reference the item; the
          // backend's sentence explains that better than a generic one.
          BusinessError(:final message) => message,
          _ => fallback,
        };
    }
  }

  String? _trimmed(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}

/// Plain-language names. The API's enum values are storage identifiers, not
/// words a photographer would use for their own kit.
String gearCategoryLabel(GearCategory category) => switch (category) {
      GearCategory.cameraBody => 'Camera body',
      GearCategory.lens => 'Lens',
      GearCategory.lighting => 'Lighting',
      GearCategory.audio => 'Audio',
      GearCategory.tripod => 'Tripod',
      GearCategory.drone => 'Drone',
      GearCategory.accessory => 'Accessory',
    };
