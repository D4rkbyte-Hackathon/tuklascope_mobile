import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart'; 

import '../../core/widgets/gradient_scaffold.dart';
import 'compass_results_screen.dart';
import 'models/compass_data.dart';
import 'widgets/compass_question_card.dart';

class CompassQuestionsScreen extends StatefulWidget {
  const CompassQuestionsScreen({super.key});

  @override
  State<CompassQuestionsScreen> createState() => _CompassQuestionsScreenState();
}

class _CompassQuestionsScreenState extends State<CompassQuestionsScreen> {
  final String _userEducationLevel = 'Others'; 
  late final List<CompassQuestion> _activeQuestions;
  final Map<int, CompassOption> _selectedAnswers = {};
  
  late final List<GlobalKey> _questionKeys;
  final ScrollController _scrollController = ScrollController();

  // 🚀 ADDED: Threshold Logic
  final int _minimumRequired = 5;

  @override
  void initState() {
    super.initState();
    _initializeAndShuffleQuestions();
    _questionKeys = List.generate(_activeQuestions.length, (_) => GlobalKey());
  }

  void _initializeAndShuffleQuestions() {
    final rawQuestions = compassQuestionBanks[_userEducationLevel] ?? compassQuestionBanks['Others']!;

    _activeQuestions = rawQuestions.map((q) {
      final shuffledOptions = List<CompassOption>.from(q.options)..shuffle();
      return CompassQuestion(question: q.question, options: shuffledOptions);
    }).toList();

    _activeQuestions.shuffle();
  }

  // 🚀 UPDATED: Logic Getters
  bool get _canProceed => _selectedAnswers.length >= _minimumRequired;
  bool get _isAllAnswered => _selectedAnswers.length == _activeQuestions.length;
  double get _progress => _selectedAnswers.length / _activeQuestions.length;

  void _onOptionSelected(int questionIndex, CompassOption option) {
    setState(() => _selectedAnswers[questionIndex] = option);
 
    int? nextIndex;
    for (int i = questionIndex + 1; i < _activeQuestions.length; i++) {
      if (!_selectedAnswers.containsKey(i)) {
        nextIndex = i;
        break;
      }
    }

    if (nextIndex == null) {
      for (int i = 0; i < questionIndex; i++) {
        if (!_selectedAnswers.containsKey(i)) {
          nextIndex = i;
          break;
        }
      }
    }
    
    if (nextIndex == null) return; 
 
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _questionKeys[nextIndex!];
      final ctx = key.currentContext;
      if (ctx == null) return;
 
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        alignment: 0.08, 
      );
    });
  }

  void _submitAnswers() {
    if (_canProceed) { // 🚀 CHANGED: Only requires the minimum 5 now
      final Map<Affinity, int> scores = {
        Affinity.stem: 0, Affinity.abm: 0, Affinity.humss: 0, Affinity.tvl: 0,
      };

      for (var option in _selectedAnswers.values) {
        scores[option.affinity] = (scores[option.affinity] ?? 0) + 1;
      }

      // 🚀 CHANGED: Calculate percentage based ONLY on answered questions, not total available
      final int totalAnswered = _selectedAnswers.length;
      final Map<Affinity, double> percentages = {
        for (var key in scores.keys) key: scores[key]! / totalAnswered,
      };

      Affinity topAffinity = Affinity.stem;
      double highestScore = -1;
      
      percentages.forEach((affinity, score) {
        if (score > highestScore) {
          highestScore = score;
          topAffinity = affinity;
        }
      });

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => CompassResultsScreen(
            topAffinity: topAffinity,
            affinityScores: percentages,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final neonOrange = theme.colorScheme.secondary;
    final primaryBlue = theme.colorScheme.primary;

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, 
        centerTitle: true, 
        title: RichText(
          text: TextSpan(
            style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.w900), 
            children: [
              TextSpan(text: 'Tuklascope ', style: TextStyle(color: primaryBlue)), 
              TextSpan(text: 'Compass', style: TextStyle(color: neonOrange)), 
            ],
          ),
        ).animate().fade(duration: 600.ms).slideY(begin: -0.2, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
        
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6.0),
          child: Stack(
            children: [
              Container(height: 4, width: double.infinity, color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                height: 4,
                width: MediaQuery.of(context).size.width * _progress, // Shows progress towards 10
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primaryBlue, neonOrange]),
                  boxShadow: [BoxShadow(color: primaryBlue.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 1)],
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        bottom: false, 
        child: Stack(
          children: [
            ListView.separated(
              controller: _scrollController,
              cacheExtent: 5000,
              padding: EdgeInsets.only(
                top: 24.0,
                left: 24.0,
                right: 24.0,
                // 🚀 ADDED EXTRA PADDING at the bottom so the last card doesn't hide behind the taller submit bar
                bottom: MediaQuery.paddingOf(context).bottom + 150.0,
              ),
              physics: const BouncingScrollPhysics(),
              itemCount: _activeQuestions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 32),
              itemBuilder: (context, questionIndex) {
                return CompassQuestionCard(
                  key: _questionKeys[questionIndex],
                  questionIndex: questionIndex,
                  totalQuestions: _activeQuestions.length,
                  questionData: _activeQuestions[questionIndex],
                  selectedOption: _selectedAnswers[questionIndex],
                  onOptionSelected: (option) => _onOptionSelected(questionIndex, option),
                ).animate().fade(duration: 600.ms, delay: (100 * questionIndex).ms)
                 .slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: (100 * questionIndex).ms);
              },
            ),
            
            _buildFloatingSubmitBar(theme, neonOrange),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingSubmitBar(ThemeData theme, Color neonOrange) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: SafeArea(
            top: false, 
            child: Container(
              padding: const EdgeInsets.only(
                left: 24.0, right: 24.0, top: 20.0, bottom: 20.0, 
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.15),
                border: Border(top: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.2))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🚀 ADDED: The dynamic tip text that appears after 5 questions
                  if (_canProceed && !_isAllAnswered)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline_rounded, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                          const SizedBox(width: 8),
                          Text(
                            'You can proceed, or answer more for higher accuracy.',
                            style: GoogleFonts.inter(
                              fontSize: 12, 
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7)
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade().slideY(begin: 0.5, end: 0, duration: 300.ms),

                  SizedBox(
                    height: 56,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _canProceed ? [
                          BoxShadow(color: neonOrange.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 5))
                        ] : [],
                        gradient: LinearGradient(
                          colors: _canProceed 
                              ? [theme.colorScheme.tertiary, neonOrange] 
                              : [theme.colorScheme.onSurface.withValues(alpha: 0.4), theme.colorScheme.onSurface.withValues(alpha: 0.5)],
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: _canProceed ? _submitAnswers : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          _isAllAnswered 
                              ? 'Discover Your Path' 
                              : _canProceed 
                                  ? 'Proceed Anyway' 
                                  : 'Answer ${_minimumRequired - _selectedAnswers.length} more to proceed',
                          style: GoogleFonts.montserrat( 
                            fontSize: 18, 
                            fontWeight: FontWeight.bold, 
                            color: _canProceed ? theme.colorScheme.onSecondary : theme.colorScheme.surface,
                            letterSpacing: 1.1
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}