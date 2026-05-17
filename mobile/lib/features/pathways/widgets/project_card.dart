import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pathway_models.dart';
import '../providers/pathways_provider.dart';
import '../utils/pathway_utils.dart';
import '../screens/reward_screen.dart';
import '../widgets/pathway_quest_modals.dart';

class ProjectCard extends ConsumerWidget {
  final Pathway pathway;

  const ProjectCard({super.key, required this.pathway});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final canClaim = canClaimPathwayBadge(pathway);
    final catalogLoading = ref.watch(pathwaysCatalogProvider).isLoading;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: canClaim
              ? Colors.amber.shade700.withValues(alpha: 0.6)
              : theme.colorScheme.onSurface.withValues(alpha: 0.05),
          width: canClaim ? 1.5 : 1,
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
                  if (canClaim) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.amber.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.workspace_premium_rounded, size: 20),
                        label: Text(
                          'CLAIM BADGE',
                          style: GoogleFonts.orbitron(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        onPressed: catalogLoading
                            ? null
                            : () async {
                                try {
                                  await ref
                                      .read(pathwaysCatalogProvider.notifier)
                                      .claimBadge(pathway.id);

                                  if (!context.mounted) return;

                                  final updated =
                                      ref.read(pathwaysCatalogProvider).value;
                                  final latest = updated?.pathways.firstWhere(
                                        (p) => p.id == pathway.id,
                                        orElse: () => pathway,
                                      ) ??
                                      pathway;

                                  await showBadgeRewardModal(
                                    context,
                                    pathway: latest,
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.toString()),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
