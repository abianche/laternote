import 'dart:math';

import 'package:material_ui/material_ui.dart';

import 'knit.dart';

/// A big sewn-on button that keeps a letter shut. [undone] (0–1) snips the
/// thread and lets it hang loose, as when a letter is opened; [glow] (0–1)
/// gives it a warm halo.
class ButtonSeal extends StatelessWidget {
  const ButtonSeal({
    super.key,
    this.size = 48,
    this.undone = 0,
    this.glow = 0,
    this.semanticLabel,
  });

  /// The button's radius as a share of [size]; the rest is shadow room.
  static const radiusFactor = 0.4;

  final double size;
  final double undone;
  final double glow;

  /// Read by screen readers; without it the button is decorative.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final button = CustomPaint(
      size: Size.square(size),
      painter: ButtonSealPainter(Knit.of(context), undone: undone, glow: glow),
    );
    final label = semanticLabel;
    return label == null
        ? ExcludeSemantics(child: button)
        : Semantics(label: label, image: true, child: button);
  }
}

class ButtonSealPainter extends CustomPainter {
  const ButtonSealPainter(this.knit, {this.undone = 0, this.glow = 0});

  final Knit knit;
  final double undone;
  final double glow;

  @override
  void paint(Canvas canvas, Size size) => paintButtonSeal(
    canvas,
    size.center(Offset.zero),
    size.shortestSide * ButtonSeal.radiusFactor,
    knit,
    undone: undone,
    glow: glow,
  );

  @override
  bool shouldRepaint(ButtonSealPainter old) =>
      old.knit != knit || old.undone != undone || old.glow != glow;
}

/// Paints a button of [radius] sewn on at [center]; shared with `Envelope`.
void paintButtonSeal(
  Canvas canvas,
  Offset center,
  double radius,
  Knit k, {
  double undone = 0,
  double glow = 0,
}) {
  final r = radius;
  if (glow > 0) {
    canvas.drawCircle(
      center,
      r * 1.35,
      Paint()
        ..color = k.glow.withValues(alpha: 0.7 * glow)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.45),
    );
  }

  // Undone, the button tips off its spot, hanging by a loose thread.
  final loose = Curves.easeOut.transform(undone.clamp(0, 1));
  final c = center + Offset(r * 0.35, r * 0.55) * loose;
  if (loose > 0) {
    final dangle = Path()
      ..moveTo(center.dx, center.dy)
      ..quadraticBezierTo(
        center.dx - r * 0.5 * loose,
        c.dy + r * 0.4,
        c.dx,
        c.dy,
      );
    canvas
      ..drawPath(dangle, _line(k.outline, r * 0.13))
      ..drawPath(dangle, _line(k.thread, r * 0.07));
  }

  canvas
    ..save()
    ..translate(c.dx, c.dy)
    ..rotate(0.7 * loose)
    ..translate(-c.dx, -c.dy);

  final disc = Path()..addOval(Rect.fromCircle(center: c, radius: r));
  canvas
    ..drawShadow(
      disc,
      const Color(0xFF000000),
      r * (0.12 + 0.18 * loose),
      false,
    )
    ..drawPath(
      disc,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          colors: [k.buttonLight, k.button, k.buttonDeep],
          stops: const [0, 0.6, 1],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    )
    ..drawCircle(
      c,
      r * 0.72,
      _line(k.buttonDeep.withValues(alpha: 0.6), r * 0.07),
    )
    ..drawPath(disc, _line(k.outline, max(1.2, r * 0.08)));

  // Four holes, and a cross-stitch through them that snips as it comes
  // undone: first one stroke, then the other. Thin and in soft thread, so it
  // doesn't read as a "close" icon.
  final d = r * 0.24;
  final holes = [
    c + Offset(-d, -d),
    c + Offset(d, d),
    c + Offset(d, -d),
    c + Offset(-d, d),
  ];
  final hole = Paint()..color = Color.lerp(k.buttonDeep, k.outline, 0.5)!;
  for (final h in holes) {
    canvas.drawCircle(h, r * 0.12, hole);
  }
  for (final (i, alpha) in [
    (0, 1 - undone / 0.35),
    (2, 1 - (undone - 0.3) / 0.35),
  ]) {
    final a = alpha.clamp(0.0, 1.0);
    if (a == 0) continue;
    canvas.drawLine(
      holes[i],
      holes[i + 1],
      _line(k.thread.withValues(alpha: 0.9 * a), r * 0.075),
    );
  }
  canvas.restore();
}

Paint _line(Color color, double width) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round;
