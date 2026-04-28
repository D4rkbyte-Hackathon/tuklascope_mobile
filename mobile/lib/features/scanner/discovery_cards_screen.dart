import 'dart:io';
import 'dart:async'; // 🚀 NEW: Required for the text timer
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuklascope_mobile/features/home/providers/home_provider.dart';
import 'package:tuklascope_mobile/core/services/learn_service.dart';
import '../../core/services/discovery_service.dart';
import 'tuklas_tutor_sheet.dart';

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
  // 🚀 NEW: Added TickerProviderStateMixin for the advanced animation
  ConsumerState<DiscoveryCardsScreen> createState() =>
      _DiscoveryCardsScreenState();
}

class _DiscoveryCardsScreenState extends ConsumerState<DiscoveryCardsScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0; // 0: Fun Fact, 1: Lesson, 2: Real World
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _deckData;
  final int baseRewardXp = 50;

  // 🚀 NEW: Animation & Timer Variables
  late AnimationController _scanController;
  Timer? _phraseTimer;
  int _currentPhraseIndex = 0;
  late final List<String> _loadingPhrases;

  @override
  void initState() {
    super.initState();

    // 🚀 NEW: The dynamic phrases the AI cycles through
    _loadingPhrases = [
      'Calibrating AI lenses...',
      'Analyzing structural composition...',
      'Cross-referencing historical data...',
      'Extracting core concepts...',
      'Synthesizing ${widget.selectedLens} pathways...',
    ];

    // 🚀 NEW: Setup the sweeping laser animation loop
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // 🚀 NEW: Setup the timer to change the text every 2.5 seconds
    _phraseTimer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (mounted && _isLoading) {
        setState(() {
          _currentPhraseIndex =
              (_currentPhraseIndex + 1) % _loadingPhrases.length;
        });
      }
    });

    _fetchLearningDeck();
  }

  @override
  void dispose() {
    _scanController.dispose();
    _phraseTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLearningDeck() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final data = await LearnService.generateDeck(
      objectName: widget.objectName,
      gradeLevel: widget.gradeLevel,
      selectedLens: widget.selectedLens,
      teaserContext: widget.teaserContext,
    );

    if (!mounted) return;

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

  IconData _getLensIcon() {
    switch (widget.selectedLens.toUpperCase()) {
      case 'STEM':
        return Icons.science;
      case 'ABM':
        return Icons.trending_up;
      case 'HUMSS':
        return Icons.public;
      case 'TVL':
        return Icons.handyman;
      default:
        return Icons.lightbulb;
    }
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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: _deckData != null && !_isLoading
          ? FloatingActionButton.extended(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.auto_awesome),
              label: const Text(
                'Ask Tutor',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              onPressed: () {
                final conceptCard =
                    _deckData?['concept_card'] as Map<String, dynamic>? ?? {};
                showTuklasTutorSheet(
                  context,
                  objectName: widget.objectName,
                  strand: widget.selectedLens,
                  currentCardContent: conceptCard['lesson_text'] ?? '',
                );
              },
            )
          : null,
      bottomNavigationBar: _deckData != null && !_isLoading
          ? _buildChallengeBottomBar(theme)
          : null,
      body: _isLoading
          ? _buildAnimatedLoadingState(theme)
          : _error != null
          ? Center(
              child: Text(
                _error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            )
          : _buildContent(theme),
    );
  }

  // 🚀 NEW: The Cyber-Scanner Animation UI
  Widget _buildAnimatedLoadingState(ThemeData theme) {
    return Container(
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Cyber Scanner Box
          SizedBox(
            height: 150,
            width: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glowing outer ring
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.15,
                        ),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
                // The Central Icon
                Icon(
                  _getLensIcon(),
                  size: 60,
                  color: Colors.white.withValues(alpha: 0.8),
                ),

                // The Sweeping Laser Line
                AnimatedBuilder(
                  animation: _scanController,
                  builder: (context, child) {
                    // Moving the line from top (0) to bottom (150)
                    return Positioned(
                      top: _scanController.value * 145,
                      child: Container(
                        width: 150,
                        height: 3,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.secondary,
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),

          // 🚀 NEW: Cross-fading, sliding dynamic text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.5),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              _loadingPhrases[_currentPhraseIndex],
              key: ValueKey<int>(
                _currentPhraseIndex,
              ), // Key forces the switch animation
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'UNLOCKING SECRETS',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
        ],
      ),
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
                    style: TextStyle(
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
                  _buildActiveCard(theme),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    int index,
    String label,
    IconData icon,
    ThemeData theme,
  ) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.secondary
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.1),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.onSecondary
                    : theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? theme.colorScheme.onSecondary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveCard(ThemeData theme) {
    final concept = _deckData?['concept_card'] ?? {};
    final realWorld = _deckData?['real_world_card'] ?? {};

    if (_selectedIndex == 0) {
      return _buildGlassSection(
        'Mind-Blowing Fact',
        realWorld['fun_fact'] ?? '',
        theme,
      );
    } else if (_selectedIndex == 1) {
      return _buildGlassSection(
        'The Secret',
        concept['lesson_text'] ?? '',
        theme,
        badgeText: '${concept['domain']} | ${concept['skill']}',
      );
    } else {
      return _buildGlassSection(
        'Real World Impact',
        realWorld['application_text'] ?? '',
        theme,
      );
    }
  }

  Widget _buildGlassSection(
    String title,
    String content,
    ThemeData theme, {
    String? badgeText,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (badgeText != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badgeText.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.primary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeBottomBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32, top: 16),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_esports, size: 24),
            SizedBox(width: 12),
            Text(
              'TAKE CHALLENGE TO EARN XP',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChallengeModal() {
    final challengeCard =
        _deckData?['challenge_card'] as Map<String, dynamic>? ?? {};
    final question = challengeCard['question'] ?? "Ready?";
    final options = List<String>.from(challengeCard['options'] ?? []);
    final correctAnswer = challengeCard['correct_answer'] ?? "";
    final explanation = challengeCard['explanation'] ?? "";

    String? selectedOption;
    bool hasAnswered = false;
    bool isCorrect = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'TUKLAS CHALLENGE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        question,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.onSurface,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 32),

                      ...options.map((option) {
                        final bool isThisSelected = selectedOption == option;
                        Color buttonColor = theme.scaffoldBackgroundColor;
                        Color borderColor = theme.colorScheme.onSurface
                            .withValues(alpha: 0.1);

                        if (hasAnswered) {
                          if (isThisSelected && isCorrect) {
                            buttonColor = Colors.green.withValues(alpha: 0.2);
                            borderColor = Colors.green;
                          } else if (isThisSelected && !isCorrect) {
                            buttonColor = Colors.red.withValues(alpha: 0.2);
                            borderColor = Colors.red;
                          }
                        } else if (isThisSelected) {
                          buttonColor = theme.colorScheme.primary.withValues(
                            alpha: 0.2,
                          );
                          borderColor = theme.colorScheme.primary;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: InkWell(
                            onTap: hasAnswered
                                ? null
                                : () => setModalState(
                                    () => selectedOption = option,
                                  ),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: buttonColor,
                                border: Border.all(
                                  color: borderColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 24),
                      if (!hasAnswered)
                        ElevatedButton(
                          onPressed: selectedOption == null
                              ? null
                              : () {
                                  setModalState(() {
                                    hasAnswered = true;
                                    isCorrect =
                                        (selectedOption == correctAnswer);
                                  });

                                  if (isCorrect) {
                                    _saveProgressToBackend();
                                  } else {
                                    Future.delayed(
                                      const Duration(milliseconds: 2500),
                                      () {
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        }
                                      },
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'SUBMIT ANSWER',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isCorrect
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isCorrect ? Colors.green : Colors.red,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                isCorrect ? Icons.check_circle : Icons.cancel,
                                color: isCorrect ? Colors.green : Colors.red,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isCorrect
                                    ? "Brilliant! $explanation"
                                    : "Incorrect. The door closes...",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isCorrect ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (isCorrect) ...[
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text(
                                    'CLAIM XP',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveProgressToBackend() async {
    final success = await DiscoveryService.saveDiscovery(
      objectName: widget.objectName,
      chosenLens: widget.selectedLens,
      imagePath: widget.imagePath,
      learningDeck: _deckData!,
      xpAwarded: baseRewardXp,
    );

    if (success && mounted) {
      ref.invalidate(homeStatsProvider);
    }
  }
}
