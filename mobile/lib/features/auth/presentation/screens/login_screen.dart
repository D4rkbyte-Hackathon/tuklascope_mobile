import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'signup_screen.dart';
import '../widgets/auth_gate.dart';
import '../widgets/auth_button.dart';
import '../widgets/neon_text_field.dart';
import '../../providers/auth_controller.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/navigation/auth_transitions.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).signInWithEmailPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthGate()),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      _showError('An unexpected error occurred');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithProvider(Future<AuthResponse?> Function() providerAuth, String providerName) async {
    if (ref.read(authStateProvider).value != null) {
      _showSuccess('You are already signed in.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authResponse = await providerAuth();

      if (!mounted) return;
      if (authResponse != null) {
        _showSuccess('Successfully signed in with $providerName!');
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthGate()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      _showError('Authentication Error: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      String errorMessage = 'Failed to sign in with $providerName';
      if (e.toString().contains('MISSING_EMAIL')) {
        errorMessage = '$providerName account has no email. Please use another account.';
      }
      _showError(errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.error, duration: const Duration(seconds: 4)),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GradientScaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- NEW LOGO ADDED HERE ---
                Image.asset(
                  'assets/images/logo-clear.png',
                  height: 100, // You can adjust this height as needed
                  fit: BoxFit.contain,
                ).animate()
                 .fade(duration: 600.ms)
                 .scaleXY(begin: 0.8, end: 1.0, duration: 600.ms, curve: Curves.easeOutBack),
                
                const SizedBox(height: 16), // Spacing between logo and text
                
                Text(
                  'Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                    shadows: [Shadow(color: theme.shadowColor.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                ).animate().fade(duration: 600.ms, delay: 100.ms).slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
                
                const SizedBox(height: 48),
                
                NeonTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  neonColor: theme.colorScheme.primary,
                ).animate().fade(duration: 600.ms, delay: 200.ms).slideX(begin: -0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
                
                const SizedBox(height: 20),
                
                NeonTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  neonColor: theme.colorScheme.primary,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ).animate().fade(duration: 600.ms, delay: 300.ms).slideX(begin: -0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
                
                const SizedBox(height: 32),
                
                if (_isLoading)
                  Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
                else ...[
                  PrimaryAuthButton(
                    label: 'Login',
                    onPressed: _signIn,
                    glowColor: theme.colorScheme.primary,
                    gradientColors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)],
                    textColor: theme.colorScheme.onPrimary,
                  ).animate().fade(duration: 600.ms, delay: 400.ms),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      Expanded(child: Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.3))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Or sign in with', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14)),
                      ),
                      Expanded(child: Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.3))),
                    ],
                  ).animate().fade(duration: 600.ms, delay: 500.ms),
                  
                  const SizedBox(height: 24),
                  
                  SocialAuthButton(
                    imagePath: 'assets/images/google.png',
                    label: 'Google',
                    onPressed: () => _signInWithProvider(ref.read(authControllerProvider.notifier).signInWithGoogle, 'Google'),
                  ).animate().fade(duration: 600.ms, delay: 600.ms),
                  
                  const SizedBox(height: 16),
                  
                  SocialAuthButton(
                    imagePath: 'assets/images/facebook.png',
                    label: 'Facebook',
                    onPressed: () => _signInWithProvider(ref.read(authControllerProvider.notifier).signInWithFacebook, 'Facebook'),
                  ).animate().fade(duration: 600.ms, delay: 700.ms),
                  
                  const SizedBox(height: 32),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ", style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 15)),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(context, createAnimatedAuthRoute(const SignupScreen(), slideLeft: true)),
                        child: Text('Create Account', style: TextStyle(color: theme.colorScheme.secondary, fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ).animate().fade(duration: 600.ms, delay: 800.ms),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}