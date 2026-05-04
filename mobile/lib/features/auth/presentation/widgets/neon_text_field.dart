import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // 🚀 ADDED GOOGLE FONTS

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
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isFocused
            ? [BoxShadow(color: widget.neonColor.withValues(alpha: 0.4), blurRadius: 15, spreadRadius: 2, offset: const Offset(0, 4))]
            : [BoxShadow(color: theme.shadowColor.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        style: GoogleFonts.inter(color: theme.colorScheme.onSurface), // 🚀 SWAPPED TO INTER
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: GoogleFonts.inter(color: _isFocused ? widget.neonColor : theme.colorScheme.onSurface.withValues(alpha: 0.6)), // 🚀 SWAPPED TO INTER
          prefixIcon: Icon(widget.icon, color: _isFocused ? widget.neonColor : theme.colorScheme.onSurface.withValues(alpha: 0.4)),
          suffixIcon: widget.suffixIcon,
          filled: true,
          fillColor: theme.colorScheme.surface.withValues(alpha: 0.9),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.transparent)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: widget.neonColor, width: 2)),
        ),
      ),
    );
  }
}