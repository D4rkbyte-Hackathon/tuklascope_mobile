import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeckQueryModal extends StatefulWidget {
  final String lens;
  const DeckQueryModal({super.key, required this.lens});

  @override
  State<DeckQueryModal> createState() => _DeckQueryModalState();
}

class _DeckQueryModalState extends State<DeckQueryModal>
    with SingleTickerProviderStateMixin {
  late final Stream<int> _timerStream;
  late final List<String> _phrases;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _phrases = [
      'Calibrating AI lenses...',
      'Analyzing structural composition...',
      'Cross-referencing historical data...',
      'Extracting core concepts...',
      'Synthesizing ${widget.lens} pathways...',
    ];
    _timerStream = Stream.periodic(
      const Duration(milliseconds: 2000),
      (i) => i,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: size.width,
            height: size.height * 0.35,
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.black.withValues(alpha: 0.5) 
                  : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.1) 
                    : Colors.white.withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 100 + (_pulseController.value * 20),
                          height: 100 + (_pulseController.value * 20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.secondary,
                            strokeWidth: 3,
                          ),
                        ),
                        Icon(
                          Icons.hub,
                          size: 36,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: 48, 
                  child: StreamBuilder<int>(
                    stream: _timerStream,
                    builder: (context, snapshot) {
                      final index = (snapshot.data ?? 0) % _phrases.length;
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          _phrases[index].toUpperCase(),
                          key: ValueKey<int>(index),
                          style: GoogleFonts.orbitron(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : theme.colorScheme.primary,
                            letterSpacing: 2.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}