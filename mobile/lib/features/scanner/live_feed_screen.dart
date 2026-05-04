import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_subject_segmentation/google_mlkit_subject_segmentation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuklascope_mobile/core/services/discovery_service.dart';
import 'package:tuklascope_mobile/core/navigation/main_nav_scope.dart';
import 'package:tuklascope_mobile/features/auth/providers/auth_controller.dart';
import 'package:tuklascope_mobile/core/widgets/gradient_scaffold.dart';
import 'teaser_doors_screen.dart';

class LiveFeedScreen extends StatefulWidget {
  const LiveFeedScreen({super.key});

  @override
  State<LiveFeedScreen> createState() => _LiveFeedScreenState();
}

class _LiveFeedScreenState extends State<LiveFeedScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  int _selectedCameraIndex = 0;

  late AnimationController _scannerController;

  @override
  void initState() {
    super.initState();
    _initCamera();

    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _setCamera(_selectedCameraIndex);
    }
  }

  void _setCamera(int index) {
    _controller = CameraController(
      _cameras![index],
      ResolutionPreset.max,
      enableAudio: false,
    );

    _controller!
        .initialize()
        .then((_) {
          if (!mounted) return;
          setState(() {
            _isCameraInitialized = true;
          });
        })
        .catchError((e) {
          debugPrint("Camera Error: $e");
        });
  }

  void _toggleFlash() {
    if (_controller == null) return;
    setState(() {
      _isFlashOn = !_isFlashOn;
      _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
    });
  }

  void _flipCamera() {
    if (_cameras == null || _cameras!.length < 2) return;
    _selectedCameraIndex = _selectedCameraIndex == 0 ? 1 : 0;
    _isCameraInitialized = false;
    _setCamera(_selectedCameraIndex);
  }

  Future<void> _takePictureAndScan() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isTakingPicture) return;

    try {
      final XFile rawImage = await _controller!.takePicture();
      final File imageFile = File(rawImage.path);

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => ConfirmImageScreen(originalImage: imageFile),
        ),
      );
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_isCameraInitialized || _controller == null) {
      return GradientScaffold(
        body: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    final navScope = MainNavScope.maybeOf(context);
    final isNavBarVisible = navScope?.isNavBarVisible ?? true;
    
    final bottomSafePadding = MediaQuery.of(context).padding.bottom;
    final extraBottomPadding = (isNavBarVisible ? 120.0 : 60.0) + bottomSafePadding; 

    const double boxWidth = 280;
    const double boxHeight = 350;

    return GradientScaffold(
      body: Stack(
        children: [
          // 1. THE RESTRICTED CAMERA WINDOW
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: boxWidth,
                height: boxHeight,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: 100,
                    height: 100 * _controller!.value.aspectRatio,
                    child: CameraPreview(_controller!),
                  ),
                ),
              ),
            ),
          ),

          // 2. THE SCI-FI HUD DESIGNS AROUND THE BOX
          Positioned.fill(
            child: CustomPaint(
              painter: _AdvancedHudPainter(
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ),
            ),
          ),

          // 3. THE ANIMATED LASER INSIDE THE BOX
          Center(
            child: SizedBox(
              width: boxWidth,
              height: boxHeight,
              child: AnimatedBuilder(
                animation: _scannerController,
                builder: (context, child) {
                  return Stack(
                    children: [
                      Positioned(
                        top: _scannerController.value * (boxHeight - 4),
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary,
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.secondary,
                                blurRadius: 12,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // TOP STATUS BAR
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.radar,
                        color: theme.colorScheme.primary,
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SUBJECT TRACKING',
                        style: GoogleFonts.orbitron(
                          color: theme.colorScheme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isFlashOn ? Icons.flash_on : Icons.flash_off,
                    color: _isFlashOn
                        ? theme.colorScheme.secondary
                        : Colors.white70,
                  ),
                  onPressed: _toggleFlash,
                ),
              ],
            ),
          ),

          // BOTTOM CONTROLS (With Smooth Button)
          Positioned(
            bottom: extraBottomPadding,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    iconSize: 28,
                    icon: const Icon(
                      Icons.photo_library,
                      color: Colors.white70,
                    ),
                    onPressed: () {},
                  ),

                  // THE NEW, ULTRA-SMOOTH CAPTURE BUTTON
                  GestureDetector(
                    onTap: _takePictureAndScan,
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.4,
                            ),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  IconButton(
                    iconSize: 28,
                    icon: const Icon(
                      Icons.flip_camera_ios,
                      color: Colors.white70,
                    ),
                    onPressed: _flipCamera,
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

class _AdvancedHudPainter extends CustomPainter {
  final Color primary;
  final Color secondary;

  _AdvancedHudPainter(this.primary, this.secondary);

  @override
  void paint(Canvas canvas, Size size) {
    const double boxWidth = 280;
    const double boxHeight = 350;
    final double left = (size.width - boxWidth) / 2;
    final double top = (size.height - boxHeight) / 2;
    final double right = left + boxWidth;
    final double bottom = top + boxHeight;

    final outlinePaint = Paint()
      ..color = primary.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final bracketPaint = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.square;

    final accentPaint = Paint()
      ..color = secondary
      ..style = PaintingStyle.fill;

    // 1. Draw subtle grid behind everything
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        Paint()..color = Colors.white.withValues(alpha: 0.03),
      );
    }
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        Paint()..color = Colors.white.withValues(alpha: 0.03),
      );
    }

    // 2. Draw thin border around the camera box
    final RRect scanRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, boxWidth, boxHeight),
      const Radius.circular(16),
    );
    canvas.drawRRect(scanRect, outlinePaint);

    // 3. Draw Heavy Sci-Fi Corner Brackets
    const double length = 40.0;
    const double offset = 8.0;

    // Top Left
    canvas.drawLine(
      Offset(left - offset, top + length),
      Offset(left - offset, top - offset),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(left - offset, top - offset),
      Offset(left + length, top - offset),
      bracketPaint,
    );

    // Top Right
    canvas.drawLine(
      Offset(right + offset, top + length),
      Offset(right + offset, top - offset),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(right + offset, top - offset),
      Offset(right - length, top - offset),
      bracketPaint,
    );

    // Bottom Left
    canvas.drawLine(
      Offset(left - offset, bottom - length),
      Offset(left - offset, bottom + offset),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(left - offset, bottom + offset),
      Offset(left + length, bottom + offset),
      bracketPaint,
    );

    // Bottom Right
    canvas.drawLine(
      Offset(right + offset, bottom - length),
      Offset(right + offset, bottom + offset),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(right + offset, bottom + offset),
      Offset(right - length, bottom + offset),
      bracketPaint,
    );

    // 4. Draw Telemetry Accents
    canvas.drawCircle(Offset(left - offset, top - offset), 4, accentPaint);
    canvas.drawCircle(Offset(right + offset, bottom + offset), 4, accentPaint);

    // 5. Draw Crosshair ticks inside the box
    final crosshairPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final centerX = left + (boxWidth / 2);
    final centerY = top + (boxHeight / 2);

    canvas.drawLine(
      Offset(centerX, top + 20),
      Offset(centerX, top + 40),
      crosshairPaint,
    ); 
    canvas.drawLine(
      Offset(centerX, bottom - 20),
      Offset(centerX, bottom - 40),
      crosshairPaint,
    ); 
    canvas.drawLine(
      Offset(left + 20, centerY),
      Offset(left + 40, centerY),
      crosshairPaint,
    ); 
    canvas.drawLine(
      Offset(right - 20, centerY),
      Offset(right - 40, centerY),
      crosshairPaint,
    ); 

    // 6. Draw Text Data (🚀 MOVED TO TOP)
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'SCAN STATUS: READY\nPOSITION: OPTIMAL',
        style: GoogleFonts.orbitron(
          color: primary.withValues(alpha: 0.7),
          fontSize: 8,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Changed from `bottom + 20` to `top - 35` and aligned slightly left with the bracket
    textPainter.paint(canvas, Offset(left - offset, top - 35)); 
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -------------------------------------------------------------------------
// THE NEW CONFIRMATION & DISSOLVE SCREEN
// -------------------------------------------------------------------------

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
          content: Text(
            '$message Using original image.',
            style: GoogleFonts.inter(),
          ),
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
      builder: (context) => const _AIQueryModal(),
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
          content: Text(
            'Failed to analyze. Check your connection.',
            style: GoogleFonts.inter(),
          ),
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
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
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
            // Header
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
                      if (_segmentedImage != null)
                        _buildStickerOutline(_segmentedImage!),

                      AnimatedOpacity(
                        opacity: (_isIsolating || _segmentedImage == null)
                            ? 1.0
                            : 0.0,
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeInOut,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            widget.originalImage,
                            fit: BoxFit.cover,
                          ),
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

            // THE ACTION BUTTONS
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
              child: AnimatedOpacity(
                opacity: _isIsolating ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 500),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isIsolating
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'RETAKE',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 10,
                        ),
                        child: Text(
                          'ANALYZE',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
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

// -------------------------------------------------------------------------
// DYNAMIC LOADING MODAL FOR AI REQUEST
// -------------------------------------------------------------------------
class _AIQueryModal extends StatefulWidget {
  const _AIQueryModal();

  @override
  State<_AIQueryModal> createState() => _AIQueryModalState();
}

class _AIQueryModalState extends State<_AIQueryModal>
    with SingleTickerProviderStateMixin {
  late final List<String> _phrases;
  late final Stream<int> _timerStream;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _phrases = [
      'Connecting to server...',
      'Processing visual data...',
      'Analyzing features...',
      'Generating results...',
    ];
    _timerStream = Stream.periodic(
      const Duration(milliseconds: 2000),
      (i) => i,
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 280,
            decoration: BoxDecoration(
              color: const Color(0xFF0A0E17).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                  blurRadius: 40,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 100 + (_pulseController.value * 20),
                          height: 100 + (_pulseController.value * 20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                            strokeWidth: 3,
                          ),
                        ),
                        Icon(
                          Icons.wifi_tethering,
                          size: 36,
                          color: theme.colorScheme.secondary,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 40),
                StreamBuilder<int>(
                  stream: _timerStream,
                  builder: (context, snapshot) {
                    final index = (snapshot.data ?? 0) % _phrases.length;
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        _phrases[index].toUpperCase(),
                        key: ValueKey<int>(index),
                        style: GoogleFonts.orbitron(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.secondary,
                          letterSpacing: 2.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}