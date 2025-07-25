import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isRecording = false;
  bool _flashOn = false;
  bool _frontCamera = false;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(
      _cameras![_frontCamera ? 1 : 0],
      ResolutionPreset.ultraHigh,
    );
    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleCamera() async {
    setState(() => _frontCamera = !_frontCamera);
    await _controller.dispose();
    _setupCamera();
  }

  Future<void> _takePhoto() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      // Traiter l'image ici (enregistrement, partage, etc.)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo sauvegardée: ${image.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _controller.stopVideoRecording();
      setState(() => _isRecording = false);
    } else {
      await _controller.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller),
                _buildTopControls(),
                _buildBottomControls(),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 40,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.white, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
          IconButton(
            icon: Icon(
              _flashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () => setState(() => _flashOn = !_flashOn),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.photo_library, color: Colors.white, size: 30),
                onPressed: () {},
              ),
              GestureDetector(
                onTap: _takePhoto,
                onLongPress: _toggleRecording,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.cameraswitch, color: Colors.white, size: 30),
                onPressed: _toggleCamera,
              ),
            ],
          ),
          if (_isRecording)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                'Enregistrement...',
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            ),
        ],
      ),
    );
  }
}
