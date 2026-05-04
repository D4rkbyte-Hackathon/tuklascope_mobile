import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import '../models/profile_models.dart';

// --- BOTTOM SHEET UI ---
void showNodeDetailsBottomSheet(BuildContext context, SkillNode node) {
  final theme = Theme.of(context);
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: node.color.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: node.color.withValues(alpha: 0.1),
              blurRadius: 40,
              spreadRadius: 5,
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: node.color.withValues(alpha: 0.15),
                radius: 30,
                child: Icon(
                  node.id == 'root' ? Icons.person : Icons.hub,
                  color: node.color,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                node.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
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
              const SizedBox(height: 24),
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
      );
    },
  );
}

Widget buildStatPill(String label, String value, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Column(
      children: [
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 1,
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
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          width: 1,
        ),
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
                      child: GestureDetector(
                        onTapUp: (details) =>
                            _handleTap(context, details.localPosition),
                        child: CustomPaint(
                          painter: OrganicTreePainter(
                            theme: theme,
                            nodes: nodes,
                            scale: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.surface.withValues(
                        alpha: 0.8,
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
                color: theme.colorScheme.onSurface.withValues(alpha: 0.02),
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
                    color: theme.colorScheme.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tap to expand & explore interactively',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: theme.colorScheme.primary.withValues(alpha: 0.7),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: widget.theme.colorScheme.primary,
        title: Text(
          'Interactive Skill Tree',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pinch,
                    size: 16,
                    color: widget.theme.colorScheme.onSurface.withValues(
                      alpha: 0.6,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pinch to zoom • Drag to pan',
                    style: GoogleFonts.inter(
                      color: widget.theme.colorScheme.onSurface.withValues(
                        alpha: 0.6,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.2,
                maxScale: 3.5,
                constrained: false,
                boundaryMargin: const EdgeInsets.all(1000),
                child: SizedBox(
                  width: 2000,
                  height: 2000,
                  child: GestureDetector(
                    onTapUp: (details) =>
                        _handleTap(context, details.localPosition),
                    child: CustomPaint(
                      painter: OrganicTreePainter(
                        theme: widget.theme,
                        nodes: widget.nodes,
                        scale: 1.0,
                        isFullScreen: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTER ---
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

    void drawOrganicBranch(SkillNode n1, SkillNode n2, Color color) {
      final p1 = getOffset(n1);
      final p2 = getOffset(n2);
      final path = Path()..moveTo(p1.dx, p1.dy);

      final midPoint = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      final angle = math.atan2(p2.dy - p1.dy, p2.dx - p1.dx);
      final cpX = midPoint.dx - math.sin(angle) * 30;
      final cpY = midPoint.dy + math.cos(angle) * 30;

      path.quadraticBezierTo(cpX, cpY, p2.dx, p2.dy);
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = (n1.id == 'root' ? 4.0 : 2.0),
      );
    }

    final root = nodes.firstWhere((n) => n.id == 'root');
    for (var node in nodes) {
      if (node.id == 'root') continue;
      if (node.strand == 'root') {
        drawOrganicBranch(root, node, node.color);
      } else {
        final parentNode = nodes.firstWhere(
          (n) => n.id == node.strand,
          orElse: () => root,
        );
        drawOrganicBranch(parentNode, node, node.color);
      }
    }

    for (var node in nodes) {
      final pCenter = getOffset(node);

      if (node.id == 'root') {
        final Rect coreRect = Rect.fromCircle(
          center: pCenter,
          radius: node.radius,
        );
        canvas.drawCircle(
          pCenter,
          node.radius,
          Paint()
            ..shader = LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            ).createShader(coreRect),
        );
      } else {
        canvas.drawCircle(
          pCenter,
          node.radius + 4,
          Paint()
            ..color = node.color.withValues(alpha: 0.15)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
        canvas.drawCircle(
          pCenter,
          node.radius,
          Paint()..color = theme.colorScheme.surface,
        );
        canvas.drawCircle(
          pCenter,
          node.radius,
          Paint()
            ..color = node.color
            ..strokeWidth = 3.0
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
            fontWeight: FontWeight.bold,
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
              color: theme.colorScheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        levelPainter.paint(
          canvas,
          pCenter + Offset(-levelPainter.width / 2, node.radius + 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant OrganicTreePainter oldDelegate) => true;
}