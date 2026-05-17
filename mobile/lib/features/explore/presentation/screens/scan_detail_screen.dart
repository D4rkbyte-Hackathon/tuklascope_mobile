import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/scan_service.dart';

class ScanDetailScreen extends StatefulWidget {
  final String scanId;
  final String objectName;
  final String imagUrl;

  const ScanDetailScreen({
    super.key,
    required this.scanId,
    required this.objectName,
    required this.imagUrl,
  });

  @override
  State<ScanDetailScreen> createState() => _ScanDetailScreenState();
}

class _ScanDetailScreenState extends State<ScanDetailScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _scanData;
  bool _isLoadingScan = true;

  // Parsed learning deck data
  String _skill = 'Unknown';
  String _domain = 'General';
  String _realWorldText = '';

  @override
  void initState() {
    super.initState();
    _fetchScanDetails();
  }

  Future<void> _fetchScanDetails() async {
    try {
      final scanData = await ScanService.getScanById(widget.scanId);
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
      // Standardizes the background to your app's core theme
      backgroundColor: theme.colorScheme.surface,
      body: _isLoadingScan
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : Stack(
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
                            // Tech Deco Icon
                            Icon(Icons.analytics_outlined, color: primaryColor.withValues(alpha: 0.6)),
                          ],
                        ),
                      ).animate().fade().slideX(begin: -0.2),

                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 3. TITLE & DOMAIN TAG
                              Text(
                                widget.objectName.toUpperCase(),
                                style: GoogleFonts.orbitron(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.onSurface,
                                  letterSpacing: 2.0,
                                  height: 1.1,
                                ),
                              ).animate().fade(delay: 100.ms).slideX(begin: -0.1),
                              
                              const SizedBox(height: 8),
                              
                              // Domain Tag with Icon
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
                                    Text(
                                      _domain.toUpperCase(),
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: secondaryAccent,
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().fade(delay: 200.ms).slideX(begin: -0.1),

                              const SizedBox(height: 30),

                              // 4. HERO IMAGE (Center Stage)
                              SizedBox(
                                height: 260,
                                width: double.infinity,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Spinning tech ring
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

                                    // Inner crosshairs
                                    CustomPaint(
                                      size: const Size(220, 220),
                                      painter: _CrosshairPainter(color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                                    ),

                                    // Item image
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
                                  Text(
                                    "DISCOVERY STATS",
                                    style: GoogleFonts.orbitron(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                ],
                              ).animate().fade(delay: 300.ms),
                              
                              const SizedBox(height: 12),
                              
                              // IntrinsicHeight ensures both blocks stay exactly the same height 
                              // even if the skill text gets super long!
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // XP Block
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
                                    // Skill Block (No cutting off text)
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
                                    Text(
                                      "DATALOG // REAL WORLD",
                                      style: GoogleFonts.orbitron(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                        letterSpacing: 2.0,
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

                              const SizedBox(height: 120), // Bottom padding for floating button
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 7. BOTTOM ACTION BUTTON ("Equip" style button)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(20, 30, 20, MediaQuery.paddingOf(context).bottom + 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          theme.colorScheme.surface,
                          theme.colorScheme.surface.withValues(alpha: 0.9),
                          theme.colorScheme.surface.withValues(alpha: 0.0),
                        ],
                        stops: const [0.4, 0.8, 1.0],
                      )
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 15,
                        shadowColor: primaryColor.withValues(alpha: 0.5),
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
                          Text(
                            "ASK TUKLAS TUTOR",
                            style: GoogleFonts.orbitron(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                     .shimmer(duration: 2.seconds, color: theme.colorScheme.onPrimary.withValues(alpha: 0.3)),
                  ),
                ),
              ],
            ),
    );
  }

  // RPG style rigid stat blocks (Allows unlimited text lines for long skill names)
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
          // VALUE TEXT - Completely unrestricted, will wrap automatically
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for the subtle HUD background grid
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

// Custom Painter for tech crosshairs around the item
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

    // Top Left
    canvas.drawLine(const Offset(0, 0), const Offset(len, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, len), paint);

    // Top Right
    canvas.drawLine(Offset(w, 0), Offset(w - len, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, len), paint);

    // Bottom Left
    canvas.drawLine(Offset(0, h), Offset(len, h), paint);
    canvas.drawLine(Offset(0, h), Offset(0, h - len), paint);

    // Bottom Right
    canvas.drawLine(Offset(w, h), Offset(w - len, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - len), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}