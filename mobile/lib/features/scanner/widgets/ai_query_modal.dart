import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AiQueryModal extends StatefulWidget {
  const AiQueryModal({super.key});

  @override
  State<AiQueryModal> createState() => _AiQueryModalState();
}

class _AiQueryModalState extends State<AiQueryModal> with SingleTickerProviderStateMixin {
  late final List<String> _phrases;
  late final Stream<int> _timerStream;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _phrases = [
      'Connecting to server...',
      'Processing visual data...',
      'Analyzing features...',
      'Generating results...',
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
            // Dynamic fixed sizing based on device screen
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
                            color: theme.colorScheme.primary.withValues(alpha: 0.15),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                            strokeWidth: 3,
                          ),
                        ),
                        Icon(
                          Icons.wifi_tethering,
                          size: 36,
                          color: theme.colorScheme.secondary,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 40),
                
                // Fixed height container so changing text doesn't adjust the modal size
                SizedBox(
                  height: 24, 
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