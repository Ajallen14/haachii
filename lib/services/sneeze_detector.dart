import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FrameData {
  final Face face;
  final DateTime timestamp;
  FrameData(this.face, this.timestamp);
}

class SneezeDetector {
  final List<FrameData> _buffer = [];
  final int maxBufferSize = 5; // Keep the last 5 frames

  void addFrame(Face face) {
    _buffer.add(FrameData(face, DateTime.now()));
    if (_buffer.length > maxBufferSize) {
      _buffer.removeAt(0); // Kick out the oldest frame
    }
  }

  bool evaluateSneeze() {
    if (_buffer.length < 3) return false; // Not enough data yet

    final oldestFace = _buffer.first.face;
    final newestFace = _buffer.last.face;

    // 1. Did the eyes snap shut?
    final wasEyesOpen = (oldestFace.leftEyeOpenProbability ?? 1.0) > 0.5;
    final isEyesClosed = (newestFace.leftEyeOpenProbability ?? 1.0) < 0.2;

    // 2. Did the head jerk? (Distance between bounding box centers)
    final dx = newestFace.boundingBox.center.dx - oldestFace.boundingBox.center.dx;
    final dy = newestFace.boundingBox.center.dy - oldestFace.boundingBox.center.dy;
    final headMovementDistance = (dx * dx) + (dy * dy); // Squared distance for speed

    // If the eyes closed AND the head moved sharply
    if (wasEyesOpen && isEyesClosed && headMovementDistance > 500) {
      return true; 
    }
    return false;
  }
  
  void clearBuffer() => _buffer.clear();
}
