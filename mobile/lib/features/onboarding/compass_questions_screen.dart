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
  // TODO: Replace this with the user's actual education level from Riverpod/Supabase
  final String _userEducationLevel = 'Others'; 
  
  late final List<CompassQuestion> _activeQuestions;
  final Map<int, CompassOption> _selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    // Default to 'Others' if the specific level isn't found or is Senior High School (which shares 'Others')
    _activeQuestions = _questionBanks[_userEducationLevel] ?? _questionBanks['Others']!;
  }

  bool get _isAllAnswered => _selectedAnswers.length == _activeQuestions.length;

  void _submitAnswers() {
    if (_isAllAnswered) {
      // 1. Initialize scores
      Map<Affinity, int> scores = {
        Affinity.stem: 0,
        Affinity.abm: 0,
        Affinity.humss: 0,
        Affinity.tvl: 0,
      };

      // 2. Tally points
      for (var option in _selectedAnswers.values) {
        scores[option.affinity] = (scores[option.affinity] ?? 0) + 1;
      }

      // 3. Convert to percentages (0.0 to 1.0)
      int totalQuestions = _activeQuestions.length;
      Map<Affinity, double> percentages = {
        Affinity.stem: scores[Affinity.stem]! / totalQuestions,
        Affinity.abm: scores[Affinity.abm]! / totalQuestions,
        Affinity.humss: scores[Affinity.humss]! / totalQuestions,
        Affinity.tvl: scores[Affinity.tvl]! / totalQuestions,
      };

      // 4. Find the top affinity
      Affinity topAffinity = Affinity.stem;
      double highestScore = -1;
      percentages.forEach((affinity, score) {
        if (score > highestScore) {
          highestScore = score;
          topAffinity = affinity;
        }
      });

      // 5. Navigate and pass data
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CompassResultsScreen(
            topAffinity: topAffinity,
            affinityScores: percentages,
          ),
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
        automaticallyImplyLeading: false, // REMOVED BACK BUTTON
        centerTitle: true, // CENTRALIZED TITLE
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 24, // SLIGHTLY BIGGER
              fontWeight: FontWeight.w900,
              fontFamily: 'Roboto',
            ),
            children: [
              TextSpan(text: 'Tuklascope ', style: TextStyle(color: Color(0xFF0B3C6A))),
              TextSpan(text: 'Compass', style: TextStyle(color: Color(0xFFFF6B2C))),
            ],
          ),
        )
        .animate()
        .fade(duration: 600.ms)
        .slideY(begin: -0.2, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(24.0),
              physics: const BouncingScrollPhysics(),
              itemCount: _activeQuestions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 32),
              itemBuilder: (context, questionIndex) {
                return _buildQuestionCard(questionIndex)
                    .animate()
                    .fade(duration: 600.ms, delay: (100 * questionIndex).ms) // STAGGERED ANIMATION
                    .slideY(begin: -0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: (100 * questionIndex).ms);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isAllAnswered ? _submitAnswers : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: _isAllAnswered ? 4 : 0,
                  ),
                  child: Text(
                    _isAllAnswered ? 'Discover Your Path' : 'Answer all to proceed',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _isAllAnswered ? Colors.white : Colors.grey[500],
                    ),
                  ),
                ),
              )
              .animate()
              .fade(duration: 600.ms, delay: 500.ms)
              .slideY(begin: 0.5, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: 500.ms),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int questionIndex) {
    final questionData = _activeQuestions[questionIndex];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUESTION ${questionIndex + 1} OF ${_activeQuestions.length}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF9800),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            questionData.question,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0B3C6A),
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

  Widget _buildOptionButton(int questionIndex, CompassOption option, int optionIndex) {
    // Check if the currently selected option for this question matches this option exactly
    final bool isSelected = _selectedAnswers[questionIndex] == option;
    final String optionLetter = String.fromCharCode(65 + optionIndex);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedAnswers[questionIndex] = option; // Save the actual option object!
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFF9800).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFFFF9800) : Colors.grey[300]!,
              width: isSelected ? 2 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? const Color(0xFFFF9800) : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFF9800) : Colors.grey[400]!,
                    width: 1.5,
                  ),
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
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? const Color(0xFF0B3C6A) : Colors.grey[800],
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