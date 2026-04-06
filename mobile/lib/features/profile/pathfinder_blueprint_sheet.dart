import 'package:flutter/material.dart';

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

class PathfinderBlueprintSheet extends StatelessWidget {
  final VoidCallback onNavigateToScan;

  const PathfinderBlueprintSheet({super.key, required this.onNavigateToScan});

  static const Color _navy = Color(0xFF0D3B66);
  static const Color _cream = Color(0xFFF9F6F0);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.96,
      minChildSize: 0.42,
      maxChildSize: 0.98,
      snap: true,
      snapSizes: const [0.42, 0.96],
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Material(
            color: _cream,
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.fromLTRB(20, 10, 20, bottomInset + 88),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                    children: [
                      TextSpan(
                        text: 'Your Blueprint:\n',
                        style: TextStyle(color: _navy),
                      ),
                      TextSpan(
                        text: 'From Core Principles To Career Paths',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Kamusta! Your skill tree shows how your interests connect across tracks—here are field strengths and program ideas tailored for you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Last Updated 8/7/30',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withValues(alpha: 0.38),
                  ),
                ),
                const SizedBox(height: 24),
                _StrongestFieldsCard(navy: _navy),
                const SizedBox(height: 20),
                _CollegeProgramCard(
                  borderColor: Colors.green,
                  title: 'BS Gwapo Engineering',
                  subtitle: 'Blahblah [AI generated stuff]',
                ),
                const SizedBox(height: 20),
                _CollegeProgramCard(
                  borderColor: Colors.orange,
                  title: 'BS Rizzler Engineering',
                  subtitle: 'Blahblah [AI generated stuff]',
                ),
                const SizedBox(height: 20),
                _CollegeProgramCard(
                  borderColor: Colors.orange,
                  title: 'BS Alpha Wolf Engineering',
                  subtitle: 'Blahblah [AI generated stuff]',
                ),
                const SizedBox(height: 20),
                _BlueprintCtaCard(
                  navy: _navy,
                  onStartDiscovery: () {
                    Navigator.of(context).pop();
                    onNavigateToScan();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StrongestFieldsCard extends StatelessWidget {
  final Color navy;

  const _StrongestFieldsCard({required this.navy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: navy, width: 1),
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
              color: navy,
            ),
          ),
          const SizedBox(height: 18),
          const _FieldProgressRow(
            label: 'Agham at Math (STEM)',
            value: 0.4,
            fillColor: Colors.green,
          ),
          const SizedBox(height: 14),
          const _FieldProgressRow(
            label: 'Sining at Wika (HUMSS)',
            value: 0.3,
            fillColor: Colors.orange,
          ),
          const SizedBox(height: 14),
          const _FieldProgressRow(
            label: 'Teknikal (TVL)',
            value: 0.2,
            fillColor: Colors.orange,
          ),
          const SizedBox(height: 14),
          const _FieldProgressRow(
            label: 'Negosyo (ABM)',
            value: 0.1,
            fillColor: Colors.orange,
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
    final pct = (value * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Text(
              '$pct%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
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
                ColoredBox(color: Colors.grey[300]!),
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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.fromLTRB(18, 28, 18, 36),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: PathfinderBlueprintSheet._navy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Text(
              'College Program',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: borderColor == Colors.green
                    ? Colors.green[800]!
                    : Colors.orange[800]!,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BlueprintCtaCard extends StatelessWidget {
  final Color navy;
  final VoidCallback onStartDiscovery;

  const _BlueprintCtaCard({required this.navy, required this.onStartDiscovery});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: navy, width: 1),
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
              color: navy,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Upload a photo of any object around you and discover the concepts behind it!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.35),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onStartDiscovery,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
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
