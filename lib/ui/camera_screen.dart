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
import 'wiper_video_overlay.dart';

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
  bool _showWiperVideo = false;

  @override
  void initState() {
    super.initState();
    _initCamera();

    _audioService.startTripwire(
      onLoudNoise: () {
        _sneezeDetector.registerAudioSpike();
        debugPrint(
          "Audio spike registered. Visual thresholds lowered temporarily.",
        );
      },
    );
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
        if (_isProcessing || _isFrozen) return;
        _isProcessing = true;

        final inputImage = CameraUtils.convertCameraImageToInputImage(
          image,
          _controller!,
        );

        if (inputImage != null) {
          final List<Face> faces = await _faceService.processImage(inputImage);

          if (faces.isNotEmpty) {
            _sneezeDetector.addFrame(faces.first);

            // CONTINUOUS EVALUATION: Check for a sneeze on every single frame
            final report = _sneezeDetector.evaluateSneeze();
            if (report != null) {
              _triggerContainmentBreach(report);
            }
          } else {
            _sneezeDetector.clearBuffer();
          }
        }
        _isProcessing = false;
      });

      if (mounted) setState(() => _isCameraInitialized = true);
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  void _triggerContainmentBreach(SneezeReport report) {
    debugPrint("CONTAINMENT BREACH: SNEEZE CONFIRMED BY VISION!");

    setState(() {
      _finalReport = report;
      _isFrozen = true;
    });

    _controller?.pausePreview();
    _sneezeDetector.clearBuffer();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && _isFrozen) {
        setState(() {
          _showWiperVideo = true;
        });
      }
    });
  }

  void _resetDetection() {
    setState(() {
      _isFrozen = false;
      _finalReport = null;
      _showWiperVideo = false;
    });

    _sneezeDetector.clearBuffer();
    _controller?.resumePreview();
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

          if (_isFrozen && _finalReport != null) ...[
            IgnorePointer(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_showWiperVideo)
                    WiperVideoOverlay(
                      onComplete: () {
                        if (mounted) {
                          setState(() {
                            _showWiperVideo = false;
                          });
                        }
                      },
                    ),
                  SneezeParticleSystem(report: _finalReport!),
                ],
              ),
            ),

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
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
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
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 50,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white, size: 30),
                onPressed: _resetDetection,
              ),
            ),
          ],

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
