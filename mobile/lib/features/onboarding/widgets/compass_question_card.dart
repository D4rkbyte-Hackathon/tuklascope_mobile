import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/compass_data.dart'; // Ensure this points to your new data file

class CompassQuestionCard extends StatelessWidget {
  final int questionIndex;
  final int totalQuestions;
  final CompassQuestion questionData;
  final CompassOption? selectedOption;
  final ValueChanged<CompassOption> onOptionSelected;

  const CompassQuestionCard({
    super.key,
    required this.questionIndex,
    required this.totalQuestions,
    required this.questionData,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isAnswered = selectedOption != null;

    final Color borderColor = isAnswered ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.1);
    final double blurIntensity = isAnswered ? 15.0 : 5.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: isAnswered ? 2.0 : 1.0),
        boxShadow: [
          BoxShadow(
            color: isAnswered ? theme.colorScheme.primary.withValues(alpha: 0.2) : theme.shadowColor.withValues(alpha: 0.05),
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
                'QUESTION ${questionIndex + 1} OF $totalQuestions',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isAnswered ? theme.colorScheme.secondary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  letterSpacing: 1.2,
                ),
              ),
              if (isAnswered)
                Icon(Icons.check_circle_rounded, color: theme.colorScheme.secondary, size: 20)
                    .animate().scale(curve: Curves.easeOutBack),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            questionData.question,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(questionData.options.length, (optionIndex) {
            return _buildOptionButton(questionData.options[optionIndex], optionIndex, theme);
          }),
        ],
      ),
    );
  }

  Widget _buildOptionButton(CompassOption option, int optionIndex, ThemeData theme) {
    final bool isSelected = selectedOption == option;
    final String optionLetter = String.fromCharCode(65 + optionIndex);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => onOptionSelected(option),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.2),
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
                  color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: isSelected ? [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.5), blurRadius: 8)] : [],
                ),
                child: Center(
                  child: Text(
                    optionLetter,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.8),
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