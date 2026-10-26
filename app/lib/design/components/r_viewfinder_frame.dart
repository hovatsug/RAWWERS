import 'package:flutter/material.dart';
import 'package:rawwers/design/tokens.dart';

/// Four corner brackets, as in a camera's viewfinder, around the one number
/// a screen is about - the withdrawable amount, a booking's price. One per
/// screen at most: framing two things says neither matters.
///
/// The brackets are decoration, so a screen reader skips them and hears only
/// the child. Their colour is the accent of wherever they sit: meter700 on
/// paper, meter500 on the dark band.
class RViewfinderFrame extends StatelessWidget {
  const RViewfinderFrame({required this.child, this.color, this.gap = RSpace.s12, super.key});

  final Widget child;
  final Color? color;

  /// Space between the brackets and the child.
  final double gap;

  static const bracketsKey = ValueKey('viewfinder-brackets');

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(padding: EdgeInsets.all(gap), child: child),
        Positioned.fill(
          child: ExcludeSemantics(
            child: CustomPaint(
              key: bracketsKey,
              painter: ViewfinderPainter(
                color: color ?? Theme.of(context).colorScheme.primary,
                arm: RMotif.bracketArm,
                stroke: RMotif.bracketStroke,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ViewfinderPainter extends CustomPainter {
  const ViewfinderPainter({required this.color, required this.arm, required this.stroke});

  final Color color;
  final double arm;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    final h = stroke / 2;
    final w = size.width, ht = size.height;
    final a = arm.clamp(0.0, size.shortestSide / 2);
    for (final (x, y, dx, dy) in [(h, h, 1.0, 1.0), (w - h, h, -1.0, 1.0), (h, ht - h, 1.0, -1.0), (w - h, ht - h, -1.0, -1.0)]) {
      final path = Path()
        ..moveTo(x, y + dy * a)
        ..lineTo(x, y)
        ..lineTo(x + dx * a, y);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(ViewfinderPainter old) => old.color != color || old.arm != arm || old.stroke != stroke;
}
