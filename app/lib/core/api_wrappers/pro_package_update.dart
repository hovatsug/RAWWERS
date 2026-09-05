import 'package:rawwers/api/models/pro_package_update_request.dart';
import 'package:rawwers/api/models/pro_package_view.dart';

/// `PUT /v1/pro/me/packages/{package_id}` only overwrites fields that are
/// non-null in the request body - a partial update despite the PUT verb.
/// Building a request with only the edited fields would silently wipe the
/// rest of the package (including `price`).
///
/// Always build from the full current package, then `.copyWith(...)` just
/// the fields being edited:
///
/// ```dart
/// final request = buildProPackageUpdateRequest(current).copyWith(price: newPrice);
/// ```
ProPackageUpdateRequest buildProPackageUpdateRequest(ProPackageView current) {
  return ProPackageUpdateRequest(
    title: current.title,
    // ProPackageView only carries nicheId, never nicheSlug - that's fine,
    // the backend only requires one of the two to resolve the niche.
    nicheId: current.nicheId,
    description: current.description,
    durationMinutes: current.durationMinutes,
    price: current.price,
    currency: current.currency,
    includedPhotos: current.includedPhotos,
    extraPhotoPrice: current.extraPhotoPrice,
    proofsSlaDays: current.proofsSlaDays,
    finalsSlaDays: current.finalsSlaDays,
    addons: current.addons,
    isActive: current.isActive,
  );
}
