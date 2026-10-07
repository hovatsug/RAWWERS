import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delivery_photo_picker.g.dart';

/// One photo chosen for delivery, ready to be streamed.
class DeliveryPickedFile {
  const DeliveryPickedFile({required this.name, required this.size, required this.open, this.openRange, this.path});

  final String name;
  final int size;

  /// A fresh stream each call: an upload that retries has to start from the
  /// beginning of the file, not from wherever the last attempt got to.
  final Stream<Uint8List> Function() open;

  /// Bytes [start, end) of the file, so a large one can be sent a part at a
  /// time. Null where the source cannot read a range; the uploader then
  /// reads past the start of [open] instead.
  final Stream<Uint8List> Function(int start, int end)? openRange;

  /// Where the file is on this phone, for an instant preview while it
  /// uploads. Null in tests and wherever the source has no path.
  final String? path;
}

/// The one place the app opens the photo library for proof uploads.
///
/// A seam for the same reason the payment sheet and the gear picker are
/// one: the picker is a platform singleton that cannot run in a test, so a
/// flow that called it directly could only be checked by hand - which, for
/// this exact flow, is how a real batch upload going on to drop every photo
/// on the floor went unnoticed until a photographer hit it on a real device.
abstract interface class DeliveryPhotoPicker {
  Future<List<DeliveryPickedFile>> pickMultiple();
}

class SystemDeliveryPhotoPicker implements DeliveryPhotoPicker {
  const SystemDeliveryPhotoPicker();

  @override
  Future<List<DeliveryPickedFile>> pickMultiple() async {
    final files = await ImagePicker().pickMultiImage();
    final picked = <DeliveryPickedFile>[];
    for (final file in files) {
      picked.add(
        DeliveryPickedFile(
          name: file.name,
          size: await file.length(),
          open: () => File(file.path).openRead().map(Uint8List.fromList),
          openRange: (start, end) => File(file.path).openRead(start, end).map(Uint8List.fromList),
          path: file.path,
        ),
      );
    }
    return picked;
  }
}

@Riverpod(keepAlive: true)
DeliveryPhotoPicker deliveryPhotoPicker(Ref ref) => const SystemDeliveryPhotoPicker();
