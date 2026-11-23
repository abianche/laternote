import 'package:material_ui/material_ui.dart';

import 'stationery.dart';

/// "Laternote" in the wordmark style.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.size = 26});

  final double size;

  @override
  Widget build(BuildContext context) => Text(
    'Laternote',
    style: Stationery.of(context).wordmark.copyWith(fontSize: size),
  );
}
