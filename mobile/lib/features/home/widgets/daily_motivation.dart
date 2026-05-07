import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class DailyMotivation extends StatefulWidget {
  final int streak;
  
  const DailyMotivation({super.key, required this.streak});

  @override
  State<DailyMotivation> createState() => _DailyMotivationState();
}

class _DailyMotivationState extends State<DailyMotivation> {
  late int _currentFactIndex;

  // 2. MORE fun facts added to the list!
  static const List<String> _funFacts = [
    "Bananas are slightly radioactive because of potassium! 🍌",
    "Water can boil and freeze at the same time (triple point). 🧊",
    "A day on Venus is longer than a year on Venus! 🪐",
    "Octopuses have three hearts and blue blood. 🐙",
    "Honey never spoils. Archaeologists found edible honey in ancient Egyptian tombs! 🍯",
    "There are more trees on Earth than stars in the Milky Way. 🌲",
    "Wombat poop is cube-shaped to stop it from rolling away! ⬛",
    "The first computer bug was an actual moth trapped in a relay in 1947. 🐛",
    "Sharks have been around longer than trees. 🦈",
    "A cloud can weigh more than a million pounds! ☁️",
    "There's a planet made entirely of diamonds called 55 Cancri e. 💎",
    "A single strand of spider silk is stronger than steel of the same thickness. 🕸️",
    "The Eiffel Tower can be 15 cm taller during the summer due to thermal expansion. 🗼",
    "Humans share about 50% of their DNA with bananas. 🧬",
    "Crows can recognize human faces and remember them for years. 🐦‍⬛",
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with the standard daily fact
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    _currentFactIndex = dayOfYear % _funFacts.length;
  }

  // 3. Cycle to a random fact on tap
  void _cycleFact() {
    int newIndex;
    do {
      newIndex = Random().nextInt(_funFacts.length);
    } while (newIndex == _currentFactIndex); // Ensure we don't get the same fact twice in a row

    setState(() {
      _currentFactIndex = newIndex;
    });
  }

  // 4. Dynamic streak colors
  Color _getStreakColor(ThemeData theme) {
    if (widget.streak == 0) return Colors.grey.shade600;
    if (widget.streak < 10) return theme.colorScheme.secondary; // Normal
    if (widget.streak < 30) return Colors.cyan; // Rare
    if (widget.streak < 100) return Colors.deepPurpleAccent; // Epic
    return Colors.amber; // Legendary
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final streakColor = _getStreakColor(theme);
    final currentFact = _funFacts[_currentFactIndex];

    return GestureDetector(
      onTap: _cycleFact,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: streakColor.withOpacity(0.08), 
              blurRadius: 12, 
              offset: const Offset(0, 4)
            ),
          ],
          border: Border.all(color: streakColor.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            // 1. Shimmering Streak Section
            Column(
              children: [
                Icon(Icons.local_fire_department_rounded, size: 40, color: streakColor)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(end: 1.1, duration: 1.seconds),
                Text(
                  "${widget.streak} Day\nStreak",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.orbitron( 
                    fontWeight: FontWeight.bold, 
                    color: streakColor, 
                    height: 1.2
                  ),
                )
              ],
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: false))
            .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.6)), // 🚀 SHINY EFFECT
            
            Container(
              height: 60, width: 1,
              color: theme.dividerColor.withOpacity(0.5),
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
            
            Expanded(
              // AnimatedSwitcher ensures smooth cross-fade when cycling facts
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Column(
                  key: ValueKey<int>(_currentFactIndex),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          "Did you know?", 
                          style: GoogleFonts.montserrat( 
                            fontWeight: FontWeight.w900, 
                            fontSize: 14, 
                            color: theme.colorScheme.primary
                          )
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentFact,
                      style: GoogleFonts.inter( 
                        fontSize: 13, 
                        color: theme.colorScheme.onSurface.withOpacity(0.8), 
                        height: 1.3
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
    );
  }
}