import 'package:flutter/material.dart';
import 'dart:math';
import 'package:tuklascope_mobile/core/services/pathfinder_service.dart';

class SkillNode {
  final String id;
  final String title;
  final String description;
  final String strand; // 🚀 NEW
  final int xp;
  final Color color;
  final Offset position;
  final double radius;
  final IconData? icon;

  int get level => id == 'root' ? xp : (xp ~/ 50) + 1; // Root uses raw level

  SkillNode({
    required this.id,
    required this.title,
    required this.description,
    required this.strand,
    required this.xp,
    required this.color,
    required this.position,
    this.radius = 35.0,
    this.icon,
  });
}

class KaalamanSkillTreeScreen extends StatefulWidget {
  final String userName;
  final int coreLevel;

  const KaalamanSkillTreeScreen({
    super.key,
    required this.userName,
    required this.coreLevel,
  });

  @override
  State<KaalamanSkillTreeScreen> createState() =>
      _KaalamanSkillTreeScreenState();
}

class _KaalamanSkillTreeScreenState extends State<KaalamanSkillTreeScreen>
    with SingleTickerProviderStateMixin {
  List<SkillNode> nodes = [];
  SkillNode? _selectedNode;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _loadTreeData();
  }

  Future<void> _loadTreeData() async {
    final data = await PathfinderService.getSkillWeb();
    if (mounted) {
      _buildDynamicNodes(Theme.of(context), data);
      setState(() {
        _isLoadingData = false;
      });
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _buildDynamicNodes(ThemeData theme, Map<String, dynamic>? data) {
    final stemColor = Colors.green[600]!;
    final humssColor = Colors.orange[600]!;
    final abmColor = Colors.blue[600]!;
    final tvlColor = Colors.red[500]!;

    final xpDist = data?['xp_distribution'] as Map<String, dynamic>? ?? {};

    nodes = [
      SkillNode(
        id: 'root',
        title: widget.userName.toUpperCase(),
        description: 'Your central learning core.',
        strand: 'root',
        xp: widget.coreLevel,
        color: theme.colorScheme.surface,
        position: const Offset(0.50, 0.90),
        radius: 40.0,
      ),
      SkillNode(
        id: 'stem',
        title: 'STEM',
        description: 'Science & Math.',
        strand: 'root',
        xp: (xpDist['STEM'] ?? 0) as int,
        color: stemColor,
        position: const Offset(0.20, 0.72),
        radius: 30.0,
      ),
      SkillNode(
        id: 'humss',
        title: 'HUMSS',
        description: 'Humanities & Social Sciences.',
        strand: 'root',
        xp: (xpDist['HUMSS'] ?? 0) as int,
        color: humssColor,
        position: const Offset(0.80, 0.72),
        radius: 30.0,
      ),
      SkillNode(
        id: 'abm',
        title: 'ABM',
        description: 'Business & Mgt.',
        strand: 'root',
        xp: (xpDist['ABM'] ?? 0) as int,
        color: abmColor,
        position: const Offset(0.22, 0.42),
        radius: 30.0,
      ),
      SkillNode(
        id: 'tvl',
        title: 'TVL',
        description: 'Technical-Vocational.',
        strand: 'root',
        xp: (xpDist['TVL'] ?? 0) as int,
        color: tvlColor,
        position: const Offset(0.78, 0.42),
        radius: 30.0,
      ),
    ];

    final topSkills = (data?['top_skills'] as List<dynamic>?) ?? [];

    final List<Offset> dynamicPositions = [
      const Offset(0.50, 0.25),
      const Offset(0.25, 0.15),
      const Offset(0.75, 0.15),
      const Offset(0.15, 0.30),
      const Offset(0.85, 0.30),
      const Offset(0.50, 0.10),
      const Offset(0.35, 0.05),
      const Offset(0.65, 0.05),
    ];

    for (int i = 0; i < topSkills.length && i < dynamicPositions.length; i++) {
      final skillString = topSkills[i].toString();
      final regex = RegExp(
        r'^(.*?) \((.*?)\) \[(.*?)\] - Lv\.(\d+)$',
      ); // 🚀 NEW REGEX
      final match = regex.firstMatch(skillString);

      String skillName = skillString;
      String domainName = 'Discipline';
      String strandName = 'STEM';
      int calculatedXp = 0;

      if (match != null) {
        skillName = match.group(1)?.trim() ?? skillName;
        domainName = match.group(2)?.trim() ?? domainName;
        strandName = match.group(3)?.trim().toLowerCase() ?? 'stem';
        final int level = int.tryParse(match.group(4) ?? '1') ?? 1;
        calculatedXp = (level - 1) * 50;
      }

      // Match the color to its parent strand
      Color skillColor = theme.colorScheme.primary;
      if (strandName == 'stem') skillColor = stemColor;
      if (strandName == 'humss') skillColor = humssColor;
      if (strandName == 'abm') skillColor = abmColor;
      if (strandName == 'tvl') skillColor = tvlColor;

      nodes.add(
        SkillNode(
          id: 'skill_$i',
          title: skillName,
          description: 'Domain: $domainName',
          strand: strandName, // 🚀 Tracks its parent!
          xp: calculatedXp,
          color: skillColor,
          position: dynamicPositions[i],
          radius: 28.0,
        ),
      );
    }
  }

  void _handleTap(Offset tapPosition, Size canvasSize) {
    for (var node in nodes) {
      final nodeCenter = Offset(
        node.position.dx * canvasSize.width,
        node.position.dy * canvasSize.height,
      );
      final distance = sqrt(
        pow(tapPosition.dx - nodeCenter.dx, 2) +
            pow(tapPosition.dy - nodeCenter.dy, 2),
      );

      if (distance <= node.radius) {
        setState(() => _selectedNode = node);
        _showNodeDetailsBottomSheet(node); // 🚀 Show details on tap!
        return;
      }
    }
  }

  void _showNodeDetailsBottomSheet(SkillNode node) {
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
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: node.color.withValues(alpha: 0.2),
                  radius: 30,
                  child: Icon(
                    node.icon ?? Icons.hub,
                    color: node.color,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  node.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  node.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatPill('LEVEL', '${node.level}', node.color),
                    if (node.id != 'root')
                      _buildStatPill('TOTAL XP', '${node.xp}', node.color),
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

  Widget _buildStatPill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
        title: const Text(
          'Omni-Tree',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoadingData
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Pinch to zoom • Drag to pan • Tap nodes to explore',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final Size size = Size(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      );
                      return InteractiveViewer(
                        boundaryMargin: const EdgeInsets.all(100),
                        minScale: 0.5,
                        maxScale: 3.5,
                        constrained: false, // 🚀 Allows free panning everywhere
                        child: SizedBox(
                          width: size.width,
                          height: size.height,
                          child: GestureDetector(
                            onTapUp: (details) =>
                                _handleTap(details.localPosition, size),
                            child: AnimatedBuilder(
                              animation: _scaleAnimation,
                              builder: (context, child) {
                                return CustomPaint(
                                  size: size,
                                  painter: _OrganicTreePainter(
                                    theme: theme,
                                    nodes: nodes,
                                    selectedNodeId: _selectedNode?.id,
                                    scale: _scaleAnimation.value,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _OrganicTreePainter extends CustomPainter {
  final ThemeData theme;
  final List<SkillNode> nodes;
  final String? selectedNodeId;
  final double scale;

  _OrganicTreePainter({
    required this.theme,
    required this.nodes,
    this.selectedNodeId,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;

    Offset getOffset(SkillNode node) =>
        Offset(node.position.dx * size.width, node.position.dy * size.height);

    void drawOrganicBranch(SkillNode n1, SkillNode n2, Color color) {
      final p1 = getOffset(n1);
      final p2 = getOffset(n2);
      final path = Path()..moveTo(p1.dx, p1.dy);
      final cpX = p1.dx;
      final cpY = p2.dy + (p1.dy - p2.dy) * 0.8;
      path.quadraticBezierTo(cpX, cpY, p2.dx, p2.dy);

      final paint = Paint()
        ..color = color.withValues(alpha: 0.5 * scale.clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = (n1.id == 'root' ? 6.0 : 3.0) * scale.clamp(0.0, 1.0);
      canvas.drawPath(path, paint);
    }

    // 🚀 FIX: Draw true connections!
    for (var node in nodes) {
      if (node.id == 'root') continue;

      // Find its parent strand node
      final parentNode = nodes.firstWhere(
        (n) => n.id == node.strand,
        orElse: () => nodes.first,
      );
      drawOrganicBranch(parentNode, node, node.color);
    }

    // Draw Leaves
    for (var node in nodes) {
      final center = getOffset(node);
      final isSelected = node.id == selectedNodeId;
      final currentRadius = max(0.0, node.radius * scale);

      if (currentRadius <= 0) continue;

      if (isSelected) {
        canvas.drawCircle(
          center,
          currentRadius + 8,
          Paint()..color = theme.colorScheme.primary.withValues(alpha: 0.3),
        );
      }

      // Root has a special gradient
      if (node.id == 'root') {
        final Rect coreRect = Rect.fromCircle(
          center: center,
          radius: currentRadius,
        );
        canvas.drawCircle(
          center,
          currentRadius,
          Paint()
            ..shader = LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            ).createShader(coreRect),
        );
      } else {
        canvas.drawCircle(
          center,
          currentRadius,
          Paint()..color = node.color.withValues(alpha: 0.2),
        );
        canvas.drawCircle(
          center,
          currentRadius,
          Paint()
            ..color = node.color
            ..strokeWidth = 3.0
            ..style = PaintingStyle.stroke,
        );
      }

      if (scale > 0.5) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: node.id == 'root' ? node.title : node.title.split(' ')[0],
            style: TextStyle(
              color: Colors.white,
              fontSize: (node.id == 'root' ? 14 : 10) * scale.clamp(0.5, 1.0),
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          Offset(
            center.dx - (textPainter.width / 2),
            center.dy - (textPainter.height / 2),
          ),
        );

        final levelPainter = TextPainter(
          text: TextSpan(
            text: 'Lv.${node.level}',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 11 * scale,
              fontWeight: FontWeight.w900,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        levelPainter.paint(
          canvas,
          center + Offset(-levelPainter.width / 2, currentRadius + 4),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OrganicTreePainter oldDelegate) => true;
}
