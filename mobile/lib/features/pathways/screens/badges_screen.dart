import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/pathways_provider.dart';
import '../models/pathway_models.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final catalogState = ref.watch(pathwaysCatalogProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Your Badges',
          style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: catalogState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Error loading badges: $err')),
        data: (catalog) {
          final pathways = catalog.pathways;

          if (pathways.isEmpty) {
            return const Center(child: Text("No badges available."));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 0.85,
            ),
            itemCount: pathways.length,
            itemBuilder: (context, index) {
              final pathway = pathways[index];
              final isUnlocked = pathway.status == PathwayStatus.completed;

              return Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isUnlocked
                              ? theme.colorScheme.primary
                              : Colors.grey.withValues(alpha: 0.3),
                          width: 4,
                        ),
                        boxShadow: isUnlocked
                            ? [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 15,
                                ),
                              ]
                            : [],
                      ),
                      child: ClipOval(
                        child: ColorFiltered(
                          // Gray out the badge if they haven't completed the pathway
                          colorFilter: isUnlocked
                              ? const ColorFilter.mode(
                                  Colors.transparent,
                                  BlendMode.multiply,
                                )
                              : const ColorFilter.matrix(<double>[
                                  0.2126,
                                  0.7152,
                                  0.0722,
                                  0,
                                  0,
                                  0.2126,
                                  0.7152,
                                  0.0722,
                                  0,
                                  0,
                                  0.2126,
                                  0.7152,
                                  0.0722,
                                  0,
                                  0,
                                  0,
                                  0,
                                  0,
                                  1,
                                  0,
                                ]),
                          child: Image.asset(
                            pathway.badgeUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stack) =>
                                const Icon(Icons.shield, size: 50),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    pathway.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
