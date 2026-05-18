import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/scan_service.dart';

class ScanDetailScreen extends StatefulWidget {
  final String scanId;
  final String objectName;
  final String imagUrl;
  final List<Map<String, dynamic>>? relatedScans; 

  const ScanDetailScreen({
    super.key,
    required this.scanId,
    required this.objectName,
    required this.imagUrl,
    this.relatedScans, 
  });

  @override
  State<ScanDetailScreen> createState() => _ScanDetailScreenState();
}

class _ScanDetailScreenState extends State<ScanDetailScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _scanData;
  bool _isLoadingScan = true;

  late String _currentScanId;

  // Parsed learning deck data
  String _skill = 'Unknown';
  String _domain = 'General';
  String _realWorldText = '';

  @override
  void initState() {
    super.initState();
    _currentScanId = widget.scanId;
    _fetchScanDetails();
  }

  Future<void> _fetchScanDetails() async {
    try {
      final scanData = await ScanService.getScanById(_currentScanId);
      if (mounted) {
        setState(() {
          _scanData = scanData;
          _isLoadingScan = false;
          _parseLearningDeck(scanData);
        });
      }
    } catch (e) {
      debugPrint('Error fetching scan details: $e');
      if (mounted) {
        setState(() => _isLoadingScan = false);
      }
    }
  }

  void _switchLens(String newScanId) {
    if (_currentScanId == newScanId) return;
    setState(() {
      _currentScanId = newScanId;
      _isLoadingScan = true;
    });
    _fetchScanDetails();
  }

  void _parseLearningDeck(Map<String, dynamic>? scanData) {
    if (scanData == null) return;

    try {
      var learningDeck = scanData['learning_deck'];
      if (learningDeck == null) return;

      if (learningDeck is String && learningDeck.isNotEmpty) {
        learningDeck = jsonDecode(learningDeck);
      }

      if (learningDeck['concept_card'] != null) {
        final conceptCard = learningDeck['concept_card'];
        _skill = conceptCard['skill'] ?? 'Unknown';
        _domain = conceptCard['domain'] ?? 'General';
      }

      if (learningDeck['real_world_card'] != null) {
        final realWorldCard = learningDeck['real_world_card'];
        _realWorldText = realWorldCard['fun_fact'] ?? 'No data available.';
      }
    } catch (e) {
      debugPrint('Error parsing learning deck: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final primaryColor = theme.colorScheme.primary;
    final secondaryAccent = theme.colorScheme.secondary;
    final tertiaryAccent = theme.colorScheme.tertiary;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // 1. CLEAN, THEME-ADAPTIVE BACKGROUND GRADIENT
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.surface,
                    primaryColor.withValues(alpha: isDark ? 0.08 : 0.03),
                    theme.colorScheme.surface,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Subtle Tech Grid overlay
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.03 : 0.06, 
              child: CustomPaint(painter: _GridPainter(color: theme.colorScheme.onSurface)),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 2. TOP BAR & BACK BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                            border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface, size: 16),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.analytics_outlined, color: primaryColor.withValues(alpha: 0.6)),
                    ],
                  ),
                ).animate().fade().slideX(begin: -0.2),

                Expanded(
                  child: _isLoadingScan 
                  ? Center(child: CircularProgressIndicator(color: primaryColor))
                  : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 3. TITLE
                        Text(
                          widget.objectName.toUpperCase(),
                          style: GoogleFonts.orbitron(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: 1.5,
                            height: 1.1,
                          ),
                        ).animate().fade(delay: 100.ms).slideX(begin: -0.1),
                        
                        const SizedBox(height: 16),
                        
                        // Domain Tag + Strand Switcher (Wrapped in a Column to strictly prevent horizontal overflow)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Current Active Domain Tag
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: secondaryAccent.withValues(alpha: 0.15),
                                border: Border(left: BorderSide(color: secondaryAccent, width: 3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.category_rounded, size: 14, color: secondaryAccent),
                                  const SizedBox(width: 6),
                                  // Added Flexible here to prevent text overflow if Domain name is very long
                                  Flexible(
                                    child: Text(
                                      _domain.toUpperCase(),
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: secondaryAccent,
                                        letterSpacing: 2.0,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Strand Switcher Options (Stacked safely below to prevent overflow)
                            if (widget.relatedScans != null && widget.relatedScans!.length > 1) ...[
                              const SizedBox(height: 16),
                              Text("AVAILABLE STRANDS:", style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                              const SizedBox(height: 8),
                              // Wrap dynamically breaks into next line if it runs out of horizontal space
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: widget.relatedScans!.map((s) {
                                  final strandName = s['chosen_lens'] as String? ?? 'STEM';
                                  final sId = s['id'] as String;
                                  final isSelected = _currentScanId == sId;
                                  
                                  return ChoiceChip(
                                    label: Text(strandName),
                                    selected: isSelected,
                                    selectedColor: primaryColor.withValues(alpha: 0.3),
                                    backgroundColor: theme.colorScheme.surface,
                                    labelStyle: GoogleFonts.orbitron(
                                      fontSize: 10,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? primaryColor : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                    onSelected: (_) => _switchLens(sId),
                                  );
                                }).toList(),
                              ),
                            ]
                          ],
                        ).animate().fade(delay: 200.ms).slideX(begin: -0.1),

                        const SizedBox(height: 30),

                        // 4. HERO IMAGE (Center Stage)
                        SizedBox(
                          height: 260,
                          width: double.infinity,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: primaryColor.withValues(alpha: 0.3), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withValues(alpha: 0.15),
                                      blurRadius: 40,
                                      spreadRadius: 5,
                                    )
                                  ]
                                ),
                              ).animate(onPlay: (c) => c.repeat())
                               .rotate(duration: 20.seconds)
                               .scaleXY(begin: 0.95, end: 1.05, duration: 3.seconds, curve: Curves.easeInOut)
                               .then().scaleXY(begin: 1.05, end: 0.95, duration: 3.seconds, curve: Curves.easeInOut),

                              CustomPaint(
                                size: const Size(220, 220),
                                painter: _CrosshairPainter(color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                              ),

                              if (widget.imagUrl.isNotEmpty)
                                Image.network(
                                  widget.imagUrl,
                                  fit: BoxFit.contain,
                                ).animate().scale(begin: const Offset(0.8, 0.8), duration: 600.ms, curve: Curves.easeOutBack).fade()
                              else
                                Icon(Icons.science, size: 100, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // 5. RPG STAT BLOCKS
                        Row(
                          children: [
                            Icon(Icons.bar_chart_rounded, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                "DISCOVERY STATS",
                                style: GoogleFonts.orbitron(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ),
                          ],
                        ).animate().fade(delay: 300.ms),
                        
                        const SizedBox(height: 12),
                        
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _buildStatBlock(
                                  label: "KNOWLEDGE XP",
                                  value: "+${_scanData?['xp_awarded'] ?? 50}",
                                  icon: Icons.stars_rounded,
                                  color: primaryColor,
                                  theme: theme,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatBlock(
                                  label: "SKILL UNLOCKED",
                                  value: _skill,
                                  icon: Icons.psychology_rounded,
                                  color: secondaryAccent,
                                  theme: theme,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fade(delay: 400.ms).slideY(begin: 0.1),

                        const SizedBox(height: 24),

                        // 6. REAL WORLD LORE DATALOG
                        if (_realWorldText.isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(Icons.travel_explore_rounded, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  "DATALOG // REAL WORLD",
                                  style: GoogleFonts.orbitron(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ),
                            ],
                          ).animate().fade(delay: 500.ms),
                          
                          const SizedBox(height: 12),
                          
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: tertiaryAccent.withValues(alpha: 0.05),
                              border: Border.all(color: tertiaryAccent.withValues(alpha: 0.3), width: 1.5),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(24),
                                bottomLeft: Radius.circular(24),
                                bottomRight: Radius.circular(4),
                              )
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.public_rounded, color: tertiaryAccent, size: 22)
                                  .animate(onPlay: (c) => c.repeat(reverse: true))
                                  .fadeIn(duration: 1.seconds),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _realWorldText,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      height: 1.6,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fade(delay: 600.ms).slideY(begin: 0.1),
                        ],

                        const SizedBox(height: 32),
                        
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              shadowColor: primaryColor.withValues(alpha: 0.4),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Tuklas Tutor initializing...', style: GoogleFonts.orbitron(color: theme.colorScheme.onPrimary)),
                                  backgroundColor: primaryColor,
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.smart_toy_rounded, size: 22),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    "ASK TUKLAS TUTOR",
                                    style: GoogleFonts.orbitron(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ).animate(onPlay: (c) => c.repeat(reverse: true))
                           .shimmer(duration: 2.seconds, color: theme.colorScheme.onPrimary.withValues(alpha: 0.3)),
                        ),
                        
                        SizedBox(height: MediaQuery.paddingOf(context).bottom + 40), 
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBlock({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 10)
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    const spacing = 40.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CrosshairPainter extends CustomPainter {
  final Color color;
  const _CrosshairPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final double w = size.width;
    final double h = size.height;
    const double len = 15.0;

    canvas.drawLine(const Offset(0, 0), const Offset(len, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, len), paint);
    canvas.drawLine(Offset(w, 0), Offset(w - len, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, len), paint);
    canvas.drawLine(Offset(0, h), Offset(len, h), paint);
    canvas.drawLine(Offset(0, h), Offset(0, h - len), paint);
    canvas.drawLine(Offset(w, h), Offset(w - len, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - len), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}