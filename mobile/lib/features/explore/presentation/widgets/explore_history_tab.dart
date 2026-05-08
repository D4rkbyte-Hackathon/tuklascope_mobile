import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; 
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/scan_service.dart';
import 'scan_history_card.dart';
import '../screens/scan_detail_screen.dart';
import '../../../../core/navigation/main_nav_scope.dart';
import 'dart:ui'; // 👈 NEW: Required for BackdropFilter (Glassmorphism)

class ExploreHistoryTab extends StatefulWidget {
  const ExploreHistoryTab({super.key});

  @override
  State<ExploreHistoryTab> createState() => _ExploreHistoryTabState();
}

class _ExploreHistoryTabState extends State<ExploreHistoryTab> {
  List<Map<String, dynamic>> _scanHistory = [];
  bool _isLoadingScanHistory = true;
  String _searchQuery = '';
  
  // 🚀 NEW: Filter States
  String _sortOrder = 'newest'; // 'newest' or 'oldest'
  String? _selectedLens; // e.g., 'STEM', 'History', etc.

  @override
  void initState() {
    super.initState();
    _fetchScanHistory();
  }

  Future<void> _fetchScanHistory() async {
    setState(() => _isLoadingScanHistory = true);
    try {
      final scans = await ScanService.getUserScanHistory(limit: 100);
      if (mounted) {
        setState(() {
          _scanHistory = scans;
          _isLoadingScanHistory = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching scan history: $e');
      if (mounted) setState(() => _isLoadingScanHistory = false);
    }
  }

  // 🚀 UPDATED: Client-side Filtering & Sorting
  List<Map<String, dynamic>> _getFilteredScans() {
    var filtered = _scanHistory.where((scan) {
      // Filter by Search Query
      final matchesSearch = _searchQuery.isEmpty ||
          (scan['object_name'] as String?)
              ?.toLowerCase()
              .contains(_searchQuery.toLowerCase()) == true;
      
      // Filter by Lens
      final matchesLens = _selectedLens == null || scan['chosen_lens'] == _selectedLens;
      
      return matchesSearch && matchesLens;
    }).toList();

    // Sort by Date
    filtered.sort((a, b) {
      final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime.now();
      final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime.now();
      return _sortOrder == 'newest' ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom + 72;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(child: _buildSearchField(theme)),
              const SizedBox(width: 12),
              _buildFilterButton(theme), // 👈 NEW: Filter Button
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(child: _buildHistoryFeed(bottomInset, theme)),
      ],
    );
  }

  // 🚀 UI: Search Field
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
          hintText: 'Search discoveries...',
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

  // 🚀 UI: Filter Button
  Widget _buildFilterButton(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final hasActiveFilter = _selectedLens != null || _sortOrder == 'oldest';

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

  // 🚀 MODAL: Floating Sci-Fi Filter Dialog (Now using Theme Colors!)
  void _showFilterModal() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6), // Darken background
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;
            
            // 🚀 dynamically grab the app's iconic colors from the theme
            final primaryColor = theme.colorScheme.primary; 
            final accentColor = theme.colorScheme.secondary; 

            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Glassmorphism
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
                            Icon(Icons.tune, color: primaryColor, size: 24),
                            const SizedBox(width: 10),
                            Text(
                              'FILTER PROTOCOL', 
                              style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: primaryColor)
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // SORT SECTION
                        Text('SORT BY TIMELINE', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          children: [
                            _buildSciFiChip('Newest', _sortOrder == 'newest', accentColor, () {
                              setDialogState(() => _sortOrder = 'newest');
                              setState(() {});
                            }),
                            _buildSciFiChip('Oldest', _sortOrder == 'oldest', accentColor, () {
                              setDialogState(() => _sortOrder = 'oldest');
                              setState(() {});
                            }),
                          ],
                        ),
                        
                        const SizedBox(height: 28),
                        
                        // LENS SECTION
                        Text('SCANNER LENS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: ['STEM', 'History', 'Art', 'Biology'].map((lens) {
                            return _buildSciFiChip(lens, _selectedLens == lens, primaryColor, () {
                              setDialogState(() => _selectedLens = _selectedLens == lens ? null : lens);
                              setState(() {});
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
                            child: Text('ENGAGE FILTERS', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
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

  // Helper widget to build consistent Sci-Fi style toggles
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

  // 🚀 UI: History Feed & Empty States
  Widget _buildHistoryFeed(double bottomInset, ThemeData theme) {
    if (_isLoadingScanHistory) {
      return Center(child: CircularProgressIndicator(color: theme.colorScheme.secondary));
    }

    final filteredScans = _getFilteredScans();

    if (filteredScans.isEmpty) {
      if (_scanHistory.isEmpty) {
        return _buildCoolEmptyState(theme); // 👈 NEW: Cool Call to Action
      } else {
        // If there are items but filters/search hide them
        return Center(
          child: Text('No results match your filters.', 
            style: GoogleFonts.inter(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))
          ),
        );
      }
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset),
      physics: const BouncingScrollPhysics(),
      itemCount: filteredScans.length,
      separatorBuilder: (_, _) => const SizedBox(height: 20), // Increased spacing
      itemBuilder: (context, index) {
        final scan = filteredScans[index];
        final objectName = scan['object_name'] as String? ?? 'Unknown Item';
        final lens = scan['chosen_lens'] as String? ?? 'STEM';
        final createdAt = scan['created_at'] as String?;
        final imageUrl = scan['image_url'] as String?;
        final xp = scan['xp_awarded'] as int?; // 👈 Pass XP from API

        String formattedDate = 'Recently';
        if (createdAt != null) {
          try {
            final date = DateTime.parse(createdAt);
            final difference = DateTime.now().difference(date);
            if (difference.inDays == 0) formattedDate = 'Today';
            else if (difference.inDays == 1) formattedDate = 'Yesterday';
            else if (difference.inDays < 7) formattedDate = '${difference.inDays}d ago';
            else formattedDate = '${(difference.inDays / 7).toStringAsFixed(0)}w ago';
          } catch (_) {}
        }

        return ScanHistoryCard(
          title: objectName,
          subtitle: formattedDate,
          tag: lens,
          imageUrl: imageUrl,
          xpAwarded: xp,
          accent: theme.colorScheme.secondary,
          onTap: () {
            final scanId = scan['id'] as String? ?? '';
            if (scanId.isNotEmpty) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ScanDetailScreen(scanId: scanId, objectName: objectName, imagUrl: imageUrl ?? '')));
            }
          },
        ).animate()
         .fade(duration: 400.ms, delay: (50 * index).ms)
         .slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutCubic);
      },
    );
  }

  // 🚀 UI: The Cool Empty State (NOW ANIMATED!)
  Widget _buildCoolEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.document_scanner_rounded, size: 64, color: theme.colorScheme.secondary),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .scaleXY(begin: 1.0, end: 1.05, duration: 2.seconds, curve: Curves.easeInOut),
            
            const SizedBox(height: 24),
            Text(
              "Your Journey Begins",
              style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "You haven't scanned anything yet. Point your camera at the world and let's uncover some secrets!",
              style: GoogleFonts.inter(fontSize: 15, color: theme.colorScheme.onSurface.withValues(alpha: 0.6), height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            // 🚀 Call to Action Button - NOW LIVELY!
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                elevation: 8, // Higher elevation
                shadowColor: theme.colorScheme.primary.withValues(alpha: 0.6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), // Smoother curve
              ),
              icon: const Icon(Icons.camera_alt, size: 22),
              label: Text("Start Discovering", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16)),
              onPressed: () {
                MainNavScope.maybeOf(context)?.goToTab(1);
              },
            )
            // 💥 The Breathing & Shimmer Animation
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(begin: 1.0, end: 1.04, duration: 1500.ms, curve: Curves.easeInOutSine)
            .shimmer(delay: 2.seconds, duration: 1.seconds, color: Colors.white.withValues(alpha: 0.4)),
          ],
        ).animate().fade(duration: 800.ms).slideY(begin: 0.1, duration: 800.ms, curve: Curves.easeOutQuart),
      ),
    );
  }
}