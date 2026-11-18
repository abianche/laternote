import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme.dart';

class LaternoteApp extends ConsumerWidget {
  const LaternoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Laternote',
      theme: appTheme,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
