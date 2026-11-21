import 'package:material_ui/material_ui.dart';

/// Fills the viewport while staying scrollable, so pull-to-refresh works
/// without a list.
class FillScroll extends StatelessWidget {
  const FillScroll({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(height: constraints.maxHeight, child: child),
      ),
    );
  }
}

/// Centered message for a list's loading, empty and error states.
class ListNotice extends StatelessWidget {
  const ListNotice({
    super.key,
    required this.text,
    this.icon,
    this.progress = false,
    this.action,
  });

  final String text;
  final IconData? icon;
  final bool progress;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (progress) const CircularProgressIndicator(),
            if (icon case final icon?) Icon(icon, size: 48),
            const SizedBox(height: 16),
            Text(text, textAlign: TextAlign.center),
            ?action,
          ],
        ),
      ),
    );
  }
}
