import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuklascope_mobile/core/services/discovery_service.dart';
import 'package:tuklascope_mobile/core/navigation/main_nav_scope.dart';
import 'package:tuklascope_mobile/features/auth/providers/auth_controller.dart';
import 'teaser_doors_screen.dart';

class LiveFeedScreen extends StatefulWidget {
  const LiveFeedScreen({super.key});

  @override
  State<LiveFeedScreen> createState() => _LiveFeedScreenState();
}

class _LiveFeedScreenState extends State<LiveFeedScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
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
      showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.7),
        barrierDismissible: false,
        builder: (context) => ScanningModal(imageFile: imageFile),
      );
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_isCameraInitialized || _controller == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    final navScope = MainNavScope.maybeOf(context);
    final isNavBarVisible = navScope?.isNavBarVisible ?? true;
    final extraBottomPadding = isNavBarVisible ? 100.0 : 20.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: ClipRect(
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 10,
                    bottom: 16,
                    left: 20,
                    right: 20,
                  ),
                  color: Colors.black.withValues(alpha: 0.4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.fiber_manual_record,
                        color: theme.colorScheme.secondary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Camera Active',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          _isFlashOn ? Icons.flash_on : Icons.flash_off,
                          color: _isFlashOn
                              ? theme.colorScheme.secondary
                              : Colors.white,
                        ),
                        onPressed: _toggleFlash,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutQuint,
                  padding: EdgeInsets.only(
                    top: 20,
                    bottom:
                        MediaQuery.of(context).padding.bottom +
                        extraBottomPadding,
                    left: 40,
                    right: 40,
                  ),
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        iconSize: 32,
                        icon: const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                      GestureDetector(
                        onTap: _takePictureAndScan,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        iconSize: 32,
                        icon: const Icon(
                          Icons.flip_camera_ios,
                          color: Colors.white,
                        ),
                        onPressed: _flipCamera,
                      ),
                    ],
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

// 🚀 FIX: Changed to ConsumerStatefulWidget to access Riverpod
class ScanningModal extends ConsumerStatefulWidget {
  final File imageFile;

  const ScanningModal({super.key, required this.imageFile});

  @override
  ConsumerState<ScanningModal> createState() => _ScanningModalState();
}

class _ScanningModalState extends ConsumerState<ScanningModal> {
  @override
  void initState() {
    super.initState();
    _uploadAndAnalyze();
  }

  Future<void> _uploadAndAnalyze() async {
    // Fetch real grade level securely from Riverpod state
    final appUser = ref.read(appUserProvider).value;
    final String rawGrade = appUser?.profile.educationLevel ?? '';

    // 🚀 FIX: Safely map UI dropdown values to strict backend Pydantic Enum strings
    String apiSafeGradeLevel;
    switch (rawGrade) {
      case 'Elementary':
        apiSafeGradeLevel =
            'Elementary (Grades 1-6)'; // Adjust if your backend expects different
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
        apiSafeGradeLevel = 'JHS (Grades 7-10)'; // Our known 100% safe fallback
        break;
    }

    final aiResult = await DiscoveryService.analyzeImage(
      imageFile: widget.imageFile,
      gradeLevel: apiSafeGradeLevel, // Pass the strictly validated string!
    );

    if (!mounted) return;

    Navigator.pop(context);

    if (aiResult != null) {
      debugPrint("🎯 AI RESPONSE: $aiResult");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TeaserDoorsScreen(
            aiData: aiResult,
            imagePath: widget.imageFile.path,
            gradeLevel: apiSafeGradeLevel, // Pass to next screen
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Failed to analyze image. Ensure you have internet and try again.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 320,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.secondary,
                    ),
                  ),
                ),
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.document_scanner_rounded,
                    size: 36,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 35),
            Text(
              'Analyzing Artifact...',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Cross-referencing historical databases',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
