import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// We will import our Auth provider and Login Screen here
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';

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

class TuklascopeApp extends ConsumerWidget {
  const TuklascopeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to the auth state (are they logged in or out?)
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Tuklascope',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: authState.when(
        data: (state) {
          // If the user has a valid session, take them to the app (we'll build a Home screen later)
          // If not, show them the login screen.
          final session = state.session;
          if (session != null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Dashboard'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      // This tells our provider to kill the Supabase session
                      await ref.read(authServiceProvider).signOut();
                    },
                    tooltip: 'Log Out',
                  ),
                ],
              ),
              body: const Center(
                child: Text("Welcome to Tuklascope! (Home Screen Coming Soon)"),
              ),
            );
          } else {
            return const LoginScreen();
          }
        },
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, stackTrace) =>
            Scaffold(body: Center(child: Text('Authentication Error: $error'))),
      ),
    );
  }
}
