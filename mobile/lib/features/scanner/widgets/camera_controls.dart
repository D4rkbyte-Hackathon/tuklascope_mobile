import 'package:flutter/material.dart';

class CameraControls extends StatelessWidget {
  final VoidCallback onCapture;
  final VoidCallback onFlipCamera;
  final bool isFlashOn;
  final VoidCallback onToggleFlash;

  const CameraControls({
    super.key,
    required this.onCapture,
    required this.onFlipCamera,
    required this.isFlashOn,
    required this.onToggleFlash,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // FLASH TOGGLE (Left)
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFlashOn ? theme.colorScheme.secondary.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.3),
            ),
            child: IconButton(
              iconSize: 28,
              icon: Icon(
                isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: isFlashOn ? theme.colorScheme.secondary : Colors.white70,
              ),
              onPressed: onToggleFlash,
            ),
          ),

          // CAPTURE BUTTON (Center)
          GestureDetector(
            onTap: onCapture,
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // FLIP CAMERA (Right)
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.3),
            ),
            child: IconButton(
              iconSize: 28,
              icon: Icon(Icons.flip_camera_ios, color: theme.colorScheme.secondary),
              onPressed: onFlipCamera,
            ),
          ),
        ],
      ),
    );
  }
}