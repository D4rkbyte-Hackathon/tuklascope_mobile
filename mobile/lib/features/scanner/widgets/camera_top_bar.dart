import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CameraTopBar extends StatelessWidget {
  final double currentZoom;
  final double minZoom;
  final double maxZoom;
  final ValueChanged<double> onZoomChanged;

  const CameraTopBar({
    super.key,
    required this.currentZoom,
    required this.minZoom,
    required this.maxZoom,
    required this.onZoomChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // 1. Sleek Tech Bar (Less gamery, more professional)
          Container(
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'OPTICS: ${currentZoom.toStringAsFixed(1)}X',
                  style: GoogleFonts.orbitron(color: theme.colorScheme.secondary, fontSize: 10),
                ),
                Text(
                  'SENSOR: AUTO-SYNC', // Chill, normal-person text
                  style: GoogleFonts.orbitron(color: theme.colorScheme.primary, fontSize: 10),
                ),
                Row(
                  children: List.generate(5, (index) => Container(
                    width: 4, height: 4,
                    margin: const EdgeInsets.only(left: 2),
                    color: index < 3 ? theme.colorScheme.secondary : theme.colorScheme.primary.withValues(alpha: 0.3),
                  )),
                )
              ],
            ),
          ),
          
          const SizedBox(height: 15),

          // 2. Main Status Row (Tracking Badge)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Centered for better balance
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                    boxShadow: [
                      BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.2), blurRadius: 10),
                    ]
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.center_focus_weak, color: theme.colorScheme.secondary, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        'SUBJECT TRACKING',
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Zoom Slider (Moved down to hug the camera preview)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
            child: Row(
              children: [
                Icon(Icons.zoom_out, color: theme.colorScheme.primary.withValues(alpha: 0.7), size: 18),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: theme.colorScheme.secondary,
                      inactiveTrackColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                      thumbColor: theme.colorScheme.secondary,
                      overlayColor: theme.colorScheme.secondary.withValues(alpha: 0.2),
                      trackHeight: 2.0,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                    ),
                    child: Slider(
                      value: currentZoom,
                      min: minZoom,
                      max: maxZoom,
                      onChanged: onZoomChanged,
                    ),
                  ),
                ),
                Icon(Icons.zoom_in, color: theme.colorScheme.primary.withValues(alpha: 0.7), size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}