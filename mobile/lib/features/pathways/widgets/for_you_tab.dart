// mobile/lib/features/pathways/widgets/for_you_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/pathway_models.dart';
import '../providers/pathways_provider.dart';
import '../screens/reward_screen.dart';
import '../services/compass_recommendation_service.dart';
import '../utils/pathway_utils.dart';
import 'pathway_quest_modals.dart';

class ForYouTab extends ConsumerWidget {
  /// When true, content is embedded in a parent [CustomScrollView] and does not
  /// scroll on its own.
  final bool embedInParentScroll;

  const ForYouTab({super.key, this.embedInParentScroll = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(pathwaysCatalogProvider);
    final compassAsync = ref.watch(compassAffinityProvider);

    return catalogAsync.when(
      loading: () => _LoadingShimmer(embedInParentScroll: embedInParentScroll),
      error: (e, _) => _ErrorState(
        embedInParentScroll: embedInParentScroll,
        onRetry: () => ref.invalidate(pathwaysCatalogProvider),
      ),
      data: (catalog) => compassAsync.when(
        loading: () => _LoadingShimmer(embedInParentScroll: embedInParentScroll),
        error: (e, _) => _NoCompassState(embedInParentScroll: embedInParentScroll),
        data: (scores) {
          if (scores == null || !scores.hasData) {
            return _NoCompassState(embedInParentScroll: embedInParentScroll);
          }
          final service = ref.read(compassRecommendationServiceProvider);
          final ranked = service.rankPathways(catalog.pathways, scores);
          return _RecommendedList(
            ranked: ranked,
            scores: scores,
            embedInParentScroll: embedInParentScroll,
          );
        },
      ),
    );
  }
}

// ─── Ranked List ─────────────────────────────────────────────────────────────

class _RecommendedList extends StatelessWidget {
  final List<RecommendedPathway> ranked;
  final CompassAffinityScores scores;
  final bool embedInParentScroll;

  const _RecommendedList({
    required this.ranked,
    required this.scores,
    this.embedInParentScroll = false,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset =
        embedInParentScroll ? 0.0 : MediaQuery.paddingOf(context).bottom + 120;

    return ListView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset),
      shrinkWrap: embedInParentScroll,
      physics: embedInParentScroll
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      children: [
        _CompassSummaryCard(scores: scores),
        const SizedBox(height: 24),
        ...ranked.asMap().entries.map((entry) {
          final index = entry.key;
          final rec = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _RecommendedPathwayCard(rec: rec)
                .animate()
                .fade(duration: 500.ms, delay: (60 * index).ms)
                .slideY(
                  begin: 0.12,
                  end: 0,
                  duration: 500.ms,
                  curve: Curves.easeOutCubic,
                  delay: (60 * index).ms,
                ),
          );
        }),
      ],
    );
  }
}

// ─── Compass Summary Banner ──────────────────────────────────────────────────

class _CompassSummaryCard extends StatelessWidget {
  final CompassAffinityScores scores;

  const _CompassSummaryCard({required this.scores});

  Color _strandColor(String strand) {
    switch (strand) {
      case 'STEM':
        return const Color(0xFF4CAF50);
      case 'ABM':
        return const Color(0xFF2196F3);
      case 'HUMSS':
        return const Color(0xFFFF9800);
      case 'TVL':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ranked = scores.rankedStrands;
    final dominant = ranked.first;
    final dominantColor = _strandColor(dominant.key);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            dominantColor.withValues(alpha: 0.15),
            theme.colorScheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: dominantColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: dominantColor.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: dominantColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.explore_rounded, color: dominantColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR COMPASS PROFILE',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Best match: ',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          TextSpan(
                            text: dominant.key,
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: dominantColor,
                            ),
                          ),
                          TextSpan(
                            text: '  ${dominant.value}%',
                            style: GoogleFonts.orbitron(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: dominantColor.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: ranked.map((entry) {
              final color = _strandColor(entry.key);
              final pct = entry.value / 100.0;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    children: [
                      Text(
                        entry.key,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: color,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: pct),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) => LinearProgressIndicator(
                            value: value,
                            minHeight: 6,
                            backgroundColor:
                                theme.colorScheme.onSurface.withValues(alpha: 0.08),
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${entry.value}%',
                        style: GoogleFonts.orbitron(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fade(duration: 500.ms).scaleXY(begin: 0.97, curve: Curves.easeOutBack);
  }
}

// ─── Individual Recommended Card ─────────────────────────────────────────────

class _RecommendedPathwayCard extends ConsumerWidget {
  final RecommendedPathway rec;

  const _RecommendedPathwayCard({required this.rec});

  Color _strandColor(String strand) {
    switch (strand.toUpperCase()) {
      case 'STEM':
        return const Color(0xFF4CAF50);
      case 'ABM':
        return const Color(0xFF2196F3);
      case 'HUMSS':
        return const Color(0xFFFF9800);
      case 'TVL':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String _matchLabel(int score) {
    if (score >= 70) return 'Perfect Fit';
    if (score >= 45) return 'Good Match';
    if (score >= 20) return 'Decent Fit';
    return 'Worth Trying';
  }

  IconData _matchIcon(int score) {
    if (score >= 70) return Icons.workspace_premium_rounded;
    if (score >= 45) return Icons.thumb_up_rounded;
    if (score >= 20) return Icons.trending_up_rounded;
    return Icons.explore_rounded;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pathway = rec.pathway;
    final canClaim = canClaimPathwayBadge(pathway);
    final catalogLoading = ref.watch(pathwaysCatalogProvider).isLoading;
    final strandColor = _strandColor(pathway.targetStrand);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RewardScreen(pathway: pathway)),
        ),
        child: Ink(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: rec.isPerfectMatch
                  ? strandColor.withValues(alpha: 0.6)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.08),
              width: rec.isPerfectMatch ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: rec.isPerfectMatch
                    ? strandColor.withValues(alpha: 0.10)
                    : Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: rec.isPerfectMatch ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                child: Stack(
                  children: [
                    Image.network(
                      pathway.imageUrl,
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 130,
                        color: strandColor.withValues(alpha: 0.1),
                        child: Center(
                          child: Icon(Icons.image_not_supported,
                              color: strandColor.withValues(alpha: 0.4)),
                        ),
                      ),
                    ),
                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.55),
                            ],
                            stops: const [0.4, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Match badge (top-left)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: strandColor.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: strandColor.withValues(alpha: 0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_matchIcon(rec.matchScore),
                                size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              _matchLabel(rec.matchScore),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Match % (top-right)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: strandColor.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          '${rec.matchScore}% match',
                          style: GoogleFonts.orbitron(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: strandColor,
                          ),
                        ),
                      ),
                    ),
                    // Status badge bottom-right
                    if (pathway.status != PathwayStatus.available)
                      Positioned(
                        bottom: 10,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: canClaim
                                ? Colors.amber.shade700.withValues(alpha: 0.95)
                                : pathway.status == PathwayStatus.completed
                                    ? Colors.green.withValues(alpha: 0.9)
                                    : Colors.amber.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            canClaim
                                ? 'Claim Badge'
                                : pathway.status == PathwayStatus.completed
                                    ? '✓ Done'
                                    : '▶ Active',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Body
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: strandColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: strandColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            pathway.targetStrand,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: strandColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          pathway.difficulty,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${pathway.totalPoints} pts',
                          style: GoogleFonts.orbitron(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      pathway.title,
                      style: GoogleFonts.montserrat(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pathway.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        height: 1.4,
                      ),
                    ),
                    if (pathway.progressPercentage > 0) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            'Progress ',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pathway.progressPercentage / 100.0,
                                minHeight: 5,
                                backgroundColor: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.08),
                                color: getProgressColor(
                                    pathway.progressPercentage),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${pathway.progressPercentage}%',
                            style: GoogleFonts.orbitron(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color:
                                  getProgressColor(pathway.progressPercentage),
                            ),
                          ),
                        ],
                      ),
                    ],
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
                          icon: const Icon(
                            Icons.workspace_premium_rounded,
                            size: 20,
                          ),
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
                              : () => _claimBadge(context, ref, pathway),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _claimBadge(
  BuildContext context,
  WidgetRef ref,
  Pathway pathway,
) async {
  try {
    await ref.read(pathwaysCatalogProvider.notifier).claimBadge(pathway.id);

    if (!context.mounted) return;

    final updated = ref.read(pathwaysCatalogProvider).value;
    final latest = updated?.pathways.firstWhere(
          (p) => p.id == pathway.id,
          orElse: () => pathway,
        ) ??
        pathway;

    await showBadgeRewardModal(context, pathway: latest);
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
    );
  }
}

// ─── Empty / Error States ─────────────────────────────────────────────────────

class _NoCompassState extends StatelessWidget {
  final bool embedInParentScroll;

  const _NoCompassState({this.embedInParentScroll = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.explore_off_rounded,
                  size: 56, color: theme.colorScheme.primary),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 0.95, end: 1.05, duration: 2.seconds),
            const SizedBox(height: 24),
            Text(
              'No Compass Data Yet',
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Complete the Tuklascope Compass quiz to get pathway recommendations tailored to your interests.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ).animate().fade(duration: 600.ms).slideY(begin: 0.1),
      ),
    ).maybeMinHeight(embedInParentScroll, 320);
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  final bool embedInParentScroll;

  const _ErrorState({
    required this.onRetry,
    this.embedInParentScroll = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text('Could not load recommendations',
              style: GoogleFonts.inter(color: theme.colorScheme.error)),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ).maybeMinHeight(embedInParentScroll, 240);
  }
}

class _LoadingShimmer extends StatelessWidget {
  final bool embedInParentScroll;

  const _LoadingShimmer({this.embedInParentScroll = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: CircularProgressIndicator(color: theme.colorScheme.secondary),
    ).maybeMinHeight(embedInParentScroll, 240);
  }
}

extension _EmbedScrollHeight on Widget {
  Widget maybeMinHeight(bool embed, double height) {
    if (!embed) return this;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: this,
    );
  }
}