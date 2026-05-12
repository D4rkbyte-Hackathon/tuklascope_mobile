import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedShimmerButton extends StatefulWidget {
  final bool isSecured;
  final bool isFocused; // 🚀 OPTIMIZATION: Track focus to kill off-screen animations
  final Color strandColor;
  final VoidCallback? onPressed;

  const AnimatedShimmerButton({
    super.key,
    required this.isSecured,
    required this.isFocused,
    required this.strandColor,
    required this.onPressed,
  });

  @override
  State<AnimatedShimmerButton> createState() => _AnimatedShimmerButtonState();
}

class _AnimatedShimmerButtonState extends State<AnimatedShimmerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    
    // 🚀 OPTIMIZATION: Only start if it's both focused and unlocked
    if (widget.isFocused && !widget.isSecured) {
      _shimmerController.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedShimmerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 🚀 OPTIMIZATION: Start/Stop animation dynamically when scrolling
    final bool shouldAnimate = widget.isFocused && !widget.isSecured;
    final bool wasAnimating = oldWidget.isFocused && !oldWidget.isSecured;

    if (shouldAnimate && !wasAnimating) {
      _shimmerController.repeat();
    } else if (!shouldAnimate && wasAnimating) {
      _shimmerController.stop();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  widget.isSecured ? Colors.transparent : widget.strandColor,
              foregroundColor:
                  widget.isSecured ? Colors.greenAccent : Colors.white,
              elevation: widget.isSecured ? 0 : 8,
              shadowColor: widget.strandColor.withValues(alpha: 0.6),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: widget.isSecured
                      ? Colors.greenAccent
                      : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            onPressed: widget.onPressed,
            child: const SizedBox.shrink(),
          ),
        ),
        if (!widget.isSecured)
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return FractionalTranslation(
                      translation: Offset(
                          -1.5 + (_shimmerController.value * 3.0), 0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.1),
                              Colors.white.withValues(alpha: 0.5),
                              Colors.white.withValues(alpha: 0.1),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.4, 0.5, 0.6, 1.0],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Text(
                widget.isSecured ? 'PORTAL CLOSED' : 'ENTER PORTAL',
                style: GoogleFonts.inter(
                  color: widget.isSecured ? Colors.greenAccent : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}