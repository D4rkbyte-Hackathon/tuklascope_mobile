import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'package:tuklascope_mobile/core/navigation/main_nav_scope.dart';
import 'package:tuklascope_mobile/core/widgets/gradient_scaffold.dart';

import 'confirm_image_screen.dart';
import 'widgets/advanced_hud_painter.dart';
import 'widgets/camera_top_bar.dart';
import 'widgets/camera_controls.dart';

class LiveFeedScreen extends StatefulWidget {
  const LiveFeedScreen({super.key});

  @override
  State<LiveFeedScreen> createState() => _LiveFeedScreenState();
}

class _LiveFeedScreenState extends State<LiveFeedScreen> with SingleTickerProviderStateMixin {
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

    _controller!.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
    }).catchError((e) {
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
          // 1. RESTRICTED CAMERA WINDOW
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

          // 2. SCI-FI HUD DESIGN
          Positioned.fill(
            child: CustomPaint(
              painter: AdvancedHudPainter(theme.colorScheme.primary, theme.colorScheme.secondary),
            ),
          ),

          // 3. ANIMATED LASER
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

          // 4. TOP BAR
          CameraTopBar(
            isFlashOn: _isFlashOn,
            onToggleFlash: _toggleFlash,
          ),

          // 5. BOTTOM CONTROLS
          CameraControls(
            onCapture: _takePictureAndScan,
            onFlipCamera: _flipCamera,
            bottomPadding: extraBottomPadding,
          ),
        ],
      ),
    );
  }
}