import 'dart:convert';
import 'dart:io';

/// Which delivered photos this device has already put in its photo library.
///
/// The app cannot look in the library to find out: on iOS it holds the
/// add-only permission, which can write a photo but never read one back. So
/// it remembers what it saved. Deleting a photo from the library afterwards
/// is invisible here, which is why "save all" offers to save them again.
abstract interface class SavedPhotos {
  Future<Set<String>> savedIn(String galleryId);

  Future<void> markSaved(String galleryId, String assetId);
}

/// One small JSON file in the app's support directory: gallery id to the
/// asset ids saved from it. Not the cache directory, which the OS may clear,
/// and not secure storage, since nothing here is secret.
class FileSavedPhotos implements SavedPhotos {
  FileSavedPhotos(this._directory);

  final Future<Directory> Function() _directory;

  /// Read once and shared: two saves arriving before the first read ends
  /// must not each start from their own empty copy.
  Future<Map<String, Set<String>>>? _loaded;

  /// Writes queue behind each other, so two saves finishing together cannot
  /// interleave and drop one.
  Future<void> _writing = Future.value();

  Future<File> _file() async => File('${(await _directory()).path}/saved-photos.json');

  Future<Map<String, Set<String>>> _load() => _loaded ??= _read();

  Future<Map<String, Set<String>>> _read() async {
    var result = <String, Set<String>>{};
    try {
      final file = await _file();
      if (file.existsSync()) {
        final decoded = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        result = {
          for (final MapEntry(:key, :value) in decoded.entries) key: {...(value as List).cast<String>()},
        };
      }
    } on Object {
      // Unreadable is the same as empty: the worst case is saving a photo
      // twice, never skipping one that was not saved.
    }
    return result;
  }

  @override
  Future<Set<String>> savedIn(String galleryId) async => {...?(await _load())[galleryId]};

  @override
  Future<void> markSaved(String galleryId, String assetId) async {
    final all = await _load();
    if (!(all[galleryId] ??= <String>{}).add(assetId)) return;
    final encoded = jsonEncode({for (final MapEntry(:key, :value) in all.entries) key: value.toList()});
    _writing = _writing.then((_) async {
      try {
        final file = await _file();
        await file.parent.create(recursive: true);
        await file.writeAsString(encoded, flush: true);
      } on Object {
        // Not remembering a save only means it may be saved again later.
      }
    });
    await _writing;
  }
}
