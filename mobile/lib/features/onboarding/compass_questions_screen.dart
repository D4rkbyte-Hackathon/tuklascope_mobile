import 'package:flutter/material.dart';
import '../../core/widgets/gradient_scaffold.dart';
import 'compass_results_screen.dart';

// --- MOCK DATA FOR THE 5 QUESTIONS ---
const List<Map<String, dynamic>> _mockQuestions = [
  {
    'question': 'You are faced with a challenging problem. How do you usually approach it?',
    'options': [
      'Analyze the situation systematically using logic and data.',
      'Look for creative, out-of-the-box solutions.',
      'Consider the human element and how it affects people.',
      'Take practical, hands-on steps to build a prototype.',
    ]
  },
  {
    'question': 'What kind of environment do you thrive in the most?',
    'options': [
      'A structured lab or research facility.',
      'A dynamic, fast-paced corporate setting.',
      'A collaborative community or classroom.',
      'A workshop or fieldwork environment.',
    ]
  },
  {
    'question': 'When exploring historical artifacts, what fascinates you the most?',
    'options': [
      'The technological advancements and inventions.',
      'The economic trade routes and wealth creation.',
      'The cultural shifts, philosophies, and societal norms.',
      'The architecture, crafts, and physical materials used.',
    ]
  },
  {
    'question': 'In a group project, what is your typical role?',
    'options': [
      'The researcher who finds all the data and facts.',
      'The manager who organizes the timeline and resources.',
      'The communicator who ensures everyone is heard.',
      'The builder who actually puts the final product together.',
    ]
  },
  {
    'question': 'What is your ultimate career goal?',
    'options': [
      'To discover or invent something entirely new.',
      'To lead a successful enterprise or business venture.',
      'To inspire, teach, or help others in society.',
      'To master a highly specialized technical skill.',
    ]
  }
];

class CompassQuestionsScreen extends StatefulWidget {
  const CompassQuestionsScreen({super.key});

  @override
  State<CompassQuestionsScreen> createState() => _CompassQuestionsScreenState();
}

class _CompassQuestionsScreenState extends State<CompassQuestionsScreen> {
  // A map to store the selected answer index for each question.
  // Key = Question Index (0-4), Value = Selected Option Index (0-3)
  final Map<int, int> _selectedAnswers = {};

  // Check if the user has answered all 5 questions
  bool get _isAllAnswered => _selectedAnswers.length == _mockQuestions.length;

  void _submitAnswers() {
    if (_isAllAnswered) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CompassResultsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Tuklascope Compass',
          style: TextStyle(
            color: Color(0xFF0B3C6A), // Dark Blue
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0B3C6A)),
      ),
      body: Column(
        children: [
          // THE SCROLLABLE QUESTIONS LIST
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(24.0),
              physics: const BouncingScrollPhysics(),
              itemCount: _mockQuestions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 32),
              itemBuilder: (context, questionIndex) {
                return _buildQuestionCard(questionIndex);
              },
            ),
          ),

          // THE BOTTOM PROCEED BUTTON (Sticks to the bottom)
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
                  // The button is strictly disabled (grayed out) until _isAllAnswered is true!
                  onPressed: _isAllAnswered ? _submitAnswers : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800), // Tuklascope Orange
                    disabledBackgroundColor: Colors.grey[300], // Gray when incomplete
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER: BUILDS THE WHITE QUESTION CARD ---
  Widget _buildQuestionCard(int questionIndex) {
    final questionData = _mockQuestions[questionIndex];
    final String questionText = questionData['question'];
    final List<String> options = questionData['options'];

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
          // Small Header: "Question X of 5"
          Text(
            'QUESTION ${questionIndex + 1} OF ${_mockQuestions.length}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF9800), // Orange
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          
          // The Actual Question
          Text(
            questionText,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0B3C6A), // Dark Blue
              height: 1.3,
            ),
          ),
          const SizedBox(height: 24),

          // The Options
          ...List.generate(options.length, (optionIndex) {
            return _buildOptionButton(questionIndex, optionIndex, options[optionIndex]);
          }),
        ],
      ),
    );
  }

  // --- HELPER: BUILDS THE INTERACTIVE OPTION ROWS ---
  Widget _buildOptionButton(int questionIndex, int optionIndex, String text) {
    // Check if THIS specific option is the one selected for THIS question
    final bool isSelected = _selectedAnswers[questionIndex] == optionIndex;
    
    // Letters A, B, C, D
    final String optionLetter = String.fromCharCode(65 + optionIndex);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedAnswers[questionIndex] = optionIndex;
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
              // The A, B, C, D Circle
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
              
              // The Option Text
              Expanded(
                child: Text(
                  text,
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