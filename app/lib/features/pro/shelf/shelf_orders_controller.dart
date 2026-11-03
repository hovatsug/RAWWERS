import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/place_shelf_order_request.dart';
import 'package:rawwers/api/models/shelf_address.dart';
import 'package:rawwers/api/models/shelf_address_response.dart';
import 'package:rawwers/api/models/shelf_order_view.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/features/pro/shelf/shelf_controller.dart';
import 'package:rawwers/features/pro/wallet/raww_controller.dart';

part 'shelf_orders_controller.g.dart';

/// A fresh id for one order attempt. Sent with the order, so a second tap
/// (or a retry after a lost connection) is the same order, not a second one.
String newOrderRequestId([Random? random]) {
  final r = random ?? Random.secure();
  return List.generate(16, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
}

/// The photographer's saved address for The Shelf, and where it ships.
@riverpod
class ShelfAddressController extends _$ShelfAddressController {
  @override
  Future<ShelfAddressResponse> build() async {
    final result = await apiCall(
      () => ref.read(shelfClientProvider).myShelfAddressV1ProShelfAddressGet(authorization: null, xMinusUserMinusId: null),
    );
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  /// Null when saved, otherwise what to tell the photographer.
  Future<String?> save(ShelfAddress address) async {
    final result = await apiCall(
      () => ref.read(shelfClientProvider).saveShelfAddressV1ProShelfAddressPut(requestBody: address, authorization: null, xMinusUserMinusId: null),
    );
    switch (result) {
      case Ok(:final value):
        state = AsyncData(value);
        return null;
      case Err(:final failure):
        return shelfExplain(failure);
    }
  }
}

/// My orders on The Shelf, newest first.
///
/// Kept alive: the checkout only reads it to place an order, and an
/// auto-disposed notifier could be gone before the order comes back.
@Riverpod(keepAlive: true)
class ShelfOrdersController extends _$ShelfOrdersController {
  @override
  Future<List<ShelfOrderView>> build() async {
    final result = await apiCall(
      () => ref.read(shelfClientProvider).myShelfOrdersV1ProShelfOrdersGet(authorization: null, xMinusUserMinusId: null),
    );
    return switch (result) {
      Ok(:final value) => value.items,
      Err(:final failure) => throw failure,
    };
  }

  /// Places the order. The RAWW, the shelf and the list all change, so all
  /// three are reloaded. Null when placed, otherwise the reason.
  Future<String?> place({required String itemId, required String requestId}) async {
    final result = await apiCall(
      () => ref.read(shelfClientProvider).placeShelfOrderV1ProShelfOrdersPost(
            requestBody: PlaceShelfOrderRequest(itemId: itemId, clientRequestId: requestId),
            authorization: null,
            xMinusUserMinusId: null,
          ),
    );
    return _after(result);
  }

  Future<String?> cancel(String orderId) async {
    final result = await apiCall(
      () => ref.read(shelfClientProvider).cancelMyShelfOrderV1ProShelfOrdersOrderIdCancelPost(
            orderId: orderId,
            authorization: null,
            xMinusUserMinusId: null,
          ),
    );
    return _after(result);
  }

  Future<String?> _after(Result<Object?> result) async {
    switch (result) {
      case Ok():
        ref.invalidate(rawwProvider);
        ref.invalidate(shelfControllerProvider);
        ref.invalidateSelf();
        return null;
      case Err(:final failure):
        return shelfExplain(failure);
    }
  }
}
