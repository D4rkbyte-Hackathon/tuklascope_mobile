import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tuklascope_mobile/core/services/discovery_service.dart';
import 'package:tuklascope_mobile/features/home/providers/home_provider.dart';
import 'package:tuklascope_mobile/features/profile/providers/profile_provider.dart';

class ChallengeBottomSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> challengeCard;
  final String objectName;
  final String selectedLens;
  final String imagePath;
  final Map<String, dynamic> fullDeckData;
  final String? gamificationToken;

  const ChallengeBottomSheet({
    super.key,
    required this.challengeCard,
    required this.objectName,
    required this.selectedLens,
    required this.imagePath,
    required this.fullDeckData,
    this.gamificationToken,
  });

  @override
  ConsumerState<ChallengeBottomSheet> createState() =>
      _ChallengeBottomSheetState();
}

class _ChallengeBottomSheetState extends ConsumerState<ChallengeBottomSheet> {
  int attemptsLeft = 2;
  String? selectedOption;
  bool isEvaluating = false;
  bool? lastResult; // null = waiting, true = correct, false = wrong

  late final String question;
  late final List<String> options;
  late final String correctAnswer;
  late final String explanation;

  @override
  void initState() {
    super.initState();
    question = widget.challengeCard['question'] ?? "Ready?";
    options = List<String>.from(widget.challengeCard['options'] ?? []);
    correctAnswer = widget.challengeCard['correct_answer'] ?? "";
    explanation = widget.challengeCard['explanation'] ?? "";
  }

  Future<void> _saveProgressToBackend() async {
    final profileStats = await ref.read(profileStatsProvider.future);
    final xpMap = {
      'STEM': profileStats.stemXp,
      'ABM': profileStats.abmXp,
      'HUMSS': profileStats.humssXp,
      'TVL': profileStats.tvlXp,
    };

    String topStrand = 'STEM';
    int maxXp = -1;
    xpMap.forEach((strand, xp) {
      if (xp > maxXp) {
        maxXp = xp;
        topStrand = strand;
      }
    });

    final isAligned = widget.selectedLens.toUpperCase() == topStrand;

    final success = await DiscoveryService.saveDiscovery(
      objectName: widget.objectName,
      chosenLens: widget.selectedLens,
      imagePath: widget.imagePath,
      learningDeck: widget.fullDeckData,
      isAlignedWithCompass: isAligned,
      gamificationToken: widget.gamificationToken,
    );

    if (success && mounted) {
      ref.invalidate(homeStatsProvider);
      ref.invalidate(profileStatsProvider);
    }
  }

  void _submitAnswer() {
    setState(() {
      isEvaluating = true;
      lastResult = (selectedOption == correctAnswer);
    });

    if (lastResult == true) {
      _saveProgressToBackend();
    } else {
      attemptsLeft--;
      if (attemptsLeft > 0) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              selectedOption = null;
              isEvaluating = false;
              lastResult = null;
            });
          }
        });
      } else {
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (mounted) {
            Navigator.pop(context); // Close Modal
            Navigator.pop(context, false); // Return to Teaser Doors
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // BUG FIX: Wrap the container in a ConstrainedBox to limit max height to 90% of screen height
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
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
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SYSTEM OVERRIDE',
                      style: GoogleFonts.orbitron(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ).animate().fade().slideX(begin: -0.1),
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
                        ).animate().fade().scale(delay: (100 * index).ms),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  question,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    height: 1.4,
                  ),
                ).animate().fade(delay: 200.ms),
                const SizedBox(height: 32),

                ...options.map((option) {
                  final bool isThisSelected = selectedOption == option;
                  Color buttonColor = theme.scaffoldBackgroundColor;
                  Color borderColor = theme.colorScheme.onSurface.withValues(
                    alpha: 0.1,
                  );

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
                          : () => setState(() => selectedOption = option),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: buttonColor,
                          border: Border.all(color: borderColor, width: 1.5),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(4),
                          ),
                        ),
                        child: Text(
                          option,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ).animate().fade(delay: 300.ms).slideY(begin: 0.1);
                }),

                const SizedBox(height: 24),

                if (!isEvaluating)
                  ElevatedButton(
                    onPressed: selectedOption == null ? null : _submitAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'SUBMIT ANSWER',
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ).animate().fade(delay: 400.ms)
                else
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: lastResult == true
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: lastResult == true ? Colors.green : Colors.red,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                              lastResult == true
                                  ? Icons.check_circle_outline
                                  : Icons.cancel_outlined,
                              color: lastResult == true
                                  ? Colors.green
                                  : Colors.red,
                              size: 48,
                            )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scaleXY(begin: 0.9, end: 1.1),
                        const SizedBox(height: 16),
                        Text(
                          lastResult == true
                              ? "ACCESS GRANTED\n$explanation"
                              : attemptsLeft > 0
                              ? "WARNING: Incorrect. You have 1 attempt remaining."
                              : "CRITICAL FAILURE. The door closes...",
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
                              ); // Return TRUE to Teaser Doors
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.download_rounded),
                                const SizedBox(width: 8),
                                Text(
                                  'EXTRACT XP',
                                  style: GoogleFonts.orbitron(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ).animate().scale(curve: Curves.elasticOut),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
