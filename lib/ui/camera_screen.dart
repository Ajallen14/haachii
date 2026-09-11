import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:io';
import '../main.dart';
import '../services/face_detection_service.dart';
import '../utils/camera_utils.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;

  // Initialize the ML Kit face detection service
  final FaceDetectionService _faceService = FaceDetectionService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    // Find the back camera
    final backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      backCamera,
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );

    try {
      await _controller!.initialize();

      // Hooking up the real-time frame stream
      _controller!.startImageStream((CameraImage image) async {
        if (_isProcessing) {
          return;
        }
        _isProcessing = true;

        final inputImage = CameraUtils.convertCameraImageToInputImage(
          image,
          _controller!,
        );

        if (inputImage != null) {
          final List<Face> faces = await _faceService.processImage(inputImage);

          // Testing Phase 1: Print to console if we found a face
          if (faces.isNotEmpty) {
            final face = faces.first;
            debugPrint(
              'Tracking Face ID: ${face.trackingId} | Left Eye Open: ${face.leftEyeOpenProbability}',
            );
          }
        }

        _isProcessing = false;
      });

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  @override
  void dispose() {
    _faceService.dispose();
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

          // Later for CustomPainter danger zone overlay

          // Temporary back button for testing
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
