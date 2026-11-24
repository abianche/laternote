import 'dart:math';

import 'package:material_ui/material_ui.dart';

import 'knit.dart';

/// Draws [path] as a running stitch: short dashes with gaps.
void drawStitches(
  Canvas canvas,
  Path path,
  Paint paint, {
  double dash = 5,
  double gap = 4,
}) {
  for (final metric in path.computeMetrics()) {
    for (var d = 0.0; d < metric.length; d += dash + gap) {
      canvas.drawPath(
        metric.extractPath(d, min(d + dash, metric.length)),
        paint,
      );
    }
  }
}

Paint stitchPaint(Color color, {double width = 1.6}) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round;

/// A rounded shape with a running stitch [inset] inside its edge, like a
/// sewn patch. [radius] is capped at half the shortest side, so a large
/// radius gives a pill.
class StitchedBorder extends OutlinedBorder {
  const StitchedBorder({
    super.side,
    this.radius = 20,
    this.stitch = const Color(0x00000000),
    this.inset = 6,
  });

  final double radius;
  final Color stitch;
  final double inset;

  RRect _rrect(Rect rect) => RRect.fromRectAndRadius(
    rect,
    Radius.circular(min(radius, rect.shortestSide / 2)),
  );

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.strokeInset);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(_rrect(rect).deflate(side.strokeInset));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(_rrect(rect));

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style != BorderStyle.none && side.width > 0) {
      canvas.drawRRect(
        _rrect(rect).deflate(side.strokeInset / 2),
        side.toPaint(),
      );
    }
    if (stitch.a > 0 && rect.shortestSide > inset * 3) {
      drawStitches(
        canvas,
        Path()..addRRect(_rrect(rect).deflate(inset)),
        stitchPaint(stitch),
      );
    }
  }

  @override
  StitchedBorder copyWith({BorderSide? side}) => StitchedBorder(
    side: side ?? this.side,
    radius: radius,
    stitch: stitch,
    inset: inset,
  );

  @override
  StitchedBorder scale(double t) => StitchedBorder(
    side: side.scale(t),
    radius: radius * t,
    stitch: stitch,
    inset: inset * t,
  );

  @override
  bool operator ==(Object other) =>
      other is StitchedBorder &&
      other.side == side &&
      other.radius == radius &&
      other.stitch == stitch &&
      other.inset == inset;

  @override
  int get hashCode => Object.hash(side, radius, stitch, inset);
}

/// A stitched pill behind the selected tab, inset from the tab's edges.
class StitchedPill extends Decoration {
  const StitchedPill({
    required this.color,
    required this.outline,
    required this.stitch,
  });

  final Color color;
  final Color outline;
  final Color stitch;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _PillPainter(this);

  @override
  bool operator ==(Object other) =>
      other is StitchedPill &&
      other.color == color &&
      other.outline == outline &&
      other.stitch == stitch;

  @override
  int get hashCode => Object.hash(color, outline, stitch);
}

class _PillPainter extends BoxPainter {
  _PillPainter(this.pill);

  final StitchedPill pill;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size == null) return;
    final rect = (offset & size).deflate(6);
    final border = StitchedBorder(
      side: BorderSide(color: pill.outline, width: 2),
      radius: 999,
      stitch: pill.stitch,
      inset: 4.5,
    );
    canvas.drawPath(border.getOuterPath(rect), Paint()..color = pill.color);
    border.paint(canvas, rect);
  }
}

/// A knitted wool texture behind [child].
class Woven extends StatelessWidget {
  const Woven({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _WeavePainter(Knit.of(context).weave),
    child: child,
  );
}

class _WeavePainter extends CustomPainter {
  const _WeavePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final warp = Paint()
      ..color = color
      ..strokeWidth = 2;
    final weft = Paint()
      ..color = color.withValues(alpha: color.a * 0.7)
      ..strokeWidth = 2;
    for (var x = 1.0; x < size.width; x += 9) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), warp);
    }
    for (var y = 1.0; y < size.height; y += 9) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), weft);
    }
  }

  @override
  bool shouldRepaint(_WeavePainter old) => old.color != color;
}
