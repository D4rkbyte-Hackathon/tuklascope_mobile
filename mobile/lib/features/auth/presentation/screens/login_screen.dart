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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred')),
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
          const SnackBar(
            content: Text('You are already signed in.'),
            backgroundColor: Color(0xFF64B5F6),
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
          const SnackBar(
            content: Text('Successfully signed in with Google!'),
            backgroundColor: Color(0xFF64B5F6),
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
          SnackBar(content: Text('Authentication Error: ${e.message}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to sign in with Google';
        if (e.toString().contains('MISSING_EMAIL')) {
          errorMessage = 'Google account has no email. Please use another account.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red, duration: const Duration(seconds: 4)),
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
    return GradientScaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0B3C6A),
                    shadows: [Shadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                  ),
                ).animate().fade(duration: 600.ms, delay: 100.ms).slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 48),

                NeonTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  neonColor: const Color(0xFF64B5F6),
                ).animate().fade(duration: 600.ms, delay: 200.ms).slideX(begin: -0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 20),

                NeonTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  neonColor: const Color(0xFF64B5F6),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey[600]),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ).animate().fade(duration: 600.ms, delay: 300.ms).slideX(begin: -0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 32),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator(color: Color(0xFF64B5F6)))
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- NEON GLOW BUTTON ---
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF64B5F6).withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 5)),
                          ],
                          gradient: const LinearGradient(colors: [Color(0xFF64B5F6), Color(0xFF42A5F5)]),
                        ),
                        child: ElevatedButton(
                          onPressed: _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                          ),
                          child: const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[400])),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Or sign in with', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                          ),
                          Expanded(child: Divider(color: Colors.grey[400])),
                        ],
                      ).animate().fade(duration: 600.ms, delay: 500.ms),

                      const SizedBox(height: 24),

                      _buildSocialButton(imagePath: 'assets/images/google.png', label: 'Google', onPressed: _signInWithGoogle)
                          .animate().fade(duration: 600.ms, delay: 600.ms),

                      const SizedBox(height: 16),

                      _buildSocialButton(imagePath: 'assets/images/facebook.png', label: 'Facebook', onPressed: () {})
                          .animate().fade(duration: 600.ms, delay: 700.ms),

                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? ", style: TextStyle(color: Colors.grey[700], fontSize: 15)),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(context, _createAnimatedRoute(const SignupScreen())),
                            child: const Text('Create Account', style: TextStyle(color: Color(0xFFFF6B2C), fontSize: 15, fontWeight: FontWeight.bold)),
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

  Widget _buildSocialButton({required String imagePath, required String label, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Image.asset(imagePath, width: 24, height: 24),
        label: Text(label, style: const TextStyle(color: Color(0xFF0B3C6A), fontSize: 16, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0B3C6A),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32), side: BorderSide(color: Colors.grey[200]!, width: 1)),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isFocused
            ? [BoxShadow(color: widget.neonColor.withValues(alpha: 0.4), blurRadius: 15, spreadRadius: 2, offset: const Offset(0, 4))]
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        style: const TextStyle(color: Color(0xFF0B3C6A)),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(color: _isFocused ? widget.neonColor : Colors.grey[600]),
          prefixIcon: Icon(widget.icon, color: _isFocused ? widget.neonColor : Colors.grey[400]),
          suffixIcon: widget.suffixIcon,
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.9),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.transparent)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: widget.neonColor, width: 2)),
        ),
      ),
    );
  }
}