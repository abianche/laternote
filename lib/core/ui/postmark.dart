import 'dart:math';

import 'package:material_ui/material_ui.dart';

import 'stationery.dart';

/// A tilted round postmark showing [date]'s day and year, or "?" before a
/// date is chosen. Decorative: the date is always written out nearby.
class Postmark extends StatelessWidget {
  const Postmark({super.key, required this.date, this.size = 76});

  final DateTime? date;
  final double size;

  @override
  Widget build(BuildContext context) {
    final s = Stationery.of(context);
    final material = MaterialLocalizations.of(context);
    final date = this.date;
    final ink = s.postmark.withValues(alpha: 0.85);
    return ExcludeSemantics(
      child: Transform.rotate(
        angle: -0.14,
        child: CustomPaint(
          painter: _RingsPainter(ink),
          child: SizedBox.square(
            dimension: size,
            child: Center(
              child: date == null
                  ? Text(
                      '?',
                      style: s.wordmark.copyWith(
                        fontSize: size * 0.4,
                        color: ink,
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          material.formatShortMonthDay(date),
                          style: s.smallCaps.copyWith(
                            fontSize: size * 0.14,
                            color: ink,
                          ),
                        ),
                        Text(
                          material.formatYear(date),
                          style: fraunces(
                            700,
                            size: size * 0.2,
                            height: 1.1,
                          ).copyWith(color: ink),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  const _RingsPainter(this.ink);

  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final pen = Paint()
      ..style = PaintingStyle.stroke
      ..color = ink;
    canvas
      ..drawCircle(c, r * 0.96, pen..strokeWidth = max(1.2, r / 22))
      ..drawCircle(c, r * 0.8, pen..strokeWidth = max(0.8, r / 40));
    // Ticks between the rings, like a dated rubber stamp.
    for (var i = 0; i < 36; i++) {
      final a = i * pi / 18;
      final dir = Offset(cos(a), sin(a));
      canvas.drawLine(c + dir * r * 0.84, c + dir * r * 0.9, pen);
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) => old.ink != ink;
}
