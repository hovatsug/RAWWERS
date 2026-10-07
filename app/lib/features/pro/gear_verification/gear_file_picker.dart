import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gear_file_picker.g.dart';

/// A camera file the photographer chose, ready to be streamed.
class PickedGearFile {
  const PickedGearFile({required this.name, required this.size, required this.open, this.openRange});

  final String name;
  final int size;

  /// A fresh stream each call: an upload that retries has to start from the
  /// beginning of the file, not from wherever the last attempt got to.
  final Stream<Uint8List> Function() open;

  /// Bytes [start, end), so a 16-58 MB RAW can be sent a part at a time and
  /// resumed. Null when the platform gave no file path.
  final Stream<Uint8List> Function(int start, int end)? openRange;

  String get extension {
    final dot = name.lastIndexOf('.');
    return dot < 0 ? '' : name.substring(dot + 1).toLowerCase();
  }
}

/// The one place the app opens the system file picker for gear evidence.
///
/// A seam for the same reason the payment sheet is one: the picker is a
/// platform singleton that cannot run in a test, so a flow that called it
/// directly could only be checked by hand.
abstract interface class GearFilePicker {
  /// Null when the person backed out.
  Future<PickedGearFile?> pick();
}

class SystemGearFilePicker implements GearFilePicker {
  const SystemGearFilePicker();

  @override
  Future<PickedGearFile?> pick() async {
    // Any type, and the extension checked afterwards. `image_picker` cannot do
    // this job at all - it hands back the photo library's rendition, not the
    // camera's file - and a custom-extension filter depends on the platform
    // knowing every maker's RAW type, which iOS does not.
    final file = await FilePicker.pickFile(type: FileType.any);
    if (file == null) return null;
    final size = file.lengthSync() ?? await file.length() ?? 0;
    final path = file.path;
    return PickedGearFile(
      name: file.name,
      size: size,
      open: file.readAsByteStream,
      openRange: path == null ? null : (start, end) => File(path).openRead(start, end).map(Uint8List.fromList),
    );
  }
}

@Riverpod(keepAlive: true)
GearFilePicker gearFilePicker(Ref ref) => const SystemGearFilePicker();
