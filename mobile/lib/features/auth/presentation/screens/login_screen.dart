import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../onboarding/compass_questions_screen.dart';
import 'signup_screen.dart';
import '../widgets/auth_gate.dart';

import '../../providers/auth_controller.dart';
import '../../../../core/widgets/gradient_scaffold.dart';

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

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .signInWithEmailPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthGate()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          )
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: const Text('An unexpected error occurred'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    final currentUser = ref.read(authStateProvider).value;
    if (currentUser != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('You are already signed in.'),
            backgroundColor: Theme.of(context).colorScheme.primary, // Themed
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authResponse = await ref.read(authControllerProvider.notifier).signInWithGoogle();

      if (authResponse != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Successfully signed in with Google!'),
            backgroundColor: Theme.of(context).colorScheme.primary, // Themed
          ),
        );
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthGate()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication Error: ${e.message}'), 
            backgroundColor: Theme.of(context).colorScheme.error, // Themed
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to sign in with Google';
        if (e.toString().contains('MISSING_EMAIL')) {
          errorMessage = 'Google account has no email. Please use another account.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage), 
            backgroundColor: Theme.of(context).colorScheme.error, // Themed
            duration: const Duration(seconds: 4)
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  //facebook sign in
  Future<void> _signInWithFacebook() async {
    final currentUser = ref.read(authStateProvider).value;
    if (currentUser != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('You are already signed in.'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Call the Facebook auth method from your controller
      final authResponse = await ref.read(authControllerProvider.notifier).signInWithFacebook();

      // Supabase OAuth usually handles redirects externally, but if it returns a response:
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Successfully signed in with Facebook!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthGate()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication Error: ${e.message}'), 
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to sign in with Facebook'), 
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4)
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  // --- CUSTOM PAGE TRANSITION ---
  Route _createAnimatedRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutExpo;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(opacity: animation.drive(fadeTween), child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Cache theme for cleaner code below

    return GradientScaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary, // Themed
                    shadows: [Shadow(color: theme.shadowColor.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                ).animate().fade(duration: 600.ms, delay: 100.ms).slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 48),

                NeonTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  neonColor: theme.colorScheme.primary, // Themed
                ).animate().fade(duration: 600.ms, delay: 200.ms).slideX(begin: -0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 20),

                NeonTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  neonColor: theme.colorScheme.primary, // Themed
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility, 
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5) // Themed
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ).animate().fade(duration: 600.ms, delay: 300.ms).slideX(begin: -0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 32),

                if (_isLoading)
                  Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)) // Themed
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- NEON GLOW BUTTON ---
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.4), // Themed
                              blurRadius: 20, 
                              spreadRadius: 2, 
                              offset: const Offset(0, 5)
                            ),
                          ],
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary, 
                              theme.colorScheme.primary.withValues(alpha: 0.8) // Themed gradient
                            ]
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: theme.colorScheme.onPrimary, // Themed (Ensures text is visible)
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                          ),
                          child: const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(child: Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.3))), // Themed
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Or sign in with', 
                              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14) // Themed
                            ),
                          ),
                          Expanded(child: Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.3))), // Themed
                        ],
                      ).animate().fade(duration: 600.ms, delay: 500.ms),

                      const SizedBox(height: 24),

                      _buildSocialButton(
                        context: context, 
                        imagePath: 'assets/images/google.png', 
                        label: 'Google', 
                        onPressed: _signInWithGoogle
                      ).animate().fade(duration: 600.ms, delay: 600.ms),

                      const SizedBox(height: 16),

                      _buildSocialButton(
                        context: context, 
                        imagePath: 'assets/images/facebook.png', 
                        label: 'Facebook', 
                        onPressed: _signInWithFacebook
                      ).animate().fade(duration: 600.ms, delay: 700.ms),

                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ", 
                            style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 15) // Themed
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(context, _createAnimatedRoute(const SignupScreen())),
                            child: Text(
                              'Create Account', 
                              style: TextStyle(color: theme.colorScheme.secondary, fontSize: 15, fontWeight: FontWeight.bold) // Themed (Orange)
                            ),
                          ),
                        ],
                      ).animate().fade(duration: 600.ms, delay: 800.ms),
                    ],
                  ).animate().fade(duration: 600.ms, delay: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Added context to access theme
  Widget _buildSocialButton({required BuildContext context, required String imagePath, required String label, required VoidCallback onPressed}) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: theme.shadowColor.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Image.asset(imagePath, width: 24, height: 24),
        label: Text(label, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600)), // Themed text
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.surface, // Themed background
          foregroundColor: theme.colorScheme.onSurface, // Themed splash
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32), 
            side: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.1), width: 1) // Themed border
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

// --- DYNAMIC NEON INPUT WIDGET ---
class NeonTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final Color neonColor;

  const NeonTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    required this.neonColor,
  });

  @override
  State<NeonTextField> createState() => _NeonTextFieldState();
}

class _NeonTextFieldState extends State<NeonTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Cache theme

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isFocused
            ? [BoxShadow(color: widget.neonColor.withValues(alpha: 0.4), blurRadius: 15, spreadRadius: 2, offset: const Offset(0, 4))]
            : [BoxShadow(color: theme.shadowColor.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))], // Themed shadow
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        style: TextStyle(color: theme.colorScheme.onSurface), // Themed typed text
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(color: _isFocused ? widget.neonColor : theme.colorScheme.onSurface.withValues(alpha: 0.6)), // Themed label
          prefixIcon: Icon(widget.icon, color: _isFocused ? widget.neonColor : theme.colorScheme.onSurface.withValues(alpha: 0.4)), // Themed icon
          suffixIcon: widget.suffixIcon,
          filled: true,
          fillColor: theme.colorScheme.surface.withValues(alpha: 0.9), // Themed input background
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.transparent)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: widget.neonColor, width: 2)),
        ),
      ),
    );
  }
}