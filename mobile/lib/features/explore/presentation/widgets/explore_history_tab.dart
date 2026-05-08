import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; 
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/scan_service.dart';
import 'scan_history_card.dart';
import '../screens/scan_detail_screen.dart';
import '../../../../core/navigation/main_nav_scope.dart';

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

  // 🚀 MODAL: Filter Options
  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder( // StatefulBuilder to update modal state
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filters', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Text('SORT BY', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Newest'),
                        selected: _sortOrder == 'newest',
                        onSelected: (val) {
                          setModalState(() => _sortOrder = 'newest');
                          setState(() {}); // Update main UI
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Oldest'),
                        selected: _sortOrder == 'oldest',
                        onSelected: (val) {
                          setModalState(() => _sortOrder = 'oldest');
                          setState(() {}); // Update main UI
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('LENS / SUBJECT', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['STEM', 'History', 'Art', 'Biology'].map((lens) {
                      return ChoiceChip(
                        label: Text(lens),
                        selected: _selectedLens == lens,
                        onSelected: (val) {
                          setModalState(() => _selectedLens = val ? lens : null);
                          setState(() {}); // Update main UI
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text('Apply Filters', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  )
                ],
              ),
            );
          }
        );
      },
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

  // 🚀 UI: The Cool Empty State
  Widget _buildCoolEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Floating 3D-like Icon effect
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
            const SizedBox(height: 32),
            
            // 🚀 Call to Action Button - Now Fully Wired!
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                elevation: 4,
                shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              icon: const Icon(Icons.camera_alt),
              label: Text("Start Discovering", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16)),
              onPressed: () {
                // This talks to your MainNavigationState to instantly slide over to Tab 1 (Scanner)
                MainNavScope.maybeOf(context)?.goToTab(1);
              },
            ),
          ],
        ).animate().fade(duration: 800.ms).slideY(begin: 0.1, duration: 800.ms, curve: Curves.easeOutQuart),
      ),
    );
  }
}