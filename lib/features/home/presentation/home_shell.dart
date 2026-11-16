import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';

/// Minimal signed-in landing page. The inbox feature lands in
/// later MVP issues; this screen exists so sign-in has somewhere to go.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laternote'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Account',
            onPressed: () => context.go(Routes.account),
          ),
        ],
      ),
      body: const Center(child: Text("You're signed in.")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(Routes.compose),
        icon: const Icon(Icons.edit_outlined),
        label: const Text('New message'),
      ),
    );
  }
}
