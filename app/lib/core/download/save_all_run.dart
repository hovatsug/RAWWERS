import 'package:rawwers/core/download/photo_saver.dart';
import 'package:rawwers/core/download/saved_photos.dart';

/// How a "save all" ended.
class SaveAllResult {
  const SaveAllResult({
    required this.total,
    required this.saved,
    required this.skipped,
    required this.failed,
    this.cancelled = false,
    this.stoppedBy,
  });

  final int total;

  /// Saved by this run.
  final int saved;

  /// Already saved on this device before, so not downloaded again.
  final int skipped;

  /// The 1-based positions in the gallery of the photos that could not be
  /// saved, after one retry each.
  final List<int> failed;

  /// The person stopped it. The photos after that point were not tried.
  final bool cancelled;

  /// A failure no other photo could get past - the library refusing, the
  /// device full, no links at all - so the run stopped there. Null when it
  /// went through to the end or was cancelled.
  final SaveFailure? stoppedBy;

  /// How many photos the run reached, whatever happened to them.
  int get reached => saved + skipped + failed.length;

  bool get allAlreadySaved => skipped == total && total > 0;
}

/// Saves every photo of a gallery to the device, one at a time.
///
/// One at a time on purpose: each photo is a full-resolution original,
/// downloaded to a temporary file and handed to the library before the next
/// starts, so a gallery of hundreds never holds more than one in memory or on
/// disk, and the phone's connection is not split between several downloads
/// that would each take longer to fail.
///
/// The links come from the downloads endpoint, which answers for the whole
/// gallery in one call and only for what the client may download - so this
/// asks permission of nobody but the server, and whatever rule the server
/// applies to downloading applies here too. Links are signed for ten minutes
/// (FINALS_DOWNLOAD_URL_TTL_SECONDS); the set is fetched again when it is
/// older than [linkMaxAge], and before retrying a photo that failed, but not
/// more often than [minRefreshGap], so a run of failures cannot reach the
/// endpoint's limit of 20 a minute.
class SaveAllRun {
  SaveAllRun({
    required this.galleryId,
    required this.assetIds,
    required this.fetchLinks,
    required this.save,
    required this.savedPhotos,
    DateTime Function()? now,
    this.linkMaxAge = const Duration(minutes: 5),
    this.minRefreshGap = const Duration(seconds: 30),
  }) : _now = now ?? DateTime.now;

  final String galleryId;

  /// In gallery order.
  final List<String> assetIds;

  /// Every link the server will give now, by asset id; null if it would not
  /// answer.
  final Future<Map<String, String>?> Function() fetchLinks;

  final Future<SaveOutcome> Function(String url, String assetId) save;
  final SavedPhotos savedPhotos;
  final DateTime Function() _now;
  final Duration linkMaxAge;
  final Duration minRefreshGap;

  bool _cancelled = false;

  /// Stops after the photo being saved now. Its download is not cut short:
  /// half a file is of no use, and it is seconds away from being in the
  /// library.
  void cancel() => _cancelled = true;

  Map<String, String> _links = const {};
  DateTime? _linksAt;

  Future<bool> _refreshLinks() async {
    final links = await fetchLinks();
    if (links == null) return false;
    _links = links;
    _linksAt = _now();
    return true;
  }

  bool _olderThan(Duration age) => _linksAt == null || _now().difference(_linksAt!) > age;

  Future<SaveOutcome> _attempt(String assetId) async {
    final url = _links[assetId];
    if (url == null || url.isEmpty) return const SaveFailed(SaveFailure.linkUnavailable);
    return save(url, assetId);
  }

  /// [onProgress] gets how many photos have been dealt with so far and the
  /// total, before each photo and once at the end. With [includeSaved] the
  /// photos this device already saved are saved again.
  Future<SaveAllResult> run({bool includeSaved = false, void Function(int reached, int total)? onProgress}) async {
    final total = assetIds.length;
    final already = includeSaved ? const <String>{} : await savedPhotos.savedIn(galleryId);
    var saved = 0;
    var skipped = 0;
    final failed = <int>[];

    SaveAllResult result({bool cancelled = false, SaveFailure? stoppedBy}) => SaveAllResult(
      total: total,
      saved: saved,
      skipped: skipped,
      failed: List.unmodifiable(failed),
      cancelled: cancelled,
      stoppedBy: stoppedBy,
    );

    for (var i = 0; i < total; i++) {
      if (_cancelled) return result(cancelled: true);
      onProgress?.call(i, total);
      final assetId = assetIds[i];
      if (already.contains(assetId)) {
        skipped++;
        continue;
      }

      if (_olderThan(linkMaxAge) && !await _refreshLinks() && _linksAt == null) {
        // Never had a single link: the server is unreachable or will not let
        // these be downloaded. Every photo would fail the same way.
        return result(stoppedBy: SaveFailure.linkUnavailable);
      }

      var outcome = await _attempt(assetId);
      if (outcome case SaveFailed(:final reason) when _worthRetrying(reason)) {
        if (_olderThan(minRefreshGap)) await _refreshLinks();
        outcome = await _attempt(assetId);
      }

      switch (outcome) {
        case Saved():
          saved++;
          await savedPhotos.markSaved(galleryId, assetId);
        case SaveFailed(reason: SaveFailure.permissionDenied):
          return result(stoppedBy: SaveFailure.permissionDenied);
        case SaveFailed(reason: SaveFailure.notEnoughSpace):
          failed.add(i + 1);
          return result(stoppedBy: SaveFailure.notEnoughSpace);
        case SaveFailed():
          failed.add(i + 1);
      }
    }
    onProgress?.call(total, total);
    return result();
  }

  /// A failure that a second try can fix: an expired link, a dropped
  /// connection, a library that refused one file. Permission and space are
  /// not, and stop the run instead.
  static bool _worthRetrying(SaveFailure reason) => switch (reason) {
    SaveFailure.linkUnavailable || SaveFailure.network || SaveFailure.storage => true,
    SaveFailure.permissionDenied || SaveFailure.notEnoughSpace => false,
  };
}
