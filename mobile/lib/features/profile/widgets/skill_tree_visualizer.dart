import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import '../models/profile_models.dart';

// --- SHARED GLASS CARD HELPER ---
Widget _buildGlassCard(
  ThemeData theme, {
  required Widget child,
  EdgeInsetsGeometry? padding,
}) {
  final isDark = theme.brightness == Brightness.dark;
  return Container(
    padding: padding,
    decoration: BoxDecoration(
      color: isDark
          ? Colors.black.withValues(alpha: 0.3)
          : Colors.white.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.6),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 15,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: child,
  );
}

// --- 🚀 THE PATHFINDING ENGINE ---
// Traces lineage up to the root and down to the leaves for the glowing lightning strike effect
Set<String>? getActivePathIds(String? focusId, List<SkillNode> nodes) {
  if (focusId == null) return null;

  Set<String> activeIds = {focusId, 'root'}; // Root is always powered on
  SkillNode? get(String id) => nodes.where((n) => n.id == id).firstOrNull;

  // Trace UP to parents
  void addAncestors(String id) {
    final node = get(id);
    if (node == null) return;
    for (var parentId in node.connectedNodeIds) {
      if (!activeIds.contains(parentId)) {
        activeIds.add(parentId);
        addAncestors(parentId);
      }
    }
  }

  // Trace DOWN to children
  void addDescendants(String id) {
    for (var node in nodes) {
      if (node.connectedNodeIds.contains(id) && !activeIds.contains(node.id)) {
        activeIds.add(node.id);
        addDescendants(node.id);
      }
    }
  }

  addAncestors(focusId);
  addDescendants(focusId);
  return activeIds;
}

// --- 🚀 THE NON-BLOCKING FLOATING PANEL ---
class NodeDetailsOverlay extends StatefulWidget {
  final String? focusedNodeId;
  final List<SkillNode> nodes;
  final ThemeData theme;
  final VoidCallback onClose;

  const NodeDetailsOverlay({
    super.key,
    required this.focusedNodeId,
    required this.nodes,
    required this.theme,
    required this.onClose,
  });

  @override
  State<NodeDetailsOverlay> createState() => _NodeDetailsOverlayState();
}

class _NodeDetailsOverlayState extends State<NodeDetailsOverlay> {
  SkillNode? _cachedNode;

  @override
  void didUpdateWidget(NodeDetailsOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusedNodeId != null) {
      _cachedNode = widget.nodes.firstWhere(
        (n) => n.id == widget.focusedNodeId,
        orElse: () => widget.nodes.first,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVisible = widget.focusedNodeId != null;
    final node = _cachedNode;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      bottom: isVisible ? 0 : -500, // Slides out of view entirely
      left: 0,
      right: 0,
      child: node == null ? const SizedBox.shrink() : _buildPanel(node),
    );
  }

  Widget _buildPanel(SkillNode node) {
    int currentXpInLevel = node.xp % 500;
    double progressPercent = currentXpInLevel / 500.0;
    int nextLevel = node.level + 1;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: widget.theme.colorScheme.surface.withValues(alpha: 0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(
                color: node.color.withValues(alpha: 0.6),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle & Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48), // Balance
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: widget.theme.colorScheme.onSurface.withValues(
                        alpha: 0.2,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: widget.theme.colorScheme.onSurface.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
              CircleAvatar(
                backgroundColor: node.color.withValues(alpha: 0.15),
                radius: 30,
                child: Icon(
                  node.id == 'root' ? Icons.person : Icons.hub,
                  color: node.color,
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                node.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: widget.theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                node.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: widget.theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 24),

              // Gamified XP Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LVL ${node.level}',
                    style: GoogleFonts.orbitron(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'LVL $nextLevel',
                    style: GoogleFonts.orbitron(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.theme.colorScheme.onSurface.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 16,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: widget.theme.colorScheme.onSurface.withValues(
                    alpha: 0.05,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.theme.colorScheme.onSurface.withValues(
                      alpha: 0.1,
                    ),
                  ),
                ),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      widthFactor: progressPercent.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: [
                              node.color.withValues(alpha: 0.5),
                              node.color,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: node.color.withValues(alpha: 0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$currentXpInLevel / 500 XP TO NEXT LEVEL',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: widget.theme.colorScheme.onSurface.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- DYNAMIC NETWORK WIDGET (MINI VIEW) ---
class DynamicSkillTreeNetwork extends StatefulWidget {
  final ThemeData theme;
  final List<SkillNode> nodes;
  final String userName;

  const DynamicSkillTreeNetwork({
    super.key,
    required this.theme,
    required this.nodes,
    required this.userName,
  });

  @override
  State<DynamicSkillTreeNetwork> createState() =>
      _DynamicSkillTreeNetworkState();
}

class _DynamicSkillTreeNetworkState extends State<DynamicSkillTreeNetwork> {
  final ValueNotifier<String?> _focusedNodeId = ValueNotifier(null);

  void _handleTap(Offset localPosition) {
    const center = Offset(400, 400);
    for (var node in widget.nodes.reversed) {
      final nodeCenter =
          center +
          Offset(
            node.radialDistance * math.cos(node.angle),
            node.radialDistance * math.sin(node.angle),
          );
      if ((localPosition - nodeCenter).distance <= node.radius + 15) {
        _focusedNodeId.value = node.id;
        return; // Found a node
      }
    }
    _focusedNodeId.value = null; // Tapped empty space, dismiss panel
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.theme.colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 20,
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
            child: SizedBox(
              height: 350,
              width: double.infinity,
              child: Stack(
                children: [
                  // Layer 1: The Interactive Graph
                  Positioned.fill(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: 800,
                        height: 800,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTapUp: (details) =>
                              _handleTap(details.localPosition),
                          child: ValueListenableBuilder<String?>(
                            valueListenable: _focusedNodeId,
                            builder: (context, focusedId, child) {
                              final activePathIds = getActivePathIds(
                                focusedId,
                                widget.nodes,
                              );
                              return Stack(
                                children: [
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: TechGridPainter(
                                        widget.theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: OrganicTreePainter(
                                        theme: widget.theme,
                                        nodes: widget.nodes,
                                        scale: 1.0,
                                        activePathIds: activePathIds,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Layer 2: Fullscreen Button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: widget.theme.colorScheme.surface
                                .withValues(alpha: 0.5),
                            foregroundColor: widget.theme.colorScheme.primary,
                          ),
                          icon: const Icon(Icons.fullscreen),
                          onPressed: () =>
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (context) => FullScreenSkillTree(
                                    theme: widget.theme,
                                    nodes: widget.nodes,
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ),
                  ),

                  // Layer 3: The Floating Glass Panel
                  ValueListenableBuilder<String?>(
                    valueListenable: _focusedNodeId,
                    builder: (context, focusedId, child) {
                      return NodeDetailsOverlay(
                        focusedNodeId: focusedId,
                        nodes: widget.nodes,
                        theme: widget.theme,
                        onClose: () => _focusedNodeId.value = null,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          GestureDetector(
            onTap: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (context) => FullScreenSkillTree(
                  theme: widget.theme,
                  nodes: widget.nodes,
                ),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: widget.theme.colorScheme.primary.withValues(alpha: 0.05),
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
                    color: widget.theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tap to expand & explore interactively',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: widget.theme.colorScheme.primary,
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
  const FullScreenSkillTree({
    super.key,
    required this.theme,
    required this.nodes,
  });

  @override
  State<FullScreenSkillTree> createState() => _FullScreenSkillTreeState();
}

class _FullScreenSkillTreeState extends State<FullScreenSkillTree> {
  final TransformationController _transformationController =
      TransformationController();
  final ValueNotifier<String?> _focusedNodeId = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      _transformationController.value = Matrix4.translationValues(
        -(1000.0 - (screenSize.width / 2)),
        -(1000.0 - (screenSize.height / 2)),
        0.0,
      );
    });
  }

  void _handleTap(Offset localPosition) {
    const center = Offset(1000, 1000);
    for (var node in widget.nodes.reversed) {
      final nodeCenter =
          center +
          Offset(
            node.radialDistance * math.cos(node.angle),
            node.radialDistance * math.sin(node.angle),
          );
      if ((localPosition - nodeCenter).distance <= node.radius + 15) {
        _focusedNodeId.value = node.id;
        return;
      }
    }
    _focusedNodeId.value = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Layer 1: Interactive Viewer
          InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.2,
            maxScale: 3.5,
            constrained: false,
            boundaryMargin: const EdgeInsets.all(1000),
            child: SizedBox(
              width: 2000,
              height: 2000,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapUp: (details) => _handleTap(details.localPosition),
                child: ValueListenableBuilder<String?>(
                  valueListenable: _focusedNodeId,
                  builder: (context, focusedId, child) {
                    final activePathIds = getActivePathIds(
                      focusedId,
                      widget.nodes,
                    );
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: TechGridPainter(
                              widget.theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: CustomPaint(
                            painter: OrganicTreePainter(
                              theme: widget.theme,
                              nodes: widget.nodes,
                              scale: 1.0,
                              isFullScreen: true,
                              activePathIds: activePathIds,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          // Layer 2: Top Header Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 8,
                  left: 20,
                  right: 20,
                  bottom: 10,
                ),
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
                          size: 20,
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

          // Layer 3: Floating Bottom Sheet
          ValueListenableBuilder<String?>(
            valueListenable: _focusedNodeId,
            builder: (context, focusedId, child) {
              return NodeDetailsOverlay(
                focusedNodeId: focusedId,
                nodes: widget.nodes,
                theme: widget.theme,
                onClose: () => _focusedNodeId.value = null,
              );
            },
          ),
        ],
      ),
    );
  }
}

// --- BACKGROUND GRID PAINTER ---
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
    for (double i = 0; i < size.width; i += spacing)
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);
    for (double i = 0; i < size.height; i += spacing)
      canvas.drawLine(Offset(0, i), Offset(size.width, i), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- 🚀 THE GENIUS GRAPH PAINTER ---
class OrganicTreePainter extends CustomPainter {
  final ThemeData theme;
  final List<SkillNode> nodes;
  final double scale;
  final bool isFullScreen;
  final Set<String>? activePathIds; // The precise lineage algorithm output

  OrganicTreePainter({
    required this.theme,
    required this.nodes,
    required this.scale,
    this.isFullScreen = false,
    this.activePathIds,
  });

  bool isNodeFocused(SkillNode node) {
    if (activePathIds == null) return true; // Everything visible when no focus
    return activePathIds!.contains(node.id);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;
    final center = isFullScreen
        ? const Offset(1000, 1000)
        : const Offset(400, 400);

    // 🪐 Draw Orbital Guides
    final orbitPaint = Paint()
      ..color = theme.colorScheme.onSurface.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, 110, orbitPaint);
    canvas.drawCircle(center, 220, orbitPaint);
    canvas.drawCircle(center, 330, orbitPaint);

    Offset getOffset(SkillNode node) =>
        center +
        Offset(
          node.radialDistance * math.cos(node.angle),
          node.radialDistance * math.sin(node.angle),
        );

    // Draw Smooth Edges
    void drawEdge(SkillNode n1, SkillNode n2) {
      bool isEdgeFocused =
          isNodeFocused(n1) && isNodeFocused(n2) && activePathIds != null;
      double opacity = activePathIds == null
          ? 0.25
          : (isEdgeFocused ? 0.9 : 0.02);
      double thickness = activePathIds == null
          ? 1.5
          : (isEdgeFocused ? 4.0 : 0.5);

      if (opacity < 0.05 && activePathIds != null) return;

      final p1 = getOffset(n1);
      final p2 = getOffset(n2);
      final path = Path()..moveTo(p1.dx, p1.dy);

      final midPoint = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      final angle = math.atan2(p2.dy - p1.dy, p2.dx - p1.dx);
      final cpX = midPoint.dx - math.sin(angle) * (n1.id == 'root' ? 0 : 50);
      final cpY = midPoint.dy + math.cos(angle) * (n1.id == 'root' ? 0 : 50);

      path.quadraticBezierTo(cpX, cpY, p2.dx, p2.dy);

      final gradient = LinearGradient(
        colors: [
          n1.color.withValues(alpha: opacity),
          n2.color.withValues(alpha: opacity),
        ],
      ).createShader(Rect.fromPoints(p1, p2));
      canvas.drawPath(
        path,
        Paint()
          ..shader = gradient
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = thickness,
      );
    }

    // Render Edges
    for (var node in nodes) {
      if (node.id == 'root') continue;
      if (node.connectedNodeIds.isNotEmpty) {
        for (String parentId in node.connectedNodeIds) {
          try {
            final parentNode = nodes.firstWhere((n) => n.id == parentId);
            drawEdge(parentNode, node);
          } catch (_) {}
        }
      } else if (node.strand == 'root') {
        drawEdge(nodes.first, node);
      }
    }

    // Render Nodes
    for (var node in nodes) {
      final pCenter = getOffset(node);
      final isFocused = isNodeFocused(node);
      double nodeOpacity = isFocused ? 1.0 : 0.15;

      canvas.drawCircle(
        pCenter,
        node.radius + (isFocused ? 6 : 2),
        Paint()
          ..color = node.color.withValues(alpha: isFocused ? 0.3 : 0.0)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
      canvas.drawCircle(
        pCenter,
        node.radius,
        Paint()
          ..color = theme.colorScheme.surface.withValues(alpha: nodeOpacity),
      );
      canvas.drawCircle(
        pCenter,
        node.radius,
        Paint()
          ..color = node.color.withValues(alpha: nodeOpacity)
          ..strokeWidth = isFocused ? 3.5 : 1.5
          ..style = PaintingStyle.stroke,
      );

      if (!isFocused) continue;

      final text = node.id == 'root' ? node.title : node.title.split(' ')[0];
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: GoogleFonts.inter(
            color: theme.colorScheme.onSurface,
            fontSize: node.id == 'root' ? 16 : 11,
            fontWeight: FontWeight.w900,
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
    }
  }

  @override
  bool shouldRepaint(covariant OrganicTreePainter oldDelegate) => true;
}
