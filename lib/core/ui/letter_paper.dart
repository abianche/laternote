import 'package:material_ui/material_ui.dart';

import 'knit.dart';
import 'stitches.dart';

/// A soft sheet of ruled letter paper with a stitched edge. Rules are spaced
/// to [Knit.letter]'s line height, so a child in that style writes on them
/// when it starts at [padding]'s top.
class LetterPaper extends StatelessWidget {
  const LetterPaper({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(24, 22, 22, 26),
  });

  final Widget child;
  final EdgeInsets padding;

  static const _radius = 22.0;

  @override
  Widget build(BuildContext context) {
    final k = Knit.of(context);
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: k.fabric,
        shape: StitchedBorder(
          radius: _radius,
          stitch: k.stitchCalm,
          inset: 8,
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x33705030),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _RulesPainter(
          rule: k.rule,
          top: padding.top,
          lineHeight: k.letter.fontSize! * k.letter.height!,
          sideInset: 16,
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class _RulesPainter extends CustomPainter {
  const _RulesPainter({
    required this.rule,
    required this.top,
    required this.lineHeight,
    required this.sideInset,
  });

  final Color rule;
  final double top;
  final double lineHeight;
  final double sideInset;

  @override
  void paint(Canvas canvas, Size size) {
    final pen = Paint()
      ..color = rule
      ..strokeWidth = 1.5;
    // Just under each line's baseline, inside the stitching.
    for (
      var y = top + lineHeight * 0.8;
      y < size.height - 14;
      y += lineHeight
    ) {
      canvas.drawLine(
        Offset(sideInset, y),
        Offset(size.width - sideInset, y),
        pen,
      );
    }
  }

  @override
  bool shouldRepaint(_RulesPainter old) =>
      old.rule != rule ||
      old.top != top ||
      old.lineHeight != lineHeight ||
      old.sideInset != sideInset;
}
