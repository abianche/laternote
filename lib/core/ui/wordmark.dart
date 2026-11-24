import 'package:material_ui/material_ui.dart';

import 'knit.dart';

/// "Laternote" in the wordmark style.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.size = 26});

  final double size;

  @override
  Widget build(BuildContext context) => Text(
    'Laternote',
    style: Knit.of(context).wordmark.copyWith(fontSize: size),
  );
}
