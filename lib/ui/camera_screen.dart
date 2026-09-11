import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../main.dart';
import '../services/face_detection_service.dart';
import '../services/audio_service.dart';
import '../services/sneeze_detector.dart';
import '../utils/camera_utils.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;

  final FaceDetectionService _faceService = FaceDetectionService();
  final AudioService _audioService = AudioService();
  final SneezeDetector _sneezeDetector = SneezeDetector();

  @override
  void initState() {
    super.initState();
    _initCamera();
    _audioService.startTripwire(onLoudNoise: _handleAudioSpike);
  }

  Future<void> _initCamera() async {
    final backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      backCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    try {
      await _controller!.initialize();

      _controller!.startImageStream((CameraImage image) async {
        if (_isProcessing) return;
        _isProcessing = true;

        final inputImage = CameraUtils.convertCameraImageToInputImage(
          image,
          _controller!,
        );

        if (inputImage != null) {
          final List<Face> faces = await _faceService.processImage(inputImage);

          if (faces.isNotEmpty) {
            _sneezeDetector.addFrame(faces.first);
          }
        }
        _isProcessing = false;
      });

      if (mounted) setState(() => _isCameraInitialized = true);
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  void _handleAudioSpike() {
    bool isSneezeConfirmed = _sneezeDetector.evaluateSneeze();

    if (isSneezeConfirmed) {
      debugPrint("CONTAINMENT BREACH: SNEEZE CONFIRMED!");
      // Later todo: Freeze the camera feed and draw the Ballistic Report Overlay!

      // Clear the buffer so we don't double-trigger
      _sneezeDetector.clearBuffer();
    } else {
      debugPrint("False alarm. Probably just a cough.");
    }
  }

  @override
  void dispose() {
    _faceService.dispose();
    _audioService.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.redAccent)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),

          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
