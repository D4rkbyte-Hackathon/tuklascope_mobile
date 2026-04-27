import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DailyMotivation extends StatelessWidget {
  final int streak;
  
  const DailyMotivation({super.key, required this.streak});

  // A list of cool science/discovery facts
  static const List<String> _funFacts = [
    "Bananas are slightly radioactive because of potassium! 🍌",
    "Water can boil and freeze at the same time (triple point). 🧊",
    "A day on Venus is longer than a year on Venus! 🪐",
    "Octopuses have three hearts and blue blood. 🐙",
    "Honey never spoils. Archaeologists found edible honey in ancient Egyptian tombs! 🍯",
    "There are more trees on Earth than stars in the Milky Way. 🌲",
    "Wombat poop is cube-shaped to stop it from rolling away! ⬛"
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // 3. Pseudo-random logic: Changes exactly once per day
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final dailyFact = _funFacts[dayOfYear % _funFacts.length];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: theme.shadowColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Icon(Icons.local_fire_department_rounded, size: 40, color: theme.colorScheme.secondary)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(end: 1.1, duration: 1.seconds),
              Text(
                "$streak Day\nStreak",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.secondary, height: 1.2),
              )
            ],
          ),
          Container(
            height: 60, width: 1,
            color: theme.dividerColor,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      "Did you know?", 
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: theme.colorScheme.primary)
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  dailyFact,
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.8), height: 1.3),
                ),
              ],
            ),
          )
        ],
      ),
    ).animate().fade(delay: 100.ms).slideY(begin: 0.1);
  }
}