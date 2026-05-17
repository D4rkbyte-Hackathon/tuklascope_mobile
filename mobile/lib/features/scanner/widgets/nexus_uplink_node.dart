import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class NexusUplinkNode extends StatefulWidget {
  final VoidCallback onPressed;

  const NexusUplinkNode({super.key, required this.onPressed});

  @override
  State<NexusUplinkNode> createState() => _NexusUplinkNodeState();
}

class _NexusUplinkNodeState extends State<NexusUplinkNode> with SingleTickerProviderStateMixin {
  late AnimationController _hudController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _hudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(); // Continuous smooth rotation and pulsing
  }

  @override
  void dispose() {
    _hudController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.8 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: AnimatedBuilder(
          animation: _hudController,
          builder: (context, child) {
            // Pulse logic for the core glow
            final double pulse = (math.sin(_hudController.value * math.pi * 4) + 1) / 2;

            return SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Core Glow
                  Container(
                    width: 30 + (pulse * 10),
                    height: 30 + (pulse * 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF8C00).withValues(alpha: 0.3 + (pulse * 0.2)),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),

                  // Outer Rotating Tech Ring (Clockwise)
                  Transform.rotate(
                    angle: _hudController.value * math.pi * 2,
                    child: CustomPaint(
                      size: const Size(48, 48),
                      painter: _TechRingPainter(
                        color: Colors.white.withValues(alpha: 0.4),
                        strokeWidth: 1.5,
                        isOuter: true,
                      ),
                    ),
                  ),

                  // Inner Rotating Tech Ring (Counter-Clockwise)
                  Transform.rotate(
                    angle: -(_hudController.value * math.pi * 4),
                    child: CustomPaint(
                      size: const Size(36, 36),
                      painter: _TechRingPainter(
                        color: const Color(0xFFFF8C00).withValues(alpha: 0.8),
                        strokeWidth: 2.0,
                        isOuter: false,
                      ),
                    ),
                  ),

                  // Center Node (Static Glassmorphism)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.5),
                      border: Border.all(
                        color: const Color(0xFFFF8C00),
                        width: 1,
                      ),
                    ),
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                        child: const Center(
                          child: Icon(
                            // Gamified Exit Icon instead of an arrow
                            Icons.eject_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// 🚀 CUSTOM PAINTER FOR SCI-FI HUD RINGS
class _TechRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final bool isOuter;

  _TechRingPainter({
    required this.color,
    required this.strokeWidth,
    required this.isOuter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    if (isOuter) {
      // Draw 4 precise arc segments for the outer ring
      for (int i = 0; i < 4; i++) {
        final startAngle = i * (math.pi / 2) + 0.2;
        const sweepAngle = (math.pi / 2) - 0.4;
        canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, paint);
      }
    } else {
      // Draw 2 thicker segments for the inner ring + tracking dots
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 0, math.pi / 1.5, false, paint);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi, math.pi / 1.5, false, paint);
      
      final dotPaint = Paint()..color = color..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size.width, size.height / 2), 2.5, dotPaint);
      canvas.drawCircle(Offset(0, size.height / 2), 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}