import 'package:flutter/material.dart';
import 'dart:math';

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
  State<KaalamanSkillTreeScreen> createState() => _KaalamanSkillTreeScreenState();
}

class _KaalamanSkillTreeScreenState extends State<KaalamanSkillTreeScreen> with SingleTickerProviderStateMixin {
  late final List<SkillNode> nodes;
  SkillNode? _selectedNode;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000), 
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut, 
    );

    _animationController.forward();
  }

  // 🚀 MOVED INITIALIZATION HERE TO ACCESS THE THEME!
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final theme = Theme.of(context);
      _initializeNodes(theme);
      _selectedNode = nodes.firstWhere((n) => n.id == 'root');
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _animationController.dispose(); 
    super.dispose();
  }

  void _initializeNodes(ThemeData theme) {
    final stemColor = Colors.green[600]!;
    final humssColor = Colors.orange[600]!;
    final abmColor = Colors.blue[600]!;
    final tvlColor = Colors.red[500]!;

    nodes = [
      // ROOT - Now dynamically uses the theme's surface color
      SkillNode(id: 'root', title: 'You', description: 'The roots of your journey.', career: 'Explorer', xp: 0, color: theme.colorScheme.surface, position: const Offset(0.50, 0.90), radius: 35.0),
      
      // --- STEM BRANCH ---
      SkillNode(id: 'stem', title: 'STEM', description: 'Science, Tech, Engineering & Math.', career: 'Engineer, Scientist', xp: 120, color: stemColor, position: const Offset(0.20, 0.72), radius: 30.0),
      SkillNode(id: 'stem_1', title: 'Physics', description: 'The study of matter and energy.', career: 'Mechanical Engineer', xp: 50, color: stemColor, position: const Offset(0.08, 0.58), radius: 22.0, icon: Icons.science),
      SkillNode(id: 'stem_2', title: 'Coding', description: 'Building digital logic.', career: 'Software Developer', xp: 110, color: stemColor, position: const Offset(0.32, 0.60), radius: 22.0, icon: Icons.code),
      
      // --- HUMSS BRANCH ---
      SkillNode(id: 'humss', title: 'HUMSS', description: 'Humanities & Social Sciences.', career: 'Lawyer, Writer, Teacher', xp: 90, color: humssColor, position: const Offset(0.80, 0.72), radius: 30.0),
      SkillNode(id: 'humss_1', title: 'Literature', description: 'The art of written works.', career: 'Author, Journalist', xp: 40, color: humssColor, position: const Offset(0.92, 0.58), radius: 22.0, icon: Icons.menu_book),
      SkillNode(id: 'humss_2', title: 'Sociology', description: 'The study of society.', career: 'Social Worker', xp: 50, color: humssColor, position: const Offset(0.68, 0.60), radius: 22.0, icon: Icons.people),
      
      // --- ABM BRANCH ---
      SkillNode(id: 'abm', title: 'ABM', description: 'Accountancy, Business & Mgt.', career: 'Accountant, CEO', xp: 150, color: abmColor, position: const Offset(0.22, 0.42), radius: 30.0),
      SkillNode(id: 'abm_1', title: 'Finance', description: 'Managing money and investments.', career: 'Financial Analyst', xp: 80, color: abmColor, position: const Offset(0.10, 0.28), radius: 22.0, icon: Icons.attach_money),
      SkillNode(id: 'abm_2', title: 'Marketing', description: 'Understanding consumer behavior.', career: 'Marketing Director', xp: 70, color: abmColor, position: const Offset(0.32, 0.25), radius: 22.0, icon: Icons.storefront),
      
      // --- TVL BRANCH ---
      SkillNode(id: 'tvl', title: 'TVL', description: 'Technical-Vocational Livelihood.', career: 'Technician, Chef', xp: 60, color: tvlColor, position: const Offset(0.78, 0.42), radius: 30.0),
      SkillNode(id: 'tvl_1', title: 'Culinary', description: 'The art of cooking.', career: 'Executive Chef', xp: 30, color: tvlColor, position: const Offset(0.90, 0.28), radius: 22.0, icon: Icons.restaurant),
      SkillNode(id: 'tvl_2', title: 'Electrical', description: 'Circuitry and power systems.', career: 'Master Electrician', xp: 30, color: tvlColor, position: const Offset(0.68, 0.25), radius: 22.0, icon: Icons.electrical_services),
    ];

    // --- SENIOR HIGH CAREER BRANCH ---
    final edLevel = widget.educationLevel.toLowerCase();
    final isSeniorHigh = edLevel.contains('senior') || edLevel.contains('shs') || edLevel.contains('11') || edLevel.contains('12');

    if (isSeniorHigh) {
      final careerColor = Colors.purple[400]!; 
      nodes.add(SkillNode(id: 'career', title: 'Careers', description: 'Your Future Career Tracks.', career: 'Professional', xp: 200, color: careerColor, position: const Offset(0.50, 0.52), radius: 30.0));
      nodes.add(SkillNode(id: 'career_1', title: 'University', description: 'Pursue higher education.', career: 'College Degree', xp: 50, color: careerColor, position: const Offset(0.38, 0.38), radius: 22.0, icon: Icons.school));
      nodes.add(SkillNode(id: 'career_2', title: 'Industry', description: 'Direct employment path.', career: 'Workforce', xp: 40, color: careerColor, position: const Offset(0.62, 0.38), radius: 22.0, icon: Icons.work));
      nodes.add(SkillNode(id: 'career_3', title: 'Business', description: 'Start your own enterprise.', career: 'Entrepreneur', xp: 60, color: careerColor, position: const Offset(0.50, 0.22), radius: 22.0, icon: Icons.store));
    }
  }

  void _handleTap(Offset tapPosition, Size canvasSize) {
    for (var node in nodes) {
      final nodeCenter = Offset(node.position.dx * canvasSize.width, node.position.dy * canvasSize.height);
      final distance = sqrt(pow(tapPosition.dx - nodeCenter.dx, 2) + pow(tapPosition.dy - nodeCenter.dy, 2));

      if (distance <= node.radius) {
        setState(() => _selectedNode = node);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Cache Theme

    if (!_isInitialized) {
      return Scaffold(backgroundColor: theme.scaffoldBackgroundColor); // Wait for nodes
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Themed Map Background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface, // Themed Icons/Text
        title: const Text('Kaalaman Skill Tree', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                return InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(80),
                  minScale: 0.8,
                  maxScale: 3.5,
                  child: GestureDetector(
                    onTapUp: (details) => _handleTap(details.localPosition, size),
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          size: size,
                          painter: _OrganicTreePainter(
                            theme: theme, // Pass theme to painter
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
                color: theme.colorScheme.surface, // Themed Info Panel Background
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5)
                  )
                ]
              ),
              child: _selectedNode == null 
                  ? Center(child: Text('Tap a leaf or branch to explore.', style: TextStyle(color: theme.colorScheme.onSurface)))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: _selectedNode!.id == 'root' 
                                  ? theme.colorScheme.primary.withValues(alpha: 0.1) 
                                  : _selectedNode!.color,
                              radius: 16,
                              child: _selectedNode!.icon != null 
                                ? Icon(
                                    _selectedNode!.icon, 
                                    color: _selectedNode!.id == 'root' ? theme.colorScheme.primary : Colors.white, 
                                    size: 18
                                  )
                                : null,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedNode!.title,
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.primary), // Themed Title
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Level ${_selectedNode!.level}',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 16), // Themed Blue
                                ),
                                Text(
                                  '${_selectedNode!.xp} XP',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.secondary), // Themed Orange
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedNode!.description, 
                          style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.8)) // Themed Desc
                        ),
                        const SizedBox(height: 12),
                        Text('Plausible Path:', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                        Text(
                          _selectedNode!.career, 
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.primary) // Themed Career Text
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

  _OrganicTreePainter({required this.theme, required this.nodes, this.selectedNodeId, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final root = nodes.firstWhere((n) => n.id == 'root');
    final stem = nodes.firstWhere((n) => n.id == 'stem');
    final humss = nodes.firstWhere((n) => n.id == 'humss');
    final abm = nodes.firstWhere((n) => n.id == 'abm');
    final tvl = nodes.firstWhere((n) => n.id == 'tvl');

    Offset getOffset(SkillNode node) {
      return Offset(node.position.dx * size.width, node.position.dy * size.height);
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
        ..color = color.withValues(alpha: 0.6 * scale.clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = (n1.id == 'root' ? 8.0 : 4.0) * scale.clamp(0.0, 1.0); 
      
      canvas.drawPath(path, paint);
    }

    // DRAW STANDARD BRANCHES
    drawOrganicBranch(root, stem, stem.color);
    drawOrganicBranch(stem, nodes.firstWhere((n) => n.id == 'stem_1'), stem.color);
    drawOrganicBranch(stem, nodes.firstWhere((n) => n.id == 'stem_2'), stem.color);

    drawOrganicBranch(root, humss, humss.color);
    drawOrganicBranch(humss, nodes.firstWhere((n) => n.id == 'humss_1'), humss.color);
    drawOrganicBranch(humss, nodes.firstWhere((n) => n.id == 'humss_2'), humss.color);

    drawOrganicBranch(root, abm, abm.color);
    drawOrganicBranch(abm, nodes.firstWhere((n) => n.id == 'abm_1'), abm.color);
    drawOrganicBranch(abm, nodes.firstWhere((n) => n.id == 'abm_2'), abm.color);

    drawOrganicBranch(root, tvl, tvl.color);
    drawOrganicBranch(tvl, nodes.firstWhere((n) => n.id == 'tvl_1'), tvl.color);
    drawOrganicBranch(tvl, nodes.firstWhere((n) => n.id == 'tvl_2'), tvl.color);

    // DRAW SENIOR HIGH BRANCH
    final isSeniorHigh = nodes.any((n) => n.id == 'career');
    if (isSeniorHigh) {
      final career = nodes.firstWhere((n) => n.id == 'career');
      drawOrganicBranch(root, career, career.color);
      drawOrganicBranch(career, nodes.firstWhere((n) => n.id == 'career_1'), career.color);
      drawOrganicBranch(career, nodes.firstWhere((n) => n.id == 'career_2'), career.color);
      drawOrganicBranch(career, nodes.firstWhere((n) => n.id == 'career_3'), career.color);
    }

    // DRAW ALL LEAVES AND TEXT
    for (var node in nodes) {
      final center = getOffset(node);
      final isSelected = node.id == selectedNodeId;
      final currentRadius = max(0.0, node.radius * scale);

      if (currentRadius <= 0) continue;

      if (isSelected) {
        // Selection Halo adapts to surface color
        canvas.drawCircle(center, currentRadius + 6, Paint()..color = theme.colorScheme.onSurface.withValues(alpha: 0.2));
      }

      // Draw the main node circle
      canvas.drawCircle(center, currentRadius, Paint()..color = node.color);
      
      // Draw the border stroke
      canvas.drawCircle(
        center, 
        currentRadius, 
        Paint()
          ..color = isSelected ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.2) // Adaptive Border
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 3.0 : 2.0
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
                color: Colors.white
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          
          iconPainter.paint(canvas, center - Offset(iconPainter.width / 2, iconPainter.height / 2));

          final TextPainter levelPainter = TextPainter(
            text: TextSpan(
              text: 'Lv.${node.level}',
              style: TextStyle(
                color: theme.colorScheme.onSurface, // Ensures level is visible above/below the node
                fontSize: 10 * scale, 
                fontWeight: FontWeight.bold
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          levelPainter.paint(canvas, center + Offset(-levelPainter.width / 2, currentRadius + 2));

        } else {
          final textPainter = TextPainter(
            text: TextSpan(
              text: node.title,
              style: TextStyle(
                color: node.id == 'root' ? theme.colorScheme.onSurface : Colors.white, // Root text adapts to dark mode!
                fontSize: 12 * scale.clamp(0.5, 1.0), 
                fontWeight: FontWeight.bold
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(canvas, Offset(center.dx - (textPainter.width / 2), center.dy - (textPainter.height / 2)));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OrganicTreePainter oldDelegate) {
    return oldDelegate.scale != scale || oldDelegate.selectedNodeId != selectedNodeId;
  }
}