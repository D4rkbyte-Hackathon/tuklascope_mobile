import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_subject_segmentation/google_mlkit_subject_segmentation.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tuklascope_mobile/core/services/discovery_service.dart';
import 'package:tuklascope_mobile/features/auth/providers/auth_controller.dart';
import 'package:tuklascope_mobile/core/widgets/gradient_scaffold.dart';
import 'teaser_doors_screen.dart';
import 'widgets/ai_query_modal.dart';

class ConfirmImageScreen extends ConsumerStatefulWidget {
  final File originalImage;

  const ConfirmImageScreen({super.key, required this.originalImage});

  @override
  ConsumerState<ConfirmImageScreen> createState() => _ConfirmImageScreenState();
}

class _ConfirmImageScreenState extends ConsumerState<ConfirmImageScreen> with SingleTickerProviderStateMixin {
  bool _isIsolating = true;
  File? _segmentedImage;
  late AnimationController _glitchController;
  late Animation<Color?> _glowAnimation; // Added for the breathing outline

  @override
  void initState() {
    super.initState();
    _glitchController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _isolateSubject();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize color tween here because it needs Theme.of(context)
    final theme = Theme.of(context);
    _glowAnimation = ColorTween(
      begin: theme.colorScheme.secondary, 
      end: theme.colorScheme.primary,
    ).animate(CurvedAnimation(parent: _glitchController, curve: Curves.easeInOut));
  }

  Future<void> _isolateSubject() async {
    try {
      final segmenter = SubjectSegmenter(
        options: SubjectSegmenterOptions(
          enableForegroundBitmap: true,
          enableForegroundConfidenceMask: false,
          enableMultipleSubjects: SubjectResultOptions(enableConfidenceMask: false, enableSubjectBitmap: false),
        ),
      );

      final inputImage = InputImage.fromFilePath(widget.originalImage.path);
      final result = await segmenter.processImage(inputImage);

      if (result.foregroundBitmap != null) {
        final segmentedPath = '${widget.originalImage.parent.path}/segmented_${DateTime.now().millisecondsSinceEpoch}.png';
        final segmentedFile = File(segmentedPath);
        await segmentedFile.writeAsBytes(result.foregroundBitmap!);

        if (mounted) {
          setState(() {
            _segmentedImage = segmentedFile;
            _isIsolating = false;
          });
        }
      } else {
        _handleSegmentationFailure('No clear subject found.');
      }
      segmenter.close();
    } catch (e) {
      _handleSegmentationFailure('AI model initializing...');
    }
  }

  void _handleSegmentationFailure(String message) {
    if (mounted) {
      setState(() => _isIsolating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$message Using original image.', style: GoogleFonts.orbitron()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _sendToAI() async {
    final appUser = ref.read(appUserProvider).value;
    final String rawGrade = appUser?.profile.educationLevel ?? '';

    String apiSafeGradeLevel;
    switch (rawGrade) {
      case 'Elementary': apiSafeGradeLevel = 'Elementary (Grades 1-6)'; break;
      case 'Senior High School': apiSafeGradeLevel = 'SHS (Grades 11-12)'; break;
      case 'College': case 'Others': apiSafeGradeLevel = 'College/Undergrad'; break;
      case 'High School': default: apiSafeGradeLevel = 'JHS (Grades 7-10)'; break;
    }

    final imageToUpload = _segmentedImage ?? widget.originalImage;
    showDialog(context: context, barrierDismissible: false, builder: (context) => const AiQueryModal());

    final aiResult = await DiscoveryService.analyzeImage(imageFile: imageToUpload, gradeLevel: apiSafeGradeLevel);

    if (!mounted) return;
    Navigator.pop(context);

    if (aiResult != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => TeaserDoorsScreen(aiData: aiResult, imagePath: imageToUpload.path, gradeLevel: apiSafeGradeLevel),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to analyze. Check your connection.', style: GoogleFonts.orbitron()),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    }
  }

  // Smooth alternating outline renderer
  Widget _buildStickerOutline(File image) {
    const double stroke = 6.0; 
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            for (double dx = -stroke; dx <= stroke; dx += stroke / 1.5)
              for (double dy = -stroke; dy <= stroke; dy += stroke / 1.5)
                if (dx != 0 || dy != 0)
                  Transform.translate(
                    offset: Offset(dx, dy),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        _glowAnimation.value ?? Colors.white, // Alternates colors smoothly
                        BlendMode.srcIn,
                      ),
                      child: Image.file(image, fit: BoxFit.contain),
                    ),
                  ),
            Image.file(image, fit: BoxFit.contain),
          ],
        );
      }
    );
  }

  @override
  void dispose() {
    _glitchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // HEADER 
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: _isIsolating ? theme.colorScheme.primary : theme.colorScheme.secondary, width: 4),
                ),
              ),
              child: Row(
                children: [
                  Icon(_isIsolating ? Icons.hourglass_empty : Icons.check_circle_outline, 
                       color: _isIsolating ? theme.colorScheme.primary : theme.colorScheme.secondary),
                  const SizedBox(width: 10),
                  AnimatedBuilder(
                    animation: _glitchController,
                    builder: (context, child) {
                      return Text(
                        _isIsolating ? 'PROCESSING IMAGE' : 'SUBJECT ISOLATED',
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          shadows: [
                            if (_isIsolating) BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: _glitchController.value), 
                              blurRadius: 10
                            )
                          ]
                        ),
                      );
                    }
                  ),
                ],
              ),
            ),
            
            const Spacer(),

            // INCUBATOR CHAMBER
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.55,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1117), 
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isIsolating ? theme.colorScheme.primary.withValues(alpha: 0.5) : theme.colorScheme.secondary,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isIsolating ? theme.colorScheme.primary : theme.colorScheme.secondary).withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Grid Background
                    CustomPaint(
                      painter: _GridPainter(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                    ),

                    // The image or breathing segmented sticker
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _segmentedImage != null && !_isIsolating
                            ? _buildStickerOutline(_segmentedImage!) 
                            : Image.file(widget.originalImage, fit: BoxFit.cover),
                      ),
                    ),

                    // Scanning Loader Overlay
                    if (_isIsolating)
                      Container(
                        color: Colors.black.withValues(alpha: 0.4),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.secondary,
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),

            // ACTIONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: AnimatedOpacity(
                opacity: _isIsolating ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 500),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isIsolating ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: theme.colorScheme.primary, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('RETAKE', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, letterSpacing: 2)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isIsolating ? null : _sendToAI,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.secondary, 
                          foregroundColor: Colors.black, 
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 15,
                          shadowColor: theme.colorScheme.secondary,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('ANALYZE', style: GoogleFonts.orbitron(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                            const SizedBox(width: 8),
                            const Icon(Icons.satellite_alt, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 20) canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    for (double i = 0; i < size.height; i += 20) canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}