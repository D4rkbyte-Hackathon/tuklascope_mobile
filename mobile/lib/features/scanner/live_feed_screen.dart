import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'teaser_doors_screen.dart'; // <-- Add this near your other imports

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
      _controller!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    });
  }

  void _flipCamera() {
    if (_cameras == null || _cameras!.length < 2) return;
    _selectedCameraIndex = _selectedCameraIndex == 0 ? 1 : 0;
    _isCameraInitialized = false;
    _setCamera(_selectedCameraIndex);
  }

  // The mock action: Skips taking a picture and just opens the floating dialog
  void _triggerScanningModal() {
    showDialog(
      context: context,
      // This darkens the camera feed behind the dialog to make it POP!
      barrierColor: Colors.black.withOpacity(0.7), 
      barrierDismissible: false, // Optional: Prevents them from tapping outside to cancel
      builder: (context) => const ScanningModal(),
    );
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
        // REMOVED: fit: StackFit.expand, (This was causing the stretching!)
        children: [
          // 1. THE CAMERA PREVIEW (Base Layer)
          Positioned.fill(
            child: ClipRect( // Keeps the camera from bleeding off-screen
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
            // ... The rest of your code stays exactly the same from here down!
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // The Blur Magic
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 10, // Safe area for notch
                    bottom: 16,
                    left: 20,
                    right: 20,
                  ),
                  color: Colors.black.withOpacity(0.4), // Darkens the blur
                  child: Row(
                    children: [
                      const Icon(Icons.fiber_manual_record, color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'Camera Active',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
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
                    bottom: MediaQuery.of(context).padding.bottom + 30, // Safe area for bottom swipe bar
                    left: 40,
                    right: 40,
                  ),
                  color: Colors.black.withOpacity(0.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // GALLERY BUTTON (Mocks opening modal)
                      IconButton(
                        iconSize: 32,
                        icon: const Icon(Icons.photo_library, color: Colors.white),
                        onPressed: _triggerScanningModal,
                      ),

                      // THE SHUTTER BUTTON (Mocks taking a photo)
                      GestureDetector(
                        onTap: _triggerScanningModal,
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
                        icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
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

// --- 3.2 THE ANALYZING MODAL (FLOATING VERSION) ---
class ScanningModal extends StatefulWidget {
  const ScanningModal({super.key});

  @override
  State<ScanningModal> createState() => _ScanningModalState();
}

class _ScanningModalState extends State<ScanningModal> {
  
  @override
  void initState() {
    super.initState();
    
    // THE MAGIC TIMER: Wait 3 seconds, then navigate
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return; 

      // 1. Close this Floating Dialog
      Navigator.pop(context); 
      
      // 2. Push directly to Screen 3.3 (Teaser Doors)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TeaserDoorsScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dialog is the magic widget that floats in the center
    return Dialog(
      backgroundColor: Colors.transparent, // Makes the default white square invisible
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24), // Gives it breathing room from the phone edges
      child: Container(
        height: 320, // Slightly shorter since we removed the drag handle
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFDF4), Color(0xFFD9D7CE)],
          ),
          // Round ALL FOUR corners now!
          borderRadius: BorderRadius.circular(32),
          // Add a soft glow behind the dialog to lift it off the dark background
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
            // THE SCANNING GRAPHIC
            Stack(
              alignment: Alignment.center,
              children: [
                // 1. The Outer Progress Ring
                const SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9800)), 
                  ),
                ),
                // 2. The Inner Icon Container
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

            // THE TEXT
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
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}