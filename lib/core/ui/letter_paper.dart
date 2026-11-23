import 'package:material_ui/material_ui.dart';

import 'stationery.dart';

/// A sheet of ruled letter paper with a margin line. Rules are spaced to
/// [Stationery.letter]'s line height, so a child in that style writes on
/// them when it starts at [padding]'s top.
class LetterPaper extends StatelessWidget {
  const LetterPaper({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(44, 20, 20, 24),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final s = Stationery.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: s.paper,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F5C4A2A),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _RulesPainter(
          rule: s.rule,
          margin: s.margin,
          top: padding.top,
          lineHeight: s.letter.fontSize! * s.letter.height!,
          marginX: padding.left - 14,
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class _RulesPainter extends CustomPainter {
  const _RulesPainter({
    required this.rule,
    required this.margin,
    required this.top,
    required this.lineHeight,
    required this.marginX,
  });

  final Color rule;
  final Color margin;
  final double top;
  final double lineHeight;
  final double marginX;

  @override
  void paint(Canvas canvas, Size size) {
    final pen = Paint()..color = rule;
    // Just under each line's baseline.
    for (
      var y = top + lineHeight * 0.82;
      y < size.height - 6;
      y += lineHeight
    ) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), pen);
    }
    canvas.drawLine(
      Offset(marginX, 0),
      Offset(marginX, size.height),
      Paint()..color = margin,
    );
  }

  @override
  bool shouldRepaint(_RulesPainter old) =>
      old.rule != rule ||
      old.margin != margin ||
      old.top != top ||
      old.lineHeight != lineHeight ||
      old.marginX != marginX;
}
