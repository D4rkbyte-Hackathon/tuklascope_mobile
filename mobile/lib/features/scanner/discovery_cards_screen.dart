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
  ConsumerState<DiscoveryCardsScreen> createState() =>
      _DiscoveryCardsScreenState();
}

class _DiscoveryCardsScreenState extends ConsumerState<DiscoveryCardsScreen> {
  int _selectedIndex = 0; // 0: Fun Fact, 1: Lesson, 2: Real World
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _deckData;

  final int baseRewardXp = 50;

  @override
  void initState() {
    super.initState();
    _fetchLearningDeck();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 🚀 NEW: This is no longer a Scaffold. It's a Container meant to slide up as a Bottom Sheet!
    return Container(
      height:
          MediaQuery.of(context).size.height * 0.85, // Takes up 85% of screen
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // Small drag handle indicator
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 12),
                  height: 5,
                  width: 50,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Synthesizing ${widget.selectedLens} Knowledge...',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _error != null
                    ? Center(
                        child: Text(
                          _error!,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      )
                    : _buildContent(theme),
              ),
            ],
          ),

          // Ask Tutor FAB mapped to top right of the sheet
          if (_deckData != null)
            Positioned(
              top: 20,
              right: 20,
              child: FloatingActionButton.extended(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.auto_awesome, size: 20),
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
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.selectedLens.toUpperCase()}: ${widget.objectName}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 24),
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
              ],
            ),
          ),
        ),
        _buildChallengeBottomBar(theme),
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
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
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
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
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
        isAccent: true,
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
    bool isAccent = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isAccent
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isAccent
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.onSurface.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align to top in case title wraps
            children: [
              // 🚀 FIX: Wrapped Title in Expanded to prevent RenderFlex Overflow!
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: isAccent
                        ? theme.colorScheme.primary
                        : theme.colorScheme.secondary,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              if (badgeText != null)
                Flexible(
                  // 🚀 FIX: Wrapped Badge in Flexible so it yields space if needed
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    margin: const EdgeInsets.only(left: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badgeText.toUpperCase(),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
              height: 1.6,
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
      isDismissible: false, // Prevent accidental closing
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

                        // 🚀 NEW ANTI-FARMING STYLING
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
                                    // 🚀 NEW: KICK OUT LOGIC FOR WRONG ANSWERS
                                    Future.delayed(
                                      const Duration(milliseconds: 2500),
                                      () {
                                        if (context.mounted) {
                                          Navigator.pop(context); // Close modal
                                          Navigator.pop(
                                            context,
                                          ); // Kick out of card
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
