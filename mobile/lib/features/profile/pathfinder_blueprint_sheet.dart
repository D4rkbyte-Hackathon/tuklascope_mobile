import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../../core/services/pathfinder_service.dart';

/// Opens a near-full-screen sheet that can be dragged down from the top to dismiss.
Future<void> showPathfinderBlueprintSheet(
  BuildContext context, {
  required int stemXp,
  required int humssXp,
  required int abmXp,
  required int tvlXp,
  required VoidCallback onNavigateToScan,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black87, // Darker for better contrast
    builder: (context) => PathfinderBlueprintSheet(
      stemXp: stemXp,
      humssXp: humssXp,
      abmXp: abmXp,
      tvlXp: tvlXp,
      onNavigateToScan: onNavigateToScan,
    ),
  );
}

class PathfinderBlueprintSheet extends StatefulWidget {
  final int stemXp;
  final int humssXp;
  final int abmXp;
  final int tvlXp;
  final VoidCallback onNavigateToScan;

  const PathfinderBlueprintSheet({
    super.key,
    required this.stemXp,
    required this.humssXp,
    required this.abmXp,
    required this.tvlXp,
    required this.onNavigateToScan,
  });

  @override
  State<PathfinderBlueprintSheet> createState() =>
      _PathfinderBlueprintSheetState();
}

class _PathfinderBlueprintSheetState extends State<PathfinderBlueprintSheet> {
  Future<Map<String, dynamic>?>? _analysisFuture;

  @override
  void initState() {
    super.initState();
    _analysisFuture = PathfinderService.analyzePaths();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return FutureBuilder<Map<String, dynamic>?>(
      future: _analysisFuture,
      builder: (context, snapshot) {
        // 1. Loading State - The new Animated Modal
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _NeuralLinkOverlay();
        }

        // 2. Error State
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return _buildStaticSheetShell(
            theme,
            child: Center(
              child: Text(
                'Uplink failed. Please check your connection and try again.',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          );
        }

        // 3. Success State
        final data = snapshot.data!;
        final String profileSummary =
            data['profile_summary'] ??
            'Your learning journey is uniquely yours.';
        final List<dynamic> recommendations = data['recommendations'] ?? [];

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.96,
          minChildSize: 0.42,
          maxChildSize: 0.98,
          snap: true,
          snapSizes: const [0.42, 0.96],
          builder: (context, scrollController) {
            final List<Widget> sheetItems = [
              // Drag Handle
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Header
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                  children: [
                    TextSpan(
                      text: 'TUKLASCOPE\n',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                        fontSize: 12,
                        letterSpacing: 2.0,
                      ),
                    ),
                    TextSpan(
                      text: 'Career Blueprint',
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // AI Profile Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        profileSummary,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.9,
                          ),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Real-time Fields Card
              _StrongestFieldsCard(
                stemXp: widget.stemXp,
                humssXp: widget.humssXp,
                abmXp: widget.abmXp,
                tvlXp: widget.tvlXp,
              ),
              const SizedBox(height: 32),

              Text(
                'AI Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Dynamic Career Cards
              ...recommendations.map((rec) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _CareerRecommendationCard(
                    title: rec['title'] ?? 'Unknown',
                    description: rec['description'] ?? '',
                    pathType: rec['path_type'] ?? 'General',
                    matchConfidence: rec['match_confidence'] ?? 0,
                  ),
                );
              }),

              const SizedBox(height: 16),

              // CTA Bottom Card
              _BlueprintCtaCard(
                onStartDiscovery: () {
                  Navigator.of(context).pop();
                  widget.onNavigateToScan();
                },
              ),
            ];

            return ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: Material(
                color: theme.colorScheme.surface,
                child: ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 40),
                  itemCount: sheetItems.length,
                  itemBuilder: (context, index) {
                    return sheetItems[index]
                        .animate()
                        .fade(duration: 500.ms, delay: (50 * index).ms)
                        .slideY(
                          begin: 0.1,
                          end: 0,
                          duration: 500.ms,
                          curve: Curves.easeOutCubic,
                        );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStaticSheetShell(ThemeData theme, {required Widget child}) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: child,
    );
  }
}

// =============================================================================
// NEW: NEURAL LINK LOADING OVERLAY
// =============================================================================

class _NeuralLinkOverlay extends StatefulWidget {
  const _NeuralLinkOverlay();

  @override
  State<_NeuralLinkOverlay> createState() => _NeuralLinkOverlayState();
}

class _NeuralLinkOverlayState extends State<_NeuralLinkOverlay> {
  final List<String> _phrases = [
    'Initializing Uplink...',
    'Mapping Graph Data...',
    'Analyzing Skill Synergies...',
    'Calculating Career Vectors...',
    'Querying Neural Network...',
    'Synthesizing Blueprint...',
  ];

  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Change phrase every 1.5 seconds
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _phrases.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      // We don't use a solid background here so it overlays the blurred barrier of the BottomSheet
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing, pulsating icon
            Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.hub,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scaleXY(
                  begin: 0.9,
                  end: 1.1,
                  duration: 1.seconds,
                  curve: Curves.easeInOut,
                )
                .shimmer(
                  duration: 2.seconds,
                  color: theme.colorScheme.secondary,
                ),

            const SizedBox(height: 32),

            // Animated Text
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.2),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                _phrases[_currentIndex],
                key: ValueKey<int>(
                  _currentIndex,
                ), // Important for AnimatedSwitcher
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// RE-ENGINEERED HELPER WIDGETS
// -----------------------------------------------------------------------------

class _StrongestFieldsCard extends StatelessWidget {
  final int stemXp;
  final int humssXp;
  final int abmXp;
  final int tvlXp;

  const _StrongestFieldsCard({
    required this.stemXp,
    required this.humssXp,
    required this.abmXp,
    required this.tvlXp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mathematical Calculation for Real Data
    final total = stemXp + humssXp + abmXp + tvlXp;
    final double stemPct = total == 0 ? 0 : stemXp / total;
    final double humssPct = total == 0 ? 0 : humssXp / total;
    final double abmPct = total == 0 ? 0 : abmXp / total;
    final double tvlPct = total == 0 ? 0 : tvlXp / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your Graph Distribution',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 20),
          _FieldProgressRow(
            label: 'STEM',
            value: stemPct,
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 16),
          _FieldProgressRow(
            label: 'HUMSS',
            value: humssPct,
            color: const Color(0xFF9C27B0),
          ),
          const SizedBox(height: 16),
          _FieldProgressRow(
            label: 'ABM',
            value: abmPct,
            color: const Color(0xFF2196F3),
          ),
          const SizedBox(height: 16),
          _FieldProgressRow(
            label: 'TVL',
            value: tvlPct,
            color: const Color(0xFFFF9800),
          ),
        ],
      ),
    );
  }
}

class _FieldProgressRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _FieldProgressRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = (value * 100).round();

    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  ),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: value.clamp(0.0, 1.0),
                    child: ColoredBox(color: color),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 40,
          child: Text(
            '$pct%',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _CareerRecommendationCard extends StatelessWidget {
  final String title;
  final String description;
  final String pathType;
  final int matchConfidence;

  const _CareerRecommendationCard({
    required this.title,
    required this.description,
    required this.pathType,
    required this.matchConfidence,
  });

  Color _getPathColor(ThemeData theme) {
    final type = pathType.toLowerCase();
    if (type.contains('master') || type.contains('specialist')) {
      return const Color(0xFFE91E63);
    }
    if (type.contains('hybrid') || type.contains('architect')) {
      return const Color(0xFF2196F3);
    }
    if (type.contains('future') || type.contains('pioneer')) {
      return const Color(0xFFFFC107);
    }
    return theme.colorScheme.primary; // Default
  }

  IconData _getPathIcon() {
    final type = pathType.toLowerCase();
    if (type.contains('master') || type.contains('specialist')) {
      return Icons.local_fire_department;
    }
    if (type.contains('hybrid') || type.contains('architect')) {
      return Icons.device_hub;
    }
    if (type.contains('future') || type.contains('pioneer')) {
      return Icons.rocket_launch;
    }
    return Icons.star;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pathColor = _getPathColor(theme);
    final pathIcon = _getPathIcon();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: pathColor.withValues(alpha: 0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: pathColor.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Badge & Match Score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: pathColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: pathColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(pathIcon, size: 14, color: pathColor),
                    const SizedBox(width: 6),
                    Text(
                      pathType.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: pathColor,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    '$matchConfidence%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      value: matchConfidence / 100,
                      strokeWidth: 4,
                      backgroundColor: theme.colorScheme.onSurface.withValues(
                        alpha: 0.1,
                      ),
                      color: pathColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            description,
            style: TextStyle(
              fontSize: 15,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlueprintCtaCard extends StatelessWidget {
  final VoidCallback onStartDiscovery;

  const _BlueprintCtaCard({required this.onStartDiscovery});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.secondary.withValues(alpha: 0.1),
            theme.colorScheme.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.radar, size: 32, color: theme.colorScheme.secondary),
          const SizedBox(height: 12),
          Text(
            'Keep Evolving',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan new objects to alter your trajectory and unlock new career paths.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onStartDiscovery,
            icon: const Icon(Icons.camera_alt, size: 18),
            label: const Text('Resume Discovery'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
