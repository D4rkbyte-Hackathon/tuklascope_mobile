// mobile/lib/features/profile/pathfinder_blueprint_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/pathfinder_service.dart';

/// Opens a near-full-screen sheet that can be dragged down from the top to dismiss.
Future<void> showPathfinderBlueprintSheet(
  BuildContext context, {
  required VoidCallback onNavigateToScan,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (context) =>
        PathfinderBlueprintSheet(onNavigateToScan: onNavigateToScan),
  );
}

class PathfinderBlueprintSheet extends StatefulWidget {
  final VoidCallback onNavigateToScan;

  const PathfinderBlueprintSheet({super.key, required this.onNavigateToScan});

  @override
  State<PathfinderBlueprintSheet> createState() =>
      _PathfinderBlueprintSheetState();
}

class _PathfinderBlueprintSheetState extends State<PathfinderBlueprintSheet> {
  Future<Map<String, dynamic>?>? _analysisFuture;

  @override
  void initState() {
    super.initState();
    // Trigger the API call to Render when the sheet opens
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
          return Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Analyzing your Skill Tree...',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                ],
              ),
            ),
          );
        }

        // 2. Error or Null State
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Text(
                'Failed to generate blueprint. Please try again later.',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          );
        }

        // 3. Success State - Parse the Pydantic JSON
        final data = snapshot.data!;
        final String profileSummary =
            data['profile_summary'] ?? 'Your learning journey is unique!';
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
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                    children: [
                      TextSpan(
                        text: 'Your Blueprint:\n',
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                      TextSpan(
                        text: 'From Core Principles To Career Paths',
                        style: TextStyle(color: theme.colorScheme.secondary),
                      ),
                    ],
                  ),
                ),
              ),
              // Dynamic AI Summary
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  profileSummary,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
              ),
              // Strongest Fields Card
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: _StrongestFieldsCard(),
              ),

              // Dynamic AI Recommendations
              ...recommendations.map((rec) {
                // Alternating colors based on index or path type
                final color = rec['path_type'] == 'The Specialist'
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFFF9800);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _CollegeProgramCard(
                    borderColor: color,
                    title: rec['title'] ?? 'Unknown Career',
                    subtitle: rec['description'] ?? 'No description provided.',
                  ),
                );
              }),

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
                top: Radius.circular(20),
              ),
              child: Material(
                color: theme.colorScheme.surface,
                child: ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(20, 10, 20, bottomInset + 88),
                  itemCount: sheetItems.length,
                  itemBuilder: (context, index) {
                    return sheetItems[index]
                        .animate()
                        .fade(duration: 600.ms, delay: (100 * index).ms)
                        .slideY(
                          begin: 0.1,
                          end: 0,
                          duration: 600.ms,
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
}

// -----------------------------------------------------------------------------
// HELPER WIDGETS BELOW
// -----------------------------------------------------------------------------

class _StrongestFieldsCard extends StatelessWidget {
  const _StrongestFieldsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Cache Theme

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Themed Card Surface
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ), // Themed Border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your Strongest Fields',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary, // Themed Primary
            ),
          ),
          const SizedBox(height: 18),
          const _FieldProgressRow(
            label: 'Agham at Math (STEM)',
            value: 0.4,
            fillColor: Color(0xFF4CAF50), // Safe Green
          ),
          const SizedBox(height: 14),
          _FieldProgressRow(
            label: 'Sining at Wika (HUMSS)',
            value: 0.3,
            fillColor: theme.colorScheme.secondary, // Themed Orange
          ),
          const SizedBox(height: 14),
          _FieldProgressRow(
            label: 'Teknikal (TVL)',
            value: 0.2,
            fillColor: theme.colorScheme.secondary, // Themed Orange
          ),
          const SizedBox(height: 14),
          _FieldProgressRow(
            label: 'Negosyo (ABM)',
            value: 0.1,
            fillColor: theme.colorScheme.secondary, // Themed Orange
          ),
        ],
      ),
    );
  }
}

class _FieldProgressRow extends StatelessWidget {
  final String label;
  final double value;
  final Color fillColor;

  const _FieldProgressRow({
    required this.label,
    required this.value,
    required this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Cache Theme
    final pct = (value * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface, // Themed Label
                ),
              ),
            ),
            Text(
              '$pct%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withValues(
                  alpha: 0.6,
                ), // Themed Percentage
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ), // Themed Empty Track
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value.clamp(0.0, 1.0),
                  child: ColoredBox(color: fillColor),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CollegeProgramCard extends StatelessWidget {
  final Color borderColor;
  final String title;
  final String subtitle;

  const _CollegeProgramCard({
    required this.borderColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Cache Theme

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.fromLTRB(18, 28, 18, 36),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface, // Themed Background
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: borderColor.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary, // Themed Title
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(
                    alpha: 0.7,
                  ), // Themed Subtitle
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface, // Themed Badge BG
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: borderColor.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Text(
              'College Program',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color:
                    borderColor, // Directly use the passed border color for highest adaptive visibility
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BlueprintCtaCard extends StatelessWidget {
  final VoidCallback onStartDiscovery;

  const _BlueprintCtaCard({required this.onStartDiscovery});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Cache Theme

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Themed Background
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ), // Themed Border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Want more personalized guidance?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary, // Themed Title
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Upload a photo of any object around you and discover the concepts behind it!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(
                alpha: 0.7,
              ), // Themed Description
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onStartDiscovery,
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary, // Themed Orange
              foregroundColor: theme.colorScheme.onSecondary, // Themed White
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: const StadiumBorder(),
            ),
            child: const Text('Start Discovery →'),
          ),
        ],
      ),
    );
  }
}
