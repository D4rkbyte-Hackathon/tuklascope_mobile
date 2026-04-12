import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/navigation/main_nav_scope.dart';
import '../../core/widgets/gradient_scaffold.dart';
import 'pathfinder_blueprint_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _navy = Color(0xFF0D3B66);
  static const Color _cream = Color(0xFFF9F6F0);
  static const Color _linkBlue = Color(0xFF42A5F5);
  static const Color _avgLevel = Color(0xFFE65100);

  String _fullName = 'Loading...';
  String _educationLevel = '...';
  String _location = '';
  int _streak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      if (mounted) {
        setState(() {
          _fullName = data['full_name'] ?? 'New Explorer';
          _educationLevel = data['education_level'] ?? 'Curious Mind';
          _streak = data['current_streak'] ?? 0;

          final city = data['city'] ?? '';
          final country = data['country'] ?? '';
          if (city.isNotEmpty && country.isNotEmpty) {
            _location = '$city, $country';
          } else {
            _location = city + country;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      if (mounted) {
        setState(() {
          _fullName = 'Explorer';
          _educationLevel = 'Ready to learn';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Grouping all UI elements into a list for lazy rendering
    // We use Padding instead of SizedBoxes so the animation cascades cleanly
    final List<Widget> profileItems = [
      _ProfileHeaderCard(
        navy: _navy,
        linkBlue: _linkBlue,
        fullName: _fullName,
        educationLevel: _educationLevel,
        location: _location,
        streak: _streak,
      ),
      Padding(
        padding: const EdgeInsets.only(top: 28, bottom: 12),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.15,
            ),
            children: [
              TextSpan(text: 'Your ', style: TextStyle(color: _navy)),
              const TextSpan(text: 'Skill Tree', style: TextStyle(color: Colors.orange)),
            ],
          ),
        ),
      ),
      const Padding(
        padding: EdgeInsets.only(bottom: 28),
        child: Text(
          'Watch your knowledge grow! Every discovery adds to your personal skill network and unlocks new learning pathways.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.35),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: _StatsGridCard(navy: _navy, avgLevelColor: _avgLevel),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: _SkillTreePlaceholderCard(),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _ProfilePromoCard(
          borderColor: Colors.orange,
          title: 'Open Your Blueprint',
          description: 'From core principles to career path.',
          buttonLabel: 'Open Pathfinder →',
          buttonColor: _navy,
          onPressed: () => showPathfinderBlueprintSheet(
            context,
            onNavigateToScan: () => MainNavScope.maybeOf(context)?.goToTab(1),
          ),
        ),
      ),
      _ProfilePromoCard(
        borderColor: _navy.withValues(alpha: 0.35),
        title: 'Ready to expand your network?',
        description: 'Upload a photo of any object around you and discover the concepts behind it!',
        buttonLabel: 'Start Discovery →',
        buttonColor: Colors.orange,
        onPressed: () => MainNavScope.maybeOf(context)?.goToTab(1),
      ),
    ];

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Profile & Skill Tree'),
        foregroundColor: _navy,
      ),
      body: ColoredBox(
        color: _cream,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  MediaQuery.paddingOf(context).bottom + 88,
                ),
                itemCount: profileItems.length,
                itemBuilder: (context, index) {
                  // 2. Applying the staggered animation to each lazily-loaded list item
                  return profileItems[index]
                      .animate()
                      .fade(duration: 600.ms, delay: (100 * index).ms)
                      .slideY(
                        begin: 0.1,
                        end: 0,
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                        delay: (100 * index).ms,
                      );
                },
              ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER WIDGETS BELOW (Unchanged from your custom styling)
// -----------------------------------------------------------------------------

class _ProfilePromoCard extends StatelessWidget {
  final Color borderColor;
  final String title;
  final String description;
  final String buttonLabel;
  final Color buttonColor;
  final VoidCallback onPressed;

  const _ProfilePromoCard({
    required this.borderColor,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.buttonColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F6F0),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D3B66),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: const StadiumBorder(),
              ),
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final Color navy;
  final Color linkBlue;
  final String fullName;
  final String educationLevel;
  final String location;
  final int streak;

  const _ProfileHeaderCard({
    required this.navy, 
    required this.linkBlue,
    required this.fullName,
    required this.educationLevel,
    required this.location,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: navy, width: 4),
                ),
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 40, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: navy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location.isNotEmpty ? '$educationLevel • $location' : educationLevel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[700],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black.withValues(alpha: 0.45),
                        ),
                        children: [
                          const TextSpan(text: 'Daily Streak '),
                          TextSpan(
                            text: '$streak',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {},
              child: Text(
                'Edit Profile →',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: linkBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGridCard extends StatelessWidget {
  final Color navy;
  final Color avgLevelColor;

  const _StatsGridCard({required this.navy, required this.avgLevelColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCell(
                  value: '67%',
                  label: 'Total Progress',
                  valueColor: Colors.orange,
                ),
              ),
              Expanded(
                child: _StatCell(
                  value: '420',
                  label: 'Total EXP',
                  valueColor: navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatCell(
                  value: '33',
                  label: 'Concepts Mastered',
                  valueColor: Colors.green,
                ),
              ),
              Expanded(
                child: _StatCell(
                  value: '1',
                  label: 'Average Level',
                  valueColor: avgLevelColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _StatCell({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillTreePlaceholderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12, width: 0.5),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 1,
              child: ColoredBox(
                color: Colors.black,
                child: CustomPaint(painter: _SkillTreeGraphPainter()),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '(placeholder pic)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillTreeGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.2;

    final nodes = <Offset>[
      Offset(size.width * 0.22, size.height * 0.28),
      Offset(size.width * 0.48, size.height * 0.18),
      Offset(size.width * 0.78, size.height * 0.32),
      Offset(size.width * 0.35, size.height * 0.52),
      Offset(size.width * 0.62, size.height * 0.48),
      Offset(size.width * 0.28, size.height * 0.75),
      Offset(size.width * 0.55, size.height * 0.82),
      Offset(size.width * 0.82, size.height * 0.68),
    ];

    void edge(int a, int b) {
      canvas.drawLine(nodes[a], nodes[b], linePaint);
    }

    edge(0, 1);
    edge(1, 2);
    edge(0, 3);
    edge(1, 4);
    edge(2, 4);
    edge(3, 5);
    edge(4, 6);
    edge(4, 7);
    edge(5, 6);

    final colors = [
      Colors.orange,
      Colors.amber,
      Colors.purpleAccent,
      Colors.tealAccent,
      Colors.orangeAccent,
      Colors.deepPurpleAccent,
      Colors.cyanAccent,
      Colors.limeAccent,
    ];

    for (var i = 0; i < nodes.length; i++) {
      canvas.drawCircle(
        nodes[i],
        5,
        Paint()..color = colors[i % colors.length].withValues(alpha: 0.9),
      );
      canvas.drawCircle(
        nodes[i],
        5,
        Paint()
          ..color = Colors.white24
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}