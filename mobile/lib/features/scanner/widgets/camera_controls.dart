import 'package:flutter/material.dart';

class CameraControls extends StatelessWidget {
  final VoidCallback onCapture;
  final VoidCallback onFlipCamera;
  final double bottomPadding;

  const CameraControls({
    super.key,
    required this.onCapture,
    required this.onFlipCamera,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      bottom: bottomPadding,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              iconSize: 28,
              icon: const Icon(Icons.photo_library, color: Colors.white70),
              onPressed: () {}, // TODO: Implement Gallery Picker
            ),

            // CAPTURE BUTTON
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
                      color: theme.colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 15,
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

            IconButton(
              iconSize: 28,
              icon: const Icon(Icons.flip_camera_ios, color: Colors.white70),
              onPressed: onFlipCamera,
            ),
          ],
        ),
      ),
    );
  }
}