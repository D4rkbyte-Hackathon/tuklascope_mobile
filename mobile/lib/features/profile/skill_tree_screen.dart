import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuklascope_mobile/core/services/pathfinder_service.dart';

class SkillNode {
  final String id;
  final String title;
  final String description;
  final String strand;
  final int xp;
  final Color color;
  final Offset position;
  final double radius;
  final IconData? icon;

  int get level => id == 'root' ? xp : (xp ~/ 50) + 1;

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
      duration: const Duration(milliseconds: 1800),
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
    final stemColor = Colors.green[500]!;
    final humssColor = Colors.orange[500]!;
    final abmColor = Colors.blue[400]!;
    final tvlColor = Colors.red[400]!;

    final xpDist = data?['xp_distribution'] as Map<String, dynamic>? ?? {};

    nodes = [
      SkillNode(
        id: 'root',
        title: widget.userName.toUpperCase(),
        description: 'Your Central Learning Core.',
        strand: 'root',
        xp: widget.coreLevel,
        color: theme.colorScheme.primary,
        position: const Offset(0.50, 0.90),
        radius: 45.0,
        icon: Icons.person,
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
        icon: Icons.science,
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
        icon: Icons.public,
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
        icon: Icons.trending_up,
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
        icon: Icons.build,
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
      final regex = RegExp(r'^(.*?) \((.*?)\) \[(.*?)\] - Lv\.(\d+)$');
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
          strand: strandName,
          xp: calculatedXp,
          color: skillColor,
          position: dynamicPositions[i],
          radius: 28.0,
          icon: Icons.auto_awesome,
        ),
      );
    }
  }

  void _handleTap(Offset tapPosition, Size canvasSize) {
    for (var node in nodes.reversed) {
      final nodeCenter = Offset(
        node.position.dx * canvasSize.width,
        node.position.dy * canvasSize.height,
      );
      final distance = sqrt(
        pow(tapPosition.dx - nodeCenter.dx, 2) +
            pow(tapPosition.dy - nodeCenter.dy, 2),
      );

      if (distance <= node.radius + 15) { // Slightly larger hit target
        setState(() => _selectedNode = node);
        _showNodeDetailsBottomSheet(node);
        return;
      }
    }
  }

  void _showNodeDetailsBottomSheet(SkillNode node) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(32, 12, 32, 32),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.85),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border(
                top: BorderSide(color: node.color.withValues(alpha: 0.5), width: 2),
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
                  // Drag Handle
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
                      node.icon ?? Icons.hub,
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
                      _buildStatPill('LEVEL', '${node.level}', node.color),
                      if (node.id != 'root')
                        _buildStatPill('TOTAL XP', '${node.xp}', node.color),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      if (mounted) {
        setState(() => _selectedNode = null);
      }
    });
  }

  Widget _buildStatPill(String label, String value, Color color) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.6),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
        title: Text(
          'OMNI-TREE',
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold, 
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoadingData
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Mapping neural pathways...',
                    style: GoogleFonts.inter(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final Size size = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    return InteractiveViewer(
                      boundaryMargin: const EdgeInsets.all(200),
                      minScale: 0.5,
                      maxScale: 3.5,
                      constrained: false,
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
                // Floating HUD Pill
                Positioned(
                  bottom: 40,
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
                            color: theme.colorScheme.surface.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.touch_app,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Pan • Zoom • Tap to Explore',
                                style: GoogleFonts.inter(
                                  color: theme.colorScheme.onSurface,
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

    // Draw Branches with Gradients
    void drawOrganicBranch(SkillNode n1, SkillNode n2) {
      final p1 = getOffset(n1);
      final p2 = getOffset(n2);
      final path = Path()..moveTo(p1.dx, p1.dy);
      final cpX = p1.dx;
      final cpY = p2.dy + (p1.dy - p2.dy) * 0.8;
      path.quadraticBezierTo(cpX, cpY, p2.dx, p2.dy);

      final isRootConnection = n1.id == 'root';
      
      final gradient = LinearGradient(
        colors: [
          n1.color.withValues(alpha: 0.6 * scale.clamp(0.0, 1.0)),
          n2.color.withValues(alpha: 0.6 * scale.clamp(0.0, 1.0)),
        ],
      ).createShader(Rect.fromPoints(p1, p2));

      final paint = Paint()
        ..shader = gradient
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = (isRootConnection ? 5.0 : 2.5) * scale.clamp(0.0, 1.0);
        
      canvas.drawPath(path, paint);
    }

    // Draw connections mapping to parent strands
    for (var node in nodes) {
      if (node.id == 'root') continue;

      final parentNode = nodes.firstWhere(
        (n) => n.id == node.strand,
        orElse: () => nodes.first,
      );
      drawOrganicBranch(parentNode, node);
    }

    // Draw Nodes
    for (var node in nodes) {
      final center = getOffset(node);
      final isSelected = node.id == selectedNodeId;
      final currentRadius = max(0.0, node.radius * scale);

      if (currentRadius <= 0) continue;

      // Selection Ring
      if (isSelected) {
        canvas.drawCircle(
          center,
          currentRadius + 12,
          Paint()
            ..color = node.color.withValues(alpha: 0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.0,
        );
        canvas.drawCircle(
          center,
          currentRadius + 12,
          Paint()..color = node.color.withValues(alpha: 0.1),
        );
      }

      // Base Node Rendering
      if (node.id == 'root') {
        final Rect coreRect = Rect.fromCircle(
          center: center,
          radius: currentRadius,
        );
        // Outer glow
        canvas.drawCircle(
          center,
          currentRadius + 8,
          Paint()
            ..color = node.color.withValues(alpha: 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
        );
        // Inner gradient
        canvas.drawCircle(
          center,
          currentRadius,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            ).createShader(coreRect),
        );
      } else {
        // Outer glow
        canvas.drawCircle(
          center,
          currentRadius + 4,
          Paint()
            ..color = node.color.withValues(alpha: 0.2)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
        // Background
        canvas.drawCircle(
          center,
          currentRadius,
          Paint()..color = theme.colorScheme.surface,
        );
        // Stroke
        canvas.drawCircle(
          center,
          currentRadius,
          Paint()
            ..color = node.color
            ..strokeWidth = 3.5
            ..style = PaintingStyle.stroke,
        );
      }

      // Draw Text Labels
      if (scale > 0.5) {
        final labelText = node.id == 'root' ? node.title : node.title.split(' ')[0];
        
        final textPainter = TextPainter(
          text: TextSpan(
            text: labelText,
            style: GoogleFonts.inter(
              color: node.id == 'root' ? Colors.white : theme.colorScheme.onSurface,
              fontSize: (node.id == 'root' ? 14 : 11) * scale.clamp(0.5, 1.0),
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
            center.dx - (textPainter.width / 2),
            center.dy - (textPainter.height / 2),
          ),
        );

        if (node.id != 'root') {
          final levelPainter = TextPainter(
            text: TextSpan(
              text: 'Lv.${node.level}',
              style: GoogleFonts.orbitron(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                fontSize: 11 * scale,
                fontWeight: FontWeight.w900,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          
          levelPainter.paint(
            canvas,
            center + Offset(-levelPainter.width / 2, currentRadius + 6),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OrganicTreePainter oldDelegate) {
    return oldDelegate.scale != scale || oldDelegate.selectedNodeId != selectedNodeId;
  }
}