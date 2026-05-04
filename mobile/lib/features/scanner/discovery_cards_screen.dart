import 'dart:io';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; // 🚀 NEW: Added Google Fonts
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

class _DiscoveryCardsScreenState extends ConsumerState<DiscoveryCardsScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _deckData;
  final int baseRewardXp = 50;

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
      barrierColor: Colors.black.withValues(alpha: 0.8), // Darker backdrop
      barrierDismissible: false,
      builder: (context) => _DeckQueryModal(lens: widget.selectedLens),
    );

    final data = await LearnService.generateDeck(
      objectName: widget.objectName,
      gradeLevel: widget.gradeLevel,
      selectedLens: widget.selectedLens,
      teaserContext: widget.teaserContext,
    );

    if (!mounted) return;

    Navigator.pop(context);

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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(
            context,
            false,
          ), // Pop with false (did not complete)
        ),
      ),
      floatingActionButton: _deckData != null && !_isLoading
          ? FloatingActionButton.extended(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.auto_awesome),
              label: Text(
                'Ask Tutor',
                style: GoogleFonts.inter(fontWeight: FontWeight.w900),
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
                style: GoogleFonts.inter(
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
                style: GoogleFonts.orbitron(
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
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.primary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: GoogleFonts.inter(
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sports_esports, size: 24),
            const SizedBox(width: 12),
            // 🚀 FIX: Wrapped in Flexible and FittedBox
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'TAKE CHALLENGE TO EARN XP',
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
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

    int attemptsLeft = 2;
    String? selectedOption;
    bool isEvaluating = false;
    bool? lastResult; // null = waiting, true = correct, false = wrong

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
                      // Header showing Heart Attempts
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TUKLAS CHALLENGE',
                            style: GoogleFonts.orbitron(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          Row(
                            children: List.generate(
                              2,
                              (index) => Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Icon(
                                  index < attemptsLeft
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 24,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        question,
                        style: GoogleFonts.montserrat(
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

                        if (isEvaluating && isThisSelected) {
                          if (lastResult == true) {
                            buttonColor = Colors.green.withValues(alpha: 0.2);
                            borderColor = Colors.green;
                          } else if (lastResult == false) {
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
                            onTap: isEvaluating
                                ? null
                                : () => setModalState(
                                      () => selectedOption = option,
                                    ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
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
                                style: GoogleFonts.inter(
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

                      // THE EVALUATION LOGIC UI
                      if (!isEvaluating)
                        ElevatedButton(
                          onPressed: selectedOption == null
                              ? null
                              : () {
                                  setModalState(() {
                                    isEvaluating = true;
                                    lastResult =
                                        (selectedOption == correctAnswer);
                                  });

                                  if (lastResult == true) {
                                    _saveProgressToBackend();
                                  } else {
                                    attemptsLeft--;
                                    if (attemptsLeft > 0) {
                                      // Reset after a brief flash of red
                                      Future.delayed(
                                        const Duration(milliseconds: 1500),
                                        () {
                                          if (context.mounted) {
                                            setModalState(() {
                                              selectedOption = null;
                                              isEvaluating = false;
                                              lastResult = null;
                                            });
                                          }
                                        },
                                      );
                                    } else {
                                      // Out of tries
                                      Future.delayed(
                                        const Duration(milliseconds: 2500),
                                        () {
                                          if (context.mounted) {
                                            Navigator.pop(
                                              context,
                                            ); // Close Modal
                                            Navigator.pop(
                                              context,
                                              false,
                                            ); // Return to Teaser Doors
                                          }
                                        },
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'SUBMIT ANSWER',
                            style: GoogleFonts.inter(
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
                            color: lastResult == true
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: lastResult == true
                                  ? Colors.green
                                  : Colors.red,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                lastResult == true
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: lastResult == true
                                    ? Colors.green
                                    : Colors.red,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                lastResult == true
                                    ? "Brilliant!\n$explanation"
                                    : attemptsLeft > 0
                                    ? "Incorrect. You have 1 attempt remaining."
                                    : "Incorrect. The door closes...",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  color: lastResult == true
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (lastResult == true) ...[
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Pop Modal
                                    Navigator.pop(
                                      context,
                                      true,
                                    ); // Return TRUE to lock the portal
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text(
                                    'CLAIM XP',
                                    style: GoogleFonts.orbitron(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.5,
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

// -------------------------------------------------------------------------
// UPGRADED SCI-FI LOADING MODAL FOR LEARNING DECK
// -------------------------------------------------------------------------
class _DeckQueryModal extends StatefulWidget {
  final String lens;
  const _DeckQueryModal({required this.lens});

  @override
  State<_DeckQueryModal> createState() => _DeckQueryModalState();
}

class _DeckQueryModalState extends State<_DeckQueryModal>
    with SingleTickerProviderStateMixin {
  late final Stream<int> _timerStream;
  late final List<String> _phrases;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _phrases = [
      'Calibrating AI lenses...',
      'Analyzing structural composition...',
      'Cross-referencing historical data...',
      'Extracting core concepts...',
      'Synthesizing ${widget.lens} pathways...',
    ];
    _timerStream = Stream.periodic(
      const Duration(milliseconds: 2000),
      (i) => i,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 280,
            decoration: BoxDecoration(
              color: const Color(
                0xFF0A0E17,
              ).withValues(alpha: 0.8), // Deep transparent blue
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 40,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 100 + (_pulseController.value * 20),
                          height: 100 + (_pulseController.value * 20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.secondary.withValues(
                              alpha: 0.1,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.secondary,
                            strokeWidth: 3,
                          ),
                        ),
                        Icon(
                          Icons.hub,
                          size: 36,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 40),
                StreamBuilder<int>(
                  stream: _timerStream,
                  builder: (context, snapshot) {
                    final index = (snapshot.data ?? 0) % _phrases.length;
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        _phrases[index].toUpperCase(),
                        key: ValueKey<int>(index),
                        style: GoogleFonts.orbitron(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                          letterSpacing: 2.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}