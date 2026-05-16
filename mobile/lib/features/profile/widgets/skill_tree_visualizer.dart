import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import '../models/profile_models.dart';

// --- SHARED GLASS CARD HELPER ---
Widget _buildGlassCard(ThemeData theme, {required Widget child, EdgeInsetsGeometry? padding}) {
  final isDark = theme.brightness == Brightness.dark;
  return Container(
    padding: padding,
    decoration: BoxDecoration(
      color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.6),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 15,
          offset: const Offset(0, 6),
        )
      ],
    ),
    child: child,
  );
}

// --- BOTTOM SHEET UI ---
void showNodeDetailsBottomSheet(BuildContext context, SkillNode node) {
  final theme = Theme.of(context);
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(
                color: node.color.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: node.color.withValues(alpha: 0.15),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: node.color.withValues(alpha: 0.15),
                  radius: 35,
                  child: Icon(
                    node.id == 'root' ? Icons.person : Icons.hub,
                    color: node.color,
                    size: 35,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  node.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  node.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildStatPill('LEVEL', '${node.level}', node.color),
                    buildStatPill(
                      'TOTAL XP',
                      '${node.xp}',
                      node.color,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget buildStatPill(String label, String value, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.1),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ],
    ),
    child: Column(
      children: [
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color.withValues(alpha: 0.8),
            letterSpacing: 1.5,
          ),
        ),
      ],
    ),
  );
}

// --- DYNAMIC NETWORK WIDGET ---
class DynamicSkillTreeNetwork extends StatelessWidget {
  final ThemeData theme;
  final List<SkillNode> nodes;
  final String userName;

  const DynamicSkillTreeNetwork({
    super.key,
    required this.theme,
    required this.nodes,
    required this.userName,
  });

  void _handleTap(BuildContext context, Offset localPosition) {
    const center = Offset(400, 400);
    for (var node in nodes.reversed) {
      final nodeCenter =
          center +
          Offset(
            node.radialDistance * math.cos(node.angle),
            node.radialDistance * math.sin(node.angle),
          );
      if ((localPosition - nodeCenter).distance <= node.radius + 15) {
        showNodeDetailsBottomSheet(context, node);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Stack(
              children: [
                SizedBox(
                  height: 350,
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: 800,
                      height: 800,
                      // 🚀 FIX: Moved GestureDetector to wrap the entire Stack
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTapUp: (details) =>
                            _handleTap(context, details.localPosition),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: TechGridPainter(theme.colorScheme.primary),
                              ),
                            ),
                            Positioned.fill(
                              child: CustomPaint(
                                painter: OrganicTreePainter(
                                  theme: theme,
                                  nodes: nodes,
                                  scale: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.surface.withValues(
                            alpha: 0.5,
                          ),
                          foregroundColor: theme.colorScheme.primary,
                        ),
                        icon: const Icon(Icons.fullscreen),
                        onPressed: () =>
                            Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute(
                                builder: (context) => FullScreenSkillTree(
                                  theme: theme,
                                  nodes: nodes,
                                ),
                              ),
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (context) =>
                    FullScreenSkillTree(theme: theme, nodes: nodes),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.zoom_out_map,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tap to expand & explore interactively',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- FULL SCREEN WIDGET ---
class FullScreenSkillTree extends StatefulWidget {
  final ThemeData theme;
  final List<SkillNode> nodes;

  const FullScreenSkillTree({super.key, required this.theme, required this.nodes});

  @override
  State<FullScreenSkillTree> createState() => _FullScreenSkillTreeState();
}

class _FullScreenSkillTreeState extends State<FullScreenSkillTree> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      final offsetX = 1000.0 - (screenSize.width / 2);
      final offsetY = 1000.0 - (screenSize.height / 2);
      _transformationController.value = Matrix4.translationValues(
        -offsetX,
        -offsetY,
        0.0,
      );
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _handleTap(BuildContext context, Offset localPosition) {
    const center = Offset(1000, 1000);
    for (var node in widget.nodes.reversed) {
      final nodeCenter =
          center +
          Offset(
            node.radialDistance * math.cos(node.angle),
            node.radialDistance * math.sin(node.angle),
          );
      if ((localPosition - nodeCenter).distance <= node.radius + 15) {
        showNodeDetailsBottomSheet(context, node);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 1. The Interactive Panning/Zooming Layer
          InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.2,
            maxScale: 3.5,
            constrained: false,
            boundaryMargin: const EdgeInsets.all(1000),
            child: SizedBox(
              width: 2000,
              height: 2000,
              // 🚀 FIX: Moved GestureDetector to wrap the entire Stack
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapUp: (details) =>
                    _handleTap(context, details.localPosition),
                child: Stack(
                  children: [
                    // Textured Blueprint Background
                    Positioned.fill(
                      child: CustomPaint(
                        painter: TechGridPainter(widget.theme.colorScheme.primary),
                      ),
                    ),
                    // The Neural Network
                    Positioned.fill(
                      child: CustomPaint(
                        painter: OrganicTreePainter(
                          theme: widget.theme,
                          nodes: widget.nodes,
                          scale: 1.0,
                          isFullScreen: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 2. Custom Floating Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, left: 20, right: 20, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: _buildGlassCard(
                        widget.theme,
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded, 
                          color: widget.theme.colorScheme.primary, 
                          size: 20
                        ),
                      ),
                    ),
                    Text(
                      'NEURAL NETWORK',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: widget.theme.colorScheme.primary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
            ),
          ),

          // 3. Elevated Floating Pill
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: widget.theme.colorScheme.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: widget.theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.pinch,
                          size: 16,
                          color: widget.theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pinch to zoom • Drag to pan',
                          style: GoogleFonts.inter(
                            color: widget.theme.colorScheme.onSurface,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- GAMIFIED BACKGROUND GRID PAINTER ---
class TechGridPainter extends CustomPainter {
  final Color color;
  
  TechGridPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const double spacing = 50.0;
    
    // Draw Grid Lines
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), linePaint);
    }

    // Draw Intersection Data Dots
    final dotPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
      
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- CUSTOM NODE PAINTER ---
class OrganicTreePainter extends CustomPainter {
  final ThemeData theme;
  final List<SkillNode> nodes;
  final double scale;
  final bool isFullScreen;

  OrganicTreePainter({
    required this.theme,
    required this.nodes,
    required this.scale,
    this.isFullScreen = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;

    final center = isFullScreen
        ? const Offset(1000, 1000)
        : const Offset(400, 400);

    Offset getOffset(SkillNode node) =>
        center +
        Offset(
          node.radialDistance * math.cos(node.angle),
          node.radialDistance * math.sin(node.angle),
        );

    // Buffed Gradient Branches
    void drawOrganicBranch(SkillNode n1, SkillNode n2) {
      final p1 = getOffset(n1);
      final p2 = getOffset(n2);
      final path = Path()..moveTo(p1.dx, p1.dy);

      final midPoint = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      final angle = math.atan2(p2.dy - p1.dy, p2.dx - p1.dx);
      final cpX = midPoint.dx - math.sin(angle) * 30;
      final cpY = midPoint.dy + math.cos(angle) * 30;

      path.quadraticBezierTo(cpX, cpY, p2.dx, p2.dy);
      
      final isRootConnection = n1.id == 'root';
      final gradient = LinearGradient(
        colors: [
          n1.color.withValues(alpha: 0.6),
          n2.color.withValues(alpha: 0.6),
        ],
      ).createShader(Rect.fromPoints(p1, p2));

      canvas.drawPath(
        path,
        Paint()
          ..shader = gradient
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = (isRootConnection ? 5.0 : 2.5),
      );
    }

    final root = nodes.firstWhere((n) => n.id == 'root');
    for (var node in nodes) {
      if (node.id == 'root') continue;
      if (node.strand == 'root') {
        drawOrganicBranch(root, node);
      } else {
        final parentNode = nodes.firstWhere(
          (n) => n.id == node.strand,
          orElse: () => root,
        );
        drawOrganicBranch(parentNode, node);
      }
    }

    // Buffed Glowing Nodes
    for (var node in nodes) {
      final pCenter = getOffset(node);

      if (node.id == 'root') {
        final Rect coreRect = Rect.fromCircle(
          center: pCenter,
          radius: node.radius,
        );
        // Outer Glow
        canvas.drawCircle(
          pCenter,
          node.radius + 8,
          Paint()
            ..color = node.color.withValues(alpha: 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
        );
        // Inner Gradient
        canvas.drawCircle(
          pCenter,
          node.radius,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            ).createShader(coreRect),
        );
      } else {
        // Outer Glow
        canvas.drawCircle(
          pCenter,
          node.radius + 4,
          Paint()
            ..color = node.color.withValues(alpha: 0.2)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
        // Background
        canvas.drawCircle(
          pCenter,
          node.radius,
          Paint()..color = theme.colorScheme.surface,
        );
        // Stroke Ring
        canvas.drawCircle(
          pCenter,
          node.radius,
          Paint()
            ..color = node.color
            ..strokeWidth = 3.5
            ..style = PaintingStyle.stroke,
        );
      }

      final text = node.id == 'root' ? node.title : node.title.split(' ')[0];
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: GoogleFonts.inter(
            color: node.id == 'root'
                ? Colors.white
                : theme.colorScheme.onSurface,
            fontSize: node.id == 'root' ? 16 : 12,
            fontWeight: FontWeight.w800,
            shadows: node.id != 'root' ? [
              Shadow(
                color: theme.colorScheme.surface,
                blurRadius: 4,
              )
            ] : [],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(
          pCenter.dx - (textPainter.width / 2),
          pCenter.dy - (textPainter.height / 2),
        ),
      );

      if (node.id != 'root') {
        final levelPainter = TextPainter(
          text: TextSpan(
            text: 'Lv.${node.level}',
            style: GoogleFonts.orbitron(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        levelPainter.paint(
          canvas,
          pCenter + Offset(-levelPainter.width / 2, node.radius + 4),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant OrganicTreePainter oldDelegate) => true;
}