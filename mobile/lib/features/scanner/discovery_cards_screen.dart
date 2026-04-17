// mobile/lib/features/scanner/discovery_cards_screen.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/api_config.dart';
import 'package:flutter/material.dart';
import '../../core/widgets/gradient_scaffold.dart';
import 'package:tuklascope_mobile/core/services/learn_service.dart';

class DiscoveryCardsScreen extends StatefulWidget {
  final String objectName;
  final String gradeLevel;
  final String selectedLens;

  const DiscoveryCardsScreen({
    super.key,
    required this.objectName,
    required this.gradeLevel,
    required this.selectedLens,
  });

  @override
  State<DiscoveryCardsScreen> createState() => _DiscoveryCardsScreenState();
}

class _DiscoveryCardsScreenState extends State<DiscoveryCardsScreen> {
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
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF0B3C6A)),
                  SizedBox(height: 16),
                  Text(
                    'Generating custom lesson...',
                    style: TextStyle(
                      color: Color(0xFF0B3C6A),
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
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _fetchLearningDeck,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
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
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: Colors.grey[300]),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black45,
                            Colors.transparent,
                            Color(0xFFFFFDF4),
                          ],
                          stops: [0.0, 0.4, 1.0],
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
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0B3C6A),
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
                              color: const Color(0xFFFF9800),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '+$xpReward XP',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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
                          _buildTabButton(0, 'Quick Fact', Icons.bolt),
                          const SizedBox(width: 8),
                          _buildTabButton(
                            1,
                            'Concepts',
                            Icons.lightbulb_outline,
                          ),
                          const SizedBox(width: 8),
                          _buildTabButton(
                            2,
                            'Hands-on',
                            Icons.build_circle_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildActiveCard(),
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
          child: _buildChallengeButton(),
        ),
      ],
    );
  }

  Widget _buildChallengeButton() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _showChallengeModal,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF9800),
          foregroundColor: Colors.white,
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
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // CRITICAL FIX: Removed const from Center, added it to BoxDecoration
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'TUKLAS CHALLENGE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFFF9800),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      question,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0B3C6A),
                      ),
                    ),
                    const SizedBox(height: 24),

                    ...options.map((option) {
                      // CRITICAL FIX: Made local variables final
                      final bool isThisSelected = selectedOption == option;
                      final bool isThisCorrect = option == correctAnswer;

                      Color buttonColor = Colors.white;
                      Color textColor = const Color(0xFF0B3C6A);
                      Color borderColor = Colors.grey[300]!;

                      if (hasAnswered) {
                        if (isThisCorrect) {
                          buttonColor = Colors.green[100]!;
                          borderColor = Colors.green;
                          textColor = Colors.green[800]!;
                        } else if (isThisSelected && !isThisCorrect) {
                          buttonColor = Colors.red[100]!;
                          borderColor = Colors.red;
                          textColor = Colors.red[800]!;
                        }
                      } else if (isThisSelected) {
                        buttonColor = Colors.blue[50]!;
                        borderColor = const Color(0xFF0B3C6A);
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
                              border: Border.all(color: borderColor, width: 2),
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
                                  isCorrect = (selectedOption == correctAnswer);
                                });
                                if (isCorrect) {
                                  _saveProgressToBackend();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B3C6A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'SUBMIT ANSWER',
                          style: TextStyle(
                            color: Colors.white,
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
                                  ? Colors.green[50]
                                  : Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isCorrect
                                  ? "🎉 Correct! $explanation"
                                  : "Not quite! $explanation",
                              style: TextStyle(
                                color: isCorrect
                                    ? Colors.green[800]
                                    : Colors.red[800],
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
                                backgroundColor: const Color(0xFFFF9800),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 32,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'CLAIM XP & CONTINUE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveProgressToBackend() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) return;

      // CRITICAL FIX: Made dummy string a const declaration
      const dummyImageUrl = "https://example.com/placeholder.jpg";

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/discover/save'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${session.accessToken}',
        },
        body: jsonEncode({
          "object_name": widget.objectName,
          "chosen_lens": widget.selectedLens,
          "image_url": dummyImageUrl,
          "learning_deck": _deckData,
          "xp_awarded": 50,
          "is_aligned_with_compass": false,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Progress successfully saved to Supabase!");
      } else {
        debugPrint("🚨 Failed to save progress: ${response.body}");
      }
    } catch (e) {
      debugPrint("🚨 Error saving progress: $e");
    }
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    // CRITICAL FIX: Made local variable final
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
            color: isSelected ? const Color(0xFFFF9800) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              // CRITICAL FIX: Replaced withOpacity with withValues
              color: isSelected
                  ? const Color(0xFFFF9800)
                  : const Color(0xFF0B3C6A).withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF0B3C6A),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF0B3C6A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveCard() {
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
        return _buildGlassSection('Quick Fact', quickFact);
      case 1:
        return _buildGlassSection('Concepts', concept);
      case 2:
        return _buildGlassSection('Hands-on Project', handsOn);
      default:
        return const SizedBox();
    }
  }

  Widget _buildGlassSection(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // CRITICAL FIX: Replaced withOpacity with withValues
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            // CRITICAL FIX: Replaced withOpacity with withValues
            color: Colors.black.withValues(alpha: 0.05),
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF9800),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
