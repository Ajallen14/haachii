import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FrameData {
  final Face face;
  final DateTime timestamp;
  FrameData(this.face, this.timestamp);
}

// Custom object to hold our trajectory data
class SneezeReport {
  final Rect boundingBox;
  final Offset blastVector;
  SneezeReport(this.boundingBox, this.blastVector);
}

class SneezeDetector {
  final List<FrameData> _buffer = [];
  final int maxBufferSize = 5;

  void addFrame(Face face) {
    _buffer.add(FrameData(face, DateTime.now()));
    if (_buffer.length > maxBufferSize) {
      _buffer.removeAt(0);
    }
  }

  SneezeReport? evaluateSneeze() {
    if (_buffer.length < 3) return null; 

    final oldestFace = _buffer.first.face;
    final newestFace = _buffer.last.face;
    final wasEyesOpen = (oldestFace.leftEyeOpenProbability ?? 1.0) > 0.5;
    final isEyesClosed = (newestFace.leftEyeOpenProbability ?? 1.0) < 0.2;
    final dx =
        newestFace.boundingBox.center.dx - oldestFace.boundingBox.center.dx;
    final dy =
        newestFace.boundingBox.center.dy - oldestFace.boundingBox.center.dy;
    final headMovementDistance =
        (dx * dx) + (dy * dy);

    if (wasEyesOpen && isEyesClosed && headMovementDistance > 500) {
      return SneezeReport(newestFace.boundingBox, Offset(dx, dy));
    }
    return null;
  }

  void clearBuffer() => _buffer.clear();
}
