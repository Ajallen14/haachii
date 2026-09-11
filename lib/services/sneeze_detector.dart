import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FrameData {
  final Face face;
  final DateTime timestamp;
  FrameData(this.face, this.timestamp);
}

class SneezeReport {
  final Rect boundingBox;
  final Offset blastVector;
  SneezeReport(this.boundingBox, this.blastVector);
}

class SneezeDetector {
  final List<FrameData> _buffer = [];
  final int maxBufferSize = 10; 
  DateTime? _lastAudioSpike;

  // Let the detector know a loud noise just happened
  void registerAudioSpike() {
    _lastAudioSpike = DateTime.now();
  }

  void addFrame(Face face) {
    if (_buffer.isNotEmpty) {
      final timeDiff = DateTime.now().difference(_buffer.last.timestamp).inMilliseconds;
      if (timeDiff > 500) {
        clearBuffer();
      }
    }

    _buffer.add(FrameData(face, DateTime.now()));
    if (_buffer.length > maxBufferSize) {
      _buffer.removeAt(0); 
    }
  }

  SneezeReport? evaluateSneeze() {
    if (_buffer.length < 3) return null; 

    // Check if a loud noise happened in the last 1.5 seconds
    final bool hasAudioSupport = _lastAudioSpike != null && 
        DateTime.now().difference(_lastAudioSpike!).inMilliseconds < 1500;

    final baseFace = _buffer.first.face;
    final newestFace = _buffer.last.face;

    bool eyesBlinked = false;
    double maxDx = 0.0;
    double maxDy = 0.0;
    double maxPitchDelta = 0.0;

    for (var frame in _buffer) {
      final face = frame.face;
      
      if ((face.leftEyeOpenProbability ?? 1.0) < 0.5) eyesBlinked = true;

      final dx = face.boundingBox.center.dx - baseFace.boundingBox.center.dx;
      final dy = face.boundingBox.center.dy - baseFace.boundingBox.center.dy;
      
      if (dx.abs() > maxDx.abs()) maxDx = dx;
      if (dy.abs() > maxDy.abs()) maxDy = dy;

      final pitchDelta = (baseFace.headEulerAngleX ?? 0.0) - (face.headEulerAngleX ?? 0.0);
      if (pitchDelta.abs() > maxPitchDelta.abs()) maxPitchDelta = pitchDelta;
    }

    final maxMovementDist = (maxDx * maxDx) + (maxDy * maxDy);

    // DYNAMIC THRESHOLDS: 
    // If it's a silent fake sneeze, require a sharp 6-degree nod. 
    // If we heard a noise, a slight 3-degree nod is enough.
    final double requiredPitchDelta = hasAudioSupport ? 3.0 : 6.0;
    final double requiredMovement = hasAudioSupport ? 100.0 : 200.0;

    // Trigger purely on visual movement, boosted by audio if available
    if (maxPitchDelta.abs() > requiredPitchDelta || maxMovementDist > requiredMovement) {
      
      double blastDx = maxDx;
      double blastDy = maxDy;

      // Force a downward splatter if they pitched forward without translating across the screen
      if (maxMovementDist < 50) {
        blastDx = 0.0;
        blastDy = 50.0; 
      }
      
      return SneezeReport(newestFace.boundingBox, Offset(blastDx, blastDy));
    }
    
    return null;
  }
  
  void clearBuffer() => _buffer.clear();
}