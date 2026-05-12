import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pathway_models.dart';
import '../utils/pathway_utils.dart';
import '../screens/reward_screen.dart';

class ProjectCard extends StatelessWidget {
  final Pathway pathway;

  const ProjectCard({super.key, required this.pathway});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      elevation: theme.brightness == Brightness.dark ? 0 : 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RewardScreen(pathway: pathway),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              pathway.imageUrl,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 140,
                color: theme.colorScheme.surface.withValues(alpha: 0.5),
                child: Icon(
                  Icons.image_not_supported,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pathway.difficulty,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        "${pathway.totalPoints} Points",
                        style: GoogleFonts.orbitron(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pathway.title,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pathway.description,
                    style: GoogleFonts.inter(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        "Progress:",
                        style: GoogleFonts.inter(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 30,
                        child: Text(
                          "${pathway.progressPercentage}",
                          textAlign: TextAlign.end,
                          style: GoogleFonts.orbitron(
                            fontWeight: FontWeight.bold,
                            color: getProgressColor(pathway.progressPercentage),
                          ),
                        ),
                      ),
                      Text(
                        "% Completed",
                        style: GoogleFonts.inter(
                          color: getProgressColor(pathway.progressPercentage),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
