import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class CustomCameraPage extends StatefulWidget {
  const CustomCameraPage({super.key});

  @override
  State<CustomCameraPage> createState() => _CustomCameraPageState();
}

class _CustomCameraPageState extends State<CustomCameraPage>
    with WidgetsBindingObserver {
  List<CameraDescription>? _cameras;
  CameraController? _controller;
  int _cameraIndex = 0;
  bool _isInitialized = false;
  bool _isCapturing = false;
  String? _error;
  FlashMode _flashMode = FlashMode.auto;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCameras();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      setState(() => _isInitialized = false);
    } else if (state == AppLifecycleState.resumed) {
      final cameras = _cameras;
      if (cameras != null && cameras.isNotEmpty) {
        _initController(cameras[_cameraIndex]);
      }
    }
  }

  Future<void> _initCameras() async {
    try {
      final cameras = await availableCameras();
      if (!mounted) return;
      setState(() => _cameras = cameras);
      if (cameras.isEmpty) {
        setState(() => _error = 'Tidak ada kamera yang tersedia.');
        return;
      }
      await _initController(cameras[_cameraIndex]);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Gagal mengakses kamera: $e');
    }
  }

  Future<void> _initController(CameraDescription camera) async {
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _controller = controller;
    try {
      await controller.initialize();
      await _applyFlashMode(controller);
      if (!mounted) return;
      setState(() => _isInitialized = true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Gagal menginisialisasi kamera: $e');
    }
  }

  Future<void> _applyFlashMode(CameraController controller) async {
    try {
      await controller.setFlashMode(_flashMode);
    } catch (e) {
      // Perangkat tidak mendukung flash (mis. emulator); abaikan agar tidak crash.
      debugPrint('setFlashMode gagal (flash tidak didukung): $e');
    }
  }

  Future<void> _toggleFlash() async {
    final next = switch (_flashMode) {
      FlashMode.auto => FlashMode.always,
      FlashMode.always => FlashMode.off,
      _ => FlashMode.auto,
    };
    setState(() => _flashMode = next);
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      await _applyFlashMode(controller);
    }
  }

  IconData _flashIcon() {
    return switch (_flashMode) {
      FlashMode.always => Icons.flash_on,
      FlashMode.off => Icons.flash_off,
      _ => Icons.flash_auto,
    };
  }

  Future<void> _flipCamera() async {
    final cameras = _cameras;
    if (cameras == null || cameras.length < 2) return;
    setState(() => _isInitialized = false);
    await _controller?.dispose();
    _cameraIndex = (_cameraIndex + 1) % cameras.length;
    await _initController(cameras[_cameraIndex]);
  }

  Future<void> _capturePhoto() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        _isCapturing) {
      return;
    }
    setState(() => _isCapturing = true);
    try {
      // takePicture() captures at the resolution set in CameraController (ResolutionPreset.high).
      // CameraController does not expose a quality-compression parameter; compression is
      // handled downstream by the ML inference layer.
      final xfile = await controller.takePicture();
      if (!mounted) return;
      context.go(
          '/detect/validate?path=${Uri.encodeComponent(xfile.path)}');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal mengambil foto: $e';
        _isCapturing = false;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final xfile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
      if (xfile == null || !mounted) return;
      context.go(
          '/detect/validate?path=${Uri.encodeComponent(xfile.path)}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Gagal membuka galeri: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Kamera preview
          if (_isInitialized && _controller != null)
            CameraPreview(_controller!)
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // Overlay error
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // Overlay: target area, crosshair, instruksi
          if (_isInitialized) const _OverlayPainter(),

          // Kontrol bawah
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomControls(context),
          ),

          // Tombol kembali
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => context.go('/home'),
            ),
          ),

          // Tombol flash
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 8,
            child: IconButton(
              tooltip: switch (_flashMode) {
                FlashMode.always => 'Flash: Nyala',
                FlashMode.off => 'Flash: Mati',
                _ => 'Flash: Auto',
              },
              icon: Icon(_flashIcon(), color: Colors.white),
              onPressed: _isInitialized ? _toggleFlash : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 20,
        top: 20,
      ),
      color: Colors.black87,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Tombol Galeri
          _CameraControlButton(
            icon: Icons.photo_library_outlined,
            label: 'Galeri',
            onTap: _pickFromGallery,
          ),

          // Tombol Shutter
          GestureDetector(
            onTap: _isCapturing ? null : _capturePhoto,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Center(
                child: _isCapturing
                    ? const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)
                    : Container(
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

          // Tombol Putar Kamera
          _CameraControlButton(
            icon: Icons.flip_camera_ios_outlined,
            label: 'Putar',
            onTap: _flipCamera,
          ),
        ],
      ),
    );
  }
}

/// Overlay berisi kotak target area, crosshair, dan teks instruksi.
class _OverlayPainter extends StatelessWidget {
  const _OverlayPainter();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final boxSize = size.width * 0.72;
    final boxTop = size.height * 0.18;

    return Stack(
      children: [
        // Kotak Target Area
        Positioned(
          top: boxTop,
          left: (size.width - boxSize) / 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'TARGET AREA',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Container(
                width: boxSize,
                height: boxSize,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),

        // Crosshair di tengah kotak
        Positioned(
          top: boxTop + 28, // 28px untuk tinggi label "TARGET AREA"
          left: 0,
          right: 0,
          height: boxSize,
          child: Center(
            child: CustomPaint(
              size: Size(boxSize * 0.35, boxSize * 0.35),
              painter: _CrosshairPainter(),
            ),
          ),
        ),

        // Teks instruksi di atas kontrol bawah
        Positioned(
          bottom: 130,
          left: 0,
          right: 0,
          child: Column(
            children: [
              _InstructionChip(text: 'Jarak ideal: 10–20 cm'),
              const SizedBox(height: 6),
              _InstructionChip(text: 'Pastikan pencahayaan cukup terang'),
            ],
          ),
        ),
      ],
    );
  }
}

class _InstructionChip extends StatelessWidget {
  final String text;
  const _InstructionChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      margin: const EdgeInsets.symmetric(horizontal: 48),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _CameraControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _CameraControlButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _CrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.28;
    final lineHalf = size.width * 0.18;

    // Lingkaran
    canvas.drawCircle(center, radius, paint);

    // Garis horizontal
    canvas.drawLine(
      Offset(center.dx - lineHalf, center.dy),
      Offset(center.dx + lineHalf, center.dy),
      paint,
    );
    // Garis vertikal
    canvas.drawLine(
      Offset(center.dx, center.dy - lineHalf),
      Offset(center.dx, center.dy + lineHalf),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
