// mobile/lib/features/scanner/live_feed_screen.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tuklascope_mobile/core/services/discovery_service.dart';
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

  // Initializes the device's hardware cameras
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
      enableAudio: false, // We only need visual for scanning
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

  // This is our real photo capture logic!
  Future<void> _takePictureAndScan() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isTakingPicture) return; // Prevent double-taps

    try {
      // 1. Snap the physical photo
      final XFile rawImage = await _controller!.takePicture();
      final File imageFile = File(rawImage.path);

      // 2. Open the modal and pass the image into it
      if (!mounted) return;
      showDialog(
        context: context,
        // This darkens the camera feed behind the dialog to make it POP!
        barrierColor: Colors.black.withOpacity(0.7),
        barrierDismissible:
            false, // Prevents them from tapping outside to cancel
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
    if (!_isCameraInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. THE CAMERA PREVIEW
          Positioned.fill(
            child: ClipRect(
              // Keeps the camera from bleeding off-screen
              child: FittedBox(
                fit: BoxFit.cover, // Zooms in just enough to hide black bars
                child: SizedBox(
                  width: 100, // Arbitrary base width
                  // THE MAGIC: Multiplying by the camera's raw landscape ratio
                  // forces this box into a perfect Portrait ratio!
                  height: 100 * _controller!.value.aspectRatio,
                  child: CameraPreview(_controller!),
                ),
              ),
            ),
          ),

          // 2. TOP BLURRED BAR
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 10.0,
                  sigmaY: 10.0,
                ), // The Blur Magic
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 10,
                    bottom: 16,
                    left: 20,
                    right: 20,
                  ),
                  color: Colors.black.withOpacity(0.4), // Darkens the blur
                  child: Row(
                    children: [
                      const Icon(
                        Icons.fiber_manual_record,
                        color: Colors.green,
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
                          color: _isFlashOn ? Colors.yellow : Colors.white,
                        ),
                        onPressed: _toggleFlash,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. BOTTOM BLURRED BAR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  padding: EdgeInsets.only(
                    top: 20,
                    bottom:
                        MediaQuery.of(context).padding.bottom +
                        30, // Safe area for bottom swipe bar
                    left: 40,
                    right: 40,
                  ),
                  color: Colors.black.withOpacity(0.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // GALLERY BUTTON (Still mocked for now)
                      IconButton(
                        iconSize: 32,
                        icon: const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),

                      // THE SHUTTER BUTTON (Triggers camera)
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
                                color: Colors.white, // The inner solid circle
                              ),
                            ),
                          ),
                        ),
                      ),

                      // FLIP CAMERA BUTTON
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

// --- 3.2 THE ANALYZING MODAL ---
class ScanningModal extends StatefulWidget {
  final File imageFile; // The modal now requires the photo

  const ScanningModal({super.key, required this.imageFile});

  @override
  State<ScanningModal> createState() => _ScanningModalState();
}

class _ScanningModalState extends State<ScanningModal> {
  @override
  void initState() {
    super.initState();
    _uploadAndAnalyze(); // Trigger actual API call
  }

  // The actual backend communication logic
  Future<void> _uploadAndAnalyze() async {
    // Call our backend!
    final aiResult = await DiscoveryService.analyzeImage(widget.imageFile);

    if (!mounted) return;

    // 1. Close the Analyzing Modal
    Navigator.pop(context);

    if (aiResult != null) {
      // SUCCESS!
      // Print the JSON so we can see it in VS Code Debug Console
      debugPrint("🎯 AI RESPONSE: $aiResult");

      // Go to the Teaser Doors and pass the JSON data!
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TeaserDoorsScreen(aiData: aiResult),
        ),
      );
    } else {
      // FAILURE: Show an error to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to analyze image. Ensure you have internet and try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 320,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFDF4), Color(0xFFD9D7CE)],
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
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
                const SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF9800),
                    ),
                  ),
                ),
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B3C6A).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.document_scanner_rounded,
                    size: 36,
                    color: Color(0xFF0B3C6A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 35),
            const Text(
              'Analyzing Artifact...',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B3C6A),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Cross-referencing historical databases',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
