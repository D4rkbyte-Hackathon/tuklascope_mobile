import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/services/scan_service.dart';

class ScanDetailScreen extends StatefulWidget {
  final String scanId;
  final String objectName;
  final String imagUrl;

  const ScanDetailScreen({
    super.key,
    required this.scanId,
    required this.objectName,
    required this.imagUrl,
  });

  @override
  State<ScanDetailScreen> createState() => _ScanDetailScreenState();
}

class _ScanDetailScreenState extends State<ScanDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _xpAnimationController;
  Map<String, dynamic>? _scanData;
  bool _isLoadingScan = true;

  // Parsed learning deck data
  String _skill = '';
  String _domain = '';
  String _lessonText = '';
  String _realWorldText = '';

  @override
  void initState() {
    super.initState();
    _xpAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fetchScanDetails();
  }

  @override
  void dispose() {
    _xpAnimationController.dispose();
    super.dispose();
  }

  Future<void> _fetchScanDetails() async {
    try {
      final scanData = await ScanService.getScanById(widget.scanId);
      if (mounted) {
        setState(() {
          _scanData = scanData;
          _isLoadingScan = false;
          _parseLearningDeck(scanData);
        });
        // Play XP animation
        _xpAnimationController.forward();
      }
    } catch (e) {
      debugPrint('Error fetching scan details: $e');
      if (mounted) {
        setState(() => _isLoadingScan = false);
      }
    }
  }

  void _parseLearningDeck(Map<String, dynamic>? scanData) {
    if (scanData == null) return;

    try {
      final learningDeck = scanData['learning_deck'];
      if (learningDeck == null) return;

      // Parse concept_card
      if (learningDeck['concept_card'] != null) {
        final conceptCard = learningDeck['concept_card'];
        _skill = conceptCard['skill'] ?? 'Unknown Skill';
        _domain = conceptCard['domain'] ?? 'General Knowledge';
        _lessonText = conceptCard['lesson_text'] ?? 'No lesson available';
      }

      // Parse real_world_card
      if (learningDeck['real_world_card'] != null) {
        final realWorldCard = learningDeck['real_world_card'];
        _realWorldText = realWorldCard['fun_fact'] ?? 'No fun fact available';
      }

      debugPrint('✅ Parsed learning deck data');
    } catch (e) {
      debugPrint('Error parsing learning deck: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 100;

    return GradientScaffold(
      body: SafeArea(
        bottom: false,
        child: _isLoadingScan
            ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.secondary,
                ),
              )
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ==========================================
                  // FLOATING APP BAR
                  // ==========================================
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    leading: BackButton(color: theme.colorScheme.onSurface),
                    title: Text(
                      'Discovery',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  // ==========================================
                  // CONTENT
                  // ==========================================
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 8),
                        // 1. SCAN IMAGE HERO
                        _buildScanImageSection(theme),
                        const SizedBox(height: 32),
                        // 2. GAMIFIED XP CARD
                        _buildXPRewardCard(theme),
                        const SizedBox(height: 28),
                        // 3. SKILL CARD
                        _buildSkillCard(theme),
                        const SizedBox(height: 28),
                        // 4. LESSON SECTION
                        _buildLessonSection(theme),
                        const SizedBox(height: 28),
                        // 5. REAL WORLD SECTION
                        if (_realWorldText.isNotEmpty)
                          _buildRealWorldSection(theme),
                        SizedBox(height: bottomPadding),
                      ]),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildScanImageSection(ThemeData theme) {
    return Center(
      child: Container(
        width: double.infinity,
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.secondary.withValues(alpha: 0.4),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image background
              widget.imagUrl != null && widget.imagUrl!.isNotEmpty
                  ? Image.network(
                      widget.imagUrl!,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: theme.colorScheme.surface,
                          child: Center(
                            child: Icon(
                              Icons.photo_outlined,
                              size: 80,
                              color:
                                  theme.colorScheme.onSurface.withValues(alpha: 0.2),
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: theme.colorScheme.surface,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: theme.colorScheme.surface,
                      child: Center(
                        child: Icon(
                          Icons.photo_outlined,
                          size: 80,
                          color:
                              theme.colorScheme.onSurface.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
              // Overlay gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.4),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.2, duration: 500.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildXPRewardCard(ThemeData theme) {
    final xpAwarded = _scanData?['xp_awarded'] as int? ?? 50;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.secondary.withValues(alpha: 0.25),
            theme.colorScheme.primary.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Star animation top
          ScaleTransition(
            scale: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: _xpAnimationController, curve: const Interval(0, 0.3, curve: Curves.elasticOut)),
            ),
            child: Icon(
              Icons.auto_awesome,
              color: Colors.amber[400],
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          // XP Counter
          ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1).animate(
              CurvedAnimation(parent: _xpAnimationController, curve: const Interval(0.2, 0.8, curve: Curves.elasticOut)),
            ),
            child: Column(
              children: [
                Text(
                  '+$xpAwarded',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.secondary,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  'EXPERIENCE POINTS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Celebration message
          FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: _xpAnimationController, curve: const Interval(0.6, 1, curve: Curves.easeInOut)),
            ),
            child: Text(
              '🎉 Excellent Discovery! Keep exploring!',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    )
        .animate(delay: 200.ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.15, duration: 500.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildSkillCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.12),
            theme.colorScheme.tertiary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '💡 SKILL UNLOCKED',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Skill name
          Text(
            _skill,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          // Domain
          Row(
            children: [
              Icon(
                Icons.category,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                _domain,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate(delay: 400.ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.15, duration: 500.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildLessonSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.auto_stories_outlined,
                  size: 24,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LESSON',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'Learn More',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Divider
          Divider(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            height: 1,
          ),
          const SizedBox(height: 16),
          // Lesson text
          Text(
            _lessonText,
            style: TextStyle(
              fontSize: 14,
              height: 1.8,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    )
        .animate(delay: 600.ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.15, duration: 500.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildRealWorldSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.12),
            Colors.teal.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '🌍 REAL WORLD',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.green,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Fun fact
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '✨',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _realWorldText,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.7,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate(delay: 800.ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.15, duration: 500.ms, curve: Curves.easeOutCubic);
  }
}
