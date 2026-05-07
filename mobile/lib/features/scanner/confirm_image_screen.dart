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

class _ConfirmImageScreenState extends ConsumerState<ConfirmImageScreen> {
  bool _isIsolating = true;
  File? _segmentedImage;

  @override
  void initState() {
    super.initState();
    _isolateSubject();
  }

  Future<void> _isolateSubject() async {
    try {
      final segmenter = SubjectSegmenter(
        options: SubjectSegmenterOptions(
          enableForegroundBitmap: true,
          enableForegroundConfidenceMask: false,
          enableMultipleSubjects: SubjectResultOptions(
            enableConfidenceMask: false,
            enableSubjectBitmap: false,
          ),
        ),
      );

      final inputImage = InputImage.fromFilePath(widget.originalImage.path);
      final result = await segmenter.processImage(inputImage);

      if (result.foregroundBitmap != null) {
        final segmentedPath =
            '${widget.originalImage.parent.path}/segmented_${DateTime.now().millisecondsSinceEpoch}.png';
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
      debugPrint("Segmentation Error: $e");
      _handleSegmentationFailure('AI model initializing...');
    }
  }

  void _handleSegmentationFailure(String message) {
    if (mounted) {
      setState(() => _isIsolating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$message Using original image.', style: GoogleFonts.inter()),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _sendToAI() async {
    final appUser = ref.read(appUserProvider).value;
    final String rawGrade = appUser?.profile.educationLevel ?? '';

    String apiSafeGradeLevel;
    switch (rawGrade) {
      case 'Elementary':
        apiSafeGradeLevel = 'Elementary (Grades 1-6)';
        break;
      case 'Senior High School':
        apiSafeGradeLevel = 'SHS (Grades 11-12)';
        break;
      case 'College':
      case 'Others':
        apiSafeGradeLevel = 'College/Undergrad';
        break;
      case 'High School':
      default:
        apiSafeGradeLevel = 'JHS (Grades 7-10)';
        break;
    }

    final imageToUpload = _segmentedImage ?? widget.originalImage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AiQueryModal(),
    );

    final aiResult = await DiscoveryService.analyzeImage(
      imageFile: imageToUpload,
      gradeLevel: apiSafeGradeLevel,
    );

    if (!mounted) return;
    Navigator.pop(context);

    if (aiResult != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TeaserDoorsScreen(
            aiData: aiResult,
            imagePath: imageToUpload.path,
            gradeLevel: apiSafeGradeLevel,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to analyze. Check your connection.', style: GoogleFonts.inter()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Widget _buildStickerOutline(File image) {
    const double stroke = 4.0;
    return Stack(
      fit: StackFit.expand,
      children: [
        for (double dx = -stroke; dx <= stroke; dx += stroke)
          for (double dy = -stroke; dy <= stroke; dy += stroke)
            if (dx != 0 || dy != 0)
              Transform.translate(
                offset: Offset(dx, dy),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  child: Image.file(image, fit: BoxFit.contain),
                ),
              ),
        Image.file(image, fit: BoxFit.contain),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              _isIsolating ? 'PROCESSING IMAGE' : 'SUBJECT ISOLATED',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2532), 
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_segmentedImage != null) _buildStickerOutline(_segmentedImage!),
                      AnimatedOpacity(
                        opacity: (_isIsolating || _segmentedImage == null) ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeInOut,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(widget.originalImage, fit: BoxFit.cover),
                        ),
                      ),
                      if (_isIsolating)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.secondary,
                              strokeWidth: 4,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('RETAKE', style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isIsolating ? null : _sendToAI,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 10,
                        ),
                        child: Text('ANALYZE', style: GoogleFonts.inter(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
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