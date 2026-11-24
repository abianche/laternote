import 'package:material_ui/material_ui.dart';

import 'knit.dart';
import 'stitches.dart';

/// A sewn-on fabric patch showing [date]'s day and year, or "?" before a
/// date is chosen. Decorative: the date is always written out nearby.
class DatePatch extends StatelessWidget {
  const DatePatch({super.key, required this.date, this.size = 76});

  final DateTime? date;
  final double size;

  @override
  Widget build(BuildContext context) {
    final k = Knit.of(context);
    final material = MaterialLocalizations.of(context);
    final date = this.date;
    return ExcludeSemantics(
      child: Transform.rotate(
        angle: -0.08,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: k.patch,
            shape: StitchedBorder(
              side: BorderSide(color: k.outline, width: 2),
              radius: size * 0.22,
              stitch: k.outline.withValues(alpha: 0.6),
              inset: size * 0.09,
            ),
          ),
          child: SizedBox.square(
            dimension: size,
            child: Center(
              child: date == null
                  ? Text(
                      '?',
                      style: k.wordmark.copyWith(
                        fontSize: size * 0.42,
                        color: k.outline,
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          material.formatShortMonthDay(date),
                          style: k.label.copyWith(
                            fontSize: size * 0.16,
                            color: k.outline,
                          ),
                        ),
                        Text(
                          material.formatYear(date),
                          style: fredoka(
                            700,
                            size: size * 0.24,
                            height: 1.05,
                          ).copyWith(color: k.outline),
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
