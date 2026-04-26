import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeAndShuffleQuestions();
  }

  void _initializeAndShuffleQuestions() {
    // 1. Get the raw questions based on level
    final rawQuestions = compassQuestionBanks[_userEducationLevel] ?? compassQuestionBanks['Others']!;

    // 2. Map through to Deep Copy the options, shuffle the options, and recreate the question
    _activeQuestions = rawQuestions.map((q) {
      final shuffledOptions = List<CompassOption>.from(q.options)..shuffle();
      return CompassQuestion(question: q.question, options: shuffledOptions);
    }).toList();

    // 3. Shuffle the overall order of the questions
    _activeQuestions.shuffle();
  }

  bool get _isAllAnswered => _selectedAnswers.length == _activeQuestions.length;
  double get _progress => _selectedAnswers.length / _activeQuestions.length;

  void _submitAnswers() {
    if (_isAllAnswered) {
      final Map<Affinity, int> scores = {
        Affinity.stem: 0, Affinity.abm: 0, Affinity.humss: 0, Affinity.tvl: 0,
      };

      for (var option in _selectedAnswers.values) {
        scores[option.affinity] = (scores[option.affinity] ?? 0) + 1;
      }

      final int totalQuestions = _activeQuestions.length;
      final Map<Affinity, double> percentages = {
        for (var key in scores.keys) key: scores[key]! / totalQuestions,
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
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Roboto'),
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
                width: MediaQuery.of(context).size.width * _progress,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primaryBlue, neonOrange]),
                  boxShadow: [BoxShadow(color: primaryBlue.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 1)],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView.separated(
            padding: EdgeInsets.only(
              top: 24.0, 
              left: 24.0, 
              right: 24.0, 
              bottom: MediaQuery.paddingOf(context).bottom + 120.0, 
            ),
            physics: const BouncingScrollPhysics(),
            itemCount: _activeQuestions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 32),
            itemBuilder: (context, questionIndex) {
              return CompassQuestionCard(
                questionIndex: questionIndex,
                totalQuestions: _activeQuestions.length,
                questionData: _activeQuestions[questionIndex],
                selectedOption: _selectedAnswers[questionIndex],
                onOptionSelected: (option) => setState(() => _selectedAnswers[questionIndex] = option),
              ).animate().fade(duration: 600.ms, delay: (100 * questionIndex).ms)
               .slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: (100 * questionIndex).ms);
            },
          ),
          
          _buildFloatingSubmitBar(theme, neonOrange),
        ],
      ),
    );
  }

  Widget _buildFloatingSubmitBar(ThemeData theme, Color neonOrange) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: EdgeInsets.only(
              left: 24.0, right: 24.0, top: 20.0,
              bottom: MediaQuery.of(context).padding.bottom + 20.0,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.15),
              border: Border(top: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.2))),
            ),
            child: SizedBox(
              height: 56,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _isAllAnswered ? [
                    BoxShadow(color: neonOrange.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 5))
                  ] : [],
                  gradient: LinearGradient(
                    colors: _isAllAnswered 
                        ? [theme.colorScheme.tertiary, neonOrange] 
                        : [theme.colorScheme.onSurface.withValues(alpha: 0.4), theme.colorScheme.onSurface.withValues(alpha: 0.5)],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: _isAllAnswered ? _submitAnswers : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    _isAllAnswered ? 'Discover Your Path' : 'Answer ${_activeQuestions.length - _selectedAnswers.length} more to proceed',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: _isAllAnswered ? theme.colorScheme.onSecondary : theme.colorScheme.surface,
                      letterSpacing: 1.1
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}