import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:tuklascope_mobile/core/services/learn_service.dart';
import 'tuklas_tutor_screen.dart'; // 🚀 UPDATED IMPORT
import 'widgets/deck_query_modal.dart';
import 'widgets/glass_concept_card.dart';
import 'widgets/challenge_bottom_sheet.dart';

class DiscoveryCardsScreen extends ConsumerStatefulWidget {
  final String objectName;
  final String gradeLevel;
  final String selectedLens;
  final String imagePath;
  final String teaserContext;
  final String? gamificationToken;

  const DiscoveryCardsScreen({
    super.key,
    required this.objectName,
    required this.gradeLevel,
    required this.selectedLens,
    required this.imagePath,
    required this.teaserContext,
    this.gamificationToken,
  });

  @override
  ConsumerState<DiscoveryCardsScreen> createState() =>
      _DiscoveryCardsScreenState();
}

class _DiscoveryCardsScreenState extends ConsumerState<DiscoveryCardsScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _deckData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLearningDeck();
    });
  }

  Future<void> _fetchLearningDeck() async {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      barrierDismissible: false,
      builder: (context) => DeckQueryModal(lens: widget.selectedLens),
    );

    final data = await LearnService.generateDeck(
      objectName: widget.objectName,
      gradeLevel: widget.gradeLevel,
      selectedLens: widget.selectedLens,
      teaserContext: widget.teaserContext,
    );

    if (!mounted) return;
    Navigator.pop(context); // Dismiss loading modal

    if (data != null) {
      setState(() {
        _deckData = data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = 'Failed to generate the learning deck. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _showChallengeModal() {
    final challengeCard =
        _deckData?['challenge_card'] as Map<String, dynamic>? ?? {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChallengeBottomSheet(
        challengeCard: challengeCard,
        objectName: widget.objectName,
        selectedLens: widget.selectedLens,
        imagePath: widget.imagePath,
        fullDeckData: _deckData!,
        gamificationToken: widget.gamificationToken,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      bottomNavigationBar: _deckData != null && !_isLoading
          ? _buildChallengeBottomBar(theme)
          : null,
      body: _isLoading
          ? Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(File(widget.imagePath)),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.85),
                    BlendMode.darken,
                  ),
                ),
              ),
            )
          : _error != null
          ? Center(
              child: Text(
                _error!,
                style: GoogleFonts.inter(color: theme.colorScheme.error),
              ),
            )
          : Stack(
              children: [
                _buildScrollableContent(theme, isDark),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildBackButton(theme),
                  ),
                ),
              ],
            ),
    );
  }

  static const double _heroImageHeight = 350;
  static const double _contentPanelTopRadius = 32;

  Widget _buildBackButton(ThemeData theme) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, false),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildScrollableContent(ThemeData theme, bool isDark) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Hero image sits above the panel — no overlap.
        SliverToBoxAdapter(
          child: SizedBox(
            height: _heroImageHeight,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(File(widget.imagePath), fit: BoxFit.cover),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.45),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.55],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(_contentPanelTopRadius),
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.surface,
                            theme.colorScheme.primary.withValues(
                              alpha: isDark ? 0.08 : 0.03,
                            ),
                            theme.colorScheme.surface,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Opacity(
                      opacity: isDark ? 0.03 : 0.06,
                      child: CustomPaint(
                        painter: _GridPainter(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.objectName.toUpperCase(),
                          style: GoogleFonts.orbitron(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: 2.0,
                            height: 1.1,
                          ),
                        ).animate().fade(delay: 100.ms).slideX(begin: -0.1),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.15),
                            border: Border(
                              left: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.category_rounded,
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.selectedLens.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.primary,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fade(delay: 200.ms).slideX(begin: -0.1),
                        const SizedBox(height: 40),
                        Row(
                          children: [
                            _buildTabButton(0, 'Fact', Icons.bolt, theme),
                            const SizedBox(width: 8),
                            _buildTabButton(1, 'Lesson', Icons.menu_book, theme),
                            const SizedBox(width: 8),
                            _buildTabButton(2, 'World', Icons.public, theme),
                          ],
                        ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
                        const SizedBox(height: 32),
                        _buildActiveCard(),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary.withValues(
                                alpha: 0.1,
                              ),
                              foregroundColor: theme.colorScheme.secondary,
                              side: BorderSide(
                                color: theme.colorScheme.secondary.withValues(
                                  alpha: 0.5,
                                ),
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.smart_toy_rounded, size: 22),
                            label: Text(
                              'ASK TUKLAS TUTOR',
                              style: GoogleFonts.orbitron(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                            onPressed: () {
                              final conceptCard =
                                  _deckData?['concept_card'] as Map<String, dynamic>? ??
                                  {};
                              navigateToTuklasTutor(
                                context,
                                objectName: widget.objectName,
                                strand: widget.selectedLens,
                                currentCardContent: conceptCard['lesson_text'] ?? '',
                              );
                            },
                          ),
                        ).animate().fade(delay: 400.ms).slideY(begin: 0.1),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(
    int index,
    String label,
    IconData icon,
    ThemeData theme,
  ) {
    final isSelected = _selectedIndex == index;
    final color = isSelected
        ? theme.colorScheme.secondary
        : theme.colorScheme.onSurface.withValues(alpha: 0.5);
    final bgColor = isSelected
        ? theme.colorScheme.secondary.withValues(alpha: 0.15)
        : Colors.transparent;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? theme.colorScheme.secondary
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveCard() {
    final concept = _deckData?['concept_card'] ?? {};
    final realWorld = _deckData?['real_world_card'] ?? {};

    if (_selectedIndex == 0) {
      return GlassConceptCard(
        title: 'DATALOG // ANOMALY',
        content: realWorld['fun_fact'] ?? '',
      );
    } else if (_selectedIndex == 1) {
      return GlassConceptCard(
        title: 'DATALOG // CORE SECRET',
        content: concept['lesson_text'] ?? '',
        badgeText: '${concept['domain']} | ${concept['skill']}',
      );
    } else {
      return GlassConceptCard(
        title: 'DATALOG // APPLICATION',
        content: realWorld['application_text'] ?? '',
      );
    }
  }

  Widget _buildChallengeBottomBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.paddingOf(context).bottom + 16,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child:
          ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 15,
                  shadowColor: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
                onPressed: _showChallengeModal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.sports_esports_rounded, size: 22),
                    const SizedBox(width: 12),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'TAKE CHALLENGE TO EARN XP',
                          style: GoogleFonts.orbitron(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .shimmer(
                duration: 2.seconds,
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.3),
              ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    const spacing = 40.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
