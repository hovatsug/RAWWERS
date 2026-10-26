import 'package:flutter/material.dart';
import 'package:rawwers/design/tokens.dart';

/// A light meter's exposure scale in place of a plain progress bar: tick
/// marks, a thin fill and a needle at the value. For tier progress, rating
/// and gear credit.
///
/// It never animates - a value is a reading, not an event. A screen reader
/// hears the caller's label ("70 percent to Tier 3") instead of a bare
/// percentage, because the number alone says nothing about what it measures.
class RExposureScale extends StatelessWidget {
  const RExposureScale({required this.value, required this.semanticLabel, this.ticks = RMotif.scaleTicks, super.key});

  /// 0 to 1; anything outside is clamped.
  final double value;
  final String semanticLabel;
  final int ticks;

  static const scaleKey = ValueKey('exposure-scale');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        height: RMotif.scaleTickHeight + RMotif.scaleFill,
        width: double.infinity,
        child: CustomPaint(
          key: scaleKey,
          painter: ExposureScalePainter(
            value: value.clamp(0.0, 1.0),
            ticks: ticks,
            fill: RMotif.scaleFill,
            needle: RMotif.scaleNeedle,
            tickHeight: RMotif.scaleTickHeight,
            accent: scheme.primary,
            track: scheme.outline,
            tick: scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class ExposureScalePainter extends CustomPainter {
  const ExposureScalePainter({
    required this.value,
    required this.ticks,
    required this.fill,
    required this.needle,
    required this.tickHeight,
    required this.accent,
    required this.track,
    required this.tick,
  });

  final double value;
  final int ticks;
  final double fill;
  final double needle;
  final double tickHeight;
  final Color accent;
  final Color track;
  final Color tick;

  @override
  void paint(Canvas canvas, Size size) {
    final bottom = size.height;
    final barTop = bottom - fill;
    // The track, then the fill up to the value.
    canvas.drawRect(Rect.fromLTRB(0, barTop, size.width, bottom), Paint()..color = track);
    canvas.drawRect(Rect.fromLTRB(0, barTop, size.width * value, bottom), Paint()..color = accent);
    // Tick marks above the bar, every 1/ticks; the ends and the middle longer.
    final tickPaint = Paint()
      ..color = tick
      ..strokeWidth = 1;
    for (var i = 0; i <= ticks; i++) {
      final x = (size.width - 1) * i / ticks + 0.5;
      final major = i == 0 || i == ticks || i * 2 == ticks;
      canvas.drawLine(Offset(x, barTop), Offset(x, barTop - (major ? tickHeight : tickHeight / 2)), tickPaint);
    }
    // The needle: through the ticks and the bar, at the value.
    final nx = (size.width * value).clamp(needle / 2, size.width - needle / 2);
    canvas.drawRect(Rect.fromLTRB(nx - needle / 2, 0, nx + needle / 2, bottom), Paint()..color = accent);
  }

  @override
  bool shouldRepaint(ExposureScalePainter old) =>
      old.value != value || old.ticks != ticks || old.accent != accent || old.track != track || old.tick != tick;
}
