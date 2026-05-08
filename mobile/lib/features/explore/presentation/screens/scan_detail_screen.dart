//scan detail screen
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/services/scan_service.dart';

class ScanDetailScreen extends StatefulWidget {
  final String scanId;
  final String objectName;
  final String imagUrl; // Kept your spelling so it doesn't break your navigator!

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
    // Extra padding at the bottom to ensure scroll doesn't hide behind the floating button
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 100;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // ==========================================
          // 1. HERO BACKGROUND IMAGE
          // ==========================================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: widget.imagUrl.isNotEmpty
                ? Image.network(
                    widget.imagUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                  )
                : Container(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
          ),

          // Gradient Fade into content
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5), // Darken top for back button
                    Colors.transparent,
                    theme.colorScheme.surface, // Fade smoothly into the surface below
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // ==========================================
          // 2. MAIN CONTENT SHEET (Scrollable)
          // ==========================================
          Positioned.fill(
            child: _isLoadingScan
                ? Center(
                    child: CircularProgressIndicator(color: theme.colorScheme.secondary),
                  )
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Invisible spacer to push content down below the hero image
                      SliverToBoxAdapter(
                        child: SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                      ),
                      // The Content Sheet
                      SliverToBoxAdapter(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(24, 32, 24, bottomPadding),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, -5),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Target Object Name Hero Text
                              Text(
                                widget.objectName,
                                style: GoogleFonts.montserrat(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.onSurface,
                                  height: 1.1,
                                ),
                              ).animate().fade().slideY(begin: 0.2),

                              const SizedBox(height: 32),

                              // Render your existing beautiful cards!
                              _buildXPRewardCard(theme),
                              const SizedBox(height: 28),
                              _buildSkillCard(theme),
                              const SizedBox(height: 28),
                              _buildLessonSection(theme),
                              const SizedBox(height: 28),
                              if (_realWorldText.isNotEmpty) _buildRealWorldSection(theme),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          // ==========================================
          // 3. HUD FLOATING BACK BUTTON
          // ==========================================
          Positioned(
            top: MediaQuery.paddingOf(context).top + 16,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 14),
                        const SizedBox(width: 8),
                        Text(
                          "RETURN",
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ).animate().fade().slideX(begin: -0.2),
          ),

          // ==========================================
          // 4. FLOATING "ASK TUKLAS TUTOR" BUTTON
          // ==========================================
          if (!_isLoadingScan) // Only show when loaded
            Positioned(
              bottom: MediaQuery.paddingOf(context).bottom + 20,
              left: 24,
              right: 24,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
                  ),
                  elevation: 10,
                  shadowColor: theme.colorScheme.primary.withValues(alpha: 0.6),
                ),
                icon: const Icon(Icons.smart_toy_outlined, size: 24),
                label: Text(
                  "ASK TUKLAS TUTOR",
                  style: GoogleFonts.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                onPressed: () {
                  // TODO: Wire up to Tuklas Tutor Chat Sheet
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tuklas Tutor initializing...', style: GoogleFonts.orbitron()),
                      backgroundColor: theme.colorScheme.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .shimmer(duration: 2.seconds, delay: 1.seconds, color: Colors.white.withValues(alpha: 0.3))
                  .scaleXY(begin: 1.0, end: 1.02, duration: 2.seconds, curve: Curves.easeInOut),
            ),
        ],
      ),
    );
  }

  // =========================================================================
  // YOUR EXISTING CARD BUILDERS (With minor layout tweaks to fit the new sheet)
  // =========================================================================

  Widget _buildXPRewardCard(ThemeData theme) {
    final xpAwarded = _scanData?['xp_awarded'] as int? ?? 50;

    return Container(
      width: double.infinity,
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
                  style: GoogleFonts.orbitron(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.secondary,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  'EXPERIENCE POINTS',
                  style: GoogleFonts.orbitron(
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
              style: GoogleFonts.inter(
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
      width: double.infinity,
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
              style: GoogleFonts.orbitron(
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
            style: GoogleFonts.montserrat(
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
                style: GoogleFonts.inter(
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
      width: double.infinity,
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
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'Learn More',
                    style: GoogleFonts.montserrat(
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
            style: GoogleFonts.inter(
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
      width: double.infinity,
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
              style: GoogleFonts.montserrat(
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
                style: GoogleFonts.inter(
                  fontSize: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _realWorldText,
                  style: GoogleFonts.inter(
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