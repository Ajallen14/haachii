import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../main.dart';
import '../services/face_detection_service.dart';
import '../services/audio_service.dart';
import '../services/sneeze_detector.dart';
import '../utils/camera_utils.dart';
import 'particle_system.dart';

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

  SneezeReport? _finalReport;
  bool _isFrozen = false;

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
    if (_isFrozen) return;

    final report = _sneezeDetector.evaluateSneeze();

    if (report != null) {
      debugPrint("CONTAINMENT BREACH: SNEEZE CONFIRMED!");
      
      setState(() {
        _finalReport = report;
        _isFrozen = true;
      });
      
      // Freeze the camera feed
      _controller?.pausePreview();
      
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

          // Trigger the overlays when a sneeze is confirmed
          if (_isFrozen && _finalReport != null) ...[
            // The Dynamic Particle Overlay
            SneezeParticleSystem(report: _finalReport!),
            
            // The Verdict Card
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.redAccent, width: 2),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'CONTAINMENT BREACH',
                      style: TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Blast Radius: 27 ft (8 meters)',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      'Estimated Velocity: 100 mph',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Recommended Action: Isopropyl Alcohol Deployment',
                      style: TextStyle(color: Colors.orange, fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
            
            // Reset Button to resume the live demo
            Positioned(
              top: 50,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white, size: 30),
                onPressed: () {
                  setState(() {
                    _isFrozen = false;
                    _finalReport = null;
                  });
                  _controller?.resumePreview();
                },
              ),
            ),
          ],

          // Standard Back Button
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