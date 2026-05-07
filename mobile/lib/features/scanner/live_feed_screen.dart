import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';

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

  // Zoom state
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentZoom = 1.0;

  late AnimationController _scannerController;
  late Stream<int> _tipsTimer;
  final List<String> _tips = [
    "POINT CAMERA AT AN OBJECT",
    "KEEP YOUR HANDS STEADY",
    "ENSURE GOOD LIGHTING",
    "TAP TO FOCUS ON SUBJECT"
  ];

  @override
  void initState() {
    super.initState();
    
    // FORCE PORTRAIT MODE FOR THIS SCREEN
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _initCamera();

    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _tipsTimer = Stream.periodic(const Duration(seconds: 3), (i) => i);
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

    _controller!.initialize().then((_) async {
      if (!mounted) return;
      
      _maxAvailableZoom = await _controller!.getMaxZoomLevel();
      _minAvailableZoom = await _controller!.getMinZoomLevel();
      _currentZoom = _minAvailableZoom; 

      setState(() {
        _isCameraInitialized = true;
      });
    }).catchError((e) {
      debugPrint("Camera Error: $e");
    });
  }

  void _setZoom(double zoom) {
    if (_controller == null) return;
    setState(() {
      _currentZoom = zoom;
    });
    _controller!.setZoomLevel(zoom);
  }

  void _handleTapToFocus(TapDownDetails details, BoxConstraints constraints) {
    if (_controller == null) return;
    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    _controller!.setFocusPoint(offset);
    _controller!.setExposurePoint(offset);
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
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => ConfirmImageScreen(originalImage: imageFile),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  @override
  void dispose() {
    // REVERT ORIENTATION TO ALLOW NORMAL BEHAVIOR GLOBALLY
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    
    _controller?.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_isCameraInitialized || _controller == null) {
      return GradientScaffold(
        body: Center(child: CircularProgressIndicator(color: theme.colorScheme.secondary)),
      );
    }

    final navScope = MainNavScope.maybeOf(context);
    final isNavBarVisible = navScope?.isNavBarVisible ?? true;
    final bottomSafePadding = MediaQuery.of(context).padding.bottom;
    
    // LOWERED: Changed 120->90 and 40->15 for a much tighter layout
    final extraBottomPadding = (isNavBarVisible ? 100.0 : 30.0) + bottomSafePadding; 

    // Fixed sizes since landscape is disabled
    const double boxWidth = 280;
    const double boxHeight = 350;

    return GradientScaffold(
      body: Stack(
        children: [
          // 1. GESTURE & CAMERA LAYER
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: boxWidth,
                height: boxHeight,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onTapDown: (details) => _handleTapToFocus(details, constraints),
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: 100,
                          height: 100 * _controller!.value.aspectRatio,
                          child: CameraPreview(_controller!),
                        ),
                      ),
                    );
                  }
                ),
              ),
            ),
          ),

          // 2. SCI-FI HUD
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: AdvancedHudPainter(
                  primary: theme.colorScheme.primary, 
                  secondary: theme.colorScheme.secondary,
                  boxWidth: boxWidth,
                  boxHeight: boxHeight,
                ),
              ),
            ),
          ),

          // 3. ANIMATED LASER
          Center(
            child: IgnorePointer(
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
                          left: 0, right: 0,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary,
                              boxShadow: [
                                BoxShadow(color: theme.colorScheme.secondary, blurRadius: 10, spreadRadius: 2),
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
          ),

          // 4. INTERACTIVE TIPS (Placed dynamically just above the bounding box)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: boxHeight + 80),
              child: StreamBuilder<int>(
                stream: _tipsTimer,
                builder: (context, snapshot) {
                  final index = (snapshot.data ?? 0) % _tips.length;
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      _tips[index],
                      key: ValueKey<int>(index),
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 5. TOP BAR
          CameraTopBar(
            currentZoom: _currentZoom,
            minZoom: _minAvailableZoom,
            maxZoom: _maxAvailableZoom,
            onZoomChanged: _setZoom,
          ),

          // 6. ANIMATED BOTTOM CONTROLS
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            bottom: extraBottomPadding,
            left: 0,
            right: 0,
            child: CameraControls(
              onCapture: _takePictureAndScan,
              onFlipCamera: _flipCamera,
              isFlashOn: _isFlashOn,
              onToggleFlash: _toggleFlash,
            ),
          ),
        ],
      ),
    );
  }
}