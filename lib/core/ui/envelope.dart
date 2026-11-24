import 'dart:math';

import 'package:material_ui/material_ui.dart';

import 'button_seal.dart';
import 'knit.dart';
import 'stitches.dart';

/// A felt envelope, drawn. Its height is [width] × [aspect], which includes
/// room above it for the open flap and a rising letter.
class Envelope extends StatelessWidget {
  const Envelope({
    super.key,
    this.width = 64,
    this.flap = 0,
    this.sealed = true,
    this.undone = 0,
    this.glow = 0,
    this.stamped = false,
    this.calm = false,
    this.letter,
    this.semanticLabel,
  });

  static const aspect = _bodyRatio * (1 + _headroom);

  /// Where the button sits on a closed envelope of [width], from its top
  /// left corner, and the button's radius.
  static Offset buttonCenter(double width) =>
      Offset(width / 2, width * _bodyRatio * (_headroom + _tipDepth));
  static double buttonRadius(double width) => width * _bodyRatio * _buttonRatio;

  final double width;

  /// 0 closed, 1 fully open.
  final double flap;

  /// Whether a button holds the flap shut.
  final bool sealed;

  /// How far the button has come undone, 0–1.
  final double undone;

  /// Warm halo around the button, 0–1.
  final double glow;

  /// A little heart patch: the letter was delivered.
  final bool stamped;

  /// Sage felt, for a letter still on its way, instead of warm peach.
  final bool calm;

  /// A letter inside: 0 tucked in, 1 risen out. Null for none.
  final double? letter;

  /// Read by screen readers; without it the envelope is decorative.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final painting = CustomPaint(
      size: Size(width, width * aspect),
      painter: EnvelopePainter(
        Knit.of(context),
        flap: flap,
        sealed: sealed,
        undone: undone,
        glow: glow,
        stamped: stamped,
        calm: calm,
        letter: letter,
      ),
    );
    final label = semanticLabel;
    return label == null
        ? ExcludeSemantics(child: painting)
        : Semantics(label: label, image: true, child: painting);
  }
}

const _bodyRatio = 0.64;
const _headroom = 0.55;
const _tipDepth = 0.56;
const _buttonRatio = 0.19;

class EnvelopePainter extends CustomPainter {
  const EnvelopePainter(
    this.k, {
    required this.flap,
    required this.sealed,
    required this.undone,
    required this.glow,
    required this.stamped,
    required this.calm,
    required this.letter,
  });

  final Knit k;
  final double flap;
  final bool sealed;
  final double undone;
  final double glow;
  final bool stamped;
  final bool calm;
  final double? letter;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = w * _bodyRatio;
    final top = h * _headroom;
    final body = Rect.fromLTWH(0, top, w, h);
    final corner = Radius.circular(w / 9);
    final felt = calm ? k.envelopeCalm : k.envelope;
    final inside = Color.lerp(felt, k.outline, 0.18)!;
    final edgeWidth = max(1.3, w / 40);
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = edgeWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = k.outline;
    final seam = stitchPaint(
      k.outline.withValues(alpha: 0.75),
      width: max(1, w / 60),
    );
    final dash = max(2.5, w / 22);
    final apex = Offset(
      w / 2,
      top + h * _tipDepth * cos(pi * flap.clamp(0, 1)),
    );
    final flapOpen = apex.dy < top + h * 0.05;
    Path tri(List<Offset> p) => Path()..addPolygon(p, true);
    final inset = w * 0.06;

    final back = RRect.fromRectAndCorners(
      body,
      bottomLeft: corner,
      bottomRight: corner,
      topLeft: corner / 2,
      topRight: corner / 2,
    );
    canvas.drawRRect(back, Paint()..color = inside);

    final flapPath = tri([body.topLeft, body.topRight, apex]);
    if (flapOpen) {
      canvas
        ..drawPath(flapPath, Paint()..color = inside)
        ..drawPath(flapPath, edge);
    }

    if (letter case final rise?) {
      final sheet = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          w * 0.1,
          top + h * 0.06 - rise * h * 0.95,
          w * 0.8,
          h * 0.9,
        ),
        Radius.circular(w / 30),
      );
      canvas
        ..drawRRect(sheet, Paint()..color = k.fabric)
        ..drawRRect(sheet, edge..strokeWidth = edgeWidth * 0.7);
      edge.strokeWidth = edgeWidth;
      final rule = Paint()
        ..color = k.rule
        ..strokeWidth = max(0.8, w / 150);
      for (var i = 1; i <= 5; i++) {
        final y = sheet.top + sheet.height * i / 6.5;
        canvas.drawLine(
          Offset(sheet.left + sheet.width * 0.1, y),
          Offset(sheet.right - sheet.width * 0.1, y),
          rule,
        );
      }
    }

    // The front pocket, with a stitched V where its folds meet.
    final middle = Offset(w / 2, top + h * 0.5);
    canvas
      ..save()
      ..clipRRect(back)
      ..drawPath(
        tri([
          body.topLeft,
          middle,
          body.topRight,
          body.bottomRight,
          body.bottomLeft,
        ]),
        Paint()..color = felt,
      )
      ..restore();
    if (flapOpen) {
      drawStitches(
        canvas,
        Path()
          ..moveTo(body.left + inset, body.top + inset * 0.8)
          ..lineTo(middle.dx, middle.dy - inset * 0.3)
          ..lineTo(body.right - inset, body.top + inset * 0.8),
        seam,
        dash: dash,
        gap: dash * 0.8,
      );
    }
    canvas.drawRRect(back, edge);

    if (!flapOpen) {
      final lit = Color.lerp(felt, k.fabric, 0.25)!;
      canvas
        ..drawShadow(flapPath, const Color(0xFF000000), w / 70, false)
        ..drawPath(flapPath, Paint()..color = lit)
        ..drawPath(flapPath, edge);
      drawStitches(
        canvas,
        Path()
          ..moveTo(body.left + inset * 1.6, body.top + inset * 0.7)
          ..lineTo(apex.dx, apex.dy - inset * 1.1)
          ..lineTo(body.right - inset * 1.6, body.top + inset * 0.7),
        seam,
        dash: dash,
        gap: dash * 0.8,
      );
    }

    if (stamped) _paintHeart(canvas, body);

    if (sealed) {
      paintButtonSeal(
        canvas,
        apex,
        h * _buttonRatio,
        k,
        undone: undone,
        glow: glow,
      );
    }
  }

  /// A little heart patch in the corner, sewn on at delivery.
  void _paintHeart(Canvas canvas, Rect body) {
    final s = body.height * 0.2;
    final c = Offset(body.left + s * 1.2, body.bottom - s * 1.1);
    final heart = Path()
      ..moveTo(c.dx, c.dy + s * 0.45)
      ..cubicTo(
        c.dx - s * 0.9,
        c.dy - s * 0.1,
        c.dx - s * 0.45,
        c.dy - s * 0.75,
        c.dx,
        c.dy - s * 0.3,
      )
      ..cubicTo(
        c.dx + s * 0.45,
        c.dy - s * 0.75,
        c.dx + s * 0.9,
        c.dy - s * 0.1,
        c.dx,
        c.dy + s * 0.45,
      )
      ..close();
    canvas
      ..drawPath(heart, Paint()..color = k.patch)
      ..drawPath(
        heart,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = max(1, s / 8)
          ..strokeJoin = StrokeJoin.round
          ..color = k.outline,
      );
  }

  @override
  bool shouldRepaint(EnvelopePainter old) =>
      old.k != k ||
      old.flap != flap ||
      old.sealed != sealed ||
      old.undone != undone ||
      old.glow != glow ||
      old.stamped != stamped ||
      old.calm != calm ||
      old.letter != letter;
}
