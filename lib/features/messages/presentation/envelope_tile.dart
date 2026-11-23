import 'package:material_ui/material_ui.dart';

import '../../../core/ui/stationery.dart';

/// A message in a list: its envelope, then what is known about it.
class EnvelopeTile extends StatelessWidget {
  const EnvelopeTile({
    super.key,
    required this.envelope,
    required this.title,
    required this.subtitle,
    this.note,
    this.trailing,
    this.onTap,
    this.emphasized = false,
    this.faded = false,
  });

  final Widget envelope;
  final String title;
  final String subtitle;

  /// An extra line under [subtitle], in the letter's ink.
  final String? note;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Bold title, for what hasn't been read.
  final bool emphasized;

  /// Dimmed envelope, for what has been read.
  final bool faded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final note = this.note;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            children: [
              Opacity(opacity: faded ? 0.6 : 1, child: envelope),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: emphasized ? FontWeight.w700 : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (note != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          note,
                          style: Stationery.of(context).letter.copyWith(
                            fontSize: 15,
                            height: 1.3,
                            fontStyle: FontStyle.italic,
                            color: theme.colorScheme.tertiary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// Small-caps header above a group of envelopes.
class EnvelopeGroupHeader extends StatelessWidget {
  const EnvelopeGroupHeader(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
      child: Text(
        text,
        style: Stationery.of(
          context,
        ).smallCaps.copyWith(color: Theme.of(context).colorScheme.secondary),
      ),
    );
  }
}
