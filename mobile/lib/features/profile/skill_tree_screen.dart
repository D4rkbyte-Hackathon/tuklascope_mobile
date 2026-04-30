import 'package:flutter/material.dart';
import 'dart:math';
import 'package:tuklascope_mobile/core/services/pathfinder_service.dart';

// 1. Define the Data Structure for our Nodes
class SkillNode {
  final String id;
  final String title;
  final String description;
  final String career;
  final int xp;
  final Color color;
  final Offset position;
  final double radius;
  final IconData? icon;

  int get level => (xp ~/ 50) + 1;

  SkillNode({
    required this.id,
    required this.title,
    required this.description,
    required this.career,
    required this.xp,
    required this.color,
    required this.position,
    this.radius = 35.0,
    this.icon,
  });
}

class KaalamanSkillTreeScreen extends StatefulWidget {
  final String educationLevel;

  const KaalamanSkillTreeScreen({super.key, required this.educationLevel});

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
      duration: const Duration(milliseconds: 2500),
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
        _selectedNode = nodes.isNotEmpty
            ? nodes.firstWhere((n) => n.id == 'root')
            : null;
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
    final int stemXp = (xpDist['STEM'] ?? 0) as int;
    final int abmXp = (xpDist['ABM'] ?? 0) as int;
    final int humssXp = (xpDist['HUMSS'] ?? 0) as int;
    final int tvlXp = (xpDist['TVL'] ?? 0) as int;

    nodes = [
      SkillNode(
        id: 'root',
        title: 'You',
        description: 'The roots of your journey.',
        career: 'Explorer',
        xp: 0,
        color: theme.colorScheme.surface,
        position: const Offset(0.50, 0.90),
        radius: 40.0,
      ),
      SkillNode(
        id: 'stem',
        title: 'STEM',
        description: 'Science, Tech, Engineering & Math.',
        career: 'STEM Path',
        xp: stemXp,
        color: stemColor,
        position: const Offset(0.20, 0.72),
        radius: 30.0,
      ),
      SkillNode(
        id: 'humss',
        title: 'HUMSS',
        description: 'Humanities & Social Sciences.',
        career: 'HUMSS Path',
        xp: humssXp,
        color: humssColor,
        position: const Offset(0.80, 0.72),
        radius: 30.0,
      ),
      SkillNode(
        id: 'abm',
        title: 'ABM',
        description: 'Accountancy, Business & Mgt.',
        career: 'ABM Path',
        xp: abmXp,
        color: abmColor,
        position: const Offset(0.22, 0.42),
        radius: 30.0,
      ),
      SkillNode(
        id: 'tvl',
        title: 'TVL',
        description: 'Technical-Vocational Livelihood.',
        career: 'TVL Path',
        xp: tvlXp,
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
      final regex = RegExp(r'^(.*?) \((.*?)\) - Lv\.(\d+)$');
      final match = regex.firstMatch(skillString);

      String skillName = skillString;
      String domainName = 'Discipline';
      int calculatedXp = 0;

      if (match != null) {
        skillName = match.group(1)?.trim() ?? skillName;
        domainName = match.group(2)?.trim() ?? domainName;
        final int level = int.tryParse(match.group(3) ?? '1') ?? 1;
        calculatedXp = (level - 1) * 50;
      }

      nodes.add(
        SkillNode(
          id: 'skill_$i',
          title: skillName,
          description: 'Domain: $domainName',
          career: 'Advanced Mastery',
          xp: calculatedXp,
          color: theme.colorScheme.primary,
          position: dynamicPositions[i],
          radius: 25.0,
          icon: Icons.star_border,
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
        return;
      }
    }
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
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoadingData
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: theme.colorScheme.primary),
                  const SizedBox(height: 24),
                  Text(
                    'Querying Neural Network...',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  flex: 3,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final Size size = Size(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      );
                      return InteractiveViewer(
                        boundaryMargin: const EdgeInsets.all(80),
                        minScale: 0.8,
                        maxScale: 3.5,
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
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: _selectedNode == null
                        ? Center(
                            child: Text(
                              'Tap a constellation node to explore.',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: _selectedNode!.id == 'root'
                                        ? theme.colorScheme.primary.withValues(
                                            alpha: 0.1,
                                          )
                                        : _selectedNode!.color,
                                    radius: 20,
                                    child: _selectedNode!.icon != null
                                        ? Icon(
                                            _selectedNode!.icon,
                                            color: Colors.white,
                                            size: 20,
                                          )
                                        : Text(
                                            _selectedNode!.title[0],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedNode!.title,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            color: theme.colorScheme.primary,
                                            height: 1.1,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _selectedNode!.description,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          'Lv.${_selectedNode!.level}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_selectedNode!.xp} XP',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.5),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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

    final root = nodes.firstWhere((n) => n.id == 'root');

    Offset getOffset(SkillNode node) {
      return Offset(
        node.position.dx * size.width,
        node.position.dy * size.height,
      );
    }

    void drawOrganicBranch(SkillNode n1, SkillNode n2, Color color) {
      final p1 = getOffset(n1);
      final p2 = getOffset(n2);

      final path = Path();
      path.moveTo(p1.dx, p1.dy);

      final cpX = p1.dx;
      final cpY = p2.dy + (p1.dy - p2.dy) * 0.8;

      path.quadraticBezierTo(cpX, cpY, p2.dx, p2.dy);

      final paint = Paint()
        ..color = color.withValues(alpha: 0.5 * scale.clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = (n1.id == 'root' ? 6.0 : 3.0) * scale.clamp(0.0, 1.0);

      canvas.drawPath(path, paint);
    }

    for (var node in nodes) {
      if (node.id == 'root') continue;

      if (['stem', 'abm', 'humss', 'tvl'].contains(node.id)) {
        drawOrganicBranch(root, node, node.color);
      } else if (node.id.startsWith('skill_')) {
        drawOrganicBranch(root, node, theme.colorScheme.primary);
      }
    }

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

      canvas.drawCircle(center, currentRadius, Paint()..color = node.color);

      canvas.drawCircle(
        center,
        currentRadius,
        Paint()
          ..color = isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 4.0 : 2.0,
      );

      if (scale > 0.5) {
        if (node.icon != null) {
          final TextPainter iconPainter = TextPainter(
            text: TextSpan(
              text: String.fromCharCode(node.icon!.codePoint),
              style: TextStyle(
                fontSize: currentRadius * 1.1,
                fontFamily: node.icon!.fontFamily,
                package: node.icon!.fontPackage,
                color: Colors.white,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();

          iconPainter.paint(
            canvas,
            center - Offset(iconPainter.width / 2, iconPainter.height / 2),
          );
        } else {
          final textPainter = TextPainter(
            text: TextSpan(
              text: node.title.split(' ')[0],
              style: TextStyle(
                color: node.id == 'root'
                    ? theme.colorScheme.onSurface
                    : Colors.white,
                fontSize: 10 * scale.clamp(0.5, 1.0),
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(
              center.dx - (textPainter.width / 2),
              center.dy - (textPainter.height / 2),
            ),
          );
        }

        if (node.id != 'root') {
          final TextPainter levelPainter = TextPainter(
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
  }

  @override
  bool shouldRepaint(covariant _OrganicTreePainter oldDelegate) {
    return oldDelegate.scale != scale ||
        oldDelegate.selectedNodeId != selectedNodeId ||
        oldDelegate.nodes.length != nodes.length;
  }
}
