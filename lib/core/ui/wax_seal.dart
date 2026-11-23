import 'dart:math';

import 'package:material_ui/material_ui.dart';

import 'stationery.dart';

/// A pressed wax seal with an embossed "L". [crack] (0–1) splits it in two,
/// as when a letter is opened; [glow] (0–1) gives it a warm halo.
class WaxSeal extends StatelessWidget {
  const WaxSeal({
    super.key,
    this.size = 48,
    this.crack = 0,
    this.glow = 0,
    this.semanticLabel,
  });

  final double size;
  final double crack;
  final double glow;

  /// Read by screen readers; without it the seal is decorative.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final seal = CustomPaint(
      size: Size.square(size),
      painter: WaxSealPainter(Stationery.of(context), crack: crack, glow: glow),
    );
    final label = semanticLabel;
    return label == null
        ? ExcludeSemantics(child: seal)
        : Semantics(label: label, image: true, child: seal);
  }
}

class WaxSealPainter extends CustomPainter {
  const WaxSealPainter(this.stationery, {this.crack = 0, this.glow = 0});

  final Stationery stationery;
  final double crack;
  final double glow;

  @override
  void paint(Canvas canvas, Size size) => paintWaxSeal(
    canvas,
    size.center(Offset.zero),
    size.shortestSide * 0.45,
    stationery,
    crack: crack,
    glow: glow,
  );

  @override
  bool shouldRepaint(WaxSealPainter old) =>
      old.stationery != stationery || old.crack != crack || old.glow != glow;
}

/// Paints a seal of [radius] around [center]; shared with `Envelope`.
void paintWaxSeal(
  Canvas canvas,
  Offset center,
  double radius,
  Stationery s, {
  double crack = 0,
  double glow = 0,
}) {
  if (glow > 0) {
    canvas.drawCircle(
      center,
      radius * 1.2,
      Paint()
        ..color = s.glow.withValues(alpha: 0.6 * glow)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.4),
    );
  }
  if (crack <= 0) {
    _paintWhole(canvas, center, radius, s);
    return;
  }
  // A jagged crack top to bottom; each half drifts apart and tilts.
  final crackLine = <Offset>[
    for (var i = 0; i <= 6; i++)
      center +
          Offset(
            (i.isEven ? -0.06 : 0.1) * radius,
            (-1.3 + i * 2.6 / 6) * radius,
          ),
  ];
  final far = radius * 2;
  for (final side in [-1.0, 1.0]) {
    final region = Path()
      ..addPolygon([
        center + Offset(side * far, -far),
        ...crackLine,
        center + Offset(side * far, far),
      ], true);
    final gap = crack * radius * 0.22;
    canvas
      ..save()
      ..translate(side * gap, gap * 0.35 * side)
      ..translate(center.dx, center.dy)
      ..rotate(side * crack * 0.15)
      ..translate(-center.dx, -center.dy)
      ..clipPath(region);
    _paintWhole(canvas, center, radius, s);
    canvas.restore();
  }
}

/// A wax blob: round but uneven, as poured wax is.
Path _blob(Offset c, double r) {
  final path = Path();
  const steps = 90;
  for (var i = 0; i <= steps; i++) {
    final t = i / steps * 2 * pi;
    final k =
        1 +
        0.045 * sin(7 * t + 1) +
        0.03 * sin(11 * t + 2.3) +
        0.02 * sin(3 * t + 0.4);
    final p = c + Offset(cos(t), sin(t)) * r * k;
    i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
  }
  return path..close();
}

void _paintWhole(Canvas canvas, Offset c, double r, Stationery s) {
  final blob = _blob(c, r);
  canvas
    ..drawShadow(blob, const Color(0xFF000000), r * 0.1, false)
    ..drawPath(
      blob,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          colors: [s.waxLight, s.wax, s.waxDeep],
          stops: const [0, 0.55, 1],
        ).createShader(Rect.fromCircle(center: c, radius: r * 1.1)),
    );
  // The pressed disc is lit from the opposite side to the rim.
  final disc = r * 0.7;
  canvas
    ..drawCircle(
      c,
      disc,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.4, 0.45),
          colors: [s.waxLight, s.wax, s.waxDeep],
          stops: const [0, 0.6, 1],
        ).createShader(Rect.fromCircle(center: c, radius: disc)),
    )
    ..drawCircle(
      c,
      disc,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.05
        ..color = s.waxDeep.withValues(alpha: 0.7),
    );
  // Embossed monogram: a lit edge just below the dark letter.
  for (final (offset, color) in [
    (Offset(r * 0.04, r * 0.05), s.waxLight),
    (Offset.zero, s.waxDeep),
  ]) {
    final monogram = TextPainter(
      text: TextSpan(
        text: 'L',
        style: s.wordmark.copyWith(fontSize: r * 0.95, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    monogram.paint(
      canvas,
      c + offset - Offset(monogram.width / 2, monogram.height / 2),
    );
    monogram.dispose();
  }
}
