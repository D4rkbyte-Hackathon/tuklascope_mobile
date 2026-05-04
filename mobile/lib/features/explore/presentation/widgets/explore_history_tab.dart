//explore history tab
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; 
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/scan_service.dart';
import 'scan_history_card.dart';
import '../screens/scan_detail_screen.dart';

class ExploreHistoryTab extends StatefulWidget {
  const ExploreHistoryTab({super.key});

  @override
  State<ExploreHistoryTab> createState() => _ExploreHistoryTabState();
}

class _ExploreHistoryTabState extends State<ExploreHistoryTab> {
  // 🚀 SCAN HISTORY STATE VARIABLES
  List<Map<String, dynamic>> _scanHistory = [];
  bool _isLoadingScanHistory = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchScanHistory();
  }

  // 🚀 FETCH SCAN HISTORY FROM SUPABASE
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

  // Get filtered scans based on search query
  List<Map<String, dynamic>> _getFilteredScans() {
    if (_searchQuery.isEmpty) {
      return _scanHistory;
    }
    
    return _scanHistory
        .where((scan) =>
            (scan['object_name'] as String?)
                ?.toLowerCase()
                .contains(_searchQuery.toLowerCase()) ??
            false)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom + 72;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildSearchField(theme),
        ),
        const SizedBox(height: 16),
        Expanded(child: _buildHistoryFeed(bottomInset, theme)),
      ],
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      elevation: isDark ? 0 : 1, // Shadow invisible in dark mode anyway
      shadowColor: theme.shadowColor.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(18),
      color: theme.colorScheme.surface, // Themed Input Surface
      child: TextField(
        onChanged: (value) {
          // 🔥 Now this ONLY rebuilds the History Tab! Not the whole screen!
          setState(() => _searchQuery = value);
        },
        style: GoogleFonts.inter(color: theme.colorScheme.onSurface), // Themed Input Text
        decoration: InputDecoration(
          hintText: 'Search your previously scanned stuff...',
          hintStyle: GoogleFonts.inter(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 15), 
          prefixIcon: Icon(Icons.search, color: theme.colorScheme.secondary, size: 28), 
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

  Widget _buildHistoryFeed(double bottomInset, ThemeData theme) {
    if (_isLoadingScanHistory) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.secondary),
      );
    }

    final filteredScans = _getFilteredScans();

    if (filteredScans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No scans yet' : 'No results for "$_searchQuery"',
              style: GoogleFonts.inter(fontSize: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset),
      physics: const BouncingScrollPhysics(),
      itemCount: filteredScans.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final scan = filteredScans[index];
        final objectName = scan['object_name'] as String? ?? 'Unknown Item';
        final lens = scan['chosen_lens'] as String? ?? 'STEM';
        final createdAt = scan['created_at'] as String?;
        final imageUrl = scan['image_url'] as String?;

        String formattedDate = 'Recently';
        if (createdAt != null) {
          try {
            final date = DateTime.parse(createdAt);
            final now = DateTime.now();
            final difference = now.difference(date);

            if (difference.inDays == 0) {
              formattedDate = 'Today';
            } else if (difference.inDays == 1) {
              formattedDate = 'Yesterday';
            } else if (difference.inDays < 7) {
              formattedDate = '${difference.inDays}d ago';
            } else {
              formattedDate = '${(difference.inDays / 7).toStringAsFixed(0)}w ago';
            }
          } catch (e) {
            formattedDate = 'Recently';
          }
        }

        return ScanHistoryCard(
          title: objectName,
          subtitle: formattedDate,
          tag: lens,
          imageUrl: imageUrl,
          accent: theme.colorScheme.secondary,
          onTap: () {
            final scanId = scan['id'] as String? ?? '';
            if (scanId.isNotEmpty) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ScanDetailScreen(
                    scanId: scanId,
                    objectName: objectName,
                    imagUrl: imageUrl ?? '',
                  ),
                ),
              );
            }
          },
        )
        .animate()
        .fade(duration: 600.ms, delay: (100 * index).ms)
        .slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: (100 * index).ms);
      },
    );
  }
}