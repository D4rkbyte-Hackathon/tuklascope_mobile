import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/theme_provider.dart'; // The state notifier
import 'core/theme/app_theme.dart';      // <-- ADDED: The actual color palettes we made

import 'features/auth/presentation/widgets/auth_gate.dart';

Future<void> main() async {
  // 1. Ensure Flutter bindings are initialized before calling native code
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load our secret environment variables
  await dotenv.load(fileName: ".env");

  // 3. Initialize the Supabase connection
  // Session persistence is automatic - tokens are stored in secure storage
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
    // 1. Wrap MaterialApp with ValueListenableBuilder
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'Tuklascope',
          debugShowCheckedModeBanner: false, // Optional: Removes the red debug banner
          
          // 2. Hook up the AppTheme we made in Step 1
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          
          // 3. Bind the active theme mode to our global notifier
          themeMode: currentMode, 
          
          // App strictly starts at the Splash Screen/Auth Gate now
          home: const AuthGate(),
        );
      },
    );
  }
}