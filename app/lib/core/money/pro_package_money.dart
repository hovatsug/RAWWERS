import 'package:decimal/decimal.dart';
import 'package:rawwers/api/models/pro_package_create_request.dart';
import 'package:rawwers/api/models/pro_package_update_request.dart';

/// The generated ProPackageCreateRequest/ProPackageUpdateRequest type
/// `price`/`extraPhotoPrice` as `dynamic` - the backend accepts either a
/// JSON number or a decimal string on input, which the generator can't
/// express safely, and `dynamic` gives no protection against accidentally
/// sending a `double`. Feature code must build these requests through this
/// file, never the raw generated constructor/copyWith, so a money value can
/// never be anything but a Decimal until it's serialized to the wire string
/// right here (see app/README.md, "Money is decimal-string end to end").
ProPackageCreateRequest createProPackageRequest({
  required String title,
  String? nicheId,
  String? nicheSlug,
  String? description,
  required int durationMinutes,
  required Decimal price,
  String currency = 'EUR',
  required int includedPhotos,
  required Decimal extraPhotoPrice,
  int proofsSlaDays = 3,
  int finalsSlaDays = 7,
  List<Map<String, dynamic>>? addons,
}) {
  return ProPackageCreateRequest(
    title: title,
    nicheId: nicheId,
    nicheSlug: nicheSlug,
    description: description,
    durationMinutes: durationMinutes,
    price: price.toStringAsFixed(2),
    currency: currency,
    includedPhotos: includedPhotos,
    extraPhotoPrice: extraPhotoPrice.toStringAsFixed(2),
    proofsSlaDays: proofsSlaDays,
    finalsSlaDays: finalsSlaDays,
    addons: addons,
  );
}

/// Applies price edits on top of a base request (normally
/// `buildProPackageUpdateRequest(current)` from
/// lib/core/api_wrappers/pro_package_update.dart) without ever passing a
/// non-Decimal value for `price`/`extraPhotoPrice`.
ProPackageUpdateRequest applyProPackagePriceEdits(
  ProPackageUpdateRequest base, {
  Decimal? price,
  Decimal? extraPhotoPrice,
}) {
  var result = base;
  if (price != null) {
    result = result.copyWith(price: price.toStringAsFixed(2));
  }
  if (extraPhotoPrice != null) {
    result = result.copyWith(extraPhotoPrice: extraPhotoPrice.toStringAsFixed(2));
  }
  return result;
}
