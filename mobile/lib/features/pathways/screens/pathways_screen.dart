// mobile/lib/features/pathways/screens/pathways_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import 'package:tuklascope_mobile/core/navigation/main_nav_scope.dart';

import '../models/pathway_models.dart';
import '../providers/pathways_provider.dart';
import '../services/compass_recommendation_service.dart';
import '../widgets/for_you_tab.dart';
import '../widgets/header_section.dart';
import '../widgets/project_card.dart';

class PathwaysScreen extends ConsumerStatefulWidget {
  const PathwaysScreen({super.key});

  @override
  ConsumerState<PathwaysScreen> createState() => _PathwaysScreenState();
}

class _PathwaysScreenState extends ConsumerState<PathwaysScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // All Pathways tab state
  String _searchQuery = '';
  String? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Pathway> _getFilteredProjects(List<Pathway> allPathways) {
    return allPathways.where((project) {
      final matchesSearch = _searchQuery.isEmpty ||
          project.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          project.description
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      final matchesDifficulty = _selectedDifficulty == null ||
          project.difficulty == _selectedDifficulty;
      return matchesSearch && matchesDifficulty;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final navScope = MainNavScope.maybeOf(context);
    final isNavBarVisible = navScope?.isNavBarVisible ?? true;
    final theme = Theme.of(context);
    final catalogState = ref.watch(pathwaysCatalogProvider);

    final bottomPadding = (isNavBarVisible ? 100.0 : 20.0) +
        MediaQuery.paddingOf(context).bottom;

    return PopScope(
      canPop: true,
      child: GradientScaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(pathwaysCatalogProvider.notifier).refresh(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // ── Header (stats) ─────────────────────────────────────────
                catalogState.when(
                  loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                  error: (_, __) =>
                      const SliverToBoxAdapter(child: SizedBox.shrink()),
                  data: (catalog) => SliverToBoxAdapter(
                    child: HeaderSection(
                      activePathways: catalog.activePathwaysCount,
                      averageProgress: catalog.averageProgress,
                      totalPoints: catalog.totalPointsEarned,
                    ),
                  ),
                ),

                // ── Tab Bar ────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                    child: _buildTabBar(theme),
                  ),
                ),

                // ── Active tab content ─────────────────────────────────────
                ..._buildActiveTabSlivers(
                  catalogState,
                  theme,
                ),

                SliverPadding(
                  padding: EdgeInsets.only(bottom: bottomPadding),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Tab Bar ────────────────────────────────────────────────────────────────

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
          width: 1.2,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(23),
        ),
        labelColor: theme.colorScheme.onPrimary,
        unselectedLabelColor:
            theme.colorScheme.onSurface.withValues(alpha: 0.6),
        labelStyle:
            GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14),
        tabs: const [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome_rounded, size: 16),
                SizedBox(width: 6),
                Text('For You'),
              ],
            ),
          ),
          Tab(text: 'All Pathways'),
        ],
      ),
    ).animate().fade(duration: 400.ms).slideY(begin: -0.15);
  }

  // ── Tab content (single screen scroll) ─────────────────────────────────────

  List<Widget> _buildActiveTabSlivers(
    AsyncValue<PathwayCatalogResponse> catalogState,
    ThemeData theme,
  ) {
    if (_tabController.index == 0) {
      return [
        SliverToBoxAdapter(
          child: ForYouTab(embedInParentScroll: true),
        ),
      ];
    }
    return _buildAllPathwaysSlivers(catalogState, theme);
  }

  List<Widget> _buildAllPathwaysSlivers(
    AsyncValue<PathwayCatalogResponse> catalogState,
    ThemeData theme,
  ) {
    return catalogState.when(
      loading: () => [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
      error: (err, stack) => [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Failed to load catalog',
                  style: GoogleFonts.inter(color: Colors.white),
                ),
                TextButton(
                  onPressed: () =>
                      ref.read(pathwaysCatalogProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ],
      data: (catalog) {
        final filteredList = _getFilteredProjects(catalog.pathways);

        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Expanded(child: _buildSearchField(theme)),
                  const SizedBox(width: 12),
                  _buildFilterButton(theme),
                ],
              ),
            ).animate().fade(duration: 400.ms, delay: 50.ms),
          ),
          if (filteredList.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(
                    'No quests match your criteria.',
                    style: GoogleFonts.inter(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final pathway = filteredList[index];
                  final listIndex = index + 1;
                  return ProjectCard(pathway: pathway)
                      .animate()
                      .fade(duration: 500.ms, delay: (50 * listIndex).ms)
                      .slideY(
                        begin: 0.1,
                        end: 0,
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                        delay: (50 * listIndex).ms,
                      );
                },
                childCount: filteredList.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ];
      },
    );
  }

  // ── Search & Filter ────────────────────────────────────────────────────────

  Widget _buildSearchField(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      elevation: isDark ? 0 : 2,
      shadowColor: theme.shadowColor.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(18),
      color: theme.colorScheme.surface,
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        style: GoogleFonts.inter(color: theme.colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: 'Search quests...',
          hintStyle: GoogleFonts.inter(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            fontSize: 15,
          ),
          prefixIcon:
              Icon(Icons.search, color: theme.colorScheme.secondary, size: 24),
          isDense: true,
          filled: true,
          fillColor: theme.colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: isDark
                ? BorderSide(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1))
                : BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        ),
      ),
    );
  }

  Widget _buildFilterButton(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final hasActiveFilter = _selectedDifficulty != null;

    return Material(
      elevation: isDark ? 0 : 2,
      shadowColor: theme.shadowColor.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(18),
      color: hasActiveFilter
          ? theme.colorScheme.secondary
          : theme.colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _showFilterModal,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: isDark
                ? Border.all(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1))
                : null,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            Icons.tune,
            color: hasActiveFilter
                ? theme.colorScheme.onSecondary
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  void _showFilterModal() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          final primaryColor = theme.colorScheme.primary;
          final accentColor = theme.colorScheme.secondary;

          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(28.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface
                        .withValues(alpha: isDark ? 0.7 : 0.9),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                        color: primaryColor.withValues(alpha: 0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                          color: primaryColor.withValues(alpha: 0.1),
                          blurRadius: 30,
                          spreadRadius: -5),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.explore, color: primaryColor, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            'QUEST FILTERS',
                            style: GoogleFonts.orbitron(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'DIFFICULTY LEVEL',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: ['Beginner', 'Intermediate', 'Advanced']
                            .map((diff) => _buildSciFiChip(
                                diff, _selectedDifficulty == diff, accentColor,
                                () {
                                  setDialogState(() {
                                    _selectedDifficulty =
                                        _selectedDifficulty == diff
                                            ? null
                                            : diff;
                                  });
                                  setState(() {});
                                }))
                            .toList(),
                      ),
                      const SizedBox(height: 36),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor:
                                primaryColor.withValues(alpha: 0.15),
                            foregroundColor: primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                  color: primaryColor.withValues(alpha: 0.5),
                                  width: 1.5),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text('APPLY FILTERS',
                              style: GoogleFonts.orbitron(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
                .animate()
                .scale(
                    begin: const Offset(0.9, 0.9),
                    duration: 300.ms,
                    curve: Curves.easeOutBack)
                .fade(),
          );
        });
      },
    );
  }

  Widget _buildSciFiChip(
      String label, bool isSelected, Color accentColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? accentColor
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: accentColor.withValues(alpha: 0.2), blurRadius: 8)]
              : [],
        ),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected
                ? accentColor
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}