import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gal/gal.dart';

/// Why a photo did not reach the device. Each one is something the person
/// can act on differently, so each gets its own words rather than a shared
/// "something went wrong".
enum SaveFailure {
  /// No signed link could be had for the photo - the API was unreachable, or
  /// refused, or the link was no longer valid when storage was asked for it.
  linkUnavailable,

  /// The OS said no to adding to the photo library.
  permissionDenied,

  /// The download itself failed part way.
  network,

  notEnoughSpace,

  /// The file arrived but the photo library would not take it.
  storage;

  String get message => switch (this) {
        linkUnavailable => "Couldn't get this photo from RAWWERS. Check your connection and try again.",
        permissionDenied => 'RAWWERS needs permission to add photos. You can allow it in Settings.',
        network => 'The download was interrupted. Check your connection and try again.',
        notEnoughSpace => "There isn't enough space on this device to save the photo.",
        storage => "The photo downloaded but couldn't be added to your library. Try again.",
      };
}

sealed class SaveOutcome {
  const SaveOutcome();
}

final class Saved extends SaveOutcome {
  const Saved();
}

final class SaveFailed extends SaveOutcome {
  const SaveFailed(this.reason);

  final SaveFailure reason;
}

/// The device's photo library. An interface so the saver's error handling
/// can be tested without a platform channel behind it.
abstract interface class PhotoLibrary {
  /// Whether the app may add to the library, asking if it has not yet.
  Future<bool> ensureAccess();

  /// Throws [GalException] on failure, which [PhotoSaver] translates.
  Future<void> putImage(String path);
}

class GalPhotoLibrary implements PhotoLibrary {
  const GalPhotoLibrary();

  // `toAlbum: false` is the add-only permission on iOS: the app can put a
  // photo in the library without being able to read what is already there.
  @override
  Future<bool> ensureAccess() async =>
      await Gal.hasAccess() || await Gal.requestAccess();

  @override
  Future<void> putImage(String path) => Gal.putImage(path);
}

/// Puts one photo from a signed storage URL into the device's photo library.
///
/// One file per call, on purpose: saving several photos, or all of them,
/// should call this in turn rather than grow a second path. A server-built
/// archive, when there is one, is a different thing - a file to hand to the
/// OS, not photos for the library - and would sit beside this, not replace it.
class PhotoSaver {
  PhotoSaver({
    required Dio storageDio,
    required PhotoLibrary library,
    required Future<Directory> Function() tempDirectory,
  })  : _storageDio = storageDio,
        _library = library,
        _tempDirectory = tempDirectory;

  /// Bare, like the upload's: a signed URL authenticates through its query
  /// string, and our Authorization header on top would be rejected by
  /// storage as a second auth method - and would leak the session to it.
  final Dio _storageDio;
  final PhotoLibrary _library;
  final Future<Directory> Function() _tempDirectory;

  /// [name] becomes the file name, without extension. [onProgress] gets
  /// 0.0-1.0 while downloading, and nothing when storage sends no length.
  Future<SaveOutcome> save(
    String url, {
    required String name,
    void Function(double fraction)? onProgress,
  }) async {
    // Ask first: finding out after a full-resolution download that the
    // answer is no wastes the person's data and their wait.
    if (!await _library.ensureAccess()) {
      return const SaveFailed(SaveFailure.permissionDenied);
    }

    final File file;
    try {
      file = File('${(await _tempDirectory()).path}/$name${_extensionOf(url)}');
    } on Object {
      return const SaveFailed(SaveFailure.storage);
    }

    try {
      try {
        await _storageDio.download(
          url,
          file.path,
          onReceiveProgress: (received, total) {
            if (total > 0) onProgress?.call(received / total);
          },
        );
      } on DioException catch (e) {
        // Storage answering 403/404 means the link, not the connection: an
        // expired signature or an object that is gone.
        final status = e.response?.statusCode;
        return SaveFailed(
          status == 403 || status == 404 ? SaveFailure.linkUnavailable : SaveFailure.network,
        );
      }

      try {
        await _library.putImage(file.path);
      } on GalException catch (e) {
        return SaveFailed(switch (e.type) {
          GalExceptionType.accessDenied => SaveFailure.permissionDenied,
          GalExceptionType.notEnoughSpace => SaveFailure.notEnoughSpace,
          GalExceptionType.notSupportedFormat || GalExceptionType.unexpected => SaveFailure.storage,
        });
      } on Object {
        return const SaveFailed(SaveFailure.storage);
      }
      return const Saved();
    } finally {
      // The library keeps its own copy; ours would only fill the cache.
      try {
        if (file.existsSync()) file.deleteSync();
      } on Object {
        // A leftover temp file is the OS's to clear, not a failed save.
      }
    }
  }

  /// The photo library picks the decoder from the extension, so the temp
  /// file needs the real one. Signed URLs carry it in the object key.
  static String _extensionOf(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
    for (final ext in const ['.jpg', '.jpeg', '.png', '.heic', '.heif', '.webp', '.tif', '.tiff']) {
      if (path.endsWith(ext)) return ext;
    }
    return '.jpg';
  }
}
