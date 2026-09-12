import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/gallery_item_view.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';

part 'delivered_controller.g.dart';

/// A photograph the client has paid for, with the real file behind it.
class DeliveredPhoto {
  const DeliveredPhoto({required this.item, required this.finalUrl});

  final GalleryItemView item;

  /// The original, signed and time-limited. This is the client's own
  /// photograph, so it is what they see full screen - the gallery listing
  /// offers only a thumbnail and a *watermarked* preview, and showing someone
  /// a watermark on a photo they have already bought would be absurd.
  final String finalUrl;

  String get assetId => item.mediaAssetId;
}

class DeliveredState {
  const DeliveredState({required this.photos});

  /// Only what the server unlocked. The gallery holds everything the
  /// photographer uploaded; the chosen, paid-for ones are the client's, and
  /// the rest are not theirs to see here.
  final List<DeliveredPhoto> photos;

  bool get isEmpty => photos.isEmpty;
}

/// Which photos are the client's, in the order they were shot.
///
/// A free function so the rule can be tested without standing up HTTP. It is
/// the whole of what makes this screen correct: an item appears only if the
/// downloads response carried a link for it, because that response is the
/// server's statement of what this client paid for. Iterating the gallery and
/// treating a missing link as an empty URL - the obvious refactor - silently
/// turns it into "show everything", which is the bug this guards.
List<DeliveredPhoto> crossGalleryWithLinks(
  List<GalleryItemView> items,
  Map<String, dynamic> links,
) {
  return [
    for (final item in items)
      if (links[item.mediaAssetId] case final String url)
        if (url.isNotEmpty) DeliveredPhoto(item: item, finalUrl: url),
  ];
}

/// The photographs a client owns.
///
/// Built by crossing the gallery listing with the downloads endpoint: the
/// listing supplies order and thumbnails, the downloads call supplies both
/// the set of assets this client actually owns and the links to the originals.
/// Neither alone is enough - the listing does not know what was bought, and
/// the downloads response does not know the order they were shot in.
@riverpod
class DeliveredController extends _$DeliveredController {
  @override
  Future<DeliveredState> build(String galleryId) async {
    final galleries = ref.read(proofGalleriesClientProvider);

    final detail = switch (await apiCall(
      () => galleries.getGalleryV1ProofGalleriesGalleryIdGet(
        galleryId: galleryId,
        authorization: null,
        xMinusUserMinusId: null,
      ),
    )) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };

    final links = switch (await apiCall(
      () => galleries.getDownloadLinksV1ProofGalleriesGalleryIdDownloadsGet(
        galleryId: galleryId,
        authorization: null,
        xMinusUserMinusId: null,
      ),
    )) {
      Ok(:final value) => value.urls,
      Err(:final failure) => throw failure,
    };

    return DeliveredState(photos: crossGalleryWithLinks(detail.items, links));
  }

  /// Mint a link for one photo, now.
  ///
  /// Download links are signed and short-lived, so anything acting on a
  /// specific photo asks for a fresh one rather than reusing what arrived at
  /// page load - otherwise someone who browsed for a while hands the next
  /// step a URL that has already expired, which is a failure landing right
  /// after they paid. The endpoint allows 20 generations a minute, far more
  /// than hand-paced use.
  Future<String?> freshLinkFor(String assetId) async {
    final galleries = ref.read(proofGalleriesClientProvider);
    final result = await apiCall(
      () => galleries.getDownloadLinksV1ProofGalleriesGalleryIdDownloadsGet(
        galleryId: galleryId,
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    return switch (result) {
      Ok(:final value) => value.urls[assetId] as String?,
      Err() => null,
    };
  }
}
