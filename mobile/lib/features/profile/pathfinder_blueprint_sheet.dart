// mobile/lib/features/profile/pathfinder_blueprint_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
        // 1. Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildStaticSheetShell(
            theme,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                        'Analyzing Neo4j Skill Graph...',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(
                        duration: 1500.ms,
                        color: theme.colorScheme.secondary,
                      ),
                ],
              ),
            ),
          );
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
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: child,
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
    if (pathType.contains('Specialist')) return const Color(0xFF4CAF50);
    if (pathType.contains('Interdisciplinary')) return const Color(0xFF2196F3);
    return const Color(0xFFFF9800);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pathColor = _getPathColor(theme);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: pathColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: pathColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: pathColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  pathType.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    color: pathColor,
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    '$matchConfidence%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      value: matchConfidence / 100,
                      strokeWidth: 3,
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
          const SizedBox(height: 16),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.4,
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
