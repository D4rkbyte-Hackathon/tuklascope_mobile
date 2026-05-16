import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tuklascope_mobile/core/services/learn_service.dart';
import 'tuklas_tutor_sheet.dart';
import 'widgets/deck_query_modal.dart';
import 'widgets/glass_concept_card.dart';
import 'widgets/challenge_bottom_sheet.dart';

class DiscoveryCardsScreen extends ConsumerStatefulWidget {
  final String objectName;
  final String gradeLevel;
  final String selectedLens;
  final String imagePath;
  final String teaserContext;

  const DiscoveryCardsScreen({
    super.key,
    required this.objectName,
    required this.gradeLevel,
    required this.selectedLens,
    required this.imagePath,
    required this.teaserContext,
  });

  @override
  ConsumerState<DiscoveryCardsScreen> createState() => _DiscoveryCardsScreenState();
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
    final challengeCard = _deckData?['challenge_card'] as Map<String, dynamic>? ?? {};
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => ChallengeBottomSheet(
        challengeCard: challengeCard,
        objectName: widget.objectName,
        selectedLens: widget.selectedLens,
        imagePath: widget.imagePath,
        fullDeckData: _deckData!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context, false), 
        ),
      ),
      floatingActionButton: _deckData != null && !_isLoading
          ? FloatingActionButton.extended(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.auto_awesome),
              label: Text('Ask Tutor', style: GoogleFonts.inter(fontWeight: FontWeight.w900)),
              onPressed: () {
                final conceptCard = _deckData?['concept_card'] as Map<String, dynamic>? ?? {};
                showTuklasTutorSheet(
                  context,
                  objectName: widget.objectName,
                  strand: widget.selectedLens,
                  currentCardContent: conceptCard['lesson_text'] ?? '',
                );
              },
            )
          : null,
      bottomNavigationBar: _deckData != null && !_isLoading ? _buildChallengeBottomBar(theme) : null,
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
              ? Center(child: Text(_error!, style: GoogleFonts.inter(color: theme.colorScheme.error)))
              : _buildContent(theme),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          SizedBox(
            height: 350,
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
                        Colors.black.withValues(alpha: 0.6),
                        Colors.transparent,
                        theme.scaffoldBackgroundColor,
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -30),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.selectedLens.toUpperCase()}: ${widget.objectName}',
                    style: GoogleFonts.montserrat(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      _buildTabButton(0, 'Fun Fact', Icons.bolt, theme),
                      const SizedBox(width: 8),
                      _buildTabButton(1, 'Lesson', Icons.menu_book, theme),
                      const SizedBox(width: 8),
                      _buildTabButton(2, 'Real World', Icons.public, theme),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildActiveCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon, ThemeData theme) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.secondary : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? theme.colorScheme.secondary : theme.colorScheme.onSurface.withValues(alpha: 0.1),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? theme.colorScheme.onSecondary : theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? theme.colorScheme.onSecondary : theme.colorScheme.onSurface,
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
      return GlassConceptCard(title: 'Mind-Blowing Fact', content: realWorld['fun_fact'] ?? '');
    } else if (_selectedIndex == 1) {
      return GlassConceptCard(
        title: 'The Secret', 
        content: concept['lesson_text'] ?? '',
        badgeText: '${concept['domain']} | ${concept['skill']}',
      );
    } else {
      return GlassConceptCard(title: 'Real World Impact', content: realWorld['application_text'] ?? '');
    }
  }

  Widget _buildChallengeBottomBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 64, top: 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _showChallengeModal,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: theme.colorScheme.onSecondary,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sports_esports, size: 24),
            const SizedBox(width: 12),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'TAKE CHALLENGE TO EARN XP',
                  style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}