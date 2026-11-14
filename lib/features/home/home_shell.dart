import 'package:flutter/material.dart';

import '../account/account_screen.dart';

/// Minimal signed-in landing page. The inbox/compose features land in
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
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AccountScreen()),
            ),
          ),
        ],
      ),
      body: const Center(child: Text("You're signed in.")),
    );
  }
}
