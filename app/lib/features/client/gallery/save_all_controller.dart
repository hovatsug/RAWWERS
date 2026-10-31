import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/download/save_all_run.dart';
import 'package:rawwers/features/client/gallery/delivered_controller.dart';

part 'save_all_controller.g.dart';

sealed class SaveAllState {
  const SaveAllState();
}

final class SaveAllIdle extends SaveAllState {
  const SaveAllIdle();
}

final class SaveAllRunning extends SaveAllState {
  const SaveAllRunning({required this.reached, required this.total, this.stopping = false});

  /// Photos dealt with so far; the one being saved is number [reached] + 1.
  final int reached;
  final int total;

  /// Cancel was tapped and the photo in progress is finishing.
  final bool stopping;
}

final class SaveAllDone extends SaveAllState {
  const SaveAllDone(this.result);

  final SaveAllResult result;
}

/// "Save all" for one delivered gallery.
///
/// Kept alive while a run is going, so leaving the screen does not drop it
/// half way: coming back shows where it is. Once it ends it is released with
/// the screen like everything else.
@riverpod
class SaveAllController extends _$SaveAllController {
  SaveAllRun? _run;

  @override
  SaveAllState build(String galleryId) => const SaveAllIdle();

  bool get isRunning => state is SaveAllRunning;

  /// Saves the photos in [assetIds], in that order. [includeSaved] saves the
  /// ones this device saved before as well.
  Future<void> start(List<String> assetIds, {bool includeSaved = false}) async {
    if (isRunning) return;
    final keepAlive = ref.keepAlive();
    final saver = ref.read(photoSaverProvider);
    final delivered = ref.read(deliveredControllerProvider(galleryId).notifier);
    final run = _run = SaveAllRun(
      galleryId: galleryId,
      assetIds: assetIds,
      fetchLinks: delivered.freshLinks,
      save: (url, assetId) => saver.save(url, name: 'RAWWERS-$assetId'),
      savedPhotos: ref.read(savedPhotosProvider),
    );
    state = SaveAllRunning(reached: 0, total: assetIds.length);
    try {
      final result = await run.run(
        includeSaved: includeSaved,
        onProgress: (reached, total) {
          final stopping = switch (state) {
            SaveAllRunning(:final stopping) => stopping,
            _ => false,
          };
          state = SaveAllRunning(reached: reached, total: total, stopping: stopping);
        },
      );
      state = SaveAllDone(result);
    } finally {
      _run = null;
      keepAlive.close();
    }
  }

  void cancel() {
    final current = state;
    if (current is! SaveAllRunning) return;
    _run?.cancel();
    state = SaveAllRunning(reached: current.reached, total: current.total, stopping: true);
  }
}

/// Opens this app's page in iOS Settings, where photo access is changed.
/// A provider so a test can see it was asked for without leaving the app.
@riverpod
Future<bool> Function() openAppSettings(Ref ref) =>
    () => launchUrl(Uri.parse('app-settings:'));
