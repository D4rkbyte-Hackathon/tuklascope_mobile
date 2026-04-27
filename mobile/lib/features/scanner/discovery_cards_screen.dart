// mobile/lib/features/scanner/discovery_cards_screen.dart
import 'package:flutter/material.dart';
import 'package:tuklascope_mobile/features/home/providers/home_provider.dart';
import '../../core/widgets/gradient_scaffold.dart';
import 'package:tuklascope_mobile/core/services/learn_service.dart';
import '../../core/services/discovery_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/home_screen.dart';

class DiscoveryCardsScreen extends ConsumerStatefulWidget {
  final String objectName;
  final String gradeLevel;
  final String selectedLens;
  final String imagePath; // 🚀 NEW: The path to the compressed image

  const DiscoveryCardsScreen({
    super.key,
    required this.objectName,
    required this.gradeLevel,
    required this.selectedLens,
    required this.imagePath,
  });

  @override
  ConsumerState<DiscoveryCardsScreen> createState() =>
      _DiscoveryCardsScreenState();
}

class _DiscoveryCardsScreenState extends ConsumerState<DiscoveryCardsScreen> {
  int _selectedIndex = 0;

  // State variables for network handling
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _deckData;

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
    );

    if (!mounted) return;

    if (data != null) {
      debugPrint('🎯 AI DECK RESPONSE: $data');
      setState(() {
        _deckData = data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error =
            'Failed to generate the learning deck. Please check your connection.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Cache theme

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
          shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ), // Themed Loader
                  const SizedBox(height: 16),
                  Text(
                    'Generating custom lesson...',
                    style: TextStyle(
                      color: theme.colorScheme.primary, // Themed Loader Text
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error, // Themed Error
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                      ), // Themed Error
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _fetchLearningDeck,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            theme.colorScheme.primary, // Themed Button
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            )
          : _buildContent(theme),
    );
  }

  Widget _buildContent(ThemeData theme) {
    final xpReward = _deckData?['xp_reward']?.toString() ?? '50';
    final imageUrl =
        _deckData?['image_url'] ??
        'https://images.unsplash.com/photo-1518548419970-58e3b4079ab2?q=80&w=1000&auto=format&fit=crop';

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              SizedBox(
                height: 350,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: theme.colorScheme.surface.withValues(alpha: 0.5),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.45),
                            Colors.transparent,
                            theme
                                .scaffoldBackgroundColor, // Adaptive Fade to Background!
                          ],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              '${widget.selectedLens.toUpperCase()}: ${widget.objectName}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color:
                                    theme.colorScheme.primary, // Themed Title
                                height: 1.1,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme
                                  .colorScheme
                                  .secondary, // Themed XP Pill (Orange)
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: theme
                                      .colorScheme
                                      .onSecondary, // Matches XP Text
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '+$xpReward XP',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme
                                        .colorScheme
                                        .onSecondary, // Themed XP Text
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          _buildTabButton(0, 'Quick Fact', Icons.bolt, theme),
                          const SizedBox(width: 8),
                          _buildTabButton(
                            1,
                            'Concepts',
                            Icons.lightbulb_outline,
                            theme,
                          ),
                          const SizedBox(width: 8),
                          _buildTabButton(
                            2,
                            'Hands-on',
                            Icons.build_circle_outlined,
                            theme,
                          ),
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
        ),
        Positioned(
          bottom: 24,
          left: 24,
          right: 24,
          child: _buildChallengeButton(theme),
        ),
      ],
    );
  }

  Widget _buildChallengeButton(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.secondary.withValues(
              alpha: 0.4,
            ), // Themed Shadow
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _showChallengeModal,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.secondary, // Themed Orange
          foregroundColor: theme.colorScheme.onSecondary, // Themed White
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
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
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
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
    final question =
        challengeCard['question'] ?? "Are you ready to test your knowledge?";
    final options = List<String>.from(challengeCard['options'] ?? []);
    final correctAnswer = challengeCard['correct_answer'] ?? "";
    final explanation = challengeCard['explanation'] ?? "";

    String? selectedOption;
    bool hasAnswered = false;
    bool isCorrect = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context); // Get theme inside builder

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface, // Themed Modal Background
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
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.3,
                            ), // Themed Handle
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'TUKLAS CHALLENGE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme
                              .colorScheme
                              .secondary, // Themed Challenge Title
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        question,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: theme
                              .colorScheme
                              .onSurface, // Themed Question Text
                        ),
                      ),
                      const SizedBox(height: 24),

                      ...options.map((option) {
                        final bool isThisSelected = selectedOption == option;
                        final bool isThisCorrect = option == correctAnswer;

                        // Base Option Colors (Themed)
                        Color buttonColor = theme.colorScheme.surface;
                        Color textColor = theme.colorScheme.onSurface;
                        Color borderColor = theme.colorScheme.onSurface
                            .withValues(alpha: 0.2);

                        if (hasAnswered) {
                          if (isThisCorrect) {
                            // Correct Answer Colors (Safe for Dark Mode)
                            buttonColor = Colors.green.withValues(alpha: 0.15);
                            borderColor = Colors.green;
                            textColor = Colors.green;
                          } else if (isThisSelected && !isThisCorrect) {
                            // Wrong Answer Colors (Safe for Dark Mode)
                            buttonColor = Colors.red.withValues(alpha: 0.15);
                            borderColor = Colors.red;
                            textColor = Colors.red;
                          }
                        } else if (isThisSelected) {
                          // Selected but not answered yet
                          buttonColor = theme.colorScheme.primary.withValues(
                            alpha: 0.15,
                          );
                          borderColor = theme.colorScheme.primary;
                          textColor = theme.colorScheme.primary;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: InkWell(
                            onTap: hasAnswered
                                ? null
                                : () {
                                    setModalState(() {
                                      selectedOption = option;
                                    });
                                  },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: buttonColor,
                                border: Border.all(
                                  color: borderColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (hasAnswered && isThisCorrect)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                  if (hasAnswered &&
                                      isThisSelected &&
                                      !isThisCorrect)
                                    const Icon(Icons.cancel, color: Colors.red),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 16),

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
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme
                                .colorScheme
                                .primary, // Themed Submit Button
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'SUBMIT ANSWER',
                            style: TextStyle(
                              color: theme
                                  .colorScheme
                                  .onPrimary, // Themed Submit Text
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isCorrect
                                    ? Colors.green.withValues(alpha: 0.15)
                                    : Colors.red.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isCorrect
                                    ? "🎉 Correct! $explanation"
                                    : "Not quite! $explanation",
                                style: TextStyle(
                                  color: isCorrect ? Colors.green : Colors.red,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (isCorrect)
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme
                                      .colorScheme
                                      .secondary, // Themed Claim XP Button
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 32,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'CLAIM XP & CONTINUE',
                                  style: TextStyle(
                                    color: theme
                                        .colorScheme
                                        .onSecondary, // Themed Claim Text
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
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
    if (_deckData == null) return;

    // Show a loading indicator if you want, or just let it save in the background
    final success = await DiscoveryService.saveDiscovery(
      objectName: widget.objectName,
      chosenLens: widget.selectedLens,
      imagePath: widget.imagePath,
      learningDeck: _deckData!,
    );

    if (success) {
      if (mounted) {
        // Tell Riverpod to throw away the old cached Home stats!
        // When the user returns to the Home tab, it will automatically fetch the new 1/3 score.
        ref.invalidate(homeStatsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('XP Claimed and Discovery Saved!')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save. Please try again.')),
        );
      }
    }
  }

  Widget _buildTabButton(
    int index,
    String label,
    IconData icon,
    ThemeData theme,
  ) {
    final bool isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.secondary
                : Colors.transparent, // Themed BG
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.onSurface.withValues(
                      alpha: 0.2,
                    ), // Themed Border
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.onSecondary
                    : theme.colorScheme.onSurface, // Themed Tab Icon
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? theme.colorScheme.onSecondary
                      : theme.colorScheme.onSurface, // Themed Tab Text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveCard(ThemeData theme) {
    final conceptCard =
        _deckData?['concept_card'] as Map<String, dynamic>? ?? {};
    final realWorldCard =
        _deckData?['real_world_card'] as Map<String, dynamic>? ?? {};

    final quickFact =
        realWorldCard['fun_fact'] ??
        "A fascinating fact about this artifact is currently hidden.";

    final concept =
        conceptCard['lesson_text'] ??
        "The underlying principles are still waiting to be discovered.";

    final handsOn =
        realWorldCard['application_text'] ??
        "Try finding a way to apply this in your local community!";

    switch (_selectedIndex) {
      case 0:
        return _buildGlassSection('Quick Fact', quickFact, theme);
      case 1:
        return _buildGlassSection('Concepts', concept, theme);
      case 2:
        return _buildGlassSection('Hands-on Project', handsOn, theme);
      default:
        return const SizedBox();
    }
  }

  Widget _buildGlassSection(String title, String content, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(
          alpha: 0.85,
        ), // Themed Adaptive Glass Background
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          width: 2,
        ), // Themed subtle border
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05), // Themed shadow
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.secondary, // Themed Label (Orange)
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(
                alpha: 0.9,
              ), // Themed Description
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
