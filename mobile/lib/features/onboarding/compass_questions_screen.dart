import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/widgets/gradient_scaffold.dart';
import 'compass_results_screen.dart';

// --- 1. DATA MODELS FOR SCORING ---
enum Affinity { stem, abm, humss, tvl }

class CompassOption {
  final String text;
  final Affinity affinity;
  const CompassOption({required this.text, required this.affinity});
}

class CompassQuestion {
  final String question;
  final List<CompassOption> options;
  const CompassQuestion({required this.question, required this.options});
}

// --- 2. QUESTION BANKS PER EDUCATION LEVEL ---
final Map<String, List<CompassQuestion>> _questionBanks = {
  'Elementary': [
    const CompassQuestion(
      question: 'What is your favorite activity at school?',
      options: [
        CompassOption(text: 'Doing science experiments or math puzzles.', affinity: Affinity.stem),
        CompassOption(text: 'Being the group leader or selling items at the fair.', affinity: Affinity.abm),
        CompassOption(text: 'Reading stories or helping my classmates.', affinity: Affinity.humss),
        CompassOption(text: 'Building things with blocks or doing arts and crafts.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'If you had a free afternoon, what would you do?',
      options: [
        CompassOption(text: 'Watch a video about space or animals.', affinity: Affinity.stem),
        CompassOption(text: 'Play a board game where you manage money.', affinity: Affinity.abm),
        CompassOption(text: 'Write a story or talk with friends.', affinity: Affinity.humss),
        CompassOption(text: 'Help fix something broken in the house.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'When solving a puzzle, how do you do it?',
      options: [
        CompassOption(text: 'Sort the pieces by color and shape first.', affinity: Affinity.stem),
        CompassOption(text: 'Plan who does what part if I have help.', affinity: Affinity.abm),
        CompassOption(text: 'Ask someone how they would solve it.', affinity: Affinity.humss),
        CompassOption(text: 'Just start putting pieces together to see what fits.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'What kind of hero do you like the most?',
      options: [
        CompassOption(text: 'The genius inventor with cool gadgets.', affinity: Affinity.stem),
        CompassOption(text: 'The smart leader who creates the master plan.', affinity: Affinity.abm),
        CompassOption(text: 'The kind hero who saves the town and makes peace.', affinity: Affinity.humss),
        CompassOption(text: 'The strong hero who builds the base and weapons.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'What would be a fun field trip?',
      options: [
        CompassOption(text: 'A science museum or a zoo.', affinity: Affinity.stem),
        CompassOption(text: 'A big office building or a bank.', affinity: Affinity.abm),
        CompassOption(text: 'A history museum or watching a play.', affinity: Affinity.humss),
        CompassOption(text: 'A factory or a giant bakery.', affinity: Affinity.tvl),
      ],
    ),
  ],
  'High School': [
    const CompassQuestion(
      question: 'What kind of school project excites you the most?',
      options: [
        CompassOption(text: 'Coding a program or conducting a lab experiment.', affinity: Affinity.stem),
        CompassOption(text: 'Creating a business plan or marketing a product.', affinity: Affinity.abm),
        CompassOption(text: 'Writing an essay on social issues or debating.', affinity: Affinity.humss),
        CompassOption(text: 'Drafting a design or assembling a physical model.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'In a group activity, what role do you naturally take?',
      options: [
        CompassOption(text: 'The researcher finding data and facts.', affinity: Affinity.stem),
        CompassOption(text: 'The manager assigning tasks and tracking progress.', affinity: Affinity.abm),
        CompassOption(text: 'The communicator ensuring everyone gets along.', affinity: Affinity.humss),
        CompassOption(text: 'The creator making the final presentation or prototype.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'Which of these problems would you most want to solve?',
      options: [
        CompassOption(text: 'Finding a cure for a disease or inventing a new tech.', affinity: Affinity.stem),
        CompassOption(text: 'Improving the economy or starting a successful company.', affinity: Affinity.abm),
        CompassOption(text: 'Fighting for human rights or helping communities.', affinity: Affinity.humss),
        CompassOption(text: 'Designing better infrastructure or creating culinary recipes.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'What is your preferred way of learning?',
      options: [
        CompassOption(text: 'Understanding the underlying formulas and logic.', affinity: Affinity.stem),
        CompassOption(text: 'Analyzing case studies and real-world strategies.', affinity: Affinity.abm),
        CompassOption(text: 'Discussing theories and understanding human behavior.', affinity: Affinity.humss),
        CompassOption(text: 'Hands-on practice and repetition.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'Which extracurricular activity sounds best?',
      options: [
        CompassOption(text: 'Robotics or Math Club.', affinity: Affinity.stem),
        CompassOption(text: 'Student Council or Finance Club.', affinity: Affinity.abm),
        CompassOption(text: 'School Paper or Drama Club.', affinity: Affinity.humss),
        CompassOption(text: 'Culinary Arts or Drafting/Woodshop.', affinity: Affinity.tvl),
      ],
    ),
  ],
  'Others': [
    const CompassQuestion(
      question: 'You are faced with a complex, real-world challenge. How do you approach it?',
      options: [
        CompassOption(text: 'Analyze the situation systematically using data and algorithms.', affinity: Affinity.stem),
        CompassOption(text: 'Evaluate resource allocation, risks, and financial impact.', affinity: Affinity.abm),
        CompassOption(text: 'Consider the societal impact and ethical implications.', affinity: Affinity.humss),
        CompassOption(text: 'Take practical, hands-on steps to build a functional solution.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'What kind of environment do you thrive in the most?',
      options: [
        CompassOption(text: 'A structured lab or highly technical research facility.', affinity: Affinity.stem),
        CompassOption(text: 'A fast-paced corporate boardroom or entrepreneurial hub.', affinity: Affinity.abm),
        CompassOption(text: 'A collaborative NGO, classroom, or public service sector.', affinity: Affinity.humss),
        CompassOption(text: 'A dynamic workshop, kitchen, or fieldwork environment.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'When reading the news, what section do you jump to first?',
      options: [
        CompassOption(text: 'Technology, Science, or Medicine.', affinity: Affinity.stem),
        CompassOption(text: 'Markets, Business, or the Economy.', affinity: Affinity.abm),
        CompassOption(text: 'World News, Politics, or Opinion Editorials.', affinity: Affinity.humss),
        CompassOption(text: 'Lifestyle, Automotive, or Craftsmanship.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'If you were to write a book, what would it be about?',
      options: [
        CompassOption(text: 'The future of artificial intelligence and space travel.', affinity: Affinity.stem),
        CompassOption(text: 'Strategies for scaling a global enterprise.', affinity: Affinity.abm),
        CompassOption(text: 'A deep dive into human psychology or history.', affinity: Affinity.humss),
        CompassOption(text: 'A comprehensive guide to mastering a trade or craft.', affinity: Affinity.tvl),
      ],
    ),
    const CompassQuestion(
      question: 'What is your ultimate career goal?',
      options: [
        CompassOption(text: 'To discover or invent something entirely new.', affinity: Affinity.stem),
        CompassOption(text: 'To lead a successful enterprise or multinational venture.', affinity: Affinity.abm),
        CompassOption(text: 'To inspire, teach, or create positive social change.', affinity: Affinity.humss),
        CompassOption(text: 'To be recognized as a master of a highly specialized skill.', affinity: Affinity.tvl),
      ],
    ),
  ],
};

class CompassQuestionsScreen extends StatefulWidget {
  const CompassQuestionsScreen({super.key});

  @override
  State<CompassQuestionsScreen> createState() => _CompassQuestionsScreenState();
}

class _CompassQuestionsScreenState extends State<CompassQuestionsScreen> {
  final String _userEducationLevel = 'Others'; 
  late final List<CompassQuestion> _activeQuestions;
  final Map<int, CompassOption> _selectedAnswers = {};

  final Color _neonOrange = const Color(0xFFFF6B2C);
  final Color _neonBlue = const Color(0xFF64B5F6);
  final Color _darkBlue = const Color(0xFF0B3C6A);

  @override
  void initState() {
    super.initState();
    _activeQuestions = _questionBanks[_userEducationLevel] ?? _questionBanks['Others']!;
  }

  bool get _isAllAnswered => _selectedAnswers.length == _activeQuestions.length;
  double get _progress => _selectedAnswers.length / _activeQuestions.length;

  void _submitAnswers() {
    if (_isAllAnswered) {
      Map<Affinity, int> scores = {
        Affinity.stem: 0, Affinity.abm: 0, Affinity.humss: 0, Affinity.tvl: 0,
      };

      for (var option in _selectedAnswers.values) {
        scores[option.affinity] = (scores[option.affinity] ?? 0) + 1;
      }

      int totalQuestions = _activeQuestions.length;
      Map<Affinity, double> percentages = {
        Affinity.stem: scores[Affinity.stem]! / totalQuestions,
        Affinity.abm: scores[Affinity.abm]! / totalQuestions,
        Affinity.humss: scores[Affinity.humss]! / totalQuestions,
        Affinity.tvl: scores[Affinity.tvl]! / totalQuestions,
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
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, 
        centerTitle: true, 
        title: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Roboto'),
            children: [
              TextSpan(text: 'Tuklascope ', style: TextStyle(color: Color(0xFF0B3C6A))),
              TextSpan(text: 'Compass', style: TextStyle(color: Color(0xFFFF6B2C))),
            ],
          ),
        ).animate().fade(duration: 600.ms).slideY(begin: -0.2, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
        
        // --- UX PROGRESS BAR (Now gradients from Blue to Orange) ---
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6.0),
          child: Stack(
            children: [
              Container(height: 4, width: double.infinity, color: Colors.white.withValues(alpha: 0.2)),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                height: 4,
                width: MediaQuery.of(context).size.width * _progress,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_neonBlue, _neonOrange],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(color: _neonBlue.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 1),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // MAIN LIST OF QUESTIONS
          ListView.separated(
            // 🚀 FIX: Made padding dynamic and increased clearance to 160
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
              return _buildQuestionCard(questionIndex)
                  .animate()
                  .fade(duration: 600.ms, delay: (100 * questionIndex).ms) 
                  .slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: (100 * questionIndex).ms);
            },
          ),
          
          // --- UI: FLOATING GLASSMORPHIC SUBMIT BAR (Kept this as glass since it's static and doesn't lag) ---
          Positioned(
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
                    color: Colors.white.withValues(alpha: 0.15),
                    border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
                  ),
                  child: SizedBox(
                    height: 56,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _isAllAnswered ? [
                          BoxShadow(color: _neonOrange.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 5))
                        ] : [],
                        gradient: LinearGradient(
                          colors: _isAllAnswered 
                              ? [const Color(0xFFFF9800), _neonOrange]
                              : [Colors.grey[400]!, Colors.grey[500]!],
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
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1),
                        ),
                      ),
                    ),
                  ),
                ).animate().fade(duration: 600.ms, delay: 500.ms).slideY(begin: 0.5, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI: PERFORMANCE-FRIENDLY QUESTION CARD ---
  // Removed BackdropFilter to completely eliminate scroll lag!
  Widget _buildQuestionCard(int questionIndex) {
    final questionData = _activeQuestions[questionIndex];
    final bool isAnswered = _selectedAnswers.containsKey(questionIndex);
    
    // Cards glow blue when answered to balance the color palette
    final Color borderColor = isAnswered ? _neonBlue : Colors.white.withValues(alpha: 0.5);
    final double blurIntensity = isAnswered ? 15.0 : 5.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95), // Solid highly-opaque white instead of blur
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor,
          width: isAnswered ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isAnswered ? _neonBlue.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
            blurRadius: blurIntensity,
            spreadRadius: isAnswered ? 2 : 0,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'QUESTION ${questionIndex + 1} OF ${_activeQuestions.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  // Kept Orange here for contrast against the dark blue title
                  color: isAnswered ? _neonOrange : _darkBlue.withValues(alpha: 0.6),
                  letterSpacing: 1.2,
                ),
              ),
              if (isAnswered)
                Icon(Icons.check_circle_rounded, color: _neonOrange, size: 20)
                    .animate().scale(curve: Curves.easeOutBack),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            questionData.question,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: _darkBlue,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(questionData.options.length, (optionIndex) {
            return _buildOptionButton(questionIndex, questionData.options[optionIndex], optionIndex);
          }),
        ],
      ),
    );
  }

  // --- UI: SLEEK OPTION BUTTON (Now Neon Blue) ---
  Widget _buildOptionButton(int questionIndex, CompassOption option, int optionIndex) {
    final bool isSelected = _selectedAnswers[questionIndex] == option;
    final String optionLetter = String.fromCharCode(65 + optionIndex);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedAnswers[questionIndex] = option; 
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? _neonBlue.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? _neonBlue : Colors.grey[300]!,
              width: isSelected ? 2 : 1.5,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? _neonBlue : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? _neonBlue : Colors.grey[400]!,
                    width: 1.5,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(color: _neonBlue.withValues(alpha: 0.5), blurRadius: 8)
                  ] : [],
                ),
                child: Center(
                  child: Text(
                    optionLetter,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option.text,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? _darkBlue : Colors.grey[800],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}