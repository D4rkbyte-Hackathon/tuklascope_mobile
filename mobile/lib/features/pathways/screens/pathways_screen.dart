import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart'; // Ensure this is in your pubspec.yaml
import '../../../core/widgets/gradient_scaffold.dart';
import 'package:tuklascope_mobile/core/navigation/main_nav_scope.dart';
import '../data/mock_pathways_data.dart';
import '../models/project_data.dart'; // Added to type the filtered list properly
import '../widgets/header_section.dart';
import '../widgets/project_card.dart';

class PathwaysScreen extends StatefulWidget {
  const PathwaysScreen({super.key});

  @override
  State<PathwaysScreen> createState() => _PathwaysScreenState();
}

class _PathwaysScreenState extends State<PathwaysScreen> {
  // --- STATE VARIABLES ---
  String _searchQuery = '';
  String? _selectedDifficulty; // e.g., 'Beginner', 'Intermediate', 'Advanced'

  // --- FILTERING LOGIC ---
  List<ProjectData> get _filteredProjects {
    return myProjects.where((project) {
      // 1. Check Search Query (matches Title or Description)
      final matchesSearch = _searchQuery.isEmpty ||
          project.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          project.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // 2. Check Selected Difficulty Filter
      final matchesDifficulty = 
          _selectedDifficulty == null || project.difficulty == _selectedDifficulty;
          
      return matchesSearch && matchesDifficulty;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final navScope = MainNavScope.maybeOf(context);
    final isNavBarVisible = navScope?.isNavBarVisible ?? true;
    final theme = Theme.of(context);
    
    final filteredList = _filteredProjects;
    final int itemCount = filteredList.isEmpty ? 4 : 3 + filteredList.length;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      }, 
      child: GradientScaffold(
        // 🚀 FIX: Wrap the body in a SafeArea to match HomeScreen's hard cut
        body: SafeArea(
          child: Center(
            child: ListView.builder(
              padding: EdgeInsets.zero, // 🚀 Removed the MediaQuery top padding
              itemCount: itemCount,
              itemBuilder: (context, index) {
                
                if (index == itemCount - 1) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutQuint,
                    height: (isNavBarVisible ? 100.0 : 20.0) + MediaQuery.paddingOf(context).bottom,
                  );
                }
                
                Widget item;
                
                if (index == 0) {
                  item = const HeaderSection(
                    activePathways: mockActivePathways,
                    averageProgress: mockAverageProgress,
                    totalPoints: mockTotalPoints,
                  ); 
                } 
                else if (index == 1) {
                  item = Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Row(
                      children: [
                        Expanded(child: _buildSearchField(theme)),
                        const SizedBox(width: 12),
                        _buildFilterButton(theme),
                      ],
                    ),
                  );
                } 
                else {
                  if (filteredList.isEmpty) {
                    item = Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text(
                          'No quests match your criteria.',
                          style: GoogleFonts.inter(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    );
                  } else {
                    item = ProjectCard(data: filteredList[index - 2]);
                  }
                }
                
                return item
                    .animate()
                    .fade(duration: 600.ms, delay: (50 * index).ms)
                    .slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: (50 * index).ms);
              },
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // UI WIDGETS: SEARCH & FILTER 
  // ===========================================================================

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
          hintStyle: GoogleFonts.inter(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 15), 
          prefixIcon: Icon(Icons.search, color: theme.colorScheme.secondary, size: 24), 
          isDense: true,
          filled: true,
          fillColor: theme.colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: isDark ? BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)) : BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
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
      color: hasActiveFilter ? theme.colorScheme.secondary : theme.colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _showFilterModal,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: isDark ? Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)) : null,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            Icons.tune, 
            color: hasActiveFilter ? theme.colorScheme.onSecondary : theme.colorScheme.onSurface,
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
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Glassmorphism effect
                  child: Container(
                    padding: const EdgeInsets.all(28.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: isDark ? 0.7 : 0.9),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: primaryColor.withValues(alpha: 0.3), width: 1.5),
                      boxShadow: [
                        BoxShadow(color: primaryColor.withValues(alpha: 0.1), blurRadius: 30, spreadRadius: -5),
                      ]
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HEADER
                        Row(
                          children: [
                            Icon(Icons.explore, color: primaryColor, size: 24),
                            const SizedBox(width: 10),
                            Text(
                              'QUEST FILTERS', 
                              style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: primaryColor)
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // DIFFICULTY SECTION
                        Text('DIFFICULTY LEVEL', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          // Options pulled from the mock ProjectData difficulty strings
                          children: ['Beginner', 'Intermediate', 'Advanced'].map((diff) {
                            return _buildSciFiChip(diff, _selectedDifficulty == diff, accentColor, () {
                              // Tapping an already selected chip clears it
                              setDialogState(() => _selectedDifficulty = _selectedDifficulty == diff ? null : diff);
                              setState(() {}); // Updates the main screen behind the dialog
                            });
                          }).toList(),
                        ),
                        
                        const SizedBox(height: 36),
                        
                        // APPLY BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: primaryColor.withValues(alpha: 0.15),
                              foregroundColor: primaryColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: primaryColor.withValues(alpha: 0.5), width: 1.5),
                              )
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text('APPLY FILTERS', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ).animate().scale(begin: const Offset(0.9, 0.9), duration: 300.ms, curve: Curves.easeOutBack).fade(),
            );
          }
        );
      },
    );
  }

  Widget _buildSciFiChip(String label, bool isSelected, Color accentColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accentColor : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected ? [BoxShadow(color: accentColor.withValues(alpha: 0.2), blurRadius: 8)] : [],
        ),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? accentColor : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}