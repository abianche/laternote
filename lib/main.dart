import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_environment.dart';
import 'features/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppEnvironment.validate();
  await Supabase.initialize(
    url: AppEnvironment.supabaseUrl,
    publishableKey: AppEnvironment.supabasePublishableKey,
  );
  runApp(const LaternoteApp());
}

class LaternoteApp extends StatelessWidget {
  const LaternoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laternote',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: const AuthGate(),
    );
  }
}
