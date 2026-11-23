import 'dart:math';

import 'package:material_ui/material_ui.dart';

import 'stationery.dart';
import 'wax_seal.dart';

/// An envelope, drawn. Its height is [width] × [aspect], which includes room
/// above it for the open flap and a rising letter.
class Envelope extends StatelessWidget {
  const Envelope({
    super.key,
    this.width = 64,
    this.flap = 0,
    this.sealed = true,
    this.crack = 0,
    this.glow = 0,
    this.stamped = false,
    this.letter,
    this.semanticLabel,
  });

  static const aspect = _bodyRatio * (1 + _headroom);

  final double width;

  /// 0 closed, 1 fully open.
  final double flap;

  /// Whether a seal sits on the flap's tip.
  final bool sealed;

  /// How broken the seal is, 0–1.
  final double crack;

  /// Warm halo around the seal, 0–1.
  final double glow;

  /// A postmark: the letter was delivered.
  final bool stamped;

  /// A letter inside: 0 tucked in, 1 risen out. Null for none.
  final double? letter;

  /// Read by screen readers; without it the envelope is decorative.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final painting = CustomPaint(
      size: Size(width, width * aspect),
      painter: EnvelopePainter(
        Stationery.of(context),
        outline: Theme.of(context).colorScheme.outline,
        flap: flap,
        sealed: sealed,
        crack: crack,
        glow: glow,
        stamped: stamped,
        letter: letter,
      ),
    );
    final label = semanticLabel;
    return label == null
        ? ExcludeSemantics(child: painting)
        : Semantics(label: label, image: true, child: painting);
  }
}

const _bodyRatio = 0.62;
const _headroom = 0.55;

class EnvelopePainter extends CustomPainter {
  const EnvelopePainter(
    this.s, {
    required this.outline,
    required this.flap,
    required this.sealed,
    required this.crack,
    required this.glow,
    required this.stamped,
    required this.letter,
  });

  final Stationery s;
  final Color outline;
  final double flap;
  final bool sealed;
  final double crack;
  final double glow;
  final bool stamped;
  final double? letter;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = w * _bodyRatio;
    final top = h * _headroom;
    final body = Rect.fromLTWH(0, top, w, h);
    final apex = Offset(w / 2, top + h * 0.54 * cos(pi * flap.clamp(0, 1)));
    final flapOpen = apex.dy < top;
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(0.8, w / 120)
      ..strokeJoin = StrokeJoin.round
      ..color = outline.withValues(alpha: 0.7);
    final inside = Color.lerp(s.envelope, outline, 0.25)!;
    Path tri(List<Offset> p) => Path()..addPolygon(p, true);

    final back = RRect.fromRectAndRadius(body, Radius.circular(w / 40));
    canvas
      ..drawRRect(back, Paint()..color = inside)
      ..drawRRect(back, edge);

    final flapPath = tri([body.topLeft, body.topRight, apex]);
    if (flapOpen) {
      canvas
        ..drawPath(flapPath, Paint()..color = inside)
        ..drawPath(flapPath, edge);
    }

    if (letter case final rise?) {
      final sheet = Rect.fromLTWH(
        w * 0.08,
        top + h * 0.06 - rise * h * 0.95,
        w * 0.84,
        h * 0.9,
      );
      canvas
        ..drawRect(sheet, Paint()..color = s.paper)
        ..drawRect(sheet, edge);
      final rule = Paint()
        ..color = s.rule
        ..strokeWidth = max(0.6, w / 200);
      for (var i = 1; i <= 5; i++) {
        final y = sheet.top + sheet.height * i / 6.5;
        canvas.drawLine(
          Offset(sheet.left + sheet.width * 0.1, y),
          Offset(sheet.right - sheet.width * 0.08, y),
          rule,
        );
      }
    }

    // The front pocket: two side folds and the bottom fold.
    final middle = Offset(w / 2, top + h * 0.56);
    final front = Paint()..color = s.envelope;
    final shade = Paint()..color = Color.lerp(s.envelope, outline, 0.1)!;
    for (final (path, paint) in [
      (tri([body.topLeft, body.bottomLeft, middle]), shade),
      (tri([body.topRight, body.bottomRight, middle]), shade),
      (tri([body.bottomLeft, body.bottomRight, middle]), front),
    ]) {
      canvas
        ..drawPath(path, paint)
        ..drawPath(path, edge);
    }

    if (!flapOpen) {
      canvas
        ..drawShadow(flapPath, const Color(0xFF000000), w / 80, false)
        ..drawPath(flapPath, Paint()..color = s.envelope)
        ..drawPath(flapPath, edge);
    }

    if (stamped) _paintStamp(canvas, body);

    if (sealed) {
      paintWaxSeal(canvas, apex, h * 0.2, s, crack: crack, glow: glow);
    }
  }

  /// A small cancellation mark: two rings and wavy lines.
  void _paintStamp(Canvas canvas, Rect body) {
    final r = body.height * 0.15;
    final c = Offset(body.right - r * 1.6, body.top + r * 1.6);
    final ink = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(0.7, r / 9)
      ..color = s.postmark.withValues(alpha: 0.75);
    canvas
      ..drawCircle(c, r, ink)
      ..drawCircle(c, r * 0.72, ink);
    for (var line = -1; line <= 1; line++) {
      final wave = Path()..moveTo(c.dx - r * 1.3, c.dy + line * r * 0.45);
      for (var x = 0.0; x <= r * 2.4; x += r / 6) {
        wave.lineTo(
          c.dx - r * 1.3 - x,
          c.dy + line * r * 0.45 + sin(x / r * 4) * r * 0.12,
        );
      }
      canvas.drawPath(wave, ink);
    }
  }

  @override
  bool shouldRepaint(EnvelopePainter old) =>
      old.s != s ||
      old.outline != outline ||
      old.flap != flap ||
      old.sealed != sealed ||
      old.crack != crack ||
      old.glow != glow ||
      old.stamped != stamped ||
      old.letter != letter;
}
