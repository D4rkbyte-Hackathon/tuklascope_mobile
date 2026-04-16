import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/auth/presentation/widgets/auth_gate.dart';

Future<void> main() async {
  // 1. Ensure Flutter bindings are initialized before calling native code
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load our secret environment variables
  await dotenv.load(fileName: ".env");

  // 3. Initialize the Supabase connection
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // 4. Wrap the app in a ProviderScope so Riverpod can manage our state globally
  runApp(const ProviderScope(child: TuklascopeApp()));
}

// Now that Riverpod is imported, Dart knows exactly what a ConsumerWidget is.
class TuklascopeApp extends ConsumerWidget {
  const TuklascopeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We removed the authState watcher here so it doesn't interrupt our Compass flow.
    return MaterialApp(
      title: 'Tuklascope',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // App strictly starts at the Splash Screen now
      home: const AuthGate(),
    );
  }
}
