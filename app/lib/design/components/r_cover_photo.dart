import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:rawwers/design/components/r_network_photo.dart';

/// How far down a portrait photo the crop is centred: the upper-third line.
///
/// A frame wider than the photo (a 3:2 card, a 1.4:1 profile header, a square
/// tile) shows only a band of a portrait's height. Cut from the middle, that
/// band holds a person's chest and loses the head; people in portraits sit in
/// the upper third. The band is centred on the line one third of the way
/// down the photo, and never runs past the top edge.
const double portraitFocusLine = 1 / 3;

/// Where a frame filled from [photoWidth] x [photoHeight] is cut.
///
/// Only a portrait (taller than wide) leans up. A landscape or square photo,
/// a photo whose size the server did not send (an older server, or a photo
/// whose size was never recorded), or a frame that shows the whole height,
/// is cut from the centre, as before.
Alignment coverAlignment({required int? photoWidth, required int? photoHeight, required Size frame}) {
  final w = photoWidth ?? 0;
  final h = photoHeight ?? 0;
  if (w <= 0 || h <= 0 || h <= w || !frame.width.isFinite || !frame.height.isFinite || frame.width <= 0 || frame.height <= 0) {
    return Alignment.center;
  }
  // BoxFit.cover: the photo is scaled to fill, so the shown share of its
  // height is the frame's height over the scaled photo's height.
  final scale = math.max(frame.width / w, frame.height / h);
  final shown = frame.height / (h * scale);
  if (shown >= 1) return Alignment.center;
  final spare = 1 - shown;
  final top = (portraitFocusLine - shown / 2).clamp(0.0, spare);
  return Alignment(0, 2 * top / spare - 1);
}

/// A cover photo filling its frame, with a portrait's crop leaned up
/// ([coverAlignment]). Everything else is [RNetworkPhoto]: the disk cache,
/// loading as it scrolls into view, and the quiet placeholder.
class RCoverPhoto extends StatelessWidget {
  const RCoverPhoto({
    required this.url,
    required this.photoWidth,
    required this.photoHeight,
    this.semanticLabel,
    super.key,
  });

  final String? url;
  final int? photoWidth;
  final int? photoHeight;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => RNetworkPhoto(
        url: url,
        alignment: coverAlignment(
          photoWidth: photoWidth,
          photoHeight: photoHeight,
          frame: constraints.biggest,
        ),
        semanticLabel: semanticLabel,
      ),
    );
  }
}
