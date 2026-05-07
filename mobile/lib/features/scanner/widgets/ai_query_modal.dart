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
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 280,
            decoration: BoxDecoration(
              color: const Color(0xFF0A0E17).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                  blurRadius: 40,
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
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
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
                StreamBuilder<int>(
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
                          color: theme.colorScheme.secondary,
                          letterSpacing: 2.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}