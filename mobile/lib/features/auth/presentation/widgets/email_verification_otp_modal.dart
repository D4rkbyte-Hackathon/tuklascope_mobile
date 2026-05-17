import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth_button.dart';

/// Glass-styled OTP modal for signup email verification.
class EmailVerificationOtpModal extends StatefulWidget {
  final String email;
  final Future<bool> Function(String code) onVerify;
  final Future<void> Function() onResend;

  const EmailVerificationOtpModal({
    super.key,
    required this.email,
    required this.onVerify,
    required this.onResend,
  });

  /// Shows the modal. Returns `true` when verification succeeds.
  static Future<bool?> show(
    BuildContext context, {
    required String email,
    required Future<bool> Function(String code) onVerify,
    required Future<void> Function() onResend,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (context) => EmailVerificationOtpModal(
        email: email,
        onVerify: onVerify,
        onResend: onResend,
      ),
    );
  }

  @override
  State<EmailVerificationOtpModal> createState() =>
      _EmailVerificationOtpModalState();
}

class _EmailVerificationOtpModalState extends State<EmailVerificationOtpModal> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();

  bool _isVerifying = false;
  bool _isFocused = false;
  bool _isResending = false;
  String? _errorMessage;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  static const _otpLength = 6;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
    });
    _startResendCooldown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startResendCooldown({int seconds = 60}) {
    _cooldownTimer?.cancel();
    setState(() => _resendCooldown = seconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCooldown <= 1) {
        timer.cancel();
        setState(() => _resendCooldown = 0);
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  String get _otpCode => _otpController.text.trim();

  bool get _canVerify =>
      !_isVerifying && _otpCode.length == _otpLength;

  void _onOtpChanged(String value) {
    setState(() {
      _errorMessage = null;
    });
    if (value.length == _otpLength && !_isVerifying) {
      _submit();
    }
  }

  Future<void> _submit() async {
    if (!_canVerify) return;

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    final verified = await widget.onVerify(_otpCode);

    if (!mounted) return;

    if (verified) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isVerifying = false;
      _errorMessage = 'Invalid code. Check your inbox and try again.';
    });
    _otpController.clear();
    _focusNode.requestFocus();
  }

  Future<void> _resend() async {
    if (_resendCooldown > 0 || _isResending) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      await widget.onResend();
      if (!mounted) return;
      _startResendCooldown();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'A new code was sent to ${widget.email}',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not resend code. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  String _maskedEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2 || parts[0].length < 2) return email;
    final local = parts[0];
    final visible = local.length <= 2 ? local[0] : local.substring(0, 2);
    return '$visible${'•' * (local.length - visible.length).clamp(1, 6)}@${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryNeon = theme.colorScheme.secondary;
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: isDark ? 0.88 : 0.92),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: primaryNeon.withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryNeon.withValues(alpha: 0.15),
                  blurRadius: 32,
                  spreadRadius: -4,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryNeon.withValues(alpha: 0.12),
                        border: Border.all(
                          color: primaryNeon.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Icon(
                        Icons.mark_email_read_outlined,
                        color: primaryNeon,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Verify your email',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _isVerifying
                          ? null
                          : () => Navigator.of(context).pop(false),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'We sent a 6-digit code to',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _maskedEmail(widget.email),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: primaryNeon,
                  ),
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () => _focusNode.requestFocus(),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _OtpDigitRow(
                        code: _otpController.text,
                        length: _otpLength,
                        neonColor: primaryNeon,
                        isFocused: _isFocused,
                        hasError: _errorMessage != null,
                      )
                          .animate(
                            key: ValueKey(_errorMessage),
                            onPlay: (c) =>
                                _errorMessage != null ? c.forward() : null,
                          )
                          .shakeX(
                            duration: 400.ms,
                            hz: 4,
                            curve: Curves.easeInOut,
                          ),
                      Positioned.fill(
                        child: TextField(
                          controller: _otpController,
                          focusNode: _focusNode,
                          keyboardType: TextInputType.number,
                          maxLength: _otpLength,
                          autofocus: true,
                          enabled: !_isVerifying,
                          showCursor: false,
                          enableInteractiveSelection: false,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: _onOtpChanged,
                          style: const TextStyle(
                            color: Colors.transparent,
                            fontSize: 1,
                          ),
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                if (_isVerifying)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CircularProgressIndicator(
                      color: primaryNeon,
                      strokeWidth: 2.5,
                    ),
                  )
                else
                  Opacity(
                    opacity: _canVerify ? 1 : 0.45,
                    child: PrimaryAuthButton(
                      label: 'Verify & continue',
                      onPressed: _canVerify ? _submit : () {},
                      glowColor: primaryNeon,
                      gradientColors: [
                        theme.colorScheme.tertiary,
                        theme.colorScheme.secondary,
                      ],
                      textColor: theme.colorScheme.onSecondary,
                    ),
                  ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: (_resendCooldown > 0 || _isResending || _isVerifying)
                      ? null
                      : _resend,
                  child: _isResending
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primaryNeon.withValues(alpha: 0.7),
                          ),
                        )
                      : Text(
                          _resendCooldown > 0
                              ? 'Resend code in ${_resendCooldown}s'
                              : 'Resend code',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _resendCooldown > 0
                                ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                                : primaryNeon,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 280.ms).scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1, 1),
          duration: 320.ms,
          curve: Curves.easeOutBack,
        );
  }
}

class _OtpDigitRow extends StatefulWidget {
  final String code;
  final int length;
  final Color neonColor;
  final bool isFocused;
  final bool hasError;

  const _OtpDigitRow({
    required this.code,
    required this.length,
    required this.neonColor,
    required this.isFocused,
    required this.hasError,
  });

  @override
  State<_OtpDigitRow> createState() => _OtpDigitRowState();
}

class _OtpDigitRowState extends State<_OtpDigitRow> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeIndex = widget.code.length.clamp(0, widget.length - 1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.length, (index) {
        final char = index < widget.code.length ? widget.code[index] : '';
        final isActive = widget.isFocused && index == activeIndex && char.isEmpty;
        final isFilled = char.isNotEmpty;

        Color borderColor;
        if (widget.hasError) {
          borderColor = theme.colorScheme.error.withValues(alpha: 0.8);
        } else if (isActive || isFilled) {
          borderColor = widget.neonColor;
        } else {
          borderColor = theme.colorScheme.onSurface.withValues(alpha: 0.15);
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: isActive ? 2 : 1.5),
            boxShadow: isActive || isFilled
                ? [
                    BoxShadow(
                      color: widget.neonColor.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            char,
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary,
            ),
          ),
        );
      }),
    );
  }
}
