import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pathway_models.dart';
import '../providers/pathways_provider.dart';
import 'package:tuklascope_mobile/core/navigation/main_nav_scope.dart';

class RewardScreen extends ConsumerWidget {
  final Pathway pathway;

  const RewardScreen({super.key, required this.pathway});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navScope = MainNavScope.maybeOf(context);
    final isNavBarVisible = navScope?.isNavBarVisible ?? true;
    final theme = Theme.of(context);

    // Watch the live catalog state to get real-time updates after enrolling
    final catalogState = ref.watch(pathwaysCatalogProvider);
    final isEnrolling = catalogState.isLoading;

    // Find the most up-to-date version of this pathway from the provider
    final currentPathway =
        catalogState.value?.pathways.firstWhere(
          (p) => p.id == pathway.id,
          orElse: () => pathway,
        ) ??
        pathway;

    final bool isCompleted = currentPathway.status == PathwayStatus.completed;
    final bool isAvailable = currentPathway.status == PathwayStatus.available;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Image.network(
            currentPathway.imageUrl,
            height: MediaQuery.of(context).size.height * 0.6,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: MediaQuery.of(context).size.height * 0.6,
              color: theme.colorScheme.surface.withValues(alpha: 0.5),
              child: Icon(
                Icons.image_not_supported,
                size: 50,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 100),
                Center(
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(currentPathway.badgeUrl),
                        fit: BoxFit.contain,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 6,
                        color: isCompleted ? Colors.green : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  currentPathway.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                    shadows: const [
                      Shadow(color: Colors.black54, blurRadius: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(25.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- DYNAMIC CONTENT BASED ON ENROLLMENT STATUS ---
                      if (isAvailable) ...[
                        Text(
                          "Ready to begin? Enroll in this quest to unlock tasks and start earning points.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.9,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              backgroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: isEnrolling
                                ? null
                                : () async {
                                    try {
                                      await ref
                                          .read(
                                            pathwaysCatalogProvider.notifier,
                                          )
                                          .enroll(currentPathway.id);

                                      // Check if the user is still on this screen before showing SnackBar
                                      if (!context.mounted) return;

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Successfully enrolled!',
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      // Check if mounted before showing error
                                      if (!context.mounted) return;

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(e.toString()),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                            child: isEnrolling
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'ENROLL IN QUEST',
                                    style: GoogleFonts.orbitron(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ] else ...[
                        Text(
                          isCompleted
                              ? "Congratulations! You've completed the ${currentPathway.title} journey."
                              : "You are actively on this quest. Track your milestones below.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.9,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          "Quest Milestones",
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        // The tasks are now driven entirely by the backend data!
                        ...currentPathway.tasks.map((task) {
                          return _buildMilestone(
                            task.description,
                            task.isCompleted,
                            theme,
                          );
                        }),
                      ],

                      // ---------------------------------------------------
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutQuint,
                        height:
                            (isNavBarVisible ? 100.0 : 20.0) +
                            MediaQuery.paddingOf(context).bottom,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.3),
              ),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestone(String title, bool isDone, ThemeData theme) {
    return ListTile(
      leading: Icon(
        isDone ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isDone
            ? Colors.green
            : theme.colorScheme.onSurface.withValues(alpha: 0.4),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: isDone
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
